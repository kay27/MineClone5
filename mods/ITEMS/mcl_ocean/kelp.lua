-- TODO: whenever it becomes possible to fully implement kelp without the
-- plantlike_rooted limitation, please update accordingly.
--
-- TODO: In MC, you can't actually destroy kelp by bucket'ing water in the middle.
-- However, because of the plantlike_rooted hack, we'll just allow it for now.
-- TODO: Integrate ABMs with the new kelp code, disabled. OR remove them entirely

local S = minetest.get_translator("mcl_ocean")
local mod_doc = minetest.get_modpath("doc") ~= nil

--------------------------------------------------------------------------------
-- local-ify runtime functions
--------------------------------------------------------------------------------
-- objects
local mt_registered_items = minetest.registered_items
local mt_registered_nodes = minetest.registered_nodes

-- functions
local mt_log = minetest.log
local mt_add_item = minetest.add_item
local mt_get_item_group = minetest.get_item_group
local mt_get_node = minetest.get_node
local mt_get_node_level = minetest.get_node_level
local mt_get_node_max_level = minetest.get_node_max_level
local mt_get_node_or_nil = minetest.get_node_or_nil
local mt_get_node_timer = minetest.get_node_timer
local mt_get_meta = minetest.get_meta
local mt_hash_node_position = minetest.hash_node_position
local mt_pos_to_string = minetest.pos_to_string
local mt_is_protected = minetest.is_protected
local mt_record_protection_violation = minetest.record_protection_violation
local mt_set_node = minetest.set_node

local mt_is_creative_enabled = minetest.is_creative_enabled
local mt_sound_play = minetest.sound_play

local math_min = math.min
local math_max = math.max
local math_ceil = math.ceil
local math_floor = math.floor
local math_random = math.random
local string_format = string.format
local table_copy = table.copy
local table_insert = table.insert

-- DEBUG: functions
local log = minetest.log
local chatlog = minetest.chat_send_all
il_chatlog = chatlog
il_get_meta = mt_get_meta
il_hash_pos = mt_hash_node_position

--------------------------------------------------------------------------------
-- Kelp API
--------------------------------------------------------------------------------

local kelp = {}
mcl_ocean.kelp = kelp

-- Kelp minimum and maximum age. Once reached the maximum, kelp no longer grows.
kelp.MIN_AGE = 0
kelp.MAX_AGE = 25

-- Tick interval (in seconds) for updating kelp.
kelp.TICK = 0.2

-- Tick interval (in seconds) to store kelp meta.
kelp.META_TICK = 2

-- Max age queue length
kelp.MAX_AGE_QUEUE = 20

-- The average amount of growth for kelp in a day is 2.16 (https://youtu.be/5Bp4lAjAk3I)
-- Normally, a day lasts 20 minutes, meaning kelp.next_grow() is executed
-- 1200 / TICK times. Per tick probability = (216/100) / (1200/TICK)
-- NOTE: currently, we can't exactly use the same type of randomness MC does, because
-- it has multiple complicated sets of PRNGs.
-- NOTE: Small loss of precision, should be 10 to preserve it.
-- kelp.ROLL_GROWTH_PRECISION = 10
-- kelp.ROLL_GROWTH_NUMERATOR = 216 * kelp.TICK * kelp.ROLL_GROWTH_PRECISION
-- kelp.ROLL_GROWTH_DENOMINATOR = 100 * 1200 * kelp.ROLL_GROWTH_PRECISION
kelp.ROLL_GROWTH_PRECISION = 1
kelp.ROLL_GROWTH_NUMERATOR = 216 * kelp.TICK
kelp.ROLL_GROWTH_DENOMINATOR = 100 * 1200

-- Sounds used to dig and place kelp.
kelp.leaf_sounds = mcl_sounds.node_sound_leaves_defaults()

-- TODO: is this really necessary
-- Lock drops to avoid duplicate drops, set after dropping detached kelp.
kelp.lock_drop = 0

-- Pool storing nodetimers
kelp.timers_pool = {}

-- Pool storing age, indexed by pos_hash.
kelp.age_pool = {}

-- Queue(List) of hashed positions to save their ages.
-- Invalid ones may still persist in this queue.
kelp.age_queue = {}
-- Stores only valid positions of each hashed postiions.
kelp.age_queue_pos = {}


-- is age in the growable range?
function kelp.is_age_growable(age)
	return age >= 0 and age < kelp.MAX_AGE
end


-- Is this water?
-- Returns the liquidtype, if indeed water.
function kelp.is_submerged(node)
	if mt_get_item_group(node.name, "water") ~= 0 then
		-- Expected only "source" and "flowing" from water liquids
		return mt_registered_nodes[node.name].liquidtype
	end
	return false
end


-- Is the water downward flowing?
-- (kelp can grow/be placed inside downward flowing water)
function kelp.is_downward_flowing(pos, node, pos_above, node_above, __is_above__)
	-- Function params: (pos[, node]) or (node, pos_above) or (node, node_above)
	local node = node or mt_get_node(pos)

	local result = (math_floor(node.param2 / 8) % 2) == 1
	if not (result or __is_above__) then
		-- If not, also check node above.
		-- (this is needed due a weird quirk in the definition of "downwards flowing"
		-- liquids in Minetest)
		local pos_above = pos_above or {x=pos.x,y=pos.y+1,z=pos.z}
		local node_above = node_above or mt_get_node(pos_above)
		result = kelp.is_submerged(node_above)
			or kelp.is_downward_flowing(nil, node_above, nil, nil, true)
	end
	return result
end


-- Will node fall at that position?
-- This only checks if a node would fall, meaning that node need not be at pos.
function kelp.is_falling(pos, node, is_falling, pos_bottom, node_bottom, def_bottom)
	-- Optional params: is_falling, pos_bottom, node_bottom, def_bottom

	-- NOTE: Modified from check_single_for_falling in builtin.
	-- Please update accordingly.
	local nodename = node.name

	if is_falling == false or
		is_falling == nil and mt_get_item_group(nodename, "falling_node") == 0 then
		return false
	end

	local pos_bottom = pos_bottom or {x = pos.x, y = pos.y - 1, z = pos.z}
	-- get_node_or_nil: Only fall if node below is loaded
	local node_bottom = node_bottom or mt_get_node_or_nil(pos_bottom)
	local nodename_bottom = node_bottom.name
	local def_bottom = def_bottom or node_bottom and mt_registered_nodes[nodename_bottom]
	if not def_bottom then
		return false
	end

	local same = nodename == nodename_bottom
	-- Let leveled nodes fall if it can merge with the bottom node
	if same and def_bottom.paramtype2 == "leveled" and
			mt_get_node_level(pos_bottom) <
			mt_get_node_max_level(pos_bottom) then
		return true
	end

	-- Otherwise only if the bottom node is considered "fall through"
	if not same and
			(not def_bottom.walkable or def_bottom.buildable_to) and
			(mt_get_item_group(nodename, "float") == 0 or
			def_bottom.liquidtype == "none") then
		return true
	end

	return false
end


-- Roll whether to grow kelp or not.
function kelp.roll_growth(numerator, denominator)
	-- Optional params: numerator, denominator
	return math_random(denominator or kelp.ROLL_GROWTH_DENOMINATOR) <= (numerator or kelp.ROLL_GROWTH_NUMERATOR)
end


-- Roll initial age for kelp.
function kelp.roll_init_age(min, max)
	-- Optional params
	return math_random(min or kelp.MIN_AGE, (max or kelp.MAX_AGE)-1)
end


-- Converts param2 to kelp height.
function kelp.get_height(param2)
	return math_floor(param2 / 16)
end


-- Obtain pos and node of the tip of kelp.
function kelp.get_tip(pos, param2)
	-- Optional params: param2
	local height = kelp.get_height(param2 or mt_get_node(pos).param2)
	local pos_tip = {x=pos.x, y=pos.y, z=pos.z}
	pos_tip.y = pos_tip.y + height + 1
	return pos_tip, mt_get_node(pos_tip), height
end


-- Obtain position of the first kelp unsubmerged.
function kelp.find_unsubmerged(pos, node, height)
	-- Optional params: node, height
	local node = node or mt_get_node(pos)
	local height = height or kelp.get_height(node.param2)

	local walk_pos = {x=pos.x, z=pos.z}
	local y = pos.y
	for i=1,height do
		walk_pos.y = y + i
		local walk_node = mt_get_node(walk_pos)
		if not kelp.is_submerged(walk_node) then
			return walk_pos, walk_node, height, i
		end
	end
	return nil, nil, height, height
end


-- Obtain next param2.
function kelp.next_param2(param2)
	return param2+16 - param2 % 16
end


-- Stores age from kelp.age_queue* into their respective meta
function kelp.store_meta()
	local count = 0
	for _ in pairs(kelp.age_queue_pos) do
		count = count + 1
	end
	-- chatlog(string_format("Storing age metadata: %d in queue", #kelp.age_queue))
	-- chatlog(string_format("Storing age metadata: %d valid in queue", count))
	for i=1,#kelp.age_queue do
		local pos_hash = kelp.age_queue[i]
		local pos = kelp.age_queue_pos[pos_hash]
		-- queued hashes may no longer point to a valid pos, e.g. kelp is destroyed.
		if pos then
			mt_get_meta(pos):set_int("mcl_ocean:kelp_age", kelp.age_pool[pos_hash])
		end
	end
	kelp.age_queue = {}
	kelp.age_queue_pos = {}
end


-- Store and queue a kelp's age to be saved into meta later.
function kelp.store_age(age, pos, pos_hash)
	-- Watched params: pos
	-- Optional params: pos_hash
	local pos_hash = pos_hash or mt_hash_node_position(pos)

	kelp.age_pool[pos_hash] = age
	if not kelp.age_queue_pos[pos_hash] then
		table_insert(kelp.age_queue, pos_hash)
		kelp.age_queue_pos[pos_hash] = pos
		return true, pos_hash
	end

	return false, pos_hash
end


-- Initialise a kelp's age.
function kelp.init_age(pos, age, pos_hash, meta)
	-- Watched params: pos
	-- Optional params: age, pos_hash, meta
	local pos_hash = pos_hash or mt_hash_node_position(pos)
	local meta = meta or mt_get_meta(pos)

	local age = age
	if not meta:contains("mcl_ocean:kelp_age") then
		-- NOTE: age param can only replace initial age roll.
		age = age or kelp.roll_init_age()
		kelp.store_age(age, pos, pos_hash)
	else
		age = meta:get_int("mcl_ocean:kelp_age")
		if not kelp.age_pool[pos_hash] then
			kelp.age_pool[pos_hash] = age
		end
	end

	return age, pos_hash, meta
end


-- Initialise kelp nodetimer.
function kelp.init_timer(pos, pos_hash)
	-- Optional params: pos_hash
	local pos_hash = pos_hash or mt_hash_node_position(pos)

	local timer = kelp.timers_pool[pos_hash]
	if not timer then
		timer = mt_get_node_timer(pos)
		kelp.timers_pool[pos_hash] = timer
	end
	if not timer:is_started() then
		timer:start(kelp.TICK)
	end

	return pos_hash
end


-- Apply next kelp height.
function kelp.next_height(pos, node, pos_tip, node_tip, submerged, downward_flowing)
	-- Modified params: node
	-- Optional params: node, pos_tip, node_tip, submerged, downward_flowing
	local node = node or mt_get_node(pos)
	local pos_tip = pos_tip
	local node_tip = node_tip or (pos_tip and mt_get_node(pos_tip))
	if not pos_tip then
		pos_tip,node_tip = kelp.get_tip(pos)
	end
	local downward_flowing = downward_flowing or
		(submerged or kelp.is_submerged(node_tip)
		 and kelp.is_downward_flowing(pos_tip, node_tip))

	-- Liquid source: Grow normally.
	node.param2 = kelp.next_param2(node.param2)
	mt_set_node(pos, node)

	-- Flowing liquid: Grow 1 step, but also turn the tip node into a liquid source.
	if downward_flowing then
		local alt_liq = mt_registered_nodes[node_tip.name].liquid_alternative_source
		if alt_liq then
			mt_set_node(pos_tip, {name=alt_liq})
		end
	end

	return node, pos_tip, node_tip, submerged, downward_flowing
end


-- Grow next kelp.
function kelp.next_grow(age, pos, node, pos_hash, pos_tip, node_tip, submerged, downward_flowing)
	-- Watched params: pos
	-- Modified params: node
	-- Optional params: node, pos_hash, pos_tip, node_tip, submerged, downward_flowing
	local node = node or mt_get_node(pos)
	local pos_hash = pos_hash or mt_hash_node_position(pos)
	local pos_tip = pos_tip
	local node_tip = node_tip or (pos_tip and mt_get_node(pos_tip))
	if not pos_tip then
		pos_tip,node_tip = kelp.get_tip(pos)
	end

	-- New kelp must also be submerged in water.
	local downward_flowing = downward_flowing or kelp.is_downward_flowing(pos_tip, node_tip)
	if not (submerged or kelp.is_submerged(node_tip)) then
		return
	end

	kelp.next_height(pos, node, pos_tip, node_tip, submerged, downward_flowing)

	return kelp.store_age(age, pos, pos_hash), node, pos_hash, pos_tip, node_tip, submerged, downward_flowing
end


-- Drops the items for detached kelps.
function kelp.detach_drop(pos, param2, pos_hash)
	-- Optional params: param2, pos_hash
	local height = kelp.get_height(param2 or mt_get_node(pos).param2)
	local pos_hash = pos_hash or mt_hash_node_position(pos)

	if kelp.lock_drop > 0 then
		minetest.log("error",
			string_format("Duplicate drop prevented at (%d, %d, %d) with lock level %d! Please report this.",
				pos.x, pos.y, pos.z, kelp.lock_drop))
		return
	end

	local y = pos.y
	local walk_pos = {x=pos.x, z=pos.z}
	for i=1,height do
		walk_pos.y = y+i
		mt_add_item(walk_pos, "mcl_ocean:kelp")
	end

	-- Locks drop.
	kelp.lock_drop = kelp.lock_drop + 1
	return true
end


-- Detach the kelp at dig_pos, and drop their items.
-- Synonymous to digging the kelp.
-- NOTE: this is intended for whenever kelp truly becomes segmented plants
-- instead of rooted to the floor. Don't try to remove dig_pos.
function kelp.detach_dig(dig_pos, pos, node, drop, pos_hash)
	-- Optional params: drop, pos_hash
	local pos_hash = pos_hash or mt_hash_node_position(pos)

	local param2 = node.param2
	-- pos.y points to the surface, offset needed to point to the first kelp.
	local new_height = dig_pos.y - (pos.y+1)

	-- Digs the entire kelp: invoke after_dig_node to mt_set_node.
	if new_height <= 0 then
		if drop then
			kelp.detach_drop(dig_pos, param2, pos_hash)
		end
		mt_set_node(pos, {
			name=mt_registered_nodes[node.name].node_dig_prediction,
			param=node.param,
			param2=0 })

	-- Digs the kelp beginning at a height
	else
		if drop then
			kelp.detach_drop(dig_pos, param2 - new_height, pos_hash)
		end
		mt_set_node(pos, {name=node.name, param=node.param, param2=16*new_height})
	end
end


--------------------------------------------------------------------------------
-- Kelp callback functions
--------------------------------------------------------------------------------

function kelp.surface_on_dig(pos, node, digger)
	kelp.detach_dig(pos, pos, node, true)
end


function kelp.surface_after_dig_node(pos, node)
	return mt_set_node(pos, {name=registred_nodes[node.name].node_dig_prediction})
end


function kelp.surface_on_timer(pos)
	local node = mt_get_node(pos)
	local pos_hash = mt_hash_node_position(pos)

	-- Update detahed kelps
	local dig_pos = kelp.find_unsubmerged(pos, node)
	if dig_pos then
		-- chatlog("detach_dig")
		kelp.detach_dig(dig_pos, pos, node, true, pos_hash)
	end

	-- Grow kelp on chance
	if kelp.roll_growth() then
		local age = kelp.age_pool[pos_hash]
		if kelp.is_age_growable(age) then
			kelp.next_grow(age, pos, node, pos_hash)
		end
	end

	return true
end

function kelp.surface_on_construct(pos)
	local pos_hash = mt_hash_node_position(pos)
	kelp.init_age(pos, nil, pos_hash)
	kelp.init_timer(pos, pos_hash)
end


function kelp.surface_on_destruct(pos)
	local node = mt_get_node(pos)
	local pos_hash = mt_hash_node_position(pos)

	-- on_falling callback. Activated by pistons for falling nodes too.
	if kelp.is_falling(pos, node) then
		kelp.detach_drop(pos, node.param2, pos_hash)
	end

	-- Removes position from queue
	kelp.age_queue_pos[pos_hash] = nil

	-- Unlocks drops.
	if kelp.lock_drop > 0 then
		kelp.lock_drop = kelp.lock_drop - 1
	end
end



function kelp.surface_on_mvps_move(pos, node, oldpos, nodemeta)
	-- Pistons moving falling nodes will have already activated on_falling callback.
	kelp.detach_dig(pos, pos, node, mt_get_item_group(node.name, "falling_node") ~= 1)
end


-- NOTE: Uncomment this to use ABMs.
-- local function surface_unsubmerged_abm(pos, node)
-- 	local dig_pos = find_unsubmerged(pos, node)
-- 	if dig_pos then
-- 		detach_dig(dig_pos, pos, node, true)
-- 	end
-- 	return true
-- end


function kelp.kelp_on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" or not placer then
		return itemstack
	end

	local player_name = placer:get_player_name()
	local pos_under = pointed_thing.under
	local pos_above = pointed_thing.above
	local node_under = mt_get_node(pos_under)
	local nu_name = node_under.name
	local def_under = mt_registered_nodes[nu_name]

	-- Allow rightclick to override place.
	if def_under and def_under.on_rightclick and not placer:get_player_control().sneak then
		return def_under.on_rightclick(pos_under, node_under,
				placer, itemstack, pointed_thing) or itemstack
	end

	-- Protection
	if mt_is_protected(pos_under, player_name) or
			mt_is_protected(pos_above, player_name) then
		mt_log("action", player_name
			.. " tried to place " .. itemstack:get_name()
			.. " at protected position "
			.. mt_pos_to_string(pos_under))
		mt_record_protection_violation(pos_under, player_name)
		return itemstack
	end


	local pos_tip, node_tip, def_tip
	local pos_hash = mt_hash_node_position(pos_under)
	local age = kelp.roll_init_age()


	-- Kelp must also be placed on the top/tip side of the surface/kelp
	if pos_under.y >= pos_above.y then
		return itemstack
	end

	-- When placed on kelp.
	if mt_get_item_group(nu_name, "kelp") == 1 then
		pos_tip,node_tip = kelp.get_tip(pos_under, node_under.param2)
		def_tip = mt_registered_nodes[node_tip.name]

	-- When placed on surface.
	else
		local new_kelp = false
		for _,surface in pairs(kelp.surfaces) do
			if nu_name == surface.nodename then
				node_under.name = "mcl_ocean:kelp_" ..surface.name
				node_under.param2 = 0
				new_kelp = true
				break
			end
		end
		-- Surface must support kelp
		if not new_kelp then
			return itemstack
		end

		pos_tip = pos_above
		node_tip = mt_get_node(pos_above)
		def_tip = mt_registered_nodes[node_tip.name]
	end

	-- New kelp must also be submerged in water.
	local downward_flowing = kelp.is_downward_flowing(pos_tip, node_tip)
	local submerged = kelp.is_submerged(node_tip)
	if not submerged then
		return itemstack
	end

	-- Play sound, place surface/kelp and take away an item
	local def_node = mt_registered_items[nu_name]
	if def_node.sounds then
		mt_sound_play(def_node.sounds.place, { gain = 0.5, pos = pos_under }, true)
	end
	kelp.next_height(pos_under, node_under, pos_tip, node_tip, def_tip, submerged, downward_flowing)
	if not mt_is_creative_enabled(player_name) then
		itemstack:take_item()
	end

	return itemstack
end


function kelp.lbm_register_nodetimer(pos, node)
	local pos_hash = mt_hash_node_position(pos)
	kelp.init_age(pos, nil, pos_hash)
	kelp.init_timer(pos, pos_hash)
end


local gstep_time = 0
function kelp.globalstep(dtime)
	if #kelp.age_queue > kelp.MAX_AGE_QUEUE then
		kelp.store_meta()
	end

	gstep_time = gstep_time + dtime
	if gstep_time < kelp.META_TICK then
		return
	end
	gstep_time = 0

	if #kelp.age_queue > 0 then
		kelp.store_meta()
	end
end


function kelp.on_shutdown()
	if #kelp.age_queue > 0 then
		kelp.store_meta()
	end
end

--------------------------------------------------------------------------------
-- Kelp registration API
--------------------------------------------------------------------------------

-- List of supported surfaces for seagrass and kelp.
kelp.surfaces = {
	{ name="dirt",    nodename="mcl_core:dirt",    },
	{ name="sand",    nodename="mcl_core:sand",    },
	{ name="redsand", nodename="mcl_core:redsand", },
	{ name="gravel",  nodename="mcl_core:gravel",  },
}
kelp.registered_surfaces = {}

-- Commented properties are the ones obtained using register_kelp_surface.
-- If you define your own properties, it overrides the default ones.
kelp.surface_deftemplate = {
	drawtype = "plantlike_rooted",
	paramtype = "light",
	paramtype2 = "leveled",
	place_param2 = 16,
	--tiles = def.tiles,
	special_tiles = {
		{
		image = "mcl_ocean_kelp_plant.png",
		animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0},
		tileable_vertical = true,
		}
	},
	--inventory_image = "("..def.tiles[1]..")^mcl_ocean_kelp_item.png",
	wield_image = "mcl_ocean_kelp_item.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
			{ -0.5, 0.5, -0.5, 0.5, 1.5, 0.5 },
		},
	},
	-- groups.falling_node = is_falling,
	groups = { dig_immediate = 3, deco_block = 1, plant = 1, kelp = 1, },
	--sounds = sounds,
	--node_dig_prediction = nodename,
	on_construct = kelp.surface_on_construct,
	on_destruct = kelp.surface_on_destruct,
	on_dig = kelp.surface_on_dig,
	after_dig_node = kelp.surface_after_dig_node,
	on_timer = kelp.surface_on_timer,
	mesecon = { on_mvps_move = kelp.surface_on_mvps_move, },
	drop = "", -- drops are handled in on_dig
	--_mcl_falling_node_alternative = is_falling and nodename or nil,
	_mcl_hardness = 0,
	_mcl_blast_resistance = 0,
}

-- Commented properties are the ones obtained using register_kelp_surface.
kelp.surface_docs = {
	-- entry_id_orig = nodename,
	_doc_items_entry_name = S("Kelp"),
	_doc_items_longdesc = S("Kelp grows inside water on top of dirt, sand or gravel."),
	--_doc_items_create_entry = doc_create,
	_doc_items_image = "mcl_ocean_kelp_item.png",
}

-- Creates new surfaces.
-- NOTE: surface_deftemplate will be modified in-place.
function kelp.register_kelp_surface(surface, surface_deftemplate, surface_docs)
	local name = surface.name
	local nodename = surface.nodename
	local def = mt_registered_nodes[nodename]
	local def_tiles = def.tiles

	local surfacename = "mcl_ocean:kelp_"..name
	local surface_deftemplate = surface_deftemplate or kelp.surface_deftemplate -- Optional param

	local doc_create = surface.doc_create or false
	local surface_docs = surface_docs or kelp.surface_docs -- Optional param

	if doc_create then
		surface_deftemplate._doc_items_entry_name = surface_docs._doc_items_entry_name
		surface_deftemplate._doc_items_longdesc = surface_docs._doc_items_longdesc
		surface_deftemplate._doc_items_create_entry = true
		surface_deftemplate._doc_items_image = surface_docs._doc_items_image
		-- Sets the first surface as the docs' entry ID
		if not surface_docs.entry_id_orig then
			surface_docs.entry_id_orig = nodename
		end
	elseif mod_doc then
		doc.add_entry_alias("nodes", surface_docs.entry_id_orig, "nodes", surfacename)
	end

	local sounds = table_copy(def.sounds)
	sounds.dig = kelp.leaf_sounds.dig
	sounds.dug = kelp.leaf_sounds.dug
	sounds.place = kelp.leaf_sounds.place

	surface_deftemplate.tiles = surface_deftemplate.tiles or def_tiles
	surface_deftemplate.inventory_image = surface_deftemplate.inventory_image or "("..def_tiles[1]..")^mcl_ocean_kelp_item.png"
	surface_deftemplate.sounds = surface_deftemplate.sound or sounds
	local falling_node = mt_get_item_group(nodename, "falling_node")
	surface_deftemplate.node_dig_prediction = surface_deftemplate.node_dig_prediction or nodename
	surface_deftemplate.groups.falling_node = surface_deftemplate.groups.falling_node or falling_node
	surface_deftemplate._mcl_falling_node_alternative = surface_deftemplate._mcl_falling_node_alternative or (falling_node and nodename or nil)

	minetest.register_node(surfacename, surface_deftemplate)
end

-- Kelp surfaces nodes ---------------------------------------------------------

-- Dirt must be registered first, for the docs
kelp.register_kelp_surface(kelp.surfaces[1], table_copy(kelp.surface_deftemplate), kelp.surface_docs)
for i=2, #kelp.surfaces do
	kelp.register_kelp_surface(kelp.surfaces[i], table_copy(kelp.surface_deftemplate), kelp.surface_docs)
end

-- Kelp item -------------------------------------------------------------------

minetest.register_craftitem("mcl_ocean:kelp", {
	description = S("Kelp"),
	_tt_help = S("Grows in water on dirt, sand, gravel"),
	_doc_items_create_entry = false,
	inventory_image = "mcl_ocean_kelp_item.png",
	wield_image = "mcl_ocean_kelp_item.png",
	on_place = kelp.kelp_on_place,
	groups = { deco_block = 1 },
})

if mod_doc then
	doc.add_entry_alias("nodes", kelp.surface_docs.entry_id_orig, "craftitems", "mcl_ocean:kelp")
end

-- Dried kelp ------------------------------------------------------------------

-- TODO: This is supposed to be eaten very fast
minetest.register_craftitem("mcl_ocean:dried_kelp", {
	description = S("Dried Kelp"),
	_doc_items_longdesc = S("Dried kelp is a food item."),
	inventory_image = "mcl_ocean_dried_kelp.png",
	wield_image = "mcl_ocean_dried_kelp.png",
	groups = { food = 2, eatable = 1 },
	on_place = minetest.item_eat(1),
	on_secondary_use = minetest.item_eat(1),
	groups = { food = 2, eatable = 1 },
	_mcl_saturation = 0.6,
})


local mod_screwdriver = minetest.get_modpath("screwdriver") ~= nil
local on_rotate
if mod_screwdriver then
	on_rotate = screwdriver.rotate_3way
end

minetest.register_node("mcl_ocean:dried_kelp_block", {
	description = S("Dried Kelp Block"),
	_doc_items_longdesc = S("A decorative block that serves as a great furnace fuel."),
	tiles = { "mcl_ocean_dried_kelp_top.png", "mcl_ocean_dried_kelp_bottom.png", "mcl_ocean_dried_kelp_side.png" },
	groups = { handy = 1, building_block = 1, flammable = 2, fire_encouragement = 30, fire_flammability = 60 },
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	on_rotate = on_rotate,
	_mcl_hardness = 0.5,
	_mcl_blast_resistance = 12.5,
})

minetest.register_craft({
	type = "cooking",
	recipe = "mcl_ocean:kelp",
	output = "mcl_ocean:dried_kelp",
	cooktime = 10,
})
minetest.register_craft({
	recipe = {
		{ "mcl_ocean:dried_kelp","mcl_ocean:dried_kelp","mcl_ocean:dried_kelp" },
		{ "mcl_ocean:dried_kelp","mcl_ocean:dried_kelp","mcl_ocean:dried_kelp" },
		{ "mcl_ocean:dried_kelp","mcl_ocean:dried_kelp","mcl_ocean:dried_kelp" },
	},
	output = "mcl_ocean:dried_kelp_block",
})
minetest.register_craft({
	recipe = {
		{ "mcl_ocean:dried_kelp_block" },
	},
	output = "mcl_ocean:dried_kelp 9",
})
minetest.register_craft({
	type = "fuel",
	recipe = "mcl_ocean:dried_kelp_block",
	burntime = 200,
})

-- ABMs ------------------------------------------------------------------------

minetest.register_lbm({
	label = "Kelp initialise",
	name = "mcl_ocean:kelp_init",
	nodenames = { "group:kelp" },
	run_at_every_load = true, -- so old kelps are also initialised
	action = kelp.lbm_register_nodetimer,
})


minetest.register_globalstep(kelp.globalstep)
minetest.register_on_shutdown(kelp.on_shutdown)

-- NOTE: Uncomment this to use ABMs
-- minetest.register_abm({
-- 	label = "Kelp drops",
-- 	nodenames = { "group:kelp" },
-- 	interval = 1.0,
-- 	chance = 1,
-- 	catch_up = false,
-- 	action = surface_unsubmerged_abm,
-- })
--
-- minetest.register_abm({
-- 	label = "Kelp growth",
-- 	nodenames = { "group:kelp" },
-- 	interval = 45,
-- 	chance = 12,
-- 	catch_up = false,
-- 	action = grow_abm,
-- })

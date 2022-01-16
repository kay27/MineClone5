local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

local name_prefix = "mcl_structures:"

mcl_structures = {}
local rotations = {
	"0",
	"90",
	"180",
	"270"
}
local registered_structures = {}
local use_process_mapgen_block_lvm = false
local use_process_mapgen_chunk = false
local on_finished_block_callbacks = {}
local on_finished_chunk_callbacks = {}

function process_mapgen_block_lvm(vm_context)
	local nodes = minetest.find_nodes_in_area(vm_context.minp, vm_context.maxp, {"group:struct"}, true)
	for node_name, pos_list in pairs(nodes) do
		local lvm_callback = on_finished_block_callbacks[node_name]
		if lvm_callback then
			lvm_callback(vm_context, pos_list)
		end
	end
end

function process_mapgen_chunk(minp, maxp, seed, vm_context)
	local nodes = minetest.find_nodes_in_area(minp, maxp, {"group:struct"}, true)
	for node_name, pos_list in pairs(nodes) do
		local chunk_callback = on_finished_chunk_callbacks[node_name]
		if chunk_callback then
			chunk_callback(minp, maxp, seed, vm_context, pos_list)
		end
	end
	for node_name, pos_list in pairs(nodes) do
		for _, pos in pairs(pos_list) do
			local node = minetest.get_node(pos)
			if string.sub(node.name, 1, 15) == 'mcl_structures:' then
				minetest.swap_node(pos, {name = 'air'})
			end
		end
	end
end

--------------------------------------------------------------------------------------
-- mcl_structures.register_structure(struct_def)
-- struct_def:
--	name              - name, like 'desert_temple'
--	decoration        - decoration definition, to use as structure seed (thanks cora for the idea)
--	on_finished_block - callback, if needed, to use with decorations: funcion(vm_context, pos_list)
--	on_finished_chunk - next callback if needed: funcion(minp, maxp, seed, vm_context, pos_list)
--	place_function    - callback to place schematic by /spawnstruct debug command: function(pos, rotation, pr)
--	on_placed         - useful when you want to process the area after placement: function(pos, rotation, pr, size)
function mcl_structures.register_structure(def)
	local short_name         = def.name
	local name               = "mcl_structures:" .. short_name
	local decoration         = def.decoration
	local on_finished_block    = def.on_finished_block
	local on_finished_chunk  = def.on_finished_chunk
	if not name then
		minetest.log('warning', 'Structure name is not passed for registration - ignoring')
		return
	end
	if registered_structures[name] then
		minetest.log('warning', 'Structure '..name..' is already registered - owerwriting')
	end
	local decoration_id
	if decoration then
		minetest.register_node(':' .. name, {
			drawtype            = "airlike",
			sunlight_propagates = true,
			pointable           = false,
			walkable            = false,
			diggable            = false,
			buildable_to        = true,
			groups              = {
				struct                    = 1,
				not_in_creative_inventory = 1,
			},
		})
		decoration_id = minetest.register_decoration({
			deco_type      = decoration.deco_type,
			place_on       = decoration.place_on,
			sidelen        = decoration.sidelen,
			fill_ratio     = decoration.fill_ratio,
			noise_params   = decoration.noise_params,
			biomes         = decoration.biomes,
			y_min          = decoration.y_min,
			y_max          = decoration.y_max,
			spawn_by       = decoration.spawn_by,
			num_spawn_by   = decoration.num_spawn_by,
			flags          = decoration.flags,
			decoration     = name,
			height         = decoration.height,
			height_max     = decoration.height_max,
			param2         = decoration.param2,
			param2_max     = decoration.param2_max,
			place_offset_y = decoration.place_offset_y,
			schematic      = decoration.schematic,
			replacements   = decoration.replacements,
			flags          = decoration.flags,
			rotation       = decoration.rotation,
		})
	end
	registered_structures[name] = {
		place_function    = def.place_function,
		on_finished_block = on_finished_block,
		on_finished_chunk = on_finished_chunk,
		decoration_id     = decoration_id,
		short_name        = short_name,
	}
	if on_finished_block then
		on_finished_block_callbacks[name] = on_finished_block
		if not use_process_mapgen_block_lvm then
			use_process_mapgen_block_lvm = true
			mcl_mapgen.register_mapgen_block_lvm(process_mapgen_block_lvm, mcl_mapgen.order.BUILDINGS)
		end
	end
	if on_finished_chunk then
		on_finished_chunk_callbacks[name] = on_finished_chunk
		if not use_process_mapgen_chunk then
			use_process_mapgen_chunk = true
			mcl_mapgen.register_mapgen(process_mapgen_chunk, mcl_mapgen.order.BUILDINGS)
		end
	end
end

-- It doesN'T remove registered node and decoration!
function mcl_structures.unregister_structure(name)
	if not registered_structures[name] then
		minetest.log('warning','Structure '..name..' is not registered - skipping')
		return
	end
	registered_structures[name] = nil
end

local function ecb_place(blockpos, action, calls_remaining, param)
	if calls_remaining >= 1 then return end
	local pos = param.pos
	local rotation = param.rotation
	minetest.place_schematic(pos, param.schematic, rotation, param.replacements, param.force_placement, param.flags)
	local on_placed = param.on_placed
	if not on_placed then
		return
	end
	on_placed(pos, rotation, param.pr, param.size)
end

function mcl_structures.place_schematic(def)
	local pos       = def.pos
	local schematic = def.schematic
	local rotation  = def.rotation
	local pr        = def.pr
	local on_placed = def.on_placed -- on_placed(pos, rotation, pr, size)
	local emerge    = def.emerge
	if not pos then
		minetest.log('warning', '[mcl_structures] No pos. specified to place schematic')
		return
	end
	if not schematic then
		minetest.log('warning', '[mcl_structures] No schematic specified to place at ' .. minetest.pos_to_string(pos))
		return
	end
	if not rotation or rotation == 'random' then
		if pr then
			rotation = rotations[pr:next(1,#rotations)]
		else
			rotation = rotations[math.random(1,#rotations)]
		end
	end

	if not emerge and not on_placed then
		minetest.place_schematic(pos, schematic, rotation, def.replacements, def.force_placement, def.flags)
		return
	end

	local serialized_schematic = minetest.serialize_schematic(schematic, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}) .. " return schematic"
	local loaded_schematic = loadstring(serialized_schematic)()
	if not loaded_schematic then
		minetest.log('warning', '[mcl_structures] Schematic ' .. schematic .. ' load serialized string problem at ' .. minetest.pos_to_string(pos))
		return
	end
	local size = loaded_schematic.size
	if not size then
		minetest.log('warning', '[mcl_structures] Schematic ' .. schematic .. ' has no size at ' .. minetest.pos_to_string(pos))
		return
	end
	local size_x, size_y, size_z = size.x, size.y, size.z
	if rotation == "90" or rotation == "270" then
		size_x, size_z = size_z, size_x
	end
	local x, y, z = pos.x, pos.y, pos.z
	local p1 = {x = x, y = y, z = z}
	local p2 = {x = x + size_x - 1, y = y + size_y - 1, z = size_z - 1}
	local ecb_param = {
		pos             = vector.new(pos),
		schematic       = loaded_schematic,
		rotation        = rotation,
		replacements    = replacements,
		force_placement = force_placement,
		flags           = flags,
		size            = vector.new(size),
		pr              = pr,
		on_placed       = on_placed,
	}
	if not emerge then
		ecb_place(p1, nil, 0, ecb_param)
		return
	end
	minetest.log("verbose", "[mcl_structures] Emerge area " .. minetest.pos_to_string(p1) .. " - " .. minetest.pos_to_string(p2)
		.. " of size " ..minetest.pos_to_string(size) .. " to place " .. schematic .. ", rotation " .. tostring(rotation))
	minetest.emerge_area(p1, p2, ecb_place, ecb_param)
end

function mcl_structures.get_struct(file)
	local localfile = modpath.."/schematics/"..file
	local file, errorload = io.open(localfile, "rb")
	if errorload then
		minetest.log("error", "[mcl_structures] Could not open this struct: "..localfile)
		return nil
	end

	local allnode = file:read("*a")
	file:close()

	return allnode
end

-- Call on_construct on pos.
-- Useful to init chests from formspec.
function mcl_structures.init_node_construct(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	if def and def.on_construct then
		def.on_construct(pos)
		return true
	end
	return false
end

-- The call of Struct
function mcl_structures.call_struct(pos, struct_style, rotation, pr, callback)
	minetest.log("action","[mcl_structures] call_struct " .. struct_style.." at "..minetest.pos_to_string(pos))
	if not rotation then
		rotation = "random"
	end
	if struct_style == "desert_well" then
		return mcl_structures.generate_desert_well(pos, rotation)
	elseif struct_style == "igloo" then
		return mcl_structures.generate_igloo(pos, rotation, pr)
	elseif struct_style == "witch_hut" then
		return mcl_structures.generate_witch_hut(pos, rotation)
	elseif struct_style == "ice_spike_small" then
		return mcl_structures.generate_ice_spike_small(pos, rotation)
	elseif struct_style == "ice_spike_large" then
		return mcl_structures.generate_ice_spike_large(pos, rotation)
	elseif struct_style == "boulder" then
		return mcl_structures.generate_boulder(pos, rotation, pr)
	elseif struct_style == "fossil" then
		return mcl_structures.generate_fossil(pos, rotation, pr)
	elseif struct_style == "end_exit_portal" then
		return mcl_structures.generate_end_exit_portal(pos, rotation, pr, callback)
	elseif struct_style == "end_exit_portal_open" then
		return mcl_structures.generate_end_exit_portal_open(pos, rotation)
	elseif struct_style == "end_gateway_portal" then
		return mcl_structures.generate_end_gateway_portal(pos, rotation)
	elseif struct_style == "end_portal_shrine" then
		return mcl_structures.generate_end_portal_shrine(pos, rotation, pr)
	elseif struct_style == "end_portal" then
		return mcl_structures.generate_end_portal(pos, rotation, pr)
	end
end

function mcl_structures.generate_end_portal(pos, rotation, pr)
	-- todo: proper facedir
	local x0, y0, z0 = pos.x - 2, pos.y, pos.z - 2
	for x = 0, 4 do
		for z = 0, 4 do
			if x % 4 == 0 or z % 4 == 0 then
				if x % 4 ~= 0 or z % 4 ~= 0 then
					minetest.swap_node({x = x0 + x, y = y0, z = z0 + z}, {name = "mcl_portals:end_portal_frame_eye"})
				end
			else
				minetest.swap_node({x = x0 + x, y = y0, z = z0 + z}, {name = "mcl_portals:portal_end"})
			end
		end
	end
end

function mcl_structures.generate_desert_well(pos, rot)
	local newpos = {x=pos.x,y=pos.y-2,z=pos.z}
	local path = modpath.."/schematics/mcl_structures_desert_well.mts"
	return mcl_structures.place_schematic({
		pos = newpos,
		schematic = path,
		rotation = rot or "0",
		force_placement = true
	})
end

function mcl_structures.generate_igloo(pos, rotation, pr)
	-- Place igloo
	local success, rotation = mcl_structures.generate_igloo_top(pos, pr)
	-- Place igloo basement with 50% chance
	local r = pr:next(1,2)
	if r == 1 then
		-- Select basement depth
		local dim = mcl_worlds.pos_to_dimension(pos)
		--local buffer = pos.y - (mcl_mapgen.overworld.lava_max + 10)
		local buffer
		if dim == "nether" then
			buffer = pos.y - (mcl_vars.mg_lava_nether_max + 10)
		elseif dim == "end" then
			buffer = pos.y - (mcl_vars.mg_end_min + 1)
		elseif dim == "overworld" then
			buffer = pos.y - (mcl_mapgen.overworld.lava_max + 10)
		else
			return success
		end
		if buffer <= 19 then
			return success
		end
		local depth = pr:next(19, buffer)
		local bpos = {x=pos.x, y=pos.y-depth, z=pos.z}
		-- trapdoor position
		local tpos
		local dir, tdir
		if rotation == "0" then
			dir = {x=-1, y=0, z=0}
			tdir = {x=1, y=0, z=0}
			tpos = {x=pos.x+7, y=pos.y-1, z=pos.z+3}
		elseif rotation == "90" then
			dir = {x=0, y=0, z=-1}
			tdir = {x=0, y=0, z=-1}
			tpos = {x=pos.x+3, y=pos.y-1, z=pos.z+1}
		elseif rotation == "180" then
			dir = {x=1, y=0, z=0}
			tdir = {x=-1, y=0, z=0}
			tpos = {x=pos.x+1, y=pos.y-1, z=pos.z+3}
		elseif rotation == "270" then
			dir = {x=0, y=0, z=1}
			tdir = {x=0, y=0, z=1}
			tpos = {x=pos.x+3, y=pos.y-1, z=pos.z+7}
		else
			return success
		end
		local function set_brick(pos)
			local c = pr:next(1, 3) -- cracked chance
			local m = pr:next(1, 10) -- chance for monster egg
			local brick
			if m == 1 then
				if c == 1 then
					brick = "mcl_monster_eggs:monster_egg_stonebrickcracked"
				else
					brick = "mcl_monster_eggs:monster_egg_stonebrick"
				end
			else
				if c == 1 then
					brick = "mcl_core:stonebrickcracked"
				else
					brick = "mcl_core:stonebrick"
				end
			end
			minetest.set_node(pos, {name=brick})
		end
		local ladder_param2 = minetest.dir_to_wallmounted(tdir)
		local real_depth = 0
		-- Check how deep we can actuall dig
		for y=1, depth-5 do
			real_depth = real_depth + 1
			local node = minetest.get_node({x=tpos.x,y=tpos.y-y,z=tpos.z})
			local def = minetest.registered_nodes[node.name]
			if (not def) or (not def.walkable) or (def.liquidtype ~= "none") or (not def.is_ground_content) then
				bpos.y = tpos.y-y+1
				break
			end
		end
		if real_depth <= 6 then
			return success
		end
		-- Generate ladder to basement
		for y=1, real_depth-1 do
			set_brick({x=tpos.x-1,y=tpos.y-y,z=tpos.z  })
			set_brick({x=tpos.x+1,y=tpos.y-y,z=tpos.z  })
			set_brick({x=tpos.x  ,y=tpos.y-y,z=tpos.z-1})
			set_brick({x=tpos.x  ,y=tpos.y-y,z=tpos.z+1})
			minetest.set_node({x=tpos.x,y=tpos.y-y,z=tpos.z}, {name="mcl_core:ladder", param2=ladder_param2})
		end
		-- Place basement
		mcl_structures.generate_igloo_basement(bpos, rotation, pr)
		-- Place hidden trapdoor
		minetest.after(5, function(tpos, dir)
			minetest.set_node(tpos, {name="mcl_doors:trapdoor", param2=20+minetest.dir_to_facedir(dir)}) -- TODO: more reliable param2
		end, tpos, dir)
	end
	return success
end

function mcl_structures.generate_igloo_top(pos, pr)
	-- FIXME: This spawns bookshelf instead of furnace. Fix this!
	-- Furnace does not work atm because apparently meta is not set. :-(
	local newpos = {x=pos.x,y=pos.y-1,z=pos.z}
	local path = modpath.."/schematics/mcl_structures_igloo_top.mts"
	local rotation = tostring(pr:next(0,3)*90)
	return mcl_structures.place_schematic(newpos, path, rotation, nil, true), rotation
end

local function igloo_placement_callback(p1, p2, size, orientation, pr)
	local chest_offset
	if orientation == "0" then
		chest_offset = {x=5, y=1, z=5}
	elseif orientation == "90" then
		chest_offset = {x=5, y=1, z=3}
	elseif orientation == "180" then
		chest_offset = {x=3, y=1, z=1}
	elseif orientation == "270" then
		chest_offset = {x=1, y=1, z=5}
	else
		return
	end
	--local size = {x=9,y=5,z=7}
	local lootitems = mcl_loot.get_multi_loot({
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "mcl_core:apple_gold", weight = 1 },
		}
	},
	{
		stacks_min = 2,
		stacks_max = 8,
		items = {
			{ itemstring = "mcl_core:coal_lump", weight = 15, amount_min = 1, amount_max = 4 },
			{ itemstring = "mcl_core:apple", weight = 15, amount_min = 1, amount_max = 3 },
			{ itemstring = "mcl_farming:wheat_item", weight = 10, amount_min = 2, amount_max = 3 },
			{ itemstring = "mcl_core:gold_nugget", weight = 10, amount_min = 1, amount_max = 3 },
			{ itemstring = "mcl_mobitems:rotten_flesh", weight = 10 },
			{ itemstring = "mcl_tools:axe_stone", weight = 2 },
			{ itemstring = "mcl_core:emerald", weight = 1 },
		}
	}}, pr)

	local chest_pos = vector.add(p1, chest_offset)
	mcl_structures.init_node_construct(chest_pos)
	local meta = minetest.get_meta(chest_pos)
	local inv = meta:get_inventory()
	mcl_loot.fill_inventory(inv, "main", lootitems, pr)
end

function mcl_structures.generate_igloo_basement(pos, orientation, pr)
	-- TODO: Add brewing stand
	-- TODO: Add monster eggs
	-- TODO: Spawn villager and zombie villager
	local path = modpath.."/schematics/mcl_structures_igloo_basement.mts"
	mcl_structures.place_schematic(pos, path, orientation, nil, true, nil, igloo_placement_callback, pr)
end

function mcl_structures.generate_boulder(pos, rotation, pr)
	-- Choose between 2 boulder sizes (2×2×2 or 3×3×3)
	local r = pr:next(1, 10)
	local path
	if r <= 3 then
		path = modpath.."/schematics/mcl_structures_boulder_small.mts"
	else
		path = modpath.."/schematics/mcl_structures_boulder.mts"
	end

	local newpos = {x=pos.x,y=pos.y-1,z=pos.z}

	return minetest.place_schematic(newpos, path, rotation) -- don't serialize schematics for registered biome decorations, for MT 5.4.0, https://github.com/minetest/minetest/issues/10995
end

local function hut_placement_callback(p1, p2, size, orientation, pr)
	if not p1 or not p2 then return end
	local legs = minetest.find_nodes_in_area(p1, p2, "mcl_core:tree")
	for i = 1, #legs do
		while minetest.get_item_group(mcl_mapgen.get_far_node({x=legs[i].x, y=legs[i].y-1, z=legs[i].z}, true, 333333).name, "water") ~= 0 do
			legs[i].y = legs[i].y - 1
			minetest.swap_node(legs[i], {name = "mcl_core:tree", param2 = 2})
		end
	end
end

function mcl_structures.generate_witch_hut(pos, rotation, pr)
	local path = modpath.."/schematics/mcl_structures_witch_hut.mts"
	mcl_structures.place_schematic(pos, path, rotation, nil, true, nil, hut_placement_callback, pr)
end

function mcl_structures.generate_ice_spike_small(pos, rotation)
	local path = modpath.."/schematics/mcl_structures_ice_spike_small.mts"
	return minetest.place_schematic(pos, path, rotation or "random", nil, false) -- don't serialize schematics for registered biome decorations, for MT 5.4.0
end

function mcl_structures.generate_ice_spike_large(pos, rotation)
	local path = modpath.."/schematics/mcl_structures_ice_spike_large.mts"
	return minetest.place_schematic(pos, path, rotation or "random", nil, false) -- don't serialize schematics for registered biome decorations, for MT 5.4.0
end

function mcl_structures.generate_fossil(pos, rotation, pr)
	-- Generates one out of 8 possible fossil pieces
	local newpos = {x=pos.x,y=pos.y-1,z=pos.z}
	local fossils = {
		"mcl_structures_fossil_skull_1.mts", -- 4×5×5
		"mcl_structures_fossil_skull_2.mts", -- 5×5×5
		"mcl_structures_fossil_skull_3.mts", -- 5×5×7
		"mcl_structures_fossil_skull_4.mts", -- 7×5×5
		"mcl_structures_fossil_spine_1.mts", -- 3×3×13
		"mcl_structures_fossil_spine_2.mts", -- 5×4×13
		"mcl_structures_fossil_spine_3.mts", -- 7×4×13
		"mcl_structures_fossil_spine_4.mts", -- 8×5×13
	}
	local r = pr:next(1, #fossils)
	local path = modpath.."/schematics/"..fossils[r]
	return mcl_structures.place_schematic(newpos, path, rotation or "random", nil, true)
end

function mcl_structures.generate_end_exit_portal(pos, rot, pr, callback)
	local path = modpath.."/schematics/mcl_structures_end_exit_portal.mts"
	return mcl_structures.place_schematic(pos, path, rot or "0", {["mcl_portals:portal_end"] = "air"}, true, nil, callback)
end

function mcl_structures.generate_end_exit_portal_open(pos, rot)
	local path = modpath.."/schematics/mcl_structures_end_exit_portal.mts"
	return mcl_structures.place_schematic(pos, path, rot or "0", nil, true)
end

function mcl_structures.generate_end_gateway_portal(pos, rot)
	local path = modpath.."/schematics/mcl_structures_end_gateway_portal.mts"
	return mcl_structures.place_schematic(pos, path, rot or "0", nil, true)
end

local function dir_to_rotation(dir)
	local ax, az = math.abs(dir.x), math.abs(dir.z)
	if ax > az then
		if dir.x < 0 then
			return "270"
		end
		return "90"
	end
	if dir.z < 0 then
		return "180"
	end
	return "0"
end

dofile(modpath .. "/structures.lua")

-- Debug command
local spawnstruct_params = ""
for _, registered_structure in pairs(registered_structures) do
	if spawnstruct_params ~= "" then
		spawnstruct_params = spawnstruct_params .. " | "
	end
	spawnstruct_params = spawnstruct_params .. registered_structure.short_name
end
local spawnstruct_hint = S("Use /help spawnstruct to see a list of avaiable types.")
minetest.register_chatcommand("spawnstruct", {
	params = spawnstruct_params,
	description = S("Generate a pre-defined structure near your position."),
	privs = {debug = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then return end
		if param == "" then
			minetest.chat_send_player(name, S("Error: No structure type given. Please use “/spawnstruct <type>”."))
			minetest.chat_send_player(name, spawnstruct_hint)
			return
		end
		local struct = registered_structures[param]
		if not struct then
			struct = registered_structures[name_prefix .. param]
		end
		if not struct then
			minetest.chat_send_player(name, S("Error: Unknown structure type. Please use “/spawnstruct <type>”."))
			minetest.chat_send_player(name, spawnstruct_hint)
			return
		end
		local place = struct.place_function
		if not place then return end

		local pos = player:get_pos()
		if not pos then return end
		local pr = PseudoRandom(math.floor(pos.x * 333 + pos.y * 19 - pos.z + 4))
		pos = vector.round(pos)
		local dir = minetest.yaw_to_dir(player:get_look_horizontal())
		local rot = dir_to_rotation(dir)
		place(pos, rot, pr)
		minetest.chat_send_player(name, S("Structure placed."))
	end
})

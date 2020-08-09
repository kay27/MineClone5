local S = minetest.get_translator("mcl_portals")

-- Parameters

local TCAVE = 0.6
local nobj_cave = nil

-- Portal frame sizes
local FRAME_SIZE_X_MIN = 4
local FRAME_SIZE_Y_MIN = 5
local FRAME_SIZE_X_MAX = 23
local FRAME_SIZE_Y_MAX = 23

local TELEPORT_DELAY = 3 -- seconds before teleporting in Nether portal
local TELEPORT_COOLOFF = 4 -- after object was teleported, for this many seconds it won't teleported again

local mg_name = minetest.get_mapgen_setting("mg_name")
local superflat = mg_name == "flat" and minetest.get_mapgen_setting("mcl_superflat_classic") == "true"
local overworld_ground_level
if superflat then
	overworld_ground_level = mcl_vars.mg_bedrock_overworld_max + 5
elseif mg_name == "flat" then
	overworld_ground_level = 2 + (minetest.get_mapgen_setting("mgflat_ground_level") or 8)
else
	overworld_ground_level = nil
end

-- 3D noise
local np_cave = {
	offset = 0,
	scale = 1,
	spread = {x = 384, y = 128, z = 384},
	seed = 59033,
	octaves = 5,
	persist = 0.7
}

-- Table of objects (including players) which recently teleported by a
-- Nether portal. Those objects have a brief cooloff period before they
-- can teleport again. This prevents annoying back-and-forth teleportation.
local portal_cooloff = {}

-- Destroy portal if pos (portal frame or portal node) got destroyed
local destroy_portal = function(pos)
	-- Deactivate Nether portal
	minetest.log("action", "[mcl_portal] Destroying Nether portal at " .. minetest.pos_to_string(pos))
	local meta = minetest.get_meta(pos)
	local p1 = minetest.string_to_pos(meta:get_string("portal_frame1"))
	local p2 = minetest.string_to_pos(meta:get_string("portal_frame2"))
	if not p1 or not p2 then
		return
	end
	if(p1.x==p2.x) then
		p1.z = p1.z - 1
		p2.z = p2.z + 1
	else
		p1.x=p1.x-1
		p2.x=p2.x+1
	end
	p1.y=p1.y-1
	p2.y=p2.y+1

	local counter = 1

	local mp1
	for x = p1.x, p2.x do
	for y = p1.y, p2.y do
	for z = p1.z, p2.z do
		local p = vector.new(x, y, z)
		local m = minetest.get_meta(p)
		if counter == 2 then
			--[[ Only proceed if the second node still has metadata.
			(first node is a corner and not needed for the portal)
			If it doesn't have metadata, another node propably triggred the delection
			routine earlier, so we bail out earlier to avoid an infinite cascade
			of on_destroy events. ]]
			mp1 = minetest.string_to_pos(m:get_string("portal_frame1"))
			if not mp1 then
				return
			end
		end
		local nn = minetest.get_node(p).name
		if nn == "mcl_core:obsidian" or nn == "mcl_portals:portal" then
			-- Remove portal nodes, but not myself
			if nn == "mcl_portals:portal" and not vector.equals(p, pos) then
				minetest.remove_node(p)
			end
			-- Clear metadata of portal nodes and the frame
			m:set_string("portal_frame1", "")
			m:set_string("portal_frame2", "")
			m:set_string("portal_target", "")
			m:set_string("portal_time", "")
		end
		counter = counter + 1
	end
	end
	end
end

minetest.register_node("mcl_portals:portal", {
	description = S("Nether Portal"),
	_doc_items_longdesc = S("A Nether portal teleports creatures and objects to the hot and dangerous Nether dimension (and back!). Enter at your own risk!"),
	_doc_items_usagehelp = S("Stand in the portal for a moment to activate the teleportation. Entering a Nether portal for the first time will also create a new portal in the other dimension. If a Nether portal has been built in the Nether, it will lead to the Overworld. A Nether portal is destroyed if the any of the obsidian which surrounds it is destroyed, or if it was caught in an explosion."),

	tiles = {
		"blank.png",
		"blank.png",
		"blank.png",
		"blank.png",
		{
			name = "mcl_portals_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
			},
		},
		{
			name = "mcl_portals_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
			},
		},
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	use_texture_alpha = true,
	walkable = false,
	diggable = false,
	pointable = false,
	buildable_to = false,
	is_ground_content = false,
	drop = "",
	light_source = 11,
	post_effect_color = {a = 180, r = 51, g = 7, b = 89},
	alpha = 192,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1,  0.5, 0.5, 0.1},
		},
	},
	groups = {portal=1, not_in_creative_inventory = 1},
	on_destruct = destroy_portal,

	_mcl_hardness = -1,
	_mcl_blast_resistance = 0,
})

-- Functions
local function find_nether_target_y(target_x, target_z)
	if mg_name == "flat" then
		return mcl_vars.mg_flat_nether_floor + 1
	end
	local start_y = math.random(mcl_vars.mg_lava_nether_max + 1, mcl_vars.mg_bedrock_nether_top_min - 5) -- Search start
	if not nobj_cave then
		nobj_cave = minetest.get_perlin(np_cave)
	end
	local air = 4

	for y = start_y, math.max(mcl_vars.mg_lava_nether_max + 1), -1 do
		local nval_cave = nobj_cave:get_3d({x = target_x, y = y, z = target_z})

		if nval_cave > TCAVE then -- Cavern
			air = air + 1
		else -- Not cavern, check if 4 nodes of space above
			if air >= 4 then
				return y + 2
			else -- Not enough space, reset air to zero
				air = 0
			end
		end
	end

	return start_y -- Fallback
end

local function find_overworld_target_y(x, z)
	local y = overworld_ground_level or math.random(mcl_vars.mg_overworld_min + 40, mcl_vars.mg_overworld_min + 96)
	local node = minetest.get_node_or_nil({x = x, y = y, z = z})
	while node == nil and y > mcl_vars.mg_overworld_min do
		if node == nil then
			minetest.load_area({x = x, y = y - 5, z = z}, {x = x, y = y + 5, z = z})
			node = minetest.get_node_or_nil({x = x, y = y, z = z})
		end
		if node == nil then
			return y
		end
		if node.name == "air" then
			y = y - 1
			node = nil
		end
	end
	return y + 2
end

local function available_for_nether_portal(p)
	local nn = minetest.get_node(p).name
	local obsidian = nn == "mcl_core:obsidian"
	if nn ~= "air" and nn ~= "mcl_portals:portal" and minetest.get_item_group(nn, "fire") ~= 1 then
		return false, obsidian
	end
	return true, obsidian
end

local function light_frame(x1, y1, z1, x2, y2, z2, build_frame, existant_target, dim)
	local build_frame = build_frame or false
	local dim = dim or mcl_worlds.pos_to_dimension({x = x1, y = y1, z = z1})
	local orientation = 0
	if x1 == x2 then
		orientation = 1
	end
	local target = {}
	if not existant_target then
		target = {x = (x1 + x2) / 2, y = math.min(y1, y2), z = (z1 + z2) / 2}
		if dim == "overworld" then
			target.x = target.x / 8
			target.z = target.z / 8
			target.y = find_nether_target_y(target.x, target.z)
		else -- from Nether:
			target.x = mcl_worlds.nether_to_overworld(target.x)
			target.z = mcl_worlds.nether_to_overworld(target.z)
			target.y = find_overworld_target_y(target.x, target.z)
		end
	else
		target = {x = existant_target.x, y = existant_target.y, z = existant_target.z}
	end
	local disperse = 50
	local pass = 1
	while true do
		local protection = false

		for x = x1 - 1 + orientation, x2 + 1 - orientation do
			for z = z1 - orientation, z2 + orientation do
				for y = y1 - 1, y2 + 1 do
					local set_meta = true
					local frame = (x < x1) or (x > x2) or (y < y1) or (y > y2) or (z < z1) or (z > z2)
					if frame then
						if build_frame then
							if pass == 1 then
								if minetest.is_protected({x = x, y = y, z = z}, "") then
									protection = true
									x1 = x1 + math.random(0, disperse) - math.random(0, disperse)
									z1 = z1 + math.random(0, disperse) - math.random(0, disperse)
									disperse = disperse + math.random(25, 177)
									if disperse > 5000 then
										return nil
									end
									break
								end
							else
								minetest.set_node({x = x, y = y, z = z}, {name = "mcl_core:obsidian"})
							end
						else
							set_meta = minetest.get_node({x = x, y = y, z = z}).name == "mcl_core:obsidian"
						end
					else
						if not build_frame or pass == 2 then
							minetest.set_node({x = x, y = y, z = z}, {name = "mcl_portals:portal", param2 = orientation})
						end
					end
					if set_meta and not build_frame or pass == 2 then
						local meta = minetest.get_meta({x = x, y = y, z = z})
						-- Portal frame corners
						meta:set_string("portal_frame1", minetest.pos_to_string({x = x1, y = y1, z = z1}))
						meta:set_string("portal_frame2", minetest.pos_to_string({x = x2, y = y2, z = z2}))
						-- Portal target coordinates
						meta:set_string("portal_target", minetest.pos_to_string(target))
						meta:set_string("portal_time", tostring(minetest.get_us_time()))
					end
				end
				if protection then
					break
				end
			end
			if protection then
				break
			end
		end
		if build_frame == false or pass == 2 then
			break
		end
		if build_frame and not protection and pass == 1 then
			pass = 2
		end
	end
	return {x = x1, y = y1, z = z1}
end

--Build arrival portal
local function build_portal(pos, target, width, height, orientation)
	local height = height or FRAME_SIZE_Y_MIN - 2
	local width = width or FRAME_SIZE_X_MIN - 2
	local orientation = orientation or math.random(0, 1)

	if orientation == 0 then
		minetest.load_area({x = pos.x - 3, y = pos.y - 1, z = pos.z - width * 2}, {x = pos.x + width + 2, y = pos.y + height + 2, z = pos.z + width * 2})
	else
		minetest.load_area({x = pos.x - width * 2, y = pos.y - 1, z = pos.z - 3}, {x = pos.x + width * 2, y = pos.y + height + 2, z = pos.z + width + 2})
	end

	pos = light_frame(pos.x, pos.y, pos.z, pos.x + (1 - orientation) * (width - 1), pos.y + height - 1, pos.z + orientation * (width - 1), true, target)

	if orientation == 0 then
		for z = pos.z - width * 2, pos.z + width * 2 do
			if z ~= pos.z then
				for x = pos.x - 3, pos.x + width + 2 do
					for y = pos.y - 1, pos.y + height + 2 do
						if minetest.is_protected({x = x, y = y, z = z}, "") then
							if minetest.registered_nodes[minetest.get_node({x = x, y = y, z = z}).name].is_ground_content and not minetest.is_protected({x = x, y = y, z = z}, "") then
								minetest.remove_node({x = x, y = y, z = z})
							end
						end
					end
				end
			end
		end
	else
		for x = pos.x - width * 2, pos.x + width * 2 do
			if x ~= pos.x then
				for z = pos.z - 3, pos.z + width + 2 do
					for y = pos.y - 1, pos.y + height + 2 do
						if minetest.registered_nodes[minetest.get_node({x = x, y = y, z = z}).name].is_ground_content and not minetest.is_protected({x = x, y = y, z = z}, "") then
							minetest.remove_node({x = x, y = y, z = z})
						end
					end
				end
			end
		end
	end

	minetest.log("action", "[mcl_portal] Destination Nether portal generated at "..minetest.pos_to_string(pos).."!")

	return pos
end

-- Attempts to light a Nether portal at pos and
-- select target position.
-- Pos can be any of the inner part.
-- The frame MUST be filled only with air or any fire, which will be replaced with Nether portal blocks.
-- If no Nether portal can be lit, nothing happens.
-- Returns true on success and false on failure.
function mcl_portals.light_nether_portal(pos)
	-- Only allow to make portals in Overworld and Nether
	local dim = mcl_worlds.pos_to_dimension(pos)
	if dim ~= "overworld" and dim ~= "nether" then
		return 0
	end
	if not available_for_nether_portal(pos) then
		return 0
	end
	local y1 = pos.y
	local height = 1
	-- Decrease y1 to portal bottom:
	while true do
		y1 = y1 - 1
		local available, obsidian = available_for_nether_portal({x = pos.x, y = y1, z = pos.z})
		if available then
			height = height + 1
			if height > FRAME_SIZE_Y_MAX - 2 then
				return 0
			end
		elseif not obsidian then
			return 0
		else
			y1 = y1 + 1
			break
		end
	end
	local y2 = pos.y
	-- Increase y2 to portal top:
	while true do
		y2 = y2 + 1
		local available, obsidian = available_for_nether_portal({x = pos.x, y = y2, z = pos.z})
		if available then
			height = height + 1
			if height > FRAME_SIZE_Y_MAX - 2 then
				return 0
			end
		elseif not obsidian then
			return 0
		else
			if height < FRAME_SIZE_Y_MIN - 2 then
				return 0
			end
			y2 = y2 - 1
			break
		end
	end

	-- In some cases there might be 2 crossing frames and I have strong desire to light them both, so this is a counter for returning:
	local lit_portals = 0

	-- We have y1, y2 and height, check horizontal parts:

	-- Orientation 0:

	local okay_x = true
	local width = 1
	local x1 = pos.x
	local x2 = pos.x
	-- Decrease x1 to left side of the portal:
	while okay_x do
		x1 = x1 - 1
		local available, obsidian = available_for_nether_portal({x = x1, y = pos.y, z = pos.z})
		if available then
			width = width + 1
			if width > FRAME_SIZE_X_MAX - 2 then
				okay_x = false
				break
			end
		elseif not obsidian then
			okay_x = false
			break
		else
			x1 = x1 + 1
			break
		end
	end
	while okay_x do
		x2 = x2 + 1
		local available, obsidian = available_for_nether_portal({x = x2, y = pos.y, z = pos.z})
		if available then
			width = width + 1
			if width > FRAME_SIZE_X_MAX - 2 then
				okay_x = false
				break
			end
		elseif not obsidian then
			okay_x = false
			break
		else
			if width < FRAME_SIZE_X_MIN - 2 then
				okay_x = false
			end
			x2 = x2 - 1
			break
		end
	end
	-- We found some frame but in fact only a cross, need to check it all:
	if okay_x then
		for x = x1, x2 do
			if x ~= pos.x then
				for y = y1, y2 do
					if y ~= pos.y then
						local available, obsidian = available_for_nether_portal({x = x, y = y, z = pos.z})
						if not available then
							okay_x = false
							break
						end
					end
				end
			end
		end
	end
	-- Check horizontal parts of obsidian frame:
	if okay_x then
		for x = x1, x2 do
			if x ~= pos.x then
				if minetest.get_node({x = x, y = y1 - 1, z = pos.z}).name ~= "mcl_core:obsidian" or minetest.get_node({x = x, y = y2 + 1, z = pos.z}).name ~= "mcl_core:obsidian" then
					okay_x = false
					break
				end
			end
		end
	end
	-- Check vertical parts of obsidian frame:
	if okay_x then
		for y = y1, y2 do
			if y ~= pos.y then
				if minetest.get_node({x = x1 - 1, y = y, z = pos.z}).name ~= "mcl_core:obsidian" or minetest.get_node({x = x2 + 1, y = y, z = pos.z}).name ~= "mcl_core:obsidian" then
					okay_x = false
					break
				end
			end
		end
	end
	if okay_x then
		light_frame(x1, y1, pos.z, x2, y2, pos.z, false, false, dim)
		lit_portals = lit_portals + 1
	end

	-- Orientation 1:

	local width = 1
	local z1 = pos.z
	local z2 = pos.z
	-- Decrease z1 to left side of the portal:
	while true do
		z1 = z1 - 1
		local available, obsidian = available_for_nether_portal({x = pos.x, y = pos.y, z = z1})
		if available then
			width = width + 1
			if width > FRAME_SIZE_X_MAX - 2 then
				return lit_portals
			end
		elseif not obsidian then
			return lit_portals
		else
			z1 = z1 + 1
			break
		end
	end
	while true do
		z2 = z2 + 1
		local available, obsidian = available_for_nether_portal({x = pos.x, y = pos.y, z = z2})
		if available then
			width = width + 1
			if width > FRAME_SIZE_X_MAX - 2 then
				return lit_portals
			end
		elseif not obsidian then
				return lit_portals
		else
			if width < FRAME_SIZE_X_MIN - 2 then
				return lit_portals
			end
			z2 = z2 - 1
			break
		end
	end
	-- We found some frame but in fact only a cross, need to check it all:
	for z = z1, z2 do
		if z ~= pos.z then
			for y = y1, y2 do
				if y ~= pos.y then
					local available, obsidian = available_for_nether_portal({x = pos.x, y = y, z = z})
					if not available then
						return lit_portals
					end
				end
			end
		end
	end
	-- Check horizontal parts of obsidian frame:
	for z = z1, z2 do
		if z ~= pos.z then
			if minetest.get_node({x = pos.x, y = y1 - 1, z = z}).name ~= "mcl_core:obsidian" or minetest.get_node({x = pos.x, y = y2 + 1, z = z}).name ~= "mcl_core:obsidian" then
				return lit_portals
			end
		end
	end
	-- Check vertical parts of obsidian frame:
	for y = y1, y2 do
		if y ~= pos.y then
			if minetest.get_node({x = pos.x, y = y, z = z1 - 1}).name ~= "mcl_core:obsidian" or minetest.get_node({x = pos.x, y = y, z = z2 + 1}).name ~= "mcl_core:obsidian" then
				return lit_portals
			end
		end
	end
	light_frame(pos.x, y1, z1, pos.x, y2, z2, false, false, dim)

	lit_portals = lit_portals + 1

	return lit_portals
end


minetest.register_abm({
	label = "Nether portal teleportation and particles",
	nodenames = {"mcl_portals:portal"},
	interval = 1,
	chance = 2,
	action = function(pos, node)
		minetest.add_particlespawner({
			amount = 32,
			time = 4,
			minpos = {x = pos.x - 0.25, y = pos.y - 0.25, z = pos.z - 0.25},
			maxpos = {x = pos.x + 0.25, y = pos.y + 0.25, z = pos.z + 0.25},
			minvel = {x = -0.8, y = -0.8, z = -0.8},
			maxvel = {x = 0.8, y = 0.8, z = 0.8},
			minacc = {x = 0, y = 0, z = 0},
			maxacc = {x = 0, y = 0, z = 0},
			minexptime = 0.5,
			maxexptime = 1,
			minsize = 1,
			maxsize = 2,
			collisiondetection = false,
			texture = "mcl_particles_teleport.png",
		})
		for _,obj in ipairs(minetest.get_objects_inside_radius(pos,1)) do		--maikerumine added for objects to travel
			local lua_entity = obj:get_luaentity() --maikerumine added for objects to travel
			if obj:is_player() or lua_entity then
				-- Prevent quick back-and-forth teleportation
				if portal_cooloff[obj] then
					return
				end
				local meta = minetest.get_meta(pos)
				local target = minetest.string_to_pos(meta:get_string("portal_target"))
				local pos1 = minetest.string_to_pos(meta:get_string("portal_frame1"))
				local pos2 = minetest.string_to_pos(meta:get_string("portal_frame2"))
				local height = pos2.y - pos1.y + 1
				local width = (pos2.x - pos1.x) + (pos2.z - pos1.z) + 1
				-- minetest.log("action", "[mcl_portal] Entered portal, target=" .. minetest.pos_to_string(target))

				if target then
					-- force emerge of target area
					minetest.get_voxel_manip():read_from_map(target, target)
					if not minetest.get_node_or_nil(target) then
						minetest.emerge_area(vector.subtract(target, 4), vector.add(target, 4))
					end

					-- teleport function
					local teleport = function(obj, pos, target)
						if (not obj:get_luaentity()) and  (not obj:is_player()) then
							return
						end
						-- Prevent quick back-and-forth teleportation
						if portal_cooloff[obj] then
							return
						end
						local objpos = obj:get_pos()
						if objpos == nil then
							return
						end
						-- If player stands, player is at ca. something+0.5
						-- which might cause precision problems, so we used ceil.
						objpos.y = math.ceil(objpos.y)

						if minetest.get_node(objpos).name ~= "mcl_portals:portal" then
							return
						end

						-- Teleport
						obj:set_pos(target)
						if obj:is_player() then
							mcl_worlds.dimension_change(obj, mcl_worlds.pos_to_dimension(target))
							minetest.sound_play("mcl_portals_teleport", {pos=target, gain=0.5, max_hear_distance = 16}, true)
						end

						-- Enable teleportation cooloff for some seconds, to prevent back-and-forth teleportation
						portal_cooloff[obj] = true
						minetest.after(TELEPORT_COOLOFF, function(o)
							portal_cooloff[o] = false
						end, obj)
						if obj:is_player() then
							local name = obj:get_player_name()
							minetest.log("action", "[mcl_portal] "..name.." teleported to Nether portal at "..minetest.pos_to_string(target)..".")
						end
					end

					local n = minetest.get_node_or_nil(target)
					if n == nil then
						-- Emerge target area, wait for emerging to be finished, build destination portal
						-- (if there isn't already one, teleport object after a short delay.
						local emerge_callback = function(blockpos, action, calls_remaining, param)
							minetest.log("action", "[mcl_portal] emerge_callack called! action="..action)
							if calls_remaining <= 0 and action ~= minetest.EMERGE_CANCELLED and action ~= minetest.EMERGE_ERRORED then
								minetest.log("verbose", "[mcl_portal] Area for destination Nether portal emerged!")
								target = build_portal(param.target, param.pos, param.width, param.height)
								minetest.after(TELEPORT_DELAY, teleport, obj, pos, target)
							end
						end
						minetest.log("action", "[mcl_portal] Emerging area for destination Nether portal ...")
						minetest.emerge_area(vector.subtract(target, 7), vector.add(target, 7), emerge_callback, { pos = pos, target = target, width = width, height = height })
					else
						if n.name ~= "mcl_portals:portal" then -- Target portal destroyed! TODO: Find or create another one
							minetest.log("action", "[mcl_portal] Target portal destroyed! TODO: Find or create another one")
							target = build_portal(target, pos, width, height)
						end
						minetest.after(TELEPORT_DELAY, teleport, obj, pos, target)
					end

				end
			end
		end
	end,
})


--[[ ITEM OVERRIDES ]]

local longdesc = minetest.registered_nodes["mcl_core:obsidian"]._doc_items_longdesc
longdesc = longdesc .. "\n" .. S("Obsidian is also used as the frame of Nether portals.")
local usagehelp = S("To open a Nether portal, place an upright frame of obsidian with a width of 4 blocks and a height of 5 blocks, leaving only air in the center. After placing this frame, light a fire in the obsidian frame. Nether portals only work in the Overworld and the Nether.")

minetest.override_item("mcl_core:obsidian", {
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usagehelp,
	on_destruct = destroy_portal,
	_on_ignite = function(user, pointed_thing)
		local pos = {x = pointed_thing.under.x, y = pointed_thing.under.y, z = pointed_thing.under.z}
		local portals_counter = 0
		-- Check empty spaces around obsidian and light all frames found:
		for x = pos.x-1, pos.x+1 do
			for y = pos.y-1, pos.y+1 do
				for z = pos.z-1, pos.z+1 do
					local portals_placed = mcl_portals.light_nether_portal({x = x, y = y, z = z})
					if portals_placed > 0 then
						minetest.log("action", "[mcl_portal] Nether portal activated at "..minetest.pos_to_string(pos)..".")
						portals_counter = portals_counter + portals_placed
						break
					end
				end
				if portals_counter > 0 then
					break
				end
			end
			if portals_counter > 0 then
				break
			end
		end
		if portals_counter > 0 then
			if minetest.get_modpath("doc") then
				doc.mark_entry_as_revealed(user:get_player_name(), "nodes", "mcl_portals:portal")

				-- Achievement for finishing a Nether portal TO the Nether
				local dim = mcl_worlds.pos_to_dimension(pos)
				if minetest.get_modpath("awards") and dim ~= "nether" and user:is_player() then
					awards.unlock(user:get_player_name(), "mcl:buildNetherPortal")
				end
			end
			return true
		else
			return false
		end
	end,
})


local S = minetest.get_translator("mcl_portals")

-- Parameters

local ENABLE_NETHER_PORTAL_CROSS = 1
local ENABLE_NETHER_PORTAL_ANY_SHAPE = 1

-- Portal frame sizes
local FRAME_SIZE_X_MIN = 4
local FRAME_SIZE_Y_MIN = 5
local FRAME_SIZE_X_MAX = 23
local FRAME_SIZE_Y_MAX = 23

local PORTAL_NODES_MIN = 5
local PORTAL_NODES_MAX = (FRAME_SIZE_X_MAX - 2) * (FRAME_SIZE_Y_MAX - 2)

local TELEPORT_DELAY = 4 -- seconds before teleporting in Nether portal
local TELEPORT_COOLOFF = 4 -- after object was teleported, for this many seconds it won't teleported again
local DESTINATION_EXPIRES = 60 * 1000000 -- cached destination expires after this number of microseconds have passed without using the same origin portal

local PORTAL_SEARCH_HALF_CHUNK = 40 -- greater values may slow down the teleportation

-- Table of objects (including players) which recently teleported by a
-- Nether portal. Those objects have a brief cooloff period before they
-- can teleport again. This prevents annoying back-and-forth teleportation.
local portal_cooloff = {}
local teleporting_objects = {}

local portal_cross = {}

local overworld_ymin = math.max(mcl_vars.mg_overworld_min, -31)
local overworld_ymax = math.min(mcl_vars.mg_overworld_max_official, 63)
local nether_ymin = mcl_vars.mg_bedrock_nether_bottom_min
local nether_ymax = mcl_vars.mg_bedrock_nether_top_max
local overworld_dy = overworld_ymax - overworld_ymin + 1
local nether_dy = nether_ymax - nether_ymin + 1

-- local rng = PcgRandom(32321123312123)

-- Functions

local function nether_to_overworld(x)
    return 30912 - math.abs((x * 8 + 30912) % 123648 - 61824)
end

-- Destroy portal if pos (portal frame or portal node) got destroyed
function mcl_portals.destroy_nether_portal(pos)
	-- Deactivate Nether portal
	if ENABLE_NETHER_PORTAL_CROSS and #portal_cross then
		for i = 1, #portal_cross do
			if portal_cross[i].x == pos.x and portal_cross[i].y == pos.y and portal_cross[i].z == pos.z then
				portal_cross[i] = nil
				return
			end
		end
	end

	local meta = minetest.get_meta(pos)
	local node = minetest.get_node(pos)
	local nn, orientation = node.name, node.param2
	minetest.log("action", "[mcl_portal] Destroying Nether portal at " .. minetest.pos_to_string(pos) .. "(" .. nn .. ")")
	local obsidian = nn == "mcl_core:obsidian" 
	local cross = nn == "mcl_portal:portal_cross" 

	local has_meta = minetest.string_to_pos(meta:get_string("portal_frame1"))
	meta:set_string("portal_frame1", "")
	meta:set_string("portal_frame2", "")
	meta:set_string("portal_target", "")
	meta:set_string("portal_time", "")
	local check_remove = function(pos, orientation)
		local node = minetest.get_node(pos)
		if node and (node.name == "mcl_portals:portal" and (orientation == nil or (node.param2 == orientation))) or (node.name == "mcl_portals:portal_cross") then
			return minetest.remove_node(pos)
		end
	end
	if obsidian then -- check each of 6 sides of it and destroy every portal:
		check_remove({x = pos.x - 1, y = pos.y, z = pos.z}, 0)
		check_remove({x = pos.x + 1, y = pos.y, z = pos.z}, 0)
		check_remove({x = pos.x, y = pos.y, z = pos.z - 1}, 1)
		check_remove({x = pos.x, y = pos.y, z = pos.z + 1}, 1)
		check_remove({x = pos.x, y = pos.y - 1, z = pos.z})
		check_remove({x = pos.x, y = pos.y + 1, z = pos.z})
		return
	end
	if not has_meta then -- no meta means repeated call: function calls on every node destruction
		return
	end
	if orientation == 0 or cross then
		check_remove({x = pos.x - 1, y = pos.y, z = pos.z}, 0)
		check_remove({x = pos.x + 1, y = pos.y, z = pos.z}, 0)
	end
	if orientation == 1 or cross then
		check_remove({x = pos.x, y = pos.y, z = pos.z - 1}, 1)
		check_remove({x = pos.x, y = pos.y, z = pos.z + 1}, 1)
	end
	check_remove({x = pos.x, y = pos.y - 1, z = pos.z})
	check_remove({x = pos.x, y = pos.y + 1, z = pos.z})
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
	on_destruct = mcl_portals.destroy_nether_portal,

	_mcl_hardness = -1,
	_mcl_blast_resistance = 0,
})

if ENABLE_NETHER_PORTAL_CROSS then
	minetest.register_node("mcl_portals:portal_cross", {
		description = S("Nether Portal Cross"),
		tiles =
		{
			{ name = "mcl_portals_portal.png", animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.5 }},
			{ name = "mcl_portals_portal.png", animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.5 }},
			{ name = "mcl_portals_portal.png", animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.5 }},
			{ name = "mcl_portals_portal.png", animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.5 }},
			{ name = "mcl_portals_portal.png", animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.5 }},
			{ name = "mcl_portals_portal.png", animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.5 }}
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
		light_source = 12,
		post_effect_color = {a = 180, r = 51, g = 7, b = 89},
		alpha = 192,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.1, -0.5, -0.5,  0.1, 0.5, 0.5},
				{-0.5, -0.5, -0.1,  0.5, 0.5, 0.1},
			},
		},
		groups = {portal=1, not_in_creative_inventory = 1},
		on_destruct = mcl_portals.destroy_nether_portal,

		_mcl_hardness = -1,
		_mcl_blast_resistance = 0,
	})
end

local function find_target_y(x, y, z, y_min, y_max)
	local y_org = y
	local node = minetest.get_node_or_nil({x = x, y = y, z = z})
	if node == nil then
		return y
	end
	while node.name ~= "air" and y < y_max do
		y = y + 1
		node = minetest.get_node_or_nil({x = x, y = y, z = z})
		if node == nil then
			break
		end
	end
	while node == nil and y > y_min do
		y = y - 1
		node = minetest.get_node_or_nil({x = x, y = y, z = z})
	end
	if y == y_max and node ~= nil then -- try reverse direction who knows what they built there...
		while node.name ~= "air" and y > y_min do
			y = y - 1
			node = minetest.get_node_or_nil({x = x, y = y, z = z})
			if node == nil then
				break
			end
		end
	end
	if node == nil then
		return y_org
	end
	while node.name == "air" and y > y_min do
		y = y - 1
		node = minetest.get_node_or_nil({x = x, y = y, z = z})
		while node == nil and y > y_min do
			y = y - 1
			node = minetest.get_node_or_nil({x = x, y = y, z = z})
		end
		if node == nil then
			return y_org
		end
	end
	if y == y_min then
		return y_org
	end
	return y
end

local function find_nether_target_y(x, y, z)
	return find_target_y(x, y, z, nether_ymin + 4, nether_ymax - 25) + 1
end

local function find_overworld_target_y(x, y, z)
	return find_target_y(x, y, z, overworld_ymin + 4, overworld_ymax - 25) + 1
end

local function update_target(pos, target, time_str)
	local meta = minetest.get_meta(pos)
	if meta:get_string("portal_time") == time_str then
		return
	end
	local node = minetest.get_node(pos)
	if not node then
		return
	end
	local portal, cross = node.name == "mcl_portals:portal", node.name == "mcl_portals:portal_cross"
	if not portal and not cross then
		return
	end
	meta:set_string("portal_target", target)
	meta:set_string("portal_time", time_str)
	update_target({x = pos.x, y = pos.y - 1, z = pos.z}, target, time_str)
	update_target({x = pos.x, y = pos.y + 1, z = pos.z}, target, time_str)
	if node.param2 == 0 or cross then
		update_target({x = pos.x - 1, y = pos.y, z = pos.z}, target, time_str)
		update_target({x = pos.x + 1, y = pos.y, z = pos.z}, target, time_str)
	end
	if node.param2 == 0 or cross then
		update_target({x = pos.x, y = pos.y, z = pos.z - 1}, target, time_str)
		update_target({x = pos.x, y = pos.y, z = pos.z + 1}, target, time_str)
	end
end

local function ecb_setup_target_portal(blockpos, action, calls_remaining, param)
	-- param.: srcx, srcy, srcz, dstx, dsty, dstz, srcdim, ax1, ay1, az1, ax2, ay2, az2
	-- if calls_remaining <= 0 and action ~= minetest.EMERGE_CANCELLED and action ~= minetest.EMERGE_ERRORED then
	if calls_remaining <= 0 then
		minetest.log("verbose", "[mcl_portal] Area for destination Nether portal emerged!")
		local portal_nodes = minetest.find_nodes_in_area({x = param.ax1, y = param.ay1, z = param.az1}, {x = param.ax2, y = param.ay2, z = param.az2}, {"mcl_portals:portal", "mcl_portals:portal_cross"})
		local src_pos = {x = param.srcx, y = param.srcy, z = param.srcz}
		local dst_pos = {x = param.dstx, y = param.dsty, z = param.dstz}
		local meta = minetest.get_meta(src_pos)
		local p1 = minetest.string_to_pos(meta:get_string("portal_frame1")) or {x = src_pos.x, y = src_pos.y, z = src_pos.z}
		local p2 = minetest.string_to_pos(meta:get_string("portal_frame2")) or {x = src_pos.x, y = src_pos.y, z = src_pos.z}
		local portal_pos = {}
		if portal_nodes and #portal_nodes > 0 then
			-- Found some portal(s), use nearest:
			portal_pos = {x = portal_nodes[1].x, y = portal_nodes[1].y, z = portal_nodes[1].z}
			local nearest_distance = vector.distance(dst_pos, portal_pos)
			if #portal_nodes > 1 then
				for n = 2, #portal_nodes do
					local distance = vector.distance(dst_pos, portal_nodes[n])
					if distance < nearest_distance then
						portal_pos = {x = portal_nodes[n].x, y = portal_nodes[n].y, z = portal_nodes[n].z}
						nearest_distance = distance
					end
				end
			end -- here we have the best portal_pos
		else
			-- Need to build arrival portal:
			local width = math.max(math.abs(p2.z - p1.z) + math.abs(p2.x - p1.x) + 1, 2)
			local height = math.max(math.abs(p2.y - p1.y) + 1, 3)
			if param.srcdim == "overworld" then
				dst_pos.y = find_nether_target_y(dst_pos.x, dst_pos.y, dst_pos.z)
			else
				dst_pos.y = find_overworld_target_y(dst_pos.x, dst_pos.y, dst_pos.z)
			end
			portal_pos = mcl_portals.build_nether_portal(dst_pos, width, height)
		end

		local target_meta = minetest.get_meta(portal_pos)
		local p3 = minetest.string_to_pos(target_meta:get_string("portal_frame1"))
		local p4 = minetest.string_to_pos(target_meta:get_string("portal_frame2"))
		if p3 and p4 then
			portal_pos = vector.divide(vector.add(p3, p4), 2.0)
			portal_pos.y = math.min(p3.y, p4.y)
			local node = minetest.get_node(portal_pos)
			if node and node.name ~= "mcl_portals:portal" and node.name ~= "mcl_portals:portal_cross" then
				portal_pos = {x = p3.x, y = p3.y, z = p3.z}
			end
		end
		local time_str = tostring(minetest.get_us_time())
		local target = minetest.pos_to_string(portal_pos)

		-- update_target(p1, target, time_str)
		update_target(src_pos, target, time_str)
	end
end

function mcl_portals.nether_portal_get_target_position(src_pos)
	local _, current_dimension = mcl_worlds.y_to_layer(src_pos.y)
	local x, y, z, y_min, y_max = 0, src_pos.y, 0, 0, 0
	if current_dimension == "nether" then
		x = nether_to_overworld(src_pos.x)
		z = nether_to_overworld(src_pos.z)
		y = (math.min(math.max(y, nether_ymin), nether_ymax) - nether_ymin) / nether_dy * overworld_dy + overworld_ymin
		y_min = overworld_ymin
		y_max = overworld_ymax
	else -- overworld:
		x = src_pos.x / 8
		z = src_pos.z / 8
		y = (math.min(math.max(y, overworld_ymin), overworld_ymax) - overworld_ymin) / overworld_dy * nether_dy + nether_ymin
		y_min = nether_ymin
		y_max = nether_ymax
	end
	return x, y, z, current_dimension, y_min, y_max
end

local function find_or_create_portal(src_pos)
	local x, y, z, cdim, y_min, y_max = mcl_portals.nether_portal_get_target_position(src_pos)
	local pos1 = {x = x - PORTAL_SEARCH_HALF_CHUNK, y = math.max(y_min, y - PORTAL_SEARCH_HALF_CHUNK), z = z - PORTAL_SEARCH_HALF_CHUNK}
	local pos2 = {x = x + PORTAL_SEARCH_HALF_CHUNK, y = math.min(y_max, y + PORTAL_SEARCH_HALF_CHUNK), z = z + PORTAL_SEARCH_HALF_CHUNK}
	minetest.emerge_area(pos1, pos2, ecb_setup_target_portal, {srcx=src_pos.x, srcy=src_pos.y, srcz=src_pos.z, dstx=x, dsty=y, dstz=z, srcdim=cdim, ax1=pos1.x, ay1=pos1.y, az1=pos1.z, ax2=pos2.x, ay2=pos2.y, az2=pos2.z})
end

local function emerge_target_area(src_pos)
	local x, y, z, cdim, y_min, y_max = mcl_portals.nether_portal_get_target_position(src_pos)
	local pos1 = {x = x - PORTAL_SEARCH_HALF_CHUNK, y = math.max(y_min + 2, y - PORTAL_SEARCH_HALF_CHUNK), z = z - PORTAL_SEARCH_HALF_CHUNK}
	local pos2 = {x = x + PORTAL_SEARCH_HALF_CHUNK, y = math.min(y_max - 2, y + PORTAL_SEARCH_HALF_CHUNK), z = z + PORTAL_SEARCH_HALF_CHUNK}
	minetest.emerge_area(pos1, pos2)
	pos1 = {x = x - 1, y = y_min, z = z - 1}
	pos2 = {x = x + 1, y = y_max, z = z + 1}
	minetest.emerge_area(pos1, pos2)
end

local function available_for_nether_portal(p)
	local nn = minetest.get_node(p).name
	local obsidian = nn == "mcl_core:obsidian"
	if ENABLE_NETHER_PORTAL_CROSS then
		if nn ~= "air" and nn ~= "mcl_portals:portal" and minetest.get_item_group(nn, "fire") ~= 1 then
			return false, obsidian
		end
	else
		if nn ~= "air" and minetest.get_item_group(nn, "fire") ~= 1 then
			return false, obsidian
		end
	end
	return true, obsidian
end

local function light_frame(x1, y1, z1, x2, y2, z2, build_frame)
	local build_frame = build_frame or false
	local orientation = 0
	if x1 == x2 then
		orientation = 1
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
									local offset_x = math.random(-disperse, disperse)
									local offset_z = math.random(-disperse, disperse)
									disperse = disperse + math.random(25, 177)
									if disperse > 5000 then
										return nil
									end
									x1, z1 = x1 + offset_x, z1 + offset_z
									x2, z2 = x2 + offset_x, z2 + offset_z
									local _, dimension = mcl_worlds.y_to_layer(y1)
									local height = math.abs(y2 - y1)
									y1 = (y1 + y2) / 2
									if dimension == "nether" then
										y1 = find_nether_target_y(math.min(x1, x2), y1, math.min(z1, z2))
									else
										y1 = find_overworld_target_y(math.min(x1, x2), y1, math.min(z1, z2))
									end
									y2 = y1 + height
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
							local node = minetest.get_node({x = x, y = y, z = z})
							if ENABLE_NETHER_PORTAL_CROSS and node and node.name == "mcl_portals:portal" then
								table.insert(portal_cross, {x = math.floor(x), y = math.floor(y), z = math.floor(z)})
								minetest.set_node({x = x, y = y, z = z}, {name = "mcl_portals:portal_cross"})
							else
								minetest.set_node({x = x, y = y, z = z}, {name = "mcl_portals:portal", param2 = orientation})
							end
						end
					end
					if set_meta and not build_frame or pass == 2 then
						local meta = minetest.get_meta({x = x, y = y, z = z})
						-- Portal frame corners
						meta:set_string("portal_frame1", minetest.pos_to_string({x = x1, y = y1, z = z1}))
						meta:set_string("portal_frame2", minetest.pos_to_string({x = x2, y = y2, z = z2}))
						-- Portal target coordinates
						meta:set_string("portal_target", "")
						-- meta:set_string("portal_time", tostring(minetest.get_us_time()))
						meta:set_string("portal_time", tostring(0))
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
	emerge_target_area({x = x1, y = y1, z = z1})
	return {x = x1, y = y1, z = z1}
end

--Build arrival portal
function mcl_portals.build_nether_portal(pos, width, height, orientation)
	local height = height or FRAME_SIZE_Y_MIN - 2
	local width = width or FRAME_SIZE_X_MIN - 2
	local orientation = orientation or math.random(0, 1)

	if orientation == 0 then
		minetest.load_area({x = pos.x - 3, y = pos.y - 1, z = pos.z - width * 2}, {x = pos.x + width + 2, y = pos.y + height + 2, z = pos.z + width * 2})
	else
		minetest.load_area({x = pos.x - width * 2, y = pos.y - 1, z = pos.z - 3}, {x = pos.x + width * 2, y = pos.y + height + 2, z = pos.z + width + 2})
	end

	pos = light_frame(pos.x, pos.y, pos.z, pos.x + (1 - orientation) * (width - 1), pos.y + height - 1, pos.z + orientation * (width - 1), true)

	if orientation == 0 then
		for z = pos.z - width * 2, pos.z + width * 2 do
			if z ~= pos.z then
				for x = pos.x - 3, pos.x + width + 2 do
					for y = pos.y - 1, pos.y + height + 2 do
						if minetest.registered_nodes[minetest.get_node({x = x, y = y, z = z}).name].is_ground_content and not minetest.is_protected({x = x, y = y, z = z}, "") then
							minetest.remove_node({x = x, y = y, z = z})
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

local function check_shape(pos, orientation, node_counter, node_list)
	local meta = minetest.get_meta(pos)
	local target = meta:get_string("portal_time")
	if target and target == "-2" then
		return node_counter > 0, node_counter, node_list
	end
	local good, obsidian = available_for_nether_portal(pos)
	if not good and not obsidian then
		return false, node_counter, node_list
	end
	if obsidian then
		return true, node_counter, node_list
	end
	if node_counter >= PORTAL_NODES_MAX then
		return false, node_counter, node_list
	end
	meta:set_string("portal_time", "-2")
	node_list[#node_list + 1] = {x = pos.x, y = pos.y, z = pos.z}
	node_counter = node_counter + 1
	if orientation == 0 then
		good, node_counter = check_shape({x = pos.x - 1, y = pos.y, z = pos.z}, orientation, node_counter, node_list)
		if not good then
			return false, node_counter, node_list
		end
		good, node_counter = check_shape({x = pos.x + 1, y = pos.y, z = pos.z}, orientation, node_counter, node_list)
		if not good then
			return false, node_counter, node_list
		end
	else -- orientation == 1
		good, node_counter = check_shape({x = pos.x, y = pos.y, z = pos.z - 1}, orientation, node_counter, node_list)
		if not good then
			return false, node_counter, node_list
		end
		good, node_counter = check_shape({x = pos.x, y = pos.y, z = pos.z + 1}, orientation, node_counter, node_list)
		if not good then
			return false, node_counter, node_list
		end
	end
	good, node_counter = check_shape({x = pos.x, y = pos.y - 1, z = pos.z}, orientation, node_counter, node_list)
	if not good then
		return false, node_counter, node_list
	end
	good, node_counter = check_shape({x = pos.x, y = pos.y + 1, z = pos.z}, orientation, node_counter, node_list)
	return good, node_counter, node_list
end

-- Attempts to light a Nether portal at pos
-- Pos can be any of the inner part.
-- The frame MUST be filled only with air or any fire, which will be replaced with Nether portal blocks.
-- If no Nether portal can be lit, nothing happens.
-- Returns number of portals created (0, 1 or 2)
function mcl_portals.light_nether_portal_free_shape(pos)
	-- Only allow to make portals in Overworld and Nether
	local dim = mcl_worlds.pos_to_dimension(pos)
	if dim ~= "overworld" and dim ~= "nether" then
		return 0
	end

	local lit_portals = 0

	for orientation = 0, 1 do
		local good, node_counter, node_list = check_shape(pos, orientation, 0, {})
		if good and node_counter >= PORTAL_NODES_MIN then
			local pos1 = {x = node_list[1].x, y = node_list[1].y, z = node_list[1].z}
			local pos2 = {x = node_list[1].x, y = node_list[1].y, z = node_list[1].z}
			local max_y = node_list[1].y
			for i = 2, node_counter do
				if (node_list[i].y < pos1.y) or (node_list[i].y == pos1.y and (node_list[i].x < pos1.x or node_list[i].z < pos1.z)) then
					pos1 = {x = node_list[i].x, y = node_list[i].y, z = node_list[i].z}
				end
				if (node_list[i].y < pos2.y) or (node_list[i].y == pos2.y and (node_list[i].x > pos2.x or node_list[i].z < pos2.z)) then
					pos2 = {x = node_list[i].x, y = node_list[i].y, z = node_list[i].z}
				end
				if (node_list[i].y > max_y) then
					max_y = node_list[i].y
				end
			end
			pos2.y = max_y
			for i = 1, node_counter do
				local node_pos = node_list[i]
				local node = minetest.get_node(node_pos)
				if not node or node.name ~= "mcl_portals:portal" then
					minetest.set_node(node_pos, {name = "mcl_portals:portal", param2 = orientation})
					local meta = minetest.get_meta(node_pos)
					meta:set_string("portal_frame1", minetest.pos_to_string(pos1))
					meta:set_string("portal_frame2", minetest.pos_to_string(pos2))
					meta:set_string("portal_time", tostring(0))
					meta:set_string("portal_target", "")
				else
					if ENABLE_NETHER_PORTAL_CROSS then
						table.insert(portal_cross, node_pos)
						minetest.set_node(node_pos, {name = "mcl_portals:portal_cross"})
					end
				end
			end
			lit_portals = lit_portals + 1
		else
			for i = 1, node_counter do
				local node_pos = node_list[i]
				local meta = minetest.get_meta(node_pos)
				meta:set_string("portal_time", "")
			end
		end
	end

	return lit_portals
end
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

-- teleportation cooloff for some seconds, to prevent back-and-forth teleportation
local function teleport_cooloff(obj)
	minetest.after(TELEPORT_COOLOFF, function(o)
		portal_cooloff[o] = false
	end, obj)
end

-- teleport function
local function teleport(obj, pos)
	if (not obj:get_luaentity()) and  (not obj:is_player()) then
		return
	end

	local objpos = obj:get_pos()
	if objpos == nil then
		return
	end

	if portal_cooloff[obj] then
		return
	end
	-- If player stands, player is at ca. something+0.5
	-- which might cause precision problems, so we used ceil.
	objpos.y = math.ceil(objpos.y)

	if minetest.get_node(objpos).name ~= "mcl_portals:portal" then
		return
	end

	local meta = minetest.get_meta(pos)
	local delta_time = minetest.get_us_time() - (tonumber(meta:get_string("portal_time")) or 0)
	local target = minetest.string_to_pos(meta:get_string("portal_target"))
	if delta_time > DESTINATION_EXPIRES or target == nil then
		-- ares still not emerged - retry after a second
		return minetest.after(1, teleport, obj, pos)
	end

	-- Teleport
	obj:set_pos(target)
	if obj:is_player() then
		mcl_worlds.dimension_change(obj, mcl_worlds.pos_to_dimension(target))
		minetest.sound_play("mcl_portals_teleport", {pos=target, gain=0.5, max_hear_distance = 16}, true)
	end

	-- Enable teleportation cooloff for some seconds, to prevent back-and-forth teleportation
	teleport_cooloff(obj)
	portal_cooloff[obj] = true
	if obj:is_player() then
		local name = obj:get_player_name()
		minetest.log("action", "[mcl_portal] "..name.." teleported to Nether portal at "..minetest.pos_to_string(target)..".")
	end
end


local function prepare_target(pos)
	local meta, us_time = minetest.get_meta(pos), minetest.get_us_time()
	local portal_time = tonumber(meta:get_string("portal_time")) or 0
	local delta_time_us = us_time - portal_time
	local pos1, pos2 = minetest.string_to_pos(meta:get_string("portal_frame1")), minetest.string_to_pos(meta:get_string("portal_frame2"))
	if delta_time_us <= DESTINATION_EXPIRES then
		-- destination point must be still cached according to https://minecraft.gamepedia.com/Nether_portal
		for x = pos1.x, pos2.x do
			for y = pos1.y, pos2.y do
				for z = pos1.z, pos2.z do
					minetest.get_meta({x = x, y = y, z = z}):set_string("portal_time", tostring(us_time))
				end
			end
		end
		return
	end

	-- No cached destination point.
	find_or_create_portal(pos)
end

function mcl_portals.teleport_through_nether_portal(obj, portal_pos)
	-- Prevent quick back-and-forth teleportation
	if portal_cooloff[obj] then
		return
	end
	prepare_target(portal_pos)
	minetest.after(TELEPORT_DELAY, teleport, obj, portal_pos)
end

minetest.register_abm({
	label = "Nether portal teleportation and particles",
	nodenames = {"mcl_portals:portal", "mcl_portals:portal_cross"},
	interval = 2,
	chance = 1,
	action = function(pos, node)
		minetest.add_particlespawner({
			amount = 32,
			time = 3,
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
			-- texture = "mcl_portals_particle" .. rng:next(1,5) .. ".png",
			texture = "mcl_particles_teleport.png",
		})
		for _,obj in ipairs(minetest.get_objects_inside_radius(pos,1)) do		--maikerumine added for objects to travel
			local lua_entity = obj:get_luaentity() --maikerumine added for objects to travel
			if (obj:is_player() or lua_entity) and (not teleporting_objects[obj] or minetest.get_us_time()-teleporting_objects[obj] > 10000000) then
				teleporting_objects[obj]=minetest.get_us_time()
				mcl_portals.teleport_through_nether_portal(obj, pos)
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
	on_destruct = mcl_portals.destroy_nether_portal,
	_on_ignite = function(user, pointed_thing)
		local x, y, z = pointed_thing.under.x, pointed_thing.under.y, pointed_thing.under.z
		-- Check empty spaces around obsidian and light all frames found:
		local portals_placed =0
		if ENABLE_NETHER_PORTAL_ANY_SHAPE then
			portals_placed = portals_placed +
				mcl_portals.light_nether_portal_free_shape({x = x - 1, y = y, z = z}) + mcl_portals.light_nether_portal_free_shape({x = x + 1, y = y, z = z}) +
				mcl_portals.light_nether_portal_free_shape({x = x, y = y - 1, z = z}) + mcl_portals.light_nether_portal_free_shape({x = x, y = y + 1, z = z}) +
				mcl_portals.light_nether_portal_free_shape({x = x, y = y, z = z - 1}) + mcl_portals.light_nether_portal_free_shape({x = x, y = y, z = z + 1})
		else
			portals_placed = portals_placed + 
				mcl_portals.light_nether_portal({x = x - 1, y = y, z = z}) + mcl_portals.light_nether_portal({x = x + 1, y = y, z = z}) +
				mcl_portals.light_nether_portal({x = x, y = y - 1, z = z}) + mcl_portals.light_nether_portal({x = x, y = y + 1, z = z}) +
				mcl_portals.light_nether_portal({x = x, y = y, z = z - 1}) + mcl_portals.light_nether_portal({x = x, y = y, z = z + 1})
		end
		if portals_placed > 0 then
			minetest.log("action", "[mcl_portal] Nether portal activated at "..minetest.pos_to_string({x=x,y=y,z=z})..".")
			if minetest.get_modpath("doc") then
				doc.mark_entry_as_revealed(user:get_player_name(), "nodes", "mcl_portals:portal")

				-- Achievement for finishing a Nether portal TO the Nether
				local dim = mcl_worlds.pos_to_dimension({x=x, y=y, z=z})
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


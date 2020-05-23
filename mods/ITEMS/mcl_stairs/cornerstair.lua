-- Corner stairs handling

-- This code originally copied from the [mcstair] mod and merged into this mod.
-- This file is licensed under CC0.

mcl_stairs.cornerstair = {}

local get_stair_param = function(node)
	local stair = minetest.get_item_group(node.name, "stair")
	local param = node.param2 % 24
	if stair == 0 or (param > 3 and param < 20) then
		return
	elseif stair == 1 then
		return param
	elseif stair == 2 then
		if param < 12 then
			return param + 4
		else
			return param - 4
		end
	elseif stair == 3 then
		if param < 12 then
			return param + 8
		else
			return param - 8
		end
	end
end

--[[
mcl_stairs.cornerstair.add(name, stairtiles)

NOTE: This function is used internally. If you register a stair, this function is already called, no
need to call it again!

Usage:
* name is the name of the node to make corner stairs for.
* stairtiles is optional, can specify textures for inner and outer stairs. 3 data types are accepted:
    * string: one of:
        * "default": Use same textures as original node
        * "woodlike": Take first frame of the original tiles, then take a triangle piece
                      of the texture, rotate it by 90° and overlay it over the original texture
    * table: Specify textures explicitly. Table of tiles to override textures for
             inner and outer stairs. Table format:
                 { tiles_def_for_outer_stair, tiles_def_for_inner_stair }
    * nil: Equivalent to "default"
]]

function mcl_stairs.cornerstair.add(name, stairtiles)
	local node_def = minetest.registered_nodes[name]
	local outer_tiles
	local inner_tiles
	if stairtiles == "woodlike" then
		outer_tiles = table.copy(node_def.tiles)
		inner_tiles = table.copy(node_def.tiles)
		for i=2,6 do
			if outer_tiles[i] == nil then
				outer_tiles[i] = outer_tiles[i-1]
			end
			if inner_tiles[i] == nil then
				inner_tiles[i] = inner_tiles[i-1]
			end
		end
		local t = node_def.tiles[1]
		outer_tiles[1] = t.."^("..t.."^[transformR90^mcl_stairs_turntexture.png^[makealpha:255,0,255)"
		outer_tiles[2] = t.."^("..t.."^mcl_stairs_turntexture.png^[transformR270^[makealpha:255,0,255)"
		outer_tiles[3] = t
		inner_tiles[1] = t.."^("..t.."^[transformR90^(mcl_stairs_turntexture.png^[transformR180)^[makealpha:255,0,255)"
		inner_tiles[2] = t.."^("..t.."^[transformR270^(mcl_stairs_turntexture.png^[transformR90)^[makealpha:255,0,255)"
		inner_tiles[3] = t
	elseif stairtiles == nil or stairtiles == "default" then
		outer_tiles = node_def.tiles
		inner_tiles = node_def.tiles
	else
		outer_tiles = stairtiles[1]
		inner_tiles = stairtiles[2]
	end
	local outer_groups = table.copy(node_def.groups)
	outer_groups.not_in_creative_inventory = 1
	local inner_groups = table.copy(outer_groups)
	outer_groups.stair = 2
	outer_groups.not_in_craft_guide = 1
	inner_groups.stair = 3
	inner_groups.not_in_craft_guide = 1
	local drop = node_def.drop or name

	minetest.override_item(name, {
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local node = minetest.get_node(pos)
			if node.param2 == 0 then
				local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z + 1}))
				if param then
					if param == 3 or param == 7 or param == 8 then
						local param = get_stair_param(minetest.get_node({x = pos.x + 1, y = pos.y, z = pos.z}))
						if not param or (param ~= 0 and param ~= 4 and param ~= 9) then
							minetest.swap_node(pos, {name = name.."_outer", param2 = 0})
							return
						end
					elseif param == 1 or param == 6 or param == 9 then
						local param = get_stair_param(minetest.get_node({x = pos.x - 1, y = pos.y, z = pos.z}))
						if not param or (param ~= 0 and param ~= 5 and param ~= 8) then
							minetest.swap_node(pos, {name = name.."_outer", param2 = 1})
							return
						end
					end
				end
				local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z - 1}))
				if param then
					if param == 1 or param == 5 or param == 10 then
						local param = get_stair_param(minetest.get_node({x = pos.x + 1, y = pos.y, z = pos.z}))
						if not param or (param ~= 0 and param ~= 4 and param ~= 9) then
							minetest.swap_node(pos, {name = name.."_inner", param2 = 1})
							return
						end
					elseif param == 3 or param == 4 or param == 11 then
						local param = get_stair_param(minetest.get_node({x = pos.x - 1, y = pos.y, z = pos.z}))
						if not param or (param ~= 0 and param ~= 5 and param ~= 8) then
							minetest.swap_node(pos, {name = name.."_inner", param2 = 0})
							return
						end
					end
				end
			elseif node.param2 == 1 then
				local param = get_stair_param(minetest.get_node({x = pos.x + 1, y = pos.y, z = pos.z}))
				if param then
					if param == 2 or param == 7 or param == 10 then
						local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z + 1}))
						if not param or (param ~= 1 and param ~= 6 and param ~= 9) then
							minetest.swap_node(pos, {name = name.."_outer", param2 = 2})
							return
						end
					elseif param == 0 or param == 4 or param == 9 then
						local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z - 1}))
						if not param or (param ~= 1 and param ~= 5 and param ~= 10) then
							minetest.swap_node(pos, {name = name.."_outer", param2 = 1})
							return
						end
					end
				end
				local param = get_stair_param(minetest.get_node({x = pos.x - 1, y = pos.y, z = pos.z}))
				if param then
					if param == 0 or param == 5 or param == 8 then
						local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z + 1}))
						if not param or (param ~= 1 and param ~= 6 and param ~= 9) then
							minetest.swap_node(pos, {name = name.."_inner", param2 = 1})
							return
						end
					elseif param == 2 or param == 6 or param == 11 then
						local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z - 1}))
						if not param or (param ~= 1 and param ~= 5 and param ~= 10) then
							minetest.swap_node(pos, {name = name.."_inner", param2 = 2})
							return
						end
					end
				end
			elseif node.param2 == 2 then
				local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z + 1}))
				if param then
					if param == 1 or param == 6 or param == 9 then
						local param = get_stair_param(minetest.get_node({x = pos.x + 1, y = pos.y, z = pos.z}))
						if not param or (param ~= 2 and param ~= 7 and param ~= 10) then
							minetest.swap_node(pos, {name = name.."_inner", param2 = 2})
							return
						end
					elseif param == 3 or param == 7 or param == 8 then
						local param = get_stair_param(minetest.get_node({x = pos.x - 1, y = pos.y, z = pos.z}))
						if not param or (param ~= 2 and param ~= 6 and param ~= 11) then
							minetest.swap_node(pos, {name = name.."_inner", param2 = 3})
							return
						end
					end
				end
				local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z - 1}))
				if param then
					if param == 3 or param == 4 or param == 11 then
						local param = get_stair_param(minetest.get_node({x = pos.x + 1, y = pos.y, z = pos.z}))
						if not param or (param ~= 2 and param ~= 7 and param ~= 10) then
							minetest.swap_node(pos, {name = name.."_outer", param2 = 3})
							return
						end
					elseif param == 1 or param == 5 or param == 10 then
						local param = get_stair_param(minetest.get_node({x = pos.x - 1, y = pos.y, z = pos.z}))
						if not param or (param ~= 2 and param ~= 6 and param ~= 11) then
							minetest.swap_node(pos, {name = name.."_outer", param2 = 2})
							return
						end
					end
				end
			elseif node.param2 == 3 then
				local param = get_stair_param(minetest.get_node({x = pos.x + 1, y = pos.y, z = pos.z}))
				if param then
					if param == 0 or param == 4 or param == 9 then
						local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z + 1}))
						if not param or (param ~= 3 and param ~= 7 and param ~= 8) then
							minetest.swap_node(pos, {name = name.."_inner", param2 = 0})
							return
						end
					elseif param == 2 or param == 7 or param == 10 then
						local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z - 1}))
						if not param or (param ~= 3 and param ~= 4 and param ~= 11) then
							minetest.swap_node(pos, {name = name.."_inner", param2 = 3})
							return
						end
					end
				end
				local param = get_stair_param(minetest.get_node({x = pos.x - 1, y = pos.y, z = pos.z}))
				if param then
					if param == 2 or param == 6 or param == 11 then
						local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z + 1}))
						if not param or (param ~= 3 and param ~= 7 and param ~= 8) then
							minetest.swap_node(pos, {name = name.."_outer", param2 = 3})
							return
						end
					elseif param == 0 or param == 5 or param == 8 then
						local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z - 1}))
						if not param or (param ~= 3 and param ~= 4 and param ~= 11) then
							minetest.swap_node(pos, {name = name.."_outer", param2 = 0})
							return
						end
					end
				end
			elseif node.param2 == 20 then
				local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z + 1}))
				if param then
					if param == 21 or param == 18 or param == 13 then
						local param = get_stair_param(minetest.get_node({x = pos.x + 1, y = pos.y, z = pos.z}))
						if not param or (param ~= 20 and param ~= 17 and param ~= 12) then
							minetest.swap_node(pos, {name = name.."_outer", param2 = 21})
							return
						end
					elseif param == 23 or param == 19 or param == 12 then
						local param = get_stair_param(minetest.get_node({x = pos.x - 1, y = pos.y, z = pos.z}))
						if not param or (param ~= 20 and param ~= 16 and param ~= 13) then
							minetest.swap_node(pos, {name = name.."_outer", param2 = 20})
							return
						end
					end
				end
				local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z - 1}))
				if param then
					if param == 23 or param == 16 or param == 15 then
						local param = get_stair_param(minetest.get_node({x = pos.x + 1, y = pos.y, z = pos.z}))
						if not param or (param ~= 20 and param ~= 17 and param ~= 12) then
							minetest.swap_node(pos, {name = name.."_inner", param2 = 20})
							return
						end
					elseif param == 21 or param == 17 or param == 14 then
						local param = get_stair_param(minetest.get_node({x = pos.x - 1, y = pos.y, z = pos.z}))
						if not param or (param ~= 20 and param ~= 16 and param ~= 13) then
							minetest.swap_node(pos, {name = name.."_inner", param2 = 21})
							return
						end
					end
				end
			elseif node.param2 == 21 then
				local param = get_stair_param(minetest.get_node({x = pos.x + 1, y = pos.y, z = pos.z}))
				if param then
					if param == 20 or param == 17 or param == 12 then
						local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z + 1}))
						if not param or (param ~= 21 and param ~= 18 and param ~= 13) then
							minetest.swap_node(pos, {name = name.."_inner", param2 = 21})
							return
						end
					elseif param == 22 or param == 18 or param == 15 then
						local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z - 1}))
						if not param or (param ~= 21 and param ~= 17 and param ~= 14) then
							minetest.swap_node(pos, {name = name.."_inner", param2 = 22})
							return
						end
					end
				end
				local param = get_stair_param(minetest.get_node({x = pos.x - 1, y = pos.y, z = pos.z}))
				if param then
					if param == 22 or param == 19 or param == 14 then
						local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z + 1}))
						if not param or (param ~= 21 and param ~= 18 and param ~= 13) then
							minetest.swap_node(pos, {name = name.."_outer", param2 = 22})
							return
						end
					elseif param == 20 or param == 16 or param == 13 then
						local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z - 1}))
						if not param or (param ~= 21 and param ~= 17 and param ~= 14) then
							minetest.swap_node(pos, {name = name.."_outer", param2 = 21})
							return
						end
					end
				end
			elseif node.param2 == 22 then
				local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z + 1}))
				if param then
					if param == 23 or param == 19 or param == 12 then
						local param = get_stair_param(minetest.get_node({x = pos.x + 1, y = pos.y, z = pos.z}))
						if not param or (param ~= 22 and param ~= 18 and param ~= 15) then
							minetest.swap_node(pos, {name = name.."_inner", param2 = 23})
							return
						end
					elseif param == 21 or param == 18 or param == 13 then
						local param = get_stair_param(minetest.get_node({x = pos.x - 1, y = pos.y, z = pos.z}))
						if not param or (param ~= 22 and param ~= 19 and param ~= 14) then
							minetest.swap_node(pos, {name = name.."_inner", param2 = 22})
							return
						end
					end
				end
				local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z - 1}))
				if param then
					if param == 21 or param == 17 or param == 14 then
						local param = get_stair_param(minetest.get_node({x = pos.x + 1, y = pos.y, z = pos.z}))
						if not param or (param ~= 22 and param ~= 18 and param ~= 15) then
							minetest.swap_node(pos, {name = name.."_outer", param2 = 22})
							return
						end
					elseif param == 23 or param == 16 or param == 15 then
						local param = get_stair_param(minetest.get_node({x = pos.x - 1, y = pos.y, z = pos.z}))
						if not param or (param ~= 22 and param ~= 19 and param ~= 14) then
							minetest.swap_node(pos, {name = name.."_outer", param2 = 23})
							return
						end
					end
				end
			elseif node.param2 == 23 then
				local param = get_stair_param(minetest.get_node({x = pos.x + 1, y = pos.y, z = pos.z}))
				if param then
					if param == 22 or param == 18 or param == 15 then
						local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z + 1}))
						if not param or (param ~= 23 and param ~= 19 and param ~= 12) then
							minetest.swap_node(pos, {name = name.."_outer", param2 = 23})
							return
						end
					elseif param == 20 or param == 17 or param == 12 then
						local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z - 1}))
						if not param or (param ~= 23 and param ~= 16 and param ~= 15) then
							minetest.swap_node(pos, {name = name.."_outer", param2 = 20})
							return
						end
					end
				end
				local param = get_stair_param(minetest.get_node({x = pos.x - 1, y = pos.y, z = pos.z}))
				if param then
					if param == 20 or param == 16 or param == 13 then
						local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z + 1}))
						if not param or (param ~= 23 and param ~= 19 and param ~= 12) then
							minetest.swap_node(pos, {name = name.."_inner", param2 = 20})
							return
						end
					elseif param == 22 or param == 19 or param == 14 then
						local param = get_stair_param(minetest.get_node({x = pos.x, y = pos.y, z = pos.z - 1}))
						if not param or (param ~= 23 and param ~= 16 and param ~= 15) then
							minetest.swap_node(pos, {name = name.."_inner", param2 = 23})
							return
						end
					end
				end
			end
		end
	})
	minetest.register_node(":"..name.."_outer", {
		description = node_def.description,
		_doc_items_create_entry = false,
		drawtype = "nodebox",
		tiles = outer_tiles,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = outer_groups,
		sounds = node_def.sounds,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0, 0.5, 0.5}
			}
		},
		drop = drop,
		_mcl_hardness = node_def._mcl_hardness,
		on_rotate = false,
	})
	minetest.register_node(":"..name.."_inner", {
		description = node_def.description,
		_doc_items_create_entry = false,
		drawtype = "nodebox",
		tiles = inner_tiles,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = inner_groups,
		sounds = node_def.sounds,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
				{-0.5, 0, -0.5, 0, 0.5, 0}
			}
		},
		drop = drop,
		_mcl_hardness = node_def._mcl_hardness,
		on_rotate = false,
	})

	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", name, "nodes", name.."_inner")
		doc.add_entry_alias("nodes", name, "nodes", name.."_outer")
	end
end

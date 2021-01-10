mcl_spawn = {}

local S = minetest.get_translator("mcl_spawn")
local mg_name = minetest.get_mapgen_setting("mg_name")

-- Parameters
-------------

-- Resolution of search grid in nodes.
local res = 64
-- Number of points checked in the square search grid (edge * edge).
local checks = 128 * 128
-- Starting point for biome checks. This also sets the y co-ordinate for all
-- points checked, so the suitable biomes must be active at this y.
local start_pos = minetest.setting_get_pos("static_spawnpoint") or {x = 0, y = 8, z = 0}
local current_pos = start_pos
-- Table of suitable biomes
local biome_ids
minetest.register_on_mods_loaded(function()
	biome_ids = {
		minetest.get_biome_id("ColdTaiga"),
		minetest.get_biome_id("Taiga"),
		minetest.get_biome_id("MegaTaiga"),
		minetest.get_biome_id("MegaSpruceTaiga"),
		minetest.get_biome_id("Plains"),
		minetest.get_biome_id("SunflowerPlains"),
		minetest.get_biome_id("Forest"),
		minetest.get_biome_id("FlowerForest"),
		minetest.get_biome_id("BirchForest"),
		minetest.get_biome_id("BirchForestM"),
		minetest.get_biome_id("Jungle"),
		minetest.get_biome_id("JungleM"),
		minetest.get_biome_id("JungleEdge"),
		minetest.get_biome_id("JungleEdgeM"),
		minetest.get_biome_id("Savanna"),
		minetest.get_biome_id("SavannaM"),
	}
	end
)
-- Bed spawning offsets
local node_search_list =
	{
	--[[1]]	{x =  0, y = 0, z = -1},	--
	--[[2]]	{x = -1, y = 0, z =  0},	--
	--[[3]]	{x = -1, y = 0, z =  1},	--
	--[[4]]	{x =  0, y = 0, z =  2},	-- z^ 8 4 9
	--[[5]]	{x =  1, y = 0, z =  1},	--  | 3   5
	--[[6]]	{x =  1, y = 0, z =  0},	--  | 2 * 6
	--[[7]]	{x = -1, y = 0, z = -1},	--  | 7 1 A
	--[[8]]	{x = -1, y = 0, z =  2},	--  +----->
	--[[9]]	{x =  1, y = 0, z =  2},	--	x
	--[[A]]	{x =  1, y = 0, z = -1},	--
	--[[B]]	{x =  0, y = 1, z =  0},	--
	--[[C]]	{x =  0, y = 1, z =  1},	--
	}

-- End of parameters
--------------------


-- Direction table

local dirs = {
	{x = 0, y = 0, z = 1},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 0, z = -1},
	{x = 1, y = 0, z = 0},
}


-- Initial variables

local edge_len = 1
local edge_dist = 0
local dir_step = 0
local dir_ind = 1
local searched = mg_name == "v6" or mg_name == "singlenode" or
	minetest.settings:get("static_spawnpoint")
local success = false
local world_spawn_pos = {}


-- Get world 'mapgen_limit' and 'chunksize' to calculate 'spawn_limit'.
-- This accounts for how mapchunks are not generated if they or their shell exceed
-- 'mapgen_limit'.

local mapgen_limit = tonumber(minetest.get_mapgen_setting("mapgen_limit"))
local chunksize = tonumber(minetest.get_mapgen_setting("chunksize"))
local spawn_limit = math.max(mapgen_limit - (chunksize + 1) * 16, 0)


--Functions
-----------

-- Get next position on square search spiral

local function next_pos()
	if edge_dist == edge_len then
		edge_dist = 0
		dir_ind = dir_ind + 1
		if dir_ind == 5 then
			dir_ind = 1
		end
		dir_step = dir_step + 1
		edge_len = math.floor(dir_step / 2) + 1
	end

	local dir = dirs[dir_ind]
	local move = vector.multiply(dir, res)

	edge_dist = edge_dist + 1

	return vector.add(current_pos, move)
end


-- Spawn position search

local function search()
	for iter = 1, checks do
		local biome_data = minetest.get_biome_data(current_pos)
		-- Sometimes biome_data is nil
		local biome = biome_data and biome_data.biome
		for id_ind = 1, #biome_ids do
			local biome_id = biome_ids[id_ind]
			if biome == biome_id then
				local spawn_y = minetest.get_spawn_level(current_pos.x, current_pos.z)

				if spawn_y then
					world_spawn_pos = {x = current_pos.x, y = spawn_y, z = current_pos.z}
					return true
				end
			end
		end

		current_pos = next_pos()
		-- Check for position being outside world edge
		if math.abs(current_pos.x) > spawn_limit or math.abs(current_pos.z) > spawn_limit then
			return false
		end
	end

	return false
end

mcl_spawn.get_world_spawn_pos = function()
	if not searched then
		success = search()
		searched = true
		if success then
			minetest.log("action", "[mcl_spawn] Dynamic world spawn determined to be "..minetest.pos_to_string(world_spawn_pos))
		end
	end
	if success then
		return world_spawn_pos
	end
	minetest.log("action", "[mcl_spawn] Failed to determine dynamic world spawn!")
	return start_pos
end

-- Returns a spawn position of player.
-- If player is nil or not a player, a world spawn point is returned.
-- The second return value is true if returned spawn point is player-chosen,
-- false otherwise.
mcl_spawn.get_bed_spawn_pos = function(player)
	local spawn, custom_spawn = nil, false
	if player ~= nil and player:is_player() then
		local attr = player:get_meta():get_string("mcl_beds:spawn")
		if attr ~= nil and attr ~= "" then
			spawn = minetest.string_to_pos(attr)
			custom_spawn = true
		end
	end
	if not spawn or spawn == "" then
		spawn = mcl_spawn.get_world_spawn_pos()
		custom_spawn = false
	end
	return spawn, custom_spawn
end

-- Sets the player's spawn position to pos.
-- Set pos to nil to clear the spawn position.
-- If message is set, informs the player with a chat message when the spawn position
-- changed.
mcl_spawn.set_spawn_pos = function(player, pos, message)
	local spawn_changed = false
	local meta = player:get_meta()
	if pos == nil then
		if meta:get_string("mcl_beds:spawn") ~= "" then
			spawn_changed = true
			if message then
				minetest.chat_send_player(player:get_player_name(), S("Respawn position cleared!"))
			end
		end
		meta:set_string("mcl_beds:spawn", "")
	else
		local oldpos = minetest.string_to_pos(meta:get_string("mcl_beds:spawn"))
		meta:set_string("mcl_beds:spawn", minetest.pos_to_string(pos))
		if oldpos then
			-- We don't bother sending a message if the new spawn pos is basically the same
			spawn_changed = vector.distance(pos, oldpos) > 0.1
		else
			-- If it wasn't set and now it will be set, it means it is changed
			spawn_changed = true
		end
		if spawn_changed and message then
			minetest.chat_send_player(player:get_player_name(), S("New respawn position set!"))
		end
	end
	return spawn_changed
end

local function get_far_node(pos)
	local node = minetest.get_node(pos)
	if node.name ~= "ignore" then
		return node
	end
	minetest.get_voxel_manip():read_from_map(pos, pos)
	return minetest.get_node(pos)
end

local function good_for_respawn(pos)
	local node0 = get_far_node({x = pos.x, y = pos.y - 1, z = pos.z})
	local node1 = get_far_node({x = pos.x, y = pos.y, z = pos.z})
	local node2 = get_far_node({x = pos.x, y = pos.y + 1, z = pos.z})
	local def0 = minetest.registered_nodes[node0.name]
	local def1 = minetest.registered_nodes[node1.name]
	local def2 = minetest.registered_nodes[node2.name]
	return def0.walkable and (not def1.walkable) and (not def2.walkable) and
		(def1.damage_per_second == nil or def2.damage_per_second <= 0) and
		(def1.damage_per_second == nil or def2.damage_per_second <= 0)
end

mcl_spawn.get_player_spawn_pos = function(player)
	local pos, custom_spawn = mcl_spawn.get_bed_spawn_pos(player)
	if pos and custom_spawn then
		-- Check if bed is still there
		local node_bed = get_far_node(pos)
		local bgroup = minetest.get_item_group(node_bed.name, "bed")
		if bgroup ~= 1 and bgroup ~= 2 then
			-- Bed is destroyed:
			if player ~= nil and player:is_player() then
				player:get_meta():set_string("mcl_beds:spawn", "")
			end
			minetest.chat_send_player(player:get_player_name(), S("Your spawn bed was missing or blocked."))
			return mcl_spawn.get_world_spawn_pos(), false
		end

		-- Find spawning position on/near the bed free of solid or damaging blocks iterating a square spiral 15x15:

		local dir = minetest.facedir_to_dir(minetest.get_node(pos).param2)
		local offset
		for _, o in ipairs(node_search_list) do
			if dir.z == -1 then
				offset = {x =  o.x, y = o.y,  z =  o.z}
			elseif dir.z == 1 then
				offset = {x = -o.x, y = o.y,  z = -o.z}
			elseif dir.x == -1 then
				offset = {x =  o.z, y = o.y,  z = -o.x}
			else -- dir.x == 1
				offset = {x = -o.z, y = o.y,  z =  o.x}
			end
			local player_spawn_pos = vector.add(pos, offset)
			if good_for_respawn(player_spawn_pos) then
				return player_spawn_pos, true
			end
		end
		-- We here if we didn't find suitable place for respawn
	end
	return mcl_spawn.get_world_spawn_pos(), false
end

mcl_spawn.spawn = function(player)
	local pos, in_bed = mcl_spawn.get_player_spawn_pos(player)
	player:set_pos(pos)
	return in_bed or success
end

-- Respawn player at specified respawn position
minetest.register_on_respawnplayer(mcl_spawn.spawn)

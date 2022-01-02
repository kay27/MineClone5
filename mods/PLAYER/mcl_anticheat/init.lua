local flights_kick_threshold = 10
local suffocations_kick_threshold = 1

local after                     = minetest.after
local get_connected_players     = minetest.get_connected_players
local get_node                  = minetest.get_node
local get_objects_inside_radius = minetest.get_objects_inside_radius
local get_player_by_name        = minetest.get_player_by_name
local kick_player               = minetest.kick_player
local set_node                  = minetest.set_node

local ceil  = math.ceil
local floor = math.floor

local distance = vector.distance

local window_size = 10
local detection_interval = 1.7
local step_seconds = detection_interval / window_size
local joined_players = {}

local function update_player(player_object)
	if not player_object then return end
	local name = player_object:get_player_name()
	if not name then return end

	local pos = player_object:get_pos()
	local x, y, z = floor(pos.x), floor(pos.y-0.1), floor(pos.z)

	if mcl_playerplus.elytra then
		local elytra = mcl_playerplus.elytra[player_object]
		if elytra and elytra.active then
			return
		end
	end

	local air = get_node({x = x    , y = y    , z = z    }).name == "air"
		and get_node({x = x    , y = y    , z = z + 1}).name == "air"
		and get_node({x = x    , y = y + 1, z = z    }).name == "air"
		and get_node({x = x    , y = y + 1, z = z + 1}).name == "air"
		and get_node({x = x + 1, y = y    , z = z    }).name == "air"
		and get_node({x = x + 1, y = y    , z = z + 1}).name == "air"
		and get_node({x = x + 1, y = y + 1, z = z    }).name == "air"
		and get_node({x = x + 1, y = y + 1, z = z + 1}).name == "air"

	local player_data = {
		pos = pos,
		velocity = player_object:get_velocity(),
		air = air
	}

	if joined_players[name] then
		local window_offset = (joined_players[name].window_offset + 1) % window_size
		joined_players[name].window_offset = window_offset
		joined_players[name][window_offset] = player_data
	else
		joined_players[name] = {
			window_offset = 0,
			[0] = player_data,
		}
	end
end

local function check_player(name)
	if minetest.is_creative_enabled(name) then return end
	local data = joined_players[name]
	if not data then return end
	if not data[0] then return end

	local always_air = true
	local falling = data[0].velocity.y < 0
	for i = 0, window_size - 1 do
		local derivative = data[i]
		local not_enough_data = not derivative
		if not_enough_data then
			return
		end
		always_air = always_air and derivative.air
		falling = falling or derivative.velocity.y < 0
	end
	if always_air and not falling then
		-- fly detected
		if not data.flights then
			data.flights = 1
		else
			data.flights = data.flights + 1
			if data.flights >= flights_kick_threshold then
				kick_player(name, "flights")
			end
		end
		local obj_player = minetest.get_player_by_name(name)
		if not obj_player then
			kick_player(name, "flights")
		end
		local velocity = obj_player:get_velocity()
		local pos = obj_player:get_pos()
		local x, y, z = floor(pos.x), floor(pos.y), floor(pos.z)
		while (     get_node({x = x    , y = y, z = z    }).name == "air"
			and get_node({x = x    , y = y, z = z + 1}).name == "air"
			and get_node({x = x + 1, y = y, z = z    }).name == "air"
			and get_node({x = x + 1, y = y, z = z + 1}).name == "air"
		) do
			y = y - 1
		end
		obj_player:set_velocity({x = velocity.x, y = -10, z = velocity.z})
		obj_player:set_pos({x = x, y = y + 0.5, z = z})
	end
end

local function remove_player(player_object)
	if not player_object then return end
	local name = player_object:get_player_name()
	if not name then return end
	minetest.after(step_seconds, function()
		joined_players[name] = nil
	end)
end

local function step()
	for _, player in pairs(get_connected_players()) do
		update_player(player)
		check_player(player:get_player_name())
	end
	after(step_seconds, step)
end

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	if not oldnode then return end
	if not placer then return end
	if oldnode.name ~= "air" then return end
	if not placer:is_player() then return end
	local placer_pos = placer:get_pos()
	local placer_distance = distance(pos, placer_pos)
	if placer_distance < 13 then return end
	local is_choker = false
	for _, object in pairs(get_objects_inside_radius(pos, 2)) do
		if object and object:is_player() then
			local player_head_pos = object:get_pos()
			player_head_pos.y = player_head_pos.y + 1.5
			local player_head_distance = distance(pos, player_head_pos)
			if player_head_distance < 0.7 then
				after(0.05, function(node)
					set_node(pos, node)
				end, oldnode)
				is_choker = true
				break
			end
		end
	end
	if not is_choker then return end
	-- cheater choked the player from distance greater than 12:
	local name = placer:get_player_name()
	local data = joined_players[name]
	if not data then
		joined_players[name].suffocations = 1
		data = joined_players[name]
	else
		if not data.suffocations then
			data.suffocations = 1
		else
			data.suffocations = data.suffocations + 1
		end
	end
	if data.suffocations >= suffocations_kick_threshold then
		kick_player(name, "choker")
	end
end)

minetest.register_on_joinplayer(update_player)

minetest.register_on_leaveplayer(remove_player)

after(step_seconds, step)

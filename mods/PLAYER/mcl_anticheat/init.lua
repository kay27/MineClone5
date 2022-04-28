local modpath = minetest.get_modpath(minetest.get_current_modname())
dofile(modpath .. "/ratelimit.lua")

local enable_anticheat = true
local kick_cheaters = false
local kick_threshold = 10

local after                     = minetest.after
local get_connected_players     = minetest.get_connected_players
local get_node                  = minetest.get_node
local get_objects_inside_radius = minetest.get_objects_inside_radius
local get_player_by_name        = minetest.get_player_by_name
local kick_player               = minetest.kick_player
local set_node                  = minetest.set_node
local find_nodes_in_area        = minetest.find_nodes_in_area

local ceil  = math.ceil
local floor = math.floor
local vector_length = vector.length

local distance = vector.distance

local window_size = 8
local detection_interval = 1.6
local step_seconds = detection_interval / window_size
local joined_players = {}
local ip_to_players = {}
local player_name_to_ip = {}
local player_doesnt_move = {}
local ban_next_time = {}

local function update_settings()
	enable_anticheat = minetest.settings:get_bool("enable_anticheat", true)
	kick_cheaters = minetest.settings:get_bool("kick_cheaters", false)
	kick_threshold = tonumber(minetest.settings:get("kick_threshold") or 10)
	minetest.after(10, update_settings)
end
update_settings()

local function update_player(player_object)
	if not player_object then return end
	local name = player_object:get_player_name()
	if not name then return end

	local pos = player_object:get_pos()
	local x, z = floor(pos.x), floor(pos.z)
	local feet_y, head_y = floor(pos.y-0.1), floor(pos.y + 1.49)

	if mcl_playerplus.elytra then
		local elytra = mcl_playerplus.elytra[name]
		if elytra and elytra.active then
			return
		end
	end

	local air = #find_nodes_in_area({x = x, y = feet_y, z = z}, {x = x + 1, y = feet_y + 1, z = z + 1}, "air") == 8
	if air then
		local objects = get_objects_inside_radius({x = pos.x, y = pos.y - 0.6, z = pos.z}, 1.3)
		for _, obj in pairs(objects) do
			if not obj:is_player() and obj:get_luaentity() and obj:get_luaentity()._cmi_is_mob then
				air = false
				break
			end
		end
	end

	local noclip = #find_nodes_in_area({x = x, y = head_y, z = z}, {x = x + 1, y = head_y + 1, z = z + 1}, "group:opaque") == 8

	local velocity = player_object:get_velocity()
	if vector_length(velocity) < 0.00000001 then
		player_doesnt_move[name] = (player_doesnt_move[name] or 0) + 1
	else
		player_doesnt_move[name] = 0
	end
	local player_data = {
		pos = pos,
		velocity = velocity,
		air = air,
		noclip = noclip,
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
	local always_noclip = true
	local falling = data[0].velocity.y < 0
	for i = 0, window_size - 1 do
		local derivative = data[i]
		local not_enough_data = not derivative
		if not_enough_data then
			return
		end
		always_air = always_air and derivative.air
		always_noclip = always_noclip and derivative.noclip
		falling = falling or derivative.velocity.y < 0
	end
	if always_air and not falling then
		-- fly detected
		if not data.flights then
			data.flights = 1
		else
			data.flights = data.flights + 1
		end
		if kick_cheaters and kick_threshold and kick_threshold > 0 and data.flights >= kick_threshold then
			kick_player(name, "flights")
			return
		end
		local obj_player = minetest.get_player_by_name(name)
		if not obj_player then
			return
		end
		local velocity = obj_player:get_velocity()
		local pos = obj_player:get_pos()
		local x, y, z = floor(pos.x), floor(pos.y), floor(pos.z)
		while #find_nodes_in_area({x = x, y = y, z = z}, {x = x + 1, y = y, z = z + 1}, "air") == 4 do
			y = y - 1
		end
		obj_player:set_pos({x = x, y = y + 0.5, z = z})
		obj_player:set_velocity({x = 0, y = 0, z = 0})
		obj_player:set_acceleration({x = 0, y = 0, z = 0})
	end
	if always_noclip then
		-- noclip detected
		local obj_player = minetest.get_player_by_name(name)
		if not obj_player then
			return
		end
		local pos = obj_player:get_pos()
		local x, y, z = floor(pos.x), floor(pos.y+1.49), floor(pos.z)
		while #find_nodes_in_area({x = x, y = y, z = z}, {x = x + 1, y = y + 1, z = z + 1}, "group:opaque") >= 7 do
			y = y + 1
		end
		obj_player:set_pos({x = x, y = y + 0.5, z = z})
		obj_player:set_velocity({x = 0, y = 0, z = 0})
		obj_player:set_acceleration({x = 0, y = 0, z = 0})
	end
end

local function remove_player(player_object)
	if not player_object then return end
	local name = player_object:get_player_name()
	if not name then return end
	local ip = player_name_to_ip[name]
	player_name_to_ip[name] = nil
	if ip then
		local players = ip_to_players[ip]
		if players then
			for k, v in pairs(players) do
				if v == name then
					if k < #players then
						players[k] = players[#players]
					end
					players[#players] = nil
					break
				end
			end
		end
	end
	minetest.after(step_seconds, function()
		player_doesnt_move[name] = nil
		joined_players[name] = nil
	end)
end

local function step()
	if enable_anticheat then
		for _, player in pairs(get_connected_players()) do
			update_player(player)
			check_player(player:get_player_name())
		end
	end
	for ip, players in pairs(ip_to_players) do
		if #players > 2 then
			local first = players[1]
			local should_be_banned = ban_next_time[ip]
			if #players < 6 then
				for _, player_name in pairs(players) do
					if (player_doesnt_move[player_name] or 0) > 1800/step_seconds then
						minetest.kick_player(player_name, "Didn't move during 30 minutes, more than 2 connections from IP " .. ip)
					end
				end
			elseif #players < 10 then
				for _, player_name in pairs(players) do
					if (player_doesnt_move[player_name] or 0) > 600/step_seconds then
						minetest.kick_player(player_name, "Didn't move during 10 minutes, more than 5 connections from IP " .. ip)
					end
				end
			elseif #players < 26 then
				for _, player_name in pairs(players) do
					if should_be_banned then
						minetest.ban_player(player_name)
					else
						if (player_doesnt_move[player_name] or 0) > 90/step_seconds then
							minetest.kick_player(player_name, "Didn't move during 1.5 minutes being connected multiple times")
							ban_next_time[ip] = 1
						end
					end
				end
			elseif #players <= 100 then
				for _, player_name in pairs(players) do
					if should_be_banned then
						minetest.ban_player(player_name)
					else
						minetest.kick_player(player_name, "More than 25 connections from IP address " .. ip)
						ban_next_time[ip] = 1
					end
				end
			else
				for _, player_name in pairs(players) do
					minetest.ban_player(player_name)
				end
			end
		end
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
	if data.suffocations >= kick_threshold then
		kick_player(name, "choker")
	end
end)

minetest.register_on_joinplayer(update_player)

minetest.register_on_leaveplayer(remove_player)

minetest.register_on_authplayer(function(name, ip, is_success)
	if not is_success then return end
	local players = ip_to_players[ip]
	if not players then
		ip_to_players[ip] = {name}
	else
		players[#players + 1] = name
	end
	player_name_to_ip[name] = ip
end)

after(step_seconds, step)

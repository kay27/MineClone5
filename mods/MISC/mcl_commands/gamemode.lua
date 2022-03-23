local S = minetest.get_translator(minetest.get_current_modname())

local gamemode_ids = {
	survival = 1,
	creative = 2,
}

local id_to_gamemode = {}
for gamemode, id in pairs(gamemode_ids) do
	id_to_gamemode[id] = gamemode
end

local creative_mode = 'creative'

local storage = minetest.get_mod_storage()

local player_to_gamemode_id = minetest.deserialize(storage:get_string("player_to_gamemode_id") or "return {}") or {}
minetest.register_on_shutdown(function()
	storage:set_string("player_to_gamemode_id", minetest.serialize(player_to_gamemode_id))
end)

local core_is_creative_enabled = minetest.is_creative_enabled

minetest.is_creative_enabled = function(name)
	local id = player_to_gamemode_id[name]
	if id then
		local gamemode = id_to_gamemode[id]
		if gamemode then
			return gamemode == creative_mode
		end
	end
	return core_is_creative_enabled(name)
end

local registered_functions_on_gamemode_change = {}

local function handle_gamemode_command(player_name, new_gamemode)
	local old_gamemode_id = player_to_gamemode_id[player_name]
	local old_gamemode = old_gamemode_id and id_to_gamemode[old_gamemode_id]
	player_to_gamemode_id[player_name] = gamemode_ids[new_gamemode]
	if old_gamemode ~= new_gamemode then
		for _, function_ref in pairs(registered_functions_on_gamemode_change) do
			 function_ref(player_name, old_gamemode, new_gamemode)
		end
	end
	return true
end

if minetest.registered_chatcommands["gamemode"] then
	minetest.unregister_chatcommand("gamemode")
end

local function get_gamemode_param()
	local param
	local i = 0
	for gamemode, _ in pairs(gamemode_ids) do
		if i == 0 then
			param = "("
		else
			param = param .. " | "
		end
		i = i + 1
		param = param .. gamemode
	end
	if i > 0 then
		param = param .. ") "
	end
	return param
end

minetest.register_chatcommand("gamemode", {
	params = S("@1[<name>]", get_gamemode_param()),
	description = S("Set game mode for player or yourself"),
	privs = {server=true},
	func = function(name, param)
		if (param == "") then
			return false, S("Error: No game mode specified.")
		end
		if (gamemode_ids[param]) then
			handle_gamemode_command(name, param)
		else
			local new_gamemode, player_name = string.match(param, "^([%a]+) ([%a%d_-]+)$")
			if not new_gamemode or not gamemode_ids[new_gamemode] or not player_name then
				return false, S("Invalid usage, see /help @1", "gamemode")
			end
			handle_gamemode_command(player_name, new_gamemode)
		end
	end
})

local action_id_to_index = {}

function mcl_commands.register_on_gamemode_change(action_id, function_ref)
	if action_id_to_index[action_id] then
		minetest.log("warning", "[mcl_command] [gamemode] Duplicate register_on_gamemode_change action_id")
		return
	end
	local new_index = #registered_functions_on_gamemode_change + 1
	registered_functions_on_gamemode_change[new_index] = function_ref
	action_id_to_index[action_id] = new_index
end

function mcl_commands.unregister_on_gamemode_change(action_id)
	local old_index = action_id_to_index[action_id]
	if not old_index then
		minetest.log("warning", "[mcl_command] [gamemode] Can't unregister not registered action_id in unregister_on_gamemode_change")
		return
	end
	table.remove(registered_functions_on_gamemode_change, old_index)
	action_to_id[action_id] = nil
end

mcl_commands.register_on_gamemode_change("check_fly_and_noclip", function(player_name, old_gamemode, new_gamemode)
	if new_gamemode == "creative" then
		local privs = minetest.get_player_privs(player_name)
		if not privs then return end
		privs.fly = true
		privs.noclip = true
		minetest.set_player_privs(player_name, privs)
	elseif new_gamemode == "survival" then
		local privs = minetest.get_player_privs(player_name)
		if not privs then return end
		privs.fly = nil
		privs.noclip = nil
		minetest.set_player_privs(player_name, privs)
	end
end)

local S = minetest.get_translator("mcl_gamemode")
local N = function(s) return s end

mcl_gamemode = {}
mcl_gamemode.modes = {
	[0] = "survival",
	[1] = "creative",
	[2] = "adventure", -- NOT IMPLEMENTED
	[3] = "spectator", -- NOT IMPLEMENTED
}
mcl_gamemode.modes_reverse = {}
for k, v in pairs(mcl_gamemode.modes) do
	mcl_gamemode.modes_reverse[v] = k
end

mcl_gamemode.mode_names = {
	["survival"] = N("Survival"),
	["creative"] = N("Creative"),
	["adventure"] = N("Adventure"),
	["spectator"] = N("Spectator"),
}

minetest.register_on_newplayer(function(player)
	if minetest.settings:get_bool("creative_mode") then
		mcl_gamemode.set_gamemode(player, "creative")
	else
		mcl_gamemode.set_gamemode(player, "survival")
	end
end)

mcl_gamemode.get_gamemode = function(player)
	local meta = player:get_meta()
	local gamemode = meta:get_int("mcl_gamemode")
	if not gamemode or not mcl_gamemode.modes[gamemode] then
		-- Fallback
		if minetest.settings:get_bool("creative_mode") then
			return "creative"
		else
			return "survival"
		end
	else
		return mcl_gamemode.modes[gamemode]
	end
end

mcl_gamemode.set_gamemode = function(player, gamemode)
	local meta = player:get_meta()
	local int = mcl_gamemode.modes_reverse[gamemode]
	if int then
		meta:set_int("mcl_gamemode", int)
	else
		error("[mcl_gamemode] Trying to set unknown game mode "..tostring(gamemode).." for player "..player:get_player_name()"!")
	end
end

minetest.register_privilege("creative", {
	give_to_singleplayer = false,
})

local function msg_current_mode(gamemode)
	return S("Current game mode: @1", S(mcl_gamemode.mode_names[gamemode]))
end

minetest.register_chatcommand("gamemode", {
	params = S("[<gamemode>]"),
	description = S("Select your game mode. Choose between Survival or Creative"),
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, S("Unknown player!")
		end
		if param == "" then
			local gamemode = mcl_gamemode.get_gamemode(player)
			return true, msg_current_mode(gamemode)
		elseif param == "creative" or tonumber(param) == mcl_gamemode.modes_reverse["creative"] then
			if minetest.get_player_privs(name).creative or minetest.settings:get_bool("creative_mode") then
				mcl_gamemode.set_gamemode(player, "creative")
				return true, msg_current_mode("creative")
			else
				return false, S("You need the “creative” privilege!")
			end
		elseif param == "survival" or tonumber(param) == mcl_gamemode.modes_reverse["survival"] then
			mcl_gamemode.set_gamemode(player, "survival")
			return true, msg_current_mode("survival")
		elseif param == "adventure" or param == "spectator" or param == "2" or param == "3" then
			return false, S("Not implemented yet!")
		else
			return false, S("Unknown game mode!")
		end
	end,
})

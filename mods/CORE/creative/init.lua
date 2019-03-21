-- Re-implementation of `creative` mod from Minetest Game 5.0.0.
-- Offers the same function for compability.

creative = {}

creative.is_enabled_for = function(playername)
	local player = minetest.get_player_by_name(playername)
	if not player then
		error("[creative] Unknown player "..playername.."!")
	end
	local gamemode = mcl_gamemode.get_gamemode(player)
	return gamemode == "creative"
end

-- No-op, provided for compability
creative.register_tab = function() end
creative.formspec_add = ""

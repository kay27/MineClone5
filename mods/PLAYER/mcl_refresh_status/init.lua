minetest.register_on_respawnplayer(function(player)
	mcl_potions._reset_player_effects(player, true)
end)
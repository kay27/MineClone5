-- register extra flavours of a base nodedef
walkover = {}
walkover.registered_globals = {}

function walkover.register_global(func)
	table.insert(walkover.registered_globals, func)
end

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < 0.3 then return end
	for _,player in pairs(minetest.get_connected_players()) do
		local loc = player:get_pos()
		if loc then
			loc.y = math.ceil(loc.y)-1
			local nodeiamon = minetest.get_node(loc)
			if nodeiamon then
				local def = minetest.registered_nodes[nodeiamon.name]
				if def and def.on_walk_over then
					def.on_walk_over(loc, nodeiamon, player)
				end
				for _, func in pairs(walkover.registered_globals) do
					func(loc, nodeiamon, player)
				end
			end
		end
	end
	timer = 0
end)

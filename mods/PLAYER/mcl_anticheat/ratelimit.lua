-- by LoneWolfHT
-- https://github.com/minetest/minetest/issues/12220#issuecomment-1108789409

local ratelimit = {}
local after = minetest.after
local LIMIT = 2

local function remove_entry(ip)
	ratelimit[ip] = nil
end

minetest.register_on_mods_loaded(function()
	table.insert(core.registered_on_prejoinplayers, 1, function(player, ip)
		if ratelimit[ip] then
			return "You are joining too fast, please try again"
		else
			ratelimit[ip] = true
			after(LIMIT, remove_entry, ip)
		end
	end)
end)

local S = minetest.get_translator("mcl_objectplus")

mcl_objectplus = {}

mcl_objectplus.hurt = function(object)
	local pos = object:get_pos()

	-- Am I near a cactus?
	local near = minetest.find_node_near(pos, 1, "mcl_core:cactus")
	if not near then
		near = minetest.find_node_near({x=pos.x, y=pos.y-1, z=pos.z}, 1, "mcl_core:cactus")
	end
	if near then
		-- Am I touching the cactus? If so, it hurts
		local dist = vector.distance(pos, near)
		local dist_feet = vector.distance({x=pos.x, y=pos.y-1, z=pos.z}, near)
		if dist < 1.1 or dist_feet < 1.1 then
			if object:is_player() and object:get_hp() > 0 then
				local name = object:get_player_name()
				mcl_death_messages.player_damage(object, S("@1 was prickled to death by a cactus.", name))
			end
			object:set_hp(object:get_hp() - 1, { type = "punch", from = "mod" })
			local lua = object:get_luaentity()
			if lua then
				if lua._cmi_is_mob then
					lua.health = lua.health - 1
				end
			end
		end
	end
end

local voidtimer = 0

minetest.register_globalstep(function(dtime)

	voidtimer = voidtimer + dtime
	if voidtimer > 0.5 then
		voidtimer = 0
		local enable_damage = minetest.settings:get_bool("enable_damage")
		if not enable_damage then
			return
		end
		local objs = minetest.object_refs
		for id, obj in pairs(objs) do
			mcl_objectplus.hurt(obj)
		end
	end
end)

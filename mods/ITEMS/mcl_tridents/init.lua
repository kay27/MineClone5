local S = minetest.get_translator("mcl_tridents")
local cooldown = {}

minetest.register_on_joinplayer(function(player)
	cooldown[player:get_player_name()] = false
end)

minetest.register_on_leaveplayer(function(player)
	cooldown[player:get_player_name()] = false
end)

local GRAVITY = 9.81
local TRIDENT_DURABILITY = 251
local TRIDENT_COOLDOWN = 0.91

local TRIDENT_ENTITY = {
	physical = true,
	pointable = false,
	visual = "mesh",
	mesh = "mcl_trident.obj",
	visual_size = {x=-1, y=1},
	textures = {"mcl_trident.png"},
	collisionbox = {-.1, -.1, -1, .1, .1, 0.5},
	collide_with_objects = true,
	_fire_damage_resistant = true,

	_lastpos={},
	_startpos=nil,
	_damage=8,	-- Damage on impact
	_is_critical=false,
	_stuck=false,   -- Whether arrow is stuck
	_stucktimer=nil,-- Amount of time (in seconds) the arrow has been stuck so far
	_stuckrechecktimer=nil,-- An additional timer for periodically re-checking the stuck status of an arrow
	_stuckin=nil,	--Position of node in which arow is stuck.
	_shooter=nil,	-- ObjectRef of player or mob who shot it

	_viscosity=0,   -- Viscosity of node the arrow is currently in
	_deflection_cooloff=0, -- Cooloff timer after an arrow deflection, to prevent many deflections in quick succession
}

minetest.register_entity("mcl_tridents:trident_entity", TRIDENT_ENTITY)

local spawn_trident = function(player)
	local wielditem = player:get_wielded_item()
	local obj = minetest.add_entity(vector.add(player:get_pos(), {x = 0, y = 1.5, z = 0}), "mcl_tridents:trident_entity")
	local yaw = player:get_look_horizontal()+math.pi/2
	
	if cooldown[player:get_player_name()] then
		return
	end
	
	cooldown[player:get_player_name()] = true
	
	minetest.after(TRIDENT_COOLDOWN, function()
		cooldown[player:get_player_name()] = false
	end)
	
	if obj then
		local durability = TRIDENT_DURABILITY
		local unbreaking = mcl_enchanting.get_enchantment(wielditem, "unbreaking")
		if unbreaking > 0 then
			durability = durability * (unbreaking + 1)
		end
		wielditem:add_wear(65535/durability)
		obj:set_velocity(vector.multiply(player:get_look_dir(), 20))
		obj:set_acceleration({x=0, y=-GRAVITY, z=0})
		obj:set_yaw(yaw)
	end
end


minetest.register_tool("mcl_tridents:trident", {
	description = S("Trident"),
	_tt_help = S("Launches a trident when you rightclick and it is in your hand"),
	_doc_items_durability = TRIDENT_DURABILITY,
	inventory_image = "mcl_trident_inv.png",
	stack_max = 1,
	groups = {weapon=1,weapon_ranged=1,trident=1,enchantability=1},
	_mcl_uses = TRIDENT_DURABILITY,
	on_place = function(itemstack, placer, pointed_thing)
		spawn_trident(placer)
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		spawn_trident(user)
	end
})

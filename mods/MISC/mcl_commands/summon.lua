local S = minetest.get_translator(minetest.get_current_modname())

local orig_func = minetest.registered_chatcommands["spawnentity"].func
local cmd = table.copy(minetest.registered_chatcommands["spawnentity"])
cmd.func = function(name, param)
	local params = param:split(" ")
	if not params[1] or params[3] then
		return false, S("Usage: /spawnentity <EntityName> [<X>,<Y>,<Z>]")
	end
	local entity_name = params[1]
	local pos = params[2]
	local entity_def = minetest.registered_entities[entity_name]
	if not entity_def then
		entity_name = "mobs_mc:" .. entity_name
		entity_def = minetest.registered_entities[entity_name]
		if not entity_def then
			return false, S("Error: Unknown entity name")
		end
	end
	if entity_def._cmi_is_mob then
		if minetest.settings:get_bool("only_peaceful_mobs", false) and entity_def.type == "monster" then
			return false, S("Only peaceful mobs allowed!")
		end
		mobs.spawn_mob(
			entity_name,
			pos
				and minetest.string_to_pos(pos)
				or vector.add(
					minetest.get_player_by_name(name):get_pos(),
					{
						x = math.random()-0.5,
						y = math.random(),
						z = math.random()-0.5
					}
				)
		)
		return true, S("Mob @1 spawned", entity_name)
	end
	local bool, msg = orig_func(name, param)
	return bool, msg
end
minetest.unregister_chatcommand("spawnentity")
minetest.register_chatcommand("summon", cmd)
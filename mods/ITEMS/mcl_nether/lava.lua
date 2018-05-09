-- Lava in the Nether


-- TODO: Increase flow speed. This could be done by reducing viscosity,
-- but this would also allow players to swim faster in lava.

local lava_src_def = table.copy(minetest.registered_nodes["mcl_core:lava_source"])
lava_src_def.description = "Nether Lava Source"
lava_src_def._doc_items_create_entry = false
lava_src_def._doc_items_entry_name = nil
lava_src_def._doc_items_longdesc = nil
lava_src_def._doc_items_usagehelp = nil
lava_src_def.liquid_range = 7
lava_src_def.liquid_alternative_source = "mcl_nether:nether_lava_source"
lava_src_def.liquid_alternative_flowing = "mcl_nether:nether_lava_flowing"
lava_src_def.on_place = function(itemstack, placer, pointed_thing)
	local dim = mcl_worlds.pos_to_dimension(pointed_thing.under)
	local real_stack = ItemStack(itemstack)
	if dim ~= "nether" then
		real_stack:set_name("mcl_core:lava_source")
	end
	real_stack = minetest.item_place_node(real_stack, placer, pointed_thing)
	real_stack:set_name("mcl_nether:nether_lava_source")
	return real_stack
end
lava_src_def.groups.not_in_creative_inventory = 1
lava_src_def.groups.deco_block = nil
minetest.register_node("mcl_nether:nether_lava_source", lava_src_def)

local lava_flow_def = table.copy(minetest.registered_nodes["mcl_core:lava_flowing"])
lava_flow_def.description = "Flowing Nether Lava"
lava_flow_def._doc_items_create_entry = false
lava_flow_def.liquid_range = 7
lava_flow_def.liquid_alternative_flowing = "mcl_nether:nether_lava_flowing"
lava_flow_def.liquid_alternative_source = "mcl_nether:nether_lava_source"
lava_flow_def.on_place = function(itemstack, placer, pointed_thing)
	local dim = mcl_worlds.pos_to_dimension(pointed_thing.under)
	local real_stack = ItemStack(itemstack)
	if dim ~= "nether" then
		real_stack:set_name("mcl_core:lava_flowing")
	end
	real_stack = minetest.item_place_node(real_stack, placer, pointed_thing)
	real_stack:set_name("mcl_nether:nether_lava_flowing")
	return real_stack
end
lava_flow_def.groups.not_in_creative_inventory = 1
lava_flow_def.groups.deco_block = nil

minetest.register_node("mcl_nether:nether_lava_flowing", lava_flow_def)

-- Add entry aliases for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_core:lava_source", "nodes", "mcl_nether:nether_lava_source")
	doc.add_entry_alias("nodes", "mcl_core:lava_source", "nodes", "mcl_nether:nether_lava_flowing")
end


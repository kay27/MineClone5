local S = minetest.get_translator(minetest.get_current_modname())

--[[ Doors ]]

local wood_longdesc = S("Wooden doors are 2-block high barriers which can be opened or closed by hand and by a redstone signal.")
local wood_usagehelp = S("To open or close a wooden door, rightclick it or supply its lower half with a redstone signal.")

--- Crimson Door --
mclx_doors:register_door("mclx_doors:crimson_door", {
	description = S("Crimson Door"),
	_doc_items_longdesc = wood_longdesc,
	_doc_items_usagehelp = wood_usagehelp,
	inventory_image = "mcl_doors_door_crimson.png",
	groups = {handy=1,axey=1, material_wood=1, flammable=-1},
	_mcl_hardness = 3,
	_mcl_blast_resistance = 3,
	tiles_bottom = {"mcl_doors_door_crimson_lower.png", "mcl_doors_door_crimson_side_lower.png"},
	tiles_top = {"mcl_doors_door_crimson_upper.png", "mcl_doors_door_crimson_side_upper.png"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "mclx_doors:crimson_door 3",
	recipe = {
		{"mcl_mushroom:crimson_hyphae_wood", "mcl_mushroom:crimson_hyphae_wood"},
		{"mcl_mushroom:crimson_hyphae_wood", "mcl_mushroom:crimson_hyphae_wood"},
		{"mcl_mushroom:crimson_hyphae_wood", "mcl_mushroom:crimson_hyphae_wood"}
	}
})

--- Warped Door --
mclx_doors:register_door("mclx_doors:warped_door", {
	description = S("Warped Door"),
	_doc_items_longdesc = wood_longdesc,
	_doc_items_usagehelp = wood_usagehelp,
	inventory_image = "mcl_doors_door_warped.png",
	groups = {handy=1,axey=1, material_wood=1, flammable=-1},
	_mcl_hardness = 3,
	_mcl_blast_resistance = 3,
	tiles_bottom = {"mcl_doors_door_warped_lower.png", "mcl_doors_door_warped_side_lower.png"},
	tiles_top = {"mcl_doors_door_warped_upper.png", "mcl_doors_door_warped_side_upper.png"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "mclx_doors:warped_door 3",
	recipe = {
		{"mcl_mushroom:warped_hyphae_wood", "mcl_mushroom:warped_hyphae_wood"},
		{"mcl_mushroom:warped_hyphae_wood", "mcl_mushroom:warped_hyphae_wood"},
		{"mcl_mushroom:warped_hyphae_wood", "mcl_mushroom:warped_hyphae_wood"}
	}
})



minetest.register_craft({
	type = "fuel",
	recipe = "mclx_doors:crimson_door",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mclx_doors:warped_door",
	burntime = 10,
})

--[[ Trapdoors ]]
local woods = {
	-- id, desc, texture, craftitem
	{ "crimson_trapdoor", S("Crimson Trapdoor"), "mcl_doors_trapdoor_crimson.png", "mcl_doors_trapdoor_crimson_side.png", "mcl_mushroom:crimson_hyphae_wood" },
	{ "warped_trapdoor", S("Warped Trapdoor"), "mcl_doors_trapdoor_warped.png", "mcl_doors_trapdoor_warped_side.png", "mcl_mushroom:warped_hyphae_wood" },
}

for w=1, #woods do
	mclx_doors:register_trapdoor("mclx_doors:"..woods[w][1], {
		description = woods[w][2],
		_doc_items_longdesc = S("Wooden trapdoors are horizontal barriers which can be opened and closed by hand or a redstone signal. They occupy the upper or lower part of a block, depending on how they have been placed. When open, they can be climbed like a ladder."),
		_doc_items_usagehelp = S("To open or close the trapdoor, rightclick it or send a redstone signal to it."),
		tile_front = woods[w][3],
		tile_side = woods[w][4],
		wield_image = woods[w][3],
		groups = {handy=1,axey=1, mesecon_effector_on=1, material_wood=1, flammable=-1},
		_mcl_hardness = 3,
		_mcl_blast_resistance = 3,
		sounds = mcl_sounds.node_sound_wood_defaults(),
	})

	minetest.register_craft({
		output = "mclx_doors:"..woods[w][1].." 2",
		recipe = {
			{woods[w][5], woods[w][5], woods[w][5]},
			{woods[w][5], woods[w][5], woods[w][5]},
		}
	})

	minetest.register_craft({
		type = "fuel",
		recipe = "mclx_doors:"..woods[w][1],
		burntime = 15,
	})
end


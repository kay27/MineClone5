local S = minetest.get_translator(minetest.get_current_modname())

--[[ Doors ]]

local wood_longdesc = S("Wooden doors are 2-block high barriers which can be opened or closed by hand and by a redstone signal.")
local wood_usagehelp = S("To open or close a wooden door, rightclick it or supply its lower half with a redstone signal.")

--Register flammable doors--

local woods = {
	--id, desc, textures, craftitem
	{"wooden_door",S("Oak Door"),"doors_item_wood.png",{"mcl_doors_door_wood_lower.png", "mcl_doors_door_wood_side_lower.png"},{"mcl_doors_door_wood_upper.png", "mcl_doors_door_wood_side_upper.png"},"mcl_core:wood"},
	{"acacia_door",S("Acacia Door"),"mcl_doors_door_acacia.png",{"mcl_doors_door_acacia_lower.png", "mcl_doors_door_acacia_side_lower.png"},{"mcl_doors_door_acacia_upper.png", "mcl_doors_door_acacia_side_upper.png"},"mcl_core:acaciawood"},
	{"birch_door",S("Birch Door"),"mcl_doors_door_birch.png",{"mcl_doors_door_birch_lower.png", "mcl_doors_door_birch_side_lower.png"},{"mcl_doors_door_birch_upper.png", "mcl_doors_door_birch_side_upper.png"},"mcl_core:birchwood"},
	{"dark_oak_door",S("Dark Oak Door"),"mcl_doors_door_dark_oak.png",{"mcl_doors_door_dark_oak_lower.png", "mcl_doors_door_dark_oak_side_lower.png"},{"mcl_doors_door_dark_oak_upper.png", "mcl_doors_door_dark_oak_side_upper.png"},"mcl_core:darkwood"},
	{"jungle_door",S("Jungle Door"),"mcl_doors_door_jungle.png",{"mcl_doors_door_jungle_lower.png", "mcl_doors_door_jungle_side_lower.png"},{"mcl_doors_door_jungle_upper.png", "mcl_doors_door_jungle_side_upper.png"},"mcl_core:junglewood"},
	{"spruce_door",S("Spruce Door"),"mcl_doors_door_spruce.png",{"mcl_doors_door_spruce_lower.png", "mcl_doors_door_spruce_side_lower.png"},{"mcl_doors_door_spruce_upper.png", "mcl_doors_door_spruce_side_upper.png"},"mcl_core:sprucewood"},
}

for w=1, #woods do
	mcl_doors:register_door("mcl_doors:"..woods[w][1], {
		description = woods[w][2],
		_doc_items_longdesc = wood_longdesc,
		_doc_items_usagehelp = wood_usagehelp,
		inventory_image = woods[w][3],
		groups = {handy=1,axey=1, material_wood=1, flammable=-1},
		_mcl_hardness = 3,
		_mcl_blast_resistance = 3,
		tiles_bottom = woods[w][4],
		tiles_top = woods[w][5],
		sounds = mcl_sounds.node_sound_wood_defaults(),
	})

	minetest.register_craft({
		output = "mcl_doors:"..woods[w][1].." 3",
		recipe = {
		{woods[w][6], woods[w][6]},
		{woods[w][6], woods[w][6]},
		{woods[w][6], woods[w][6]}
		}
	})

	minetest.register_craft({
		type = "fuel",
		recipe = "mcl_doors:"..woods[w][1],
		burntime = 10,
	})

end

--Register non-flammable doors--

local woods_nether = {
	--id, desc, textures, craftitem
	{"crimson_door",S("Crimson Door"),"mcl_doors_door_crimson.png",{"mcl_doors_door_crimson_lower.png", "mcl_doors_door_crimson_side_lower.png"},{"mcl_doors_door_crimson_upper.png", "mcl_doors_door_crimson_side_upper.png"},"mcl_mushroom:crimson_hyphae_wood"},
	{"warped_door",S("Warped Door"),"mcl_doors_door_warped.png",{"mcl_doors_door_warped_lower.png", "mcl_doors_door_warped_side_lower.png"},{"mcl_doors_door_warped_upper.png", "mcl_doors_door_warped_side_upper.png"},"mcl_mushroom:warped_hyphae_wood"},
}

for w=1, #woods_nether do
	mcl_doors:register_door("mcl_doors:"..woods_nether[w][1], {
		description = woods_nether[w][2],
		_doc_items_longdesc = wood_longdesc,
		_doc_items_usagehelp = wood_usagehelp,
		inventory_image = woods_nether[w][3],
		groups = {handy=1,axey=1, material_wood=1},
		_mcl_hardness = 3,
		_mcl_blast_resistance = 3,
		tiles_bottom = woods_nether[w][4],
		tiles_top = woods_nether[w][5],
		sounds = mcl_sounds.node_sound_wood_defaults(),
	})

	minetest.register_craft({
		output = "mcl_doors:"..woods_nether[w][1].." 3",
		recipe = {
		{woods_nether[w][6], woods_nether[w][6]},
		{woods_nether[w][6], woods_nether[w][6]},
		{woods_nether[w][6], woods_nether[w][6]}
		}
	})

	minetest.register_craft({
		type = "fuel",
		recipe = "mcl_doors:"..woods_nether[w][1],
		burntime = 10,
	})

end

--- Iron Door ---
mcl_doors:register_door("mcl_doors:iron_door", {
	description = S("Iron Door"),
	_doc_items_longdesc = S("Iron doors are 2-block high barriers which can only be opened or closed by a redstone signal, but not by hand."),
	_doc_items_usagehelp = S("To open or close an iron door, supply its lower half with a redstone signal."),
	inventory_image = "doors_item_steel.png",
	groups = {pickaxey=1, mesecon_effector_on=1},
	_mcl_hardness = 5,
	_mcl_blast_resistance = 5,
	tiles_bottom = {"mcl_doors_door_iron_lower.png^[transformFX", "mcl_doors_door_iron_side_lower.png"},
	tiles_top = {"mcl_doors_door_iron_upper.png^[transformFX", "mcl_doors_door_iron_side_upper.png"},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",

	only_redstone_can_open = true,
})

minetest.register_craft({
	output = "mcl_doors:iron_door 3",
	recipe = {
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"}
	}
})



--[[ Trapdoors ]]

--Register flammable trapdoors--

local woods = {
	-- id, desc, texture, craftitem
	{ "trapdoor", S("Oak Trapdoor"), "doors_trapdoor.png", "doors_trapdoor_side.png", "mcl_core:wood" },
	{ "acacia_trapdoor", S("Acacia Trapdoor"), "mcl_doors_trapdoor_acacia.png", "mcl_doors_trapdoor_acacia_side.png", "mcl_core:acaciawood" },
	{ "birch_trapdoor", S("Birch Trapdoor"), "mcl_doors_trapdoor_birch.png", "mcl_doors_trapdoor_birch_side.png", "mcl_core:birchwood" },
	{ "spruce_trapdoor", S("Spruce Trapdoor"), "mcl_doors_trapdoor_spruce.png", "mcl_doors_trapdoor_spruce_side.png", "mcl_core:sprucewood" },
	{ "dark_oak_trapdoor", S("Dark Oak Trapdoor"), "mcl_doors_trapdoor_dark_oak.png", "mcl_doors_trapdoor_dark_oak_side.png", "mcl_core:darkwood" },
	{ "jungle_trapdoor", S("Jungle Trapdoor"), "mcl_doors_trapdoor_jungle.png", "mcl_doors_trapdoor_jungle_side.png", "mcl_core:junglewood" },
}

for w=1, #woods do
	mcl_doors:register_trapdoor("mcl_doors:"..woods[w][1], {
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
		output = "mcl_doors:"..woods[w][1].." 2",
		recipe = {
			{woods[w][5], woods[w][5], woods[w][5]},
			{woods[w][5], woods[w][5], woods[w][5]},
		}
	})

	minetest.register_craft({
		type = "fuel",
		recipe = "mcl_doors:"..woods[w][1],
		burntime = 15,
	})
end

--Register non-flammable trapdoors--

local woods_nether = {
	-- id, desc, texture, craftitem
	{ "crimson_trapdoor", S("Crimson Trapdoor"), "mcl_doors_trapdoor_crimson.png", "mcl_doors_trapdoor_crimson_side.png", "mcl_mushroom:crimson_hyphae_wood" },
	{ "warped_trapdoor", S("Warped Trapdoor"), "mcl_doors_trapdoor_warped.png", "mcl_doors_trapdoor_warped_side.png", "mcl_mushroom:warped_hyphae_wood" },
}

for w=1, #woods_nether do
	mcl_doors:register_trapdoor("mcl_doors:"..woods_nether[w][1], {
		description = woods_nether[w][2],
		_doc_items_longdesc = S("Wooden trapdoors are horizontal barriers which can be opened and closed by hand or a redstone signal. They occupy the upper or lower part of a block, depending on how they have been placed. When open, they can be climbed like a ladder."),
		_doc_items_usagehelp = S("To open or close the trapdoor, rightclick it or send a redstone signal to it."),
		tile_front = woods_nether[w][3],
		tile_side = woods_nether[w][4],
		wield_image = woods_nether[w][3],
		groups = {handy=1,axey=1, mesecon_effector_on=1, material_wood=1},
		_mcl_hardness = 3,
		_mcl_blast_resistance = 3,
		sounds = mcl_sounds.node_sound_wood_defaults(),
	})

	minetest.register_craft({
		output = "mcl_doors:"..woods_nether[w][1].." 2",
		recipe = {
			{woods_nether[w][5], woods_nether[w][5], woods_nether[w][5]},
			{woods_nether[w][5], woods_nether[w][5], woods_nether[w][5]},
		}
	})

	minetest.register_craft({
		type = "fuel",
		recipe = "mcl_doors:"..woods_nether[w][1],
		burntime = 15,
	})
end

--Iron Trapdoor--

mcl_doors:register_trapdoor("mcl_doors:iron_trapdoor", {
	description = S("Iron Trapdoor"),
	_doc_items_longdesc = S("Iron trapdoors are horizontal barriers which can only be opened and closed by redstone signals, but not by hand. They occupy the upper or lower part of a block, depending on how they have been placed. When open, they can be climbed like a ladder."),
	tile_front = "doors_trapdoor_steel.png",
	tile_side = "doors_trapdoor_steel_side.png",
	wield_image = "doors_trapdoor_steel.png",
	groups = {pickaxey=1, mesecon_effector_on=1},
	_mcl_hardness = 5,
	_mcl_blast_resistance = 5,
	sounds = mcl_sounds.node_sound_metal_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",

	only_redstone_can_open = true,
})

minetest.register_craft({
	output = "mcl_doors:iron_trapdoor",
	recipe = {
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
	}
})

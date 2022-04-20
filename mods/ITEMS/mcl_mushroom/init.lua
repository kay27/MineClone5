local S = minetest.get_translator("mcl_mushroom")

-- function grow()
function grow_twisting_vines(pos, moreontop)
	local y = pos.y + 1
		while not (moreontop == 0) do
			if minetest.get_node({x = pos.x, y = y, z = pos.z}).name == "air" then
				minetest.set_node({x = pos.x, y = y, z = pos.z}, {name="mcl_mushroom:twisting_vines"})
				moreontop = moreontop - 1
				y = y + 1
			elseif minetest.get_node({x = pos.x, y = y, z = pos.z}).name == "mcl_mushroom:twisting_vines" then
				y = y + 1
			else
				moreontop = 0
			end
	end
end


-- Warped fungus
-- Crimson fungus
-- Functions and Biomes

-- WARNING: The most comments are in german. Please Translate with an translater if you don't speak good german

minetest.register_node("mcl_mushroom:warped_fungus", {
	description = S("Warped Fungus Mushroom"),
	drawtype = "plantlike",
	tiles = { "farming_warped_fungus.png" },
	inventory_image = "farming_warped_fungus.png",
	wield_image = "farming_warped_fungus.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=3,mushroom=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,deco_block=1, compostability=65},
	light_source = 1,
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, -2/16, 3/16 },
	},
	node_placement_prediction = "",
	on_rightclick = function(pos, node, pointed_thing, itemstack)

	if pointed_thing:get_wielded_item():get_name() == "mcl_dye:white" then
		itemstack:take_item()
	    local nodepos = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
		if nodepos.name == "mcl_mushroom:warped_nylium" or nodepos.name == "mcl_nether:netherrack" then
	        local random = math.random(1, 5)
	        if random == 1 then
	          generate_warped_tree(pos)
	        end
		end
	end
	end,
	_mcl_blast_resistance = 0,
	stack_max = 64,
})

minetest.register_node("mcl_mushroom:twisting_vines", {
	description = S("Twisting Vines"),
	drawtype = "plantlike",
	tiles = { "twisting_vines_plant.png" },
	inventory_image = "twisting_vines.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	climbable = true,
	buildable_to = true,
	groups = {dig_immediate=3,vines=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,deco_block=1, shearsy = 1, compostability=50},
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, 0.5, 3/16 },
	},
	node_placement_prediction = "",
	on_rightclick = function(pos, node, pointed_thing, itemstack)

	if pointed_thing:get_wielded_item():get_name() == "mcl_mushroom:twisting_vines" then
	      itemstack:take_item()
	      grow_twisting_vines(pos, 1)
	elseif pointed_thing:get_wielded_item():get_name() == "mcl_dye:white" then
	      itemstack:take_item()
	      grow_twisting_vines(pos, math.random(1, 3))
	end
	end,
	drop = {
	max_items = 1,
	items = {
			{items = {"mcl_mushroom:twisting_vines"}, rarity = 3},
		}
	},
	_mcl_shears_drop = true,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = { items = {{items = {"mcl_mushroom:twisting_vines"}, rarity = 3},},
		items = {{items = {"mcl_mushroom:twisting_vines"}, rarity = 1.8181818181818181},},
		"mcl_mushroom:twisting_vines",
		"mcl_mushroom:twisting_vines"},
	_mcl_blast_resistance = 0,
	stack_max = 64,
})

minetest.register_node("mcl_mushroom:nether_sprouts", {
	description = S("Nether Sprouts"),
	drawtype = "plantlike",
	tiles = { "nether_sprouts.png" },
	inventory_image = "nether_sprouts.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	groups = {dig_immediate=3,vines=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,deco_block=1, shearsy = 1, compostability=50},
	selection_box = {
		type = "fixed",
		fixed = { -4/16, -0.5, -4/16, 4/16, 0, 4/16 },
	},
	node_placement_prediction = "",
	drop = "",
	_mcl_shears_drop = true,
	_mcl_silk_touch_drop = false,
	_mcl_blast_resistance = 0,
	stack_max = 64,
})

minetest.register_node("mcl_mushroom:warped_roots", {
	description = S("Warped Roots"),
	drawtype = "plantlike",
	tiles = { "warped_roots.png" },
	inventory_image = "warped_roots.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	groups = {dig_immediate=3,vines=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,deco_block=1, shearsy = 1, compostability=65},
	selection_box = {
		type = "fixed",
		fixed = { -6/16, -0.5, -6/16, 6/16, -4/16, 6/16 },
	},
	node_placement_prediction = "",
	_mcl_silk_touch_drop = false,
	_mcl_blast_resistance = 0,
	stack_max = 64,
})

minetest.register_node("mcl_mushroom:warped_wart_block", {
	description = S("Warped Wart Block"),
	tiles = {"warped_wart_block.png"},
	groups = {handy=1,hoe=7,swordy=1, compostability=85, deco_block=1, },
	stack_max = 64,
	_mcl_hardness = 2,
})

minetest.register_node("mcl_mushroom:shroomlight", {
	description = S("Shroomlight"),
	tiles = {"shroomlight.png"},
	groups = {handy=1,hoe=7,swordy=1, leaves=1, deco_block=1, compostability=65, },
	stack_max = 64,
	_mcl_hardness = 2,
	-- this is 15 in Minecraft
	light_source = 14,
})

minetest.register_node("mcl_mushroom:warped_hyphae", {
	description = S("Warped Hyphae"),
	_doc_items_longdesc = S("The stem of a warped hyphae"),
	_doc_items_hidden = false,
	tiles = {
		"warped_hyphae.png",
        "warped_hyphae.png",
        "warped_hyphae_side.png",
        "warped_hyphae_side.png",
        "warped_hyphae_side.png",
        "warped_hyphae_side.png",
    },
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	groups = {handy=1,axey=1, tree=1, building_block=1, material_wood=1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_rotate = on_rotate,
	_mcl_blast_resistance = 2,
	stack_max = 64,
	_mcl_hardness = 2,
	_mcl_stripped_variant = "mcl_mushroom:stripped_warped_hyphae",
})

minetest.register_node("mcl_mushroom:warped_nylium", {
	description = S("Warped Nylium"),
	tiles = {
		"warped_nylium.png",
		"mcl_nether_netherrack.png",
		"mcl_nether_netherrack.png^warped_nylium_side.png",
		"mcl_nether_netherrack.png^warped_nylium_side.png",
		"mcl_nether_netherrack.png^warped_nylium_side.png",
		"mcl_nether_netherrack.png^warped_nylium_side.png",
    },
	groups = {pickaxey=1, building_block=1, material_stone=1},
	paramtype2 = "facedir",
	stack_max = 64,
	_mcl_hardness = 0.4,
	_mcl_blast_resistance = 0.4,
	is_ground_content = true,
	drop = "mcl_nether:netherrack",
	_mcl_silk_touch_drop = true,
})

minetest.register_node("mcl_mushroom:warped_checknode", {
	description = S("Warped Checknode - only to check!"),
	tiles = {
		"mcl_nether_netherrack.png",
		"mcl_nether_netherrack.png",
		"mcl_nether_netherrack.png",
		"mcl_nether_netherrack.png",
		"mcl_nether_netherrack.png",
		"mcl_nether_netherrack.png",
    },
	groups = {pickaxey=1, building_block=1, material_stone=1, not_in_creative_inventory=1},
	paramtype2 = "facedir",
	stack_max = 64,
	_mcl_hardness = 0.4,
	_mcl_blast_resistance = 0.4,
	is_ground_content = true,
	drop = "mcl_nether:netherrack"
})

--Stem bark, stripped stem and bark

minetest.register_node("mcl_mushroom:warped_hyphae_bark", {
		description = S("Warped Hyphae"),
		_doc_items_longdesc = S("This is a decorative block surrounded by the bark of an hyphae."),
		tiles = {"warped_hyphae_side.png"},
		paramtype2 = "facedir",
		on_place = mcl_util.rotate_axis,
		stack_max = 64,
		groups = {handy=1,axey=1, bark=1, building_block=1, material_wood=1},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		is_ground_content = false,
		on_rotate = on_rotate,
		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
		_mcl_stripped_variant = "mcl_mushroom:stripped_warped_hyphae_bark",
	})

minetest.register_craft({
		output = "mcl_mushroom:warped_hyphae_bark 3",
		recipe = {
			{ "mcl_mushroom:warped_hyphae", "mcl_mushroom:warped_hyphae" },
			{ "mcl_mushroom:warped_hyphae", "mcl_mushroom:warped_hyphae" },
		}
	})


minetest.register_node("mcl_mushroom:stripped_warped_hyphae", {
		description = S("Stripped Warped Hyphae"),
		_doc_items_longdesc = S("The stripped stem of a warped hyphae"),
		_doc_items_hidden = false,
		tiles = {"stripped_warped_stem_top.png", "stripped_warped_stem_top.png", "stripped_warped_stem_side.png"},
		paramtype2 = "facedir",
		on_place = mcl_util.rotate_axis,
		stack_max = 64,
		groups = {handy=1, axey=1, tree=1, building_block=1, material_wood=1},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		on_rotate = on_rotate,
		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
	})

minetest.register_node("mcl_mushroom:stripped_warped_hyphae_bark", {
		description =  S("Stripped Warped Hyphae Bark"),
		_doc_items_longdesc = S("The stripped wood of a warped hyphae"),
		tiles = {"stripped_warped_stem_side.png"},
		paramtype2 = "facedir",
		on_place = mcl_util.rotate_axis,
		stack_max = 64,
		groups = {handy=1, axey=1, bark=1, building_block=1, material_wood=1},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		is_ground_content = false,
		on_rotate = on_rotate,
		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
	})

minetest.register_craft({
		output = "mcl_mushroom:stripped_warped_hyphae_bark 3",
		recipe = {
			{ "mcl_mushroom:stripped_warped_hyphae", "mcl_mushroom:stripped_warped_hyphae" },
			{ "mcl_mushroom:stripped_warped_hyphae", "mcl_mushroom:stripped_warped_hyphae" },
		}
	})

--Wood

minetest.register_node("mcl_mushroom:warped_hyphae_wood", {
	description = S("Warped Hyphae Wood"),
	tiles = {"warped_hyphae_wood.png"},
	groups = {handy=5,axey=1, wood=1,building_block=1, material_wood=1},
	--paramtype2 = "facedir",
	stack_max = 64,
	_mcl_hardness = 2,
})

mcl_stairs.register_stair_and_slab_simple("warped_hyphae_wood", "mcl_mushroom:warped_hyphae_wood", S("Warped Stair"), S("Warped Slab"), S("Double Warped Slab"), "woodlike")

minetest.register_craft({
	output = "mcl_mushroom:warped_hyphae_wood 4",
	recipe = {
		{"mcl_mushroom:warped_hyphae"},
	}
})

minetest.register_craft({
	output = "mcl_mushroom:warped_nylium 2",
	recipe = {
		{"mcl_mushroom:warped_wart_block"},
		{"mcl_nether:netherrack"},
	}
})

minetest.register_abm({
	label = "mcl_mushroom:warped_fungus",
	nodenames = {"mcl_mushroom:warped_fungus"},
	interval = 11,
	chance = 128,
	action = function(pos)
    local nodepos = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
    if nodepos.name == "mcl_mushroom:warped_nylium" or nodepos.name == "mcl_nether:netherrack" then
		if pos.y < -28400 then
			generate_warped_tree(pos)
		end
    end
	end
})

minetest.register_abm({
	label = "mcl_mushroom:warped_checknode",
	nodenames = {"mcl_mushroom:warped_checknode"},
	interval = 0.1,
	chance = 1,
	action = function(pos)
    local nodepos = minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z})
    if nodepos.name == "air" then
		minetest.swap_node({ x = pos.x, y = pos.y, z = pos.z }, { name = "mcl_mushroom:warped_nylium" })
		local randomg = math.random(1, 400)
		if randomg <= 5 then
			minetest.set_node({ x = pos.x, y = pos.y + 1, z = pos.z }, { name = "mcl_mushroom:warped_fungus" })
		elseif randomg > 5 and randomg <= 15 then
			local pos1 = { x = pos.x, y = pos.y + 1, z = pos.z }
			generate_warped_tree(pos1)
		elseif randomg > 15 and randomg <= 45 then
			grow_twisting_vines({ x = pos.x, y = pos.y, z = pos.z } ,math.random(1, 4))
		elseif randomg > 45 and randomg <= 50 then
			minetest.set_node({ x = pos.x, y = pos.y + 1, z = pos.z }, { name = "mcl_mushroom:crimson_fungus" })
		elseif randomg > 50 and randomg <= 150 then
			minetest.set_node({ x = pos.x, y = pos.y + 1, z = pos.z }, { name = "mcl_mushroom:nether_sprouts" })
		elseif randomg > 150 and randomg <= 250 then
			minetest.set_node({ x = pos.x, y = pos.y + 1, z = pos.z }, { name = "mcl_mushroom:warped_roots" })
		end
    else
		minetest.swap_node({ x = pos.x, y = pos.y, z = pos.z }, { name = "mcl_nether:netherrack" })
    end
	end
})


--[[ FIXME mobs:spawn({
	name = "mobs_mc:enderman",
	nodes = {"mcl_mushroom:warped_nylium"},
	--min_light = 14,
	interval = 5,
	chance = 10,
	--min_height = 3,
	--max_height = 200,
})]]



minetest.register_node("mcl_mushroom:crimson_fungus", {
	description = S("Crimson Fungus Mushroom"),
	drawtype = "plantlike",
	tiles = { "farming_crimson_fungus.png" },
	inventory_image = "farming_crimson_fungus.png",
	wield_image = "farming_crimson_fungus.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=3,mushroom=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,enderman_takable=1,deco_block=1, compostability=65},
	light_source = 1,
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, -2/16, 3/16 },
	},
	node_placement_prediction = "",
	on_rightclick = function(pos, node, pointed_thing, itemstack)
    if pointed_thing:get_wielded_item():get_name() == "mcl_dye:white" then
		itemstack:take_item()
		local nodepos = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
		if nodepos.name == "mcl_mushroom:crimson_nylium" or nodepos.name == "mcl_nether:netherrack" then
			local random = math.random(1, 5)
			if random == 1 then
				generate_crimson_tree(pos)
			end
		end
    end
	end,
	_mcl_blast_resistance = 0,
	stack_max = 64,
})

minetest.register_node("mcl_mushroom:crimson_roots", {
	description = S("Crimson Roots"),
	drawtype = "plantlike",
	tiles = { "crimson_roots.png" },
	inventory_image = "crimson_roots.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	groups = {dig_immediate=3,vines=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,deco_block=1, shearsy = 1, compostability=65},
	selection_box = {
		type = "fixed",
		fixed = { -6/16, -0.5, -6/16, 6/16, -4/16, 6/16 },
	},
	node_placement_prediction = "",
	_mcl_silk_touch_drop = false,
	_mcl_blast_resistance = 0,
	stack_max = 64,
})

minetest.register_node("mcl_mushroom:crimson_hyphae", {
	description = S("Crimson Hyphae"),
	_doc_items_longdesc = S("The stem of a crimson hyphae"),
	_doc_items_hidden = false,
	tiles = {
		"crimson_hyphae.png",
        "crimson_hyphae.png",
        "crimson_hyphae_side.png",
        "crimson_hyphae_side.png",
        "crimson_hyphae_side.png",
        "crimson_hyphae_side.png",
    },
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	groups = {handy=1,axey=1, tree=1, building_block=1, material_wood=1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_rotate = on_rotate,
	_mcl_blast_resistance = 2,
	stack_max = 64,
	_mcl_hardness = 2,
	_mcl_stripped_variant = "mcl_mushroom:stripped_crimson_hyphae",
})

--Stem bark, stripped stem and bark

minetest.register_node("mcl_mushroom:crimson_hyphae_bark", {
		description = S("Crimson Hyphae"),
		_doc_items_longdesc = S("This is a decorative block surrounded by the bark of an hyphae."),
		tiles = {"crimson_hyphae_side.png"},
		paramtype2 = "facedir",
		on_place = mcl_util.rotate_axis,
		stack_max = 64,
		groups = {handy=1,axey=1, bark=1, building_block=1, material_wood=1,},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		is_ground_content = false,
		on_rotate = on_rotate,
		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
		_mcl_stripped_variant = "mcl_mushroom:stripped_crimson_hyphae_bark",
	})

minetest.register_craft({
		output = "mcl_mushroom:crimson_hyphae_bark 3",
		recipe = {
			{ "mcl_mushroom:crimson_hyphae", "mcl_mushroom:crimson_hyphae" },
			{ "mcl_mushroom:crimson_hyphae", "mcl_mushroom:crimson_hyphae" },
		}
	})


minetest.register_node("mcl_mushroom:stripped_crimson_hyphae", {
		description = S("Stripped Crimson Hyphae"),
		_doc_items_longdesc = S("The stripped stem of a crimson hyphae"),
		_doc_items_hidden = false,
		tiles = {"stripped_crimson_stem_top.png", "stripped_crimson_stem_top.png", "stripped_crimson_stem_side.png"},
		paramtype2 = "facedir",
		on_place = mcl_util.rotate_axis,
		stack_max = 64,
		groups = {handy=1, axey=1, tree=1, building_block=1, material_wood=1},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		on_rotate = on_rotate,
		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
	})

minetest.register_node("mcl_mushroom:stripped_crimson_hyphae_bark", {
		description =  S("Stripped Crimson Hyphae Bark"),
		_doc_items_longdesc = S("The stripped wood of a crimson hyphae"),
		tiles = {"stripped_crimson_stem_side.png"},
		paramtype2 = "facedir",
		on_place = mcl_util.rotate_axis,
		stack_max = 64,
		groups = {handy=1, axey=1, bark=1, building_block=1, material_wood=1},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		is_ground_content = false,
		on_rotate = on_rotate,
		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
	})

minetest.register_craft({
		output = "mcl_mushroom:stripped_crimson_hyphae_bark 3",
		recipe = {
			{ "mcl_mushroom:stripped_crimson_hyphae", "mcl_mushroom:stripped_crimson_hyphae" },
			{ "mcl_mushroom:stripped_crimson_hyphae", "mcl_mushroom:stripped_crimson_hyphae" },
		}
	})

--Wood

minetest.register_node("mcl_mushroom:crimson_hyphae_wood", {
	description = S("Crimson Hyphae Wood"),
	tiles = {"crimson_hyphae_wood.png"},
	groups = {handy=5,axey=1, wood=1,building_block=1, material_wood=1,},
	paramtype2 = "facedir",
	stack_max = 64,
	_mcl_hardness = 2,
})

minetest.register_node("mcl_mushroom:crimson_nylium", {
	description = S("Crimson Nylium"),
	tiles = {
		"crimson_nylium.png",
        "mcl_nether_netherrack.png",
        "mcl_nether_netherrack.png^crimson_nylium_side.png",
		"mcl_nether_netherrack.png^crimson_nylium_side.png",
		"mcl_nether_netherrack.png^crimson_nylium_side.png",
		"mcl_nether_netherrack.png^crimson_nylium_side.png",
	},
	groups = {pickaxey=1, building_block=1, material_stone=1},
	paramtype2 = "facedir",
	stack_max = 64,
	_mcl_hardness = 0.4,
	_mcl_blast_resistance = 0.4,
	is_ground_content = true,
	drop = "mcl_nether:netherrack",
	_mcl_silk_touch_drop = true,
})

minetest.register_node("mcl_mushroom:crimson_checknode", {
	description = S("Crimson Checknode - only to check!"),
	tiles = {
		"mcl_nether_netherrack.png",
        "mcl_nether_netherrack.png",
        "mcl_nether_netherrack.png",
        "mcl_nether_netherrack.png",
        "mcl_nether_netherrack.png",
        "mcl_nether_netherrack.png",
    },
	groups = {pickaxey=1, building_block=1, material_stone=1, not_in_creative_inventory=1},
	paramtype2 = "facedir",
	stack_max = 64,
	_mcl_hardness = 0.4,
	_mcl_blast_resistance = 0.4,
	is_ground_content = true,
	drop = "mcl_nether:netherrack"
})

minetest.register_craft({
	output = "mcl_mushroom:crimson_hyphae_wood 4",
	recipe = {
		{"mcl_mushroom:crimson_hyphae"},
	}
})

minetest.register_craft({
	output = "mcl_mushroom:crimson_nylium 2",
	recipe = {
		{"mcl_nether:nether_wart"},
		{"mcl_nether:netherrack"},
	}
})

mcl_stairs.register_stair_and_slab_simple("crimson_hyphae_wood", "mcl_mushroom:crimson_hyphae_wood", "Crimson Stair", "Crimson Slab", "Double Crimson Slab", "woodlike")

minetest.register_abm({
	label = "mcl_mushroom:crimson_fungus",
	nodenames = {"mcl_mushroom:crimson_fungus"},
	interval = 11,
	chance = 128,
	action = function(pos)
    local nodepos = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
    if nodepos.name == "mcl_mushroom:crimson_nylium" or nodepos.name == "mcl_nether:netherrack" then
		if pos.y < -28400 then
			generate_crimson_tree(pos)
		end
    end
	end
})

minetest.register_abm({
	label = "mcl_mushroom:crimson_checknode",
	nodenames = {"mcl_mushroom:crimson_checknode"},
	interval = 0.1,
	chance = 1,
	action = function(pos)
    local nodepos = minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z})
    if nodepos.name == "air" then
		minetest.swap_node({ x = pos.x, y = pos.y, z = pos.z }, { name = "mcl_mushroom:crimson_nylium" })
		local randomg = math.random(1, 400)
		if randomg <= 10 then
			minetest.set_node({ x = pos.x, y = pos.y + 1, z = pos.z }, { name = "mcl_mushroom:crimson_fungus" })
		elseif randomg > 10 and randomg <= 25 then
			local pos1 = { x = pos.x, y = pos.y + 1, z = pos.z }
			generate_crimson_tree(pos1)
		elseif randomg > 25 and randomg <= 30 then
			minetest.set_node({ x = pos.x, y = pos.y + 1, z = pos.z }, { name = "mcl_mushroom:warped_fungus" })
		elseif randomg > 30 and randomg <= 130 then
			minetest.set_node({ x = pos.x, y = pos.y + 1, z = pos.z }, { name = "mcl_mushroom:crimson_roots" })
		end
    else
		minetest.swap_node({ x = pos.x, y = pos.y, z = pos.z }, { name = "mcl_nether:netherrack" })
    end
	end
})

function generate_warped_tree(pos)
	local breakgrow = false
	local breakgrow2 = false
	-- Tree generator
	-- first and second layer
  	for x = pos.x - 2,pos.x + 2 do
        for y = pos.y + 3, pos.y + 4 do
            for z = pos.z - 2, pos.z + 2 do
        	    if not (minetest.get_node({x = x, y = y, z = z}).name == "air") then 
					breakgrow = true 
				end
        	end
		end
    end

  	-- third and fourth layers
  	for x = pos.x - 1,pos.x + 1 do
  	    for y = pos.y + 5, pos.y + 6 do
			for z = pos.z - 1, pos.z + 1 do
  	            if not (minetest.get_node({x = x, y = y, z = z}).name == "air") then 
					breakgrow = true 
				end
  	        end
  	    end
  	end

 	-- fifth layer
	if not (minetest.get_node({x = pos.x, y = pos.y + 7, z = pos.z}).name == "air") then 
		breakgrow = true 
	end

 	-- Wood
	if not (minetest.get_node({x = pos.x, y = pos.y, z = pos.z}).name == "air") and not (minetest.get_node({x = pos.x, y = pos.y, z = pos.z}).name == "mcl_mushroom:warped_fungus") then 
		breakgrow = true 
	end
 	for y = pos.y + 1, pos.y + 4 do
		if not (minetest.get_node({x = pos.x, y = y, z = pos.z}).name == "air") then 
			breakgrow = true
		end
	end
	if not (minetest.get_node({x = pos.x, y = pos.y, z = pos.z}).name == "air") and not (minetest.get_node({x = pos.x, y = pos.y, z = pos.z}).name == "mcl_mushroom:warped_fungus") then 
		breakgrow2 = true 
	end
	if breakgrow == false then
		-- Warts
		-- first and second layer
		for x = pos.x - 2,pos.x + 2 do
			for y = pos.y + 3, pos.y + 4 do
				for z = pos.z - 2, pos.z + 2 do
					minetest.set_node({x = x, y = y, z = z}, { name = "mcl_mushroom:warped_wart_block" })
				end
			end
		end

		-- third and fourth layers
		for x = pos.x - 1,pos.x + 1 do
			for y = pos.y + 5, pos.y + 6 do
				for z = pos.z - 1, pos.z + 1 do
					minetest.set_node({x = x, y = y, z = z}, { name = "mcl_mushroom:warped_wart_block" })
				end
			end
		end

		-- fifth layer
		minetest.set_node({x = pos.x, y = pos.y + 7, z = pos.z}, { name = "mcl_mushroom:warped_wart_block" })

		-- Fungal
		local randomgenerate = math.random(1, 2)
		if randomgenerate == 1 then
			local randomx = math.random(-2, 2)
			local randomz = math.random(-2, 2)
			minetest.set_node({x = pos.x + randomx, y = pos.y + 3, z = pos.z + randomz}, { name = "mcl_mushroom:shroomlight" })
		end
		local randomgenerate = math.random(1, 8)
		if randomgenerate == 4 then
			local randomx = math.random(-2, 2)
			local randomz = math.random(-2, 2)
			minetest.set_node({x = pos.x + randomx, y = pos.y + 3, z = pos.z + randomz}, { name = "mcl_mushroom:shroomlight" })
		end
		-- Wood
		for y = pos.y, pos.y + 4 do
			minetest.set_node({x = pos.x, y = y, z = pos.z}, { name = "mcl_mushroom:warped_hyphae" })
			--print("Placed at " .. x .. " " .. y .. " " .. z)
		end
	else
		if breakgrow2 == false then 
			minetest.set_node(pos,{ name = "mcl_mushroom:warped_fungus" })
		end
	end
end

function generate_crimson_tree(pos)
	local breakgrow = false
	local breakgrow2 = false
	-- Tree generator
	-- first and second layer
  	for x = pos.x - 2,pos.x + 2 do
        for y = pos.y + 3, pos.y + 4 do
        	for z = pos.z - 2, pos.z + 2 do
        	    if not (minetest.get_node({x = x, y = y, z = z}).name == "air") then 
					breakgrow = true
				end
        	end
		end
    end

  	-- third and fourth layers
  	for x = pos.x - 1,pos.x + 1 do
  	    for y = pos.y + 5, pos.y + 6 do
  	        for z = pos.z - 1, pos.z + 1 do
  	            if not (minetest.get_node({x = x, y = y, z = z}).name == "air") then 
					breakgrow = true
				end
  	        end
  	    end
  	end

 	-- fifth layer
	if not (minetest.get_node({x = pos.x, y = pos.y + 7, z = pos.z}).name == "air") then 
		breakgrow = true
	end

 	-- Wood
	if not (minetest.get_node({x = pos.x, y = pos.y, z = pos.z}).name == "air") and not (minetest.get_node({x = pos.x, y = pos.y, z = pos.z}).name == "mcl_mushroom:crimson_fungus") then 
		breakgrow = true
	end
 	for y = pos.y + 1, pos.y + 4 do
		if not (minetest.get_node({x = pos.x, y = y, z = pos.z}).name == "air") then 
			breakgrow = true
		end
 	end
	if not (minetest.get_node({x = pos.x, y = pos.y, z = pos.z}).name == "air") and not (minetest.get_node({x = pos.x, y = pos.y, z = pos.z}).name == "mcl_mushroom:crimson_fungus") then
		breakgrow2 = true
	end
	if breakgrow == false then
		-- Warts
		-- first and second layer
		for x = pos.x - 2,pos.x + 2 do
			for y = pos.y + 3, pos.y + 4 do
				for z = pos.z - 2, pos.z + 2 do
					minetest.set_node({x = x, y = y, z = z}, { name = "mcl_nether:nether_wart_block" })
				end
			end
		end

		-- third and fourth layers
		for x = pos.x - 1,pos.x + 1 do
			for y = pos.y + 5, pos.y + 6 do
				for z = pos.z - 1, pos.z + 1 do
					minetest.set_node({x = x, y = y, z = z}, { name = "mcl_nether:nether_wart_block" })
				end
			end
		end

		-- fifth layer
		minetest.set_node({x = pos.x, y = pos.y + 7, z = pos.z}, { name = "mcl_nether:nether_wart_block" })

		-- Fungal
		local randomgenerate = math.random(1, 2)
		if randomgenerate == 1 then
			local randomx = math.random(-2, 2)
			local randomz = math.random(-2, 2)
			minetest.set_node({x = pos.x + randomx, y = pos.y + 3, z = pos.z + randomz}, { name = "mcl_mushroom:shroomlight" })
		end
		local randomgenerate = math.random(1, 8)
		if randomgenerate == 4 then
			local randomx = math.random(-2, 2)
			local randomz = math.random(-2, 2)
			minetest.set_node({x = pos.x + randomx, y = pos.y + 3, z = pos.z + randomz}, { name = "mcl_mushroom:shroomlight" })
		end
		 -- Wood
		for y = pos.y, pos.y + 4 do
			minetest.set_node({x = pos.x, y = y, z = pos.z}, { name = "mcl_mushroom:crimson_hyphae" })
			--print("Placed at " .. x .. " " .. y .. " " .. z)
		end
	else
		if breakgrow2 == false then
			minetest.set_node(pos,{ name = "mcl_mushroom:crimson_fungus" }) 
		end
	end
end


--[[
FIXME: Biomes are to rare
FIXME: Decoration don't do generate
WARNING: Outdatet, the biomes gernerate now different, with Ores
-- biomes in test!
minetest.register_biome({
  name = "WarpedForest",
  node_filler = "mcl_nether:netherrack",
  node_stone = "mcl_nether:netherrack",
  node_top = "mcl_mushroom:warped_nylium",
  node_water = "air",
  node_river_water = "air",
  y_min = -29065,
  y_max = -28940,
  heat_point = 100,
  humidity_point = 0,
  _mcl_biome_type = "hot",
  _mcl_palette_index = 19,
})
minetest.register_decoration({
  deco_type = "simple",
  place_on = {"mcl_mushroom:warped_nylium"},
  sidelen = 16,
  noise_params = {
    offset = 0.01,
    scale = 0.0022,
    spread = {x = 250, y = 250, z = 250},
    seed = 2,
    octaves = 3,
    persist = 0.66
  },
  biomes = {"WarpedForest"},
  y_min = -29065,
  y_max = -28940 + 80,
  decoration = "mcl_mushroom:warped_fungus",
})
]]
minetest.register_ore({
	ore_type        = "sheet",
	ore             = "mcl_mushroom:warped_checknode",
	-- Note: Stone is included only for v6 mapgen support. Netherrack is not generated naturally
	-- in v6, but instead set with the on_generated function in mcl_mapgen_core.
	wherein         = {"mcl_nether:netherrack", "mcl_core:stone"},
	clust_scarcity  = 14 * 14 * 14,
	clust_size      = 10,
	y_min           = -29065,
	y_max           = -28940,
	noise_threshold = 0.0,
	noise_params    = {
		offset      = 0.5,
		scale       = 0.1,
		spread      = {x = 8, y = 8, z = 8},
		seed        = 4996,
		octaves     = 1,
		persist     = 0.0
	},
})

minetest.register_ore({
	ore_type        = "sheet",
	ore             = "mcl_mushroom:crimson_checknode",
	-- Note: Stone is included only for v6 mapgen support. Netherrack is not generated naturally
	-- in v6, but instead set with the on_generated function in mcl_mapgen_core.
	wherein         = {"mcl_nether:netherrack", "mcl_core:stone"},
	clust_scarcity  = 10 * 10 * 10,
	clust_size      = 10,
	y_min           = -29065,
	y_max           = -28940,
	noise_threshold = 0.0,
	noise_params    = {
		offset      = 1,
		scale       = 0.5,
		spread      = {x = 12, y = 12, z = 12},
		seed        = 12948,
		octaves     = 1,
		persist     = 0.0
	},
})


minetest.register_decoration({
    deco_type = "simple",
    place_on = {"mcl_mushroom:warped_nylium"},
    sidelen = 16,
    fill_ratio = 0.1,
    biomes = {"Nether"},
    y_max = -28940,
    y_min = -29065,
    decoration = "mcl_mushroom:warped_fungus",
})


minetest.register_decoration({
    deco_type = "simple",
    place_on = {"mcl_mushroom:crimson_nylium"},
    sidelen = 16,
    fill_ratio = 0.1,
    biomes = {"Nether"},
    y_max = -28940,
    y_min = -29065,
    decoration = "mcl_mushroom:crimson_fungus",
})

--Hyphae Stairs and slabs

local barks = {
	{ "warped", S("Warped Bark Stairs"), S("Warped Bark Slab"), S("Double Warped Bark Slab") },
	{ "crimson", S("Crimson Bark Stairs"), S("Crimson Oak Bark Slab"), S("Double Crimson Bark Slab") },
}

for b=1, #barks do
	local bark = barks[b]
	local sub = bark[1].."_hyphae_bark"
	local id = "mcl_mushroom:"..bark[1].."_hyphae"
	
	mcl_stairs.register_stair(sub, id,
			{handy=1,axey=1, bark_stairs=1, material_wood=1},
			{minetest.registered_nodes[id].tiles[3]},
			bark[2],
			mcl_sounds.node_sound_wood_defaults(), 3, 2,
			"woodlike")
	mcl_stairs.register_slab(sub, id,
			{handy=1,axey=1, bark_slab=1, material_wood=1},
			{minetest.registered_nodes[id].tiles[3]},
			bark[3],
			mcl_sounds.node_sound_wood_defaults(), 3, 2,
			bark[4])
end
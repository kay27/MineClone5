local S = minetest.get_translator("mcl_blackstone")
local N = function(s) return s end
local LIGHT_TORCH = 10

stairs = {}

local fire_enabled = minetest.settings:get_bool("enable_fire", true)

local fire_help, eternal_fire_help
if fire_enabled then
	fire_help = S("Fire is a damaging and destructive but short-lived kind of block. It will destroy and spread towards near flammable blocks, but fire will disappear when there is nothing to burn left. It will be extinguished by nearby water and rain. Fire can be destroyed safely by punching it, but it is hurtful if you stand directly in it. If a fire is started above netherrack or a magma block, it will immediately turn into an eternal fire.")
else
	fire_help = S("Fire is a damaging but non-destructive short-lived kind of block. It will disappear when there is no flammable block around. Fire does not destroy blocks, at least not in this world. It will be extinguished by nearby water and rain. Fire can be destroyed safely by punching it, but it is hurtful if you stand directly in it. If a fire is started above netherrack or a magma block, it will immediately turn into an eternal fire.")
end

if fire_enabled then
	eternal_fire_help = S("Eternal fire is a damaging block that might create more fire. It will create fire around it when flammable blocks are nearby. Eternal fire can be extinguished by punches and nearby water blocks. Other than (normal) fire, eternal fire does not get extinguished on its own and also continues to burn under rain. Punching eternal fire is safe, but it hurts if you stand inside.")
else
	eternal_fire_help = S("Eternal fire is a damaging block. Eternal fire can be extinguished by punches and nearby water blocks. Other than (normal) fire, eternal fire does not get extinguished on its own and also continues to burn under rain. Punching eternal fire is safe, but it hurts if you stand inside.")
end


local fire_death_messages = {
	N("@1 has been cooked crisp."),
	N("@1 felt the burn."),
	N("@1 died in the flames."),
	N("@1 died in a fire."),
}

--nodes






local mod_screwdriver = minetest.get_modpath("screwdriver") ~= nil
local on_rotate
if mod_screwdriver then
	on_rotate = screwdriver.rotate_3way
end
local alldirs = {{x=0,y=0,z=1}, {x=1,y=0,z=0}, {x=0,y=0,z=-1}, {x=-1,y=0,z=0}, {x=0,y=-1,z=0}, {x=0,y=1,z=0}}

--Blocks

minetest.register_node("mcl_blackstone:blackstone", {
	description = S("Blackstone"),
	tiles = {"mcl_blackstone_top.png", "mcl_blackstone_top.png", "mcl_blackstone_side.png"},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=2, material_stone=1},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})

minetest.register_node("mcl_blackstone:blackstone_gilded", {
	description = S("Gilded Blackstone"),
	tiles = {"mcl_blackstone_side.png^mcl_blackstone_gilded_side.png"},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=2, material_stone=1, xp=1},
	drop = {
		max_items = 1,
		items = {
			{items = {'mcl_core:gold_nugget 2'},rarity = 5},
			{items = {'mcl_core:gold_nugget 3'},rarity = 5},
			{items = {'mcl_core:gold_nugget 4'},rarity = 5},
			{items = {'mcl_core:gold_nugget 5'},rarity = 5},
			{items = {'mcl_blackstone:blackstone_gilded'}, rarity = 8},
		}
	},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = mcl_core.fortune_drop_ore,
})

minetest.register_node("mcl_blackstone:nether_gold", {
	description = S("Nether Gold Ore"),
	tiles = {"mcl_nether_netherrack.png^mcl_blackstone_gilded_side.png"},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=2, material_stone=1, xp=1},
	drop = {
		max_items = 1,
		items = {
			{items = {'mcl_core:gold_nugget 2'},rarity = 5},
			{items = {'mcl_core:gold_nugget 3'},rarity = 5},
			{items = {'mcl_core:gold_nugget 4'},rarity = 5},
			{items = {'mcl_core:gold_nugget 5'},rarity = 5},
			{items = {'mcl_blackstone:nether_gold'}, rarity = 8},
		}
	},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = mcl_core.fortune_drop_ore,
})
-- Compatibility with Nether Gold mod by NO11:
minetest.register_alias("mcl_nether_gold:nether_gold_ore", "mcl_blackstone:nether_gold")

minetest.register_node("mcl_blackstone:basalt_polished", {
	description = S("Polished Basalt"),
	tiles = {"mcl_blackstone_basalt_top_polished.png", "mcl_blackstone_basalt_top_polished.png", "mcl_blackstone_basalt_side_polished.png"},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	on_rotate = on_rotate,
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=2, material_stone=1},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})


minetest.register_node("mcl_blackstone:basalt", {
	description = S("Basalt"),
	tiles = {"mcl_blackstone_basalt_top.png", "mcl_blackstone_basalt_top.png", "mcl_blackstone_basalt_side.png"},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	on_rotate = on_rotate,
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=2, material_stone=1},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})

--[[minetest.register_node("mcl_blackstone:basalt_smooth", {
	description = S("Smooth Basalt"),
	tiles = {"mcl_blackstone_basalt_smooth.png"},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=2, material_stone=1},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})
]]--


minetest.register_node("mcl_blackstone:blackstone_polished", {
	description = S("Polished Blackstone"),
	tiles = {"mcl_blackstone_polished.png"},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=2, material_stone=1},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})


minetest.register_node("mcl_blackstone:blackstone_chiseled_polished", {
	description = S("Chiseled Polished Blackstone"),
	tiles = {"mcl_blackstone_chiseled_polished.png"},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=2, material_stone=1},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})


minetest.register_node("mcl_blackstone:blackstone_brick_polished", {
	description = S("Polished Blackstone Bricks"),
	tiles = {"mcl_blackstone_polished_bricks.png"},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=2, material_stone=1},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})

minetest.register_node("mcl_blackstone:quartz_brick", {
	description = S("Quartz Bricks"),
	tiles = {"mcl_backstone_quartz_bricks.png"},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	groups = {cracky = 3, pickaxey=2, material_stone=1},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})

minetest.register_node("mcl_blackstone:soul_soil", {
	description = S("Soul Soil"),
	tiles = {"mcl_blackstone_soul_soil.png"},
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_sand_defaults(),
	groups = {cracky = 3, handy=1, shovely=1},
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})


minetest.register_node("mcl_blackstone:soul_fire", {
	description = S("Eternal Soul Fire"),
	_doc_items_longdesc = eternal_fire_help,
	drawtype = "firelike",
	tiles = {
		{
			name = "soul_fire_basic_flame_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
	inventory_image = "soul_fire_basic_flame.png",
	paramtype = "light",
	light_source = 10,
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	damage_per_second = 2,
	_mcl_node_death_message = fire_death_messages,
	groups = {fire = 1, dig_immediate = 3, not_in_creative_inventory = 1, dig_by_piston = 1, destroys_items = 1, set_on_fire=8},
	floodable = true,
	on_flood = function(pos, oldnode, newnode)
		if minetest.get_item_group(newnode.name, "water") ~= 0 then
			minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
		end
	end,
})
--[[
minetest.register_node("mcl_blackstone:chain", {
	description = S("Chain"),
	drawtype = "plantlike",
	_doc_items_longdesc = S(""),
	_doc_items_hidden = false,
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	on_rotate = on_rotate,
	tiles = {"mcl_blackstone_chain.png"},
	inventory_image = "mcl_blackstone_chain_inv.png",
	wield_image = "mcl_blackstone_chain_inv.png",
	selection_box = {
		type = "fixed",
		fixed = {{ -2/16, -8/16, -2/16, 2/16, 8/16, 2/16 }},
	},
	paramtype = "light",
	paramtype2 = "color",
	walkable = false,
	is_ground_content = true,
	groups = {pickaxey=2,deco_block=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 2,
	_mcl_hardness = 1,
})
]]--

--slabs/stairs

mcl_stairs.register_stair_and_slab_simple("blackstone", "mcl_blackstone:blackstone", "Blackstone Stair", "Blackstone Slab", "Double Blackstone Slab")


mcl_stairs.register_stair_and_slab_simple("blackstone_polished", "mcl_blackstone:blackstone_polished", "Polished Blackstone Stair", "Polished Blackstone Slab", "Polished Double Blackstone Slab")


mcl_stairs.register_stair_and_slab_simple("blackstone_chiseled_polished", "mcl_blackstone:blackstone_chiseled_polished", "Polished Chiseled Blackstone Stair", "Chiseled Polished Blackstone Slab", "Double Polished Chiseled Blackstone Slab")


mcl_stairs.register_stair_and_slab_simple("blackstone_brick_polished", "mcl_blackstone:blackstone_brick_polished", "Polished Blackstone Brick Stair", "Polished Blackstone  Brick Slab", "Double Polished Blackstone Brick Slab")

--Wall

mcl_walls.register_wall("mcl_blackstone:wall", S("Blackstone Wall"), "mcl_blackstone:blackstone")


--Redstone Things
--[[
mesecon.register_pressure_plate(
	"mcl_blackstone:pressure_plate_blackstone",
	S("Blackstone Pressure Plate"),
	{"mcl_blackstone.png"},
	{"mcl_blackstone.png"},
	"mcl_blackstone.png",
	nil,
	{{"mcl_blackstone:blackstone", "mcl_blackstone:blackstone"}},
--	mcl_sounds.node_sound_stone_defaults(),
	{pickaxey=1, material_stone=1},
	{ player = true, mob = true },
	S("A Blackstone pressure plate is a redstone component which supplies its surrounding blocks with redstone power while a player or mob stands on top of it. It is not triggered by anything else."))


mesecon.register_button(
	"stone",
	S("Blacktone Button"),
	"mcl_blackstone.png",
	"mcl_blackstone:blackstone",
--	mcl_sounds.node_sound_stone_defaults(),
	{material_stone=1,handy=1,pickaxey=1,cracky=3},
	1,
	false,
	(""),
	"mesecons_button_push")
]]--
--lavacooling


minetest.register_abm({
	label = "Lava cooling (basalt)",
	nodenames = {"group:lava"},
	neighbors = {"mcl_core:ice"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local water = minetest.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+1, z=pos.z+1}, "mcl_core:ice")

		local lavatype = minetest.registered_nodes[node.name].liquidtype

		for w=1, #water do
			local waternode = minetest.get_node(water[w])
			local watertype = minetest.registered_nodes[waternode.name].liquidtype
			if water[w].y < pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(water[w], {name="mcl_blackstone:basalt"})
			elseif lavatype == "flowing" and water[w].y == pos.y and (water[w].x == pos.x or water[w].z == pos.z) then
				minetest.set_node(pos, {name="mcl_blackstone:basalt"})
			elseif lavatype == "flowing" and water[w].y > pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(pos, {name="mcl_blackstone:basalt"})
			end
		end
	end,
})


--[[minetest.register_abm({
	label = "Fire souling",
	nodenames = {"mcl_nether:soul_sand"},
	neighbors = {"mcl_fire:fire"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local water = minetest.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+1, z=pos.z+1}, "mcl_fire:fire")

		local lavatype = minetest.registered_nodes[node.name].liquidtype

		for w=1, #water do
			local waternode = minetest.get_node(water[w])
			local watertype = minetest.registered_nodes[waternode.name].liquidtype
			if water[w].y < pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(water[w], {name="mcl_blackstone:soul_fire"})
			elseif lavatype == "flowing" and water[w].y == pos.y and (water[w].x == pos.x or water[w].z == pos.z) then
				minetest.set_node(pos, {name="mcl_blackstone:soul_fire"})
			elseif lavatype == "flowing" and water[w].y > pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(pos, {name="mcl_blackstone:soul_fire"})
			end
		end
	end,
})
]]--

minetest.register_abm({
	label = "Lava cooling (blackstone)",
	nodenames = {"group:lava"},
	neighbors = {"mcl_core:packed_ice"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local water = minetest.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+1, z=pos.z+1}, "mcl_core:packed_ice")

		local lavatype = minetest.registered_nodes[node.name].liquidtype

		for w=1, #water do
			local waternode = minetest.get_node(water[w])
			local watertype = minetest.registered_nodes[waternode.name].liquidtype
			if water[w].y < pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(water[w], {name="mcl_blackstone:blackstone"})
			elseif lavatype == "flowing" and water[w].y == pos.y and (water[w].x == pos.x or water[w].z == pos.z) then
				minetest.set_node(pos, {name="mcl_blackstone:blackstone"})
			elseif lavatype == "flowing" and water[w].y > pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(pos, {name="mcl_blackstone:blackstone"})
			end
		end
	end,
})

--crafting



minetest.register_craft({
	output = 'mcl_blackstone:blackstone_polished 4',
	recipe = {
		{'mcl_blackstone:blackstone','mcl_blackstone:blackstone'},
		{'mcl_blackstone:blackstone','mcl_blackstone:blackstone'},
	}
})

minetest.register_craft({
	output = 'mcl_blackstone:basalt_polished 4',
	recipe = {
		{'mcl_blackstone:basalt','mcl_blackstone:basalt'},
		{'mcl_blackstone:basalt','mcl_blackstone:basalt'},
	}
})

minetest.register_craft({
	output = 'mcl_blackstone:blackstone_chiseled_polished 2',
	recipe = {
		{'mcl_blackstone:blackstone_polished'},
		{'mcl_blackstone:blackstone_polished'},
	}
})
minetest.register_craft({
	output = 'mcl_blackstone:blackstone_brick_polished 4',
	recipe = {
		{'mcl_blackstone:blackstone_polished','mcl_blackstone:blackstone_polished'},
		{'mcl_blackstone:blackstone_polished','mcl_blackstone:blackstone_polished'},
	}
})


minetest.register_craft({
	output = 'mcl_tools:pick_stone',
	recipe = {
		{'mcl_blackstone:blackstone', 'mcl_blackstone:blackstone', 'mcl_blackstone:blackstone'},
		{'', 'mcl_core:stick', ''},
		{'', 'mcl_core:stick', ''},
	}
})


minetest.register_craft({
	output = 'mcl_tools:axe_stone',
	recipe = {
		{'mcl_blackstone:blackstone', 'mcl_blackstone:blackstone'},
		{'mcl_blackstone:blackstone', 'mcl_core:stick'},
		{'', 'mcl_core:stick'},
	}
})


minetest.register_craft({
	output = 'mcl_tools:axe_stone',
	recipe = {
		{'mcl_blackstone:blackstone', 'mcl_blackstone:blackstone'},
		{'mcl_core:stick',  'mcl_blackstone:blackstone'},
		{'', 'mcl_core:stick'},
	}
})


minetest.register_craft({
	output = 'mcl_tools:shovel_stone',
	recipe = {
		{'mcl_blackstone:blackstone'},
		{'mcl_core:stick'},
		{'mcl_core:stick'},
	}
})


minetest.register_craft({
	output = 'mcl_tools:sword_stone',
	recipe = {
		{'mcl_blackstone:blackstone'},
		{'mcl_blackstone:blackstone'},
		{'mcl_core:stick'},
	}
})


minetest.register_craft({
	output = "mcl_farming:hoe_stone",
	recipe = {
		{"mcl_blackstone:blackstone", "mcl_blackstone:blackstone"},
		{"", "mcl_core:stick"},
		{"", "mcl_core:stick"}
	}
})
minetest.register_craft({
	output = "mcl_farming:hoe_stone",
	recipe = {
		{"mcl_blackstone:blackstone", "mcl_blackstone:blackstone"},
		{"mcl_core:stick", ""},
		{"mcl_core:stick", ""}
	}
})

minetest.register_craft({
	output = "mcl_furnaces:furnace",
	recipe = {
		{"mcl_blackstone:blackstone", "mcl_blackstone:blackstone", "mcl_blackstone:blackstone"},
		{"mcl_blackstone:blackstone", "",			   "mcl_blackstone:blackstone"},
		{"mcl_blackstone:blackstone", "mcl_blackstone:blackstone", "mcl_blackstone:blackstone"}
	}
})




minetest.register_craft({
	output = 'mcl_core:packed_ice',
	recipe = {
		{'mcl_core:ice','mcl_core:ice'},
		{'mcl_core:ice','mcl_core:ice'},
	}
})

minetest.register_craft({
	output = 'mcl_blackstone:quartz_brick 4',
	recipe = {
		{'mcl_nether:quartz_block','mcl_nether:quartz_block'},
		{'mcl_nether:quartz_block','mcl_nether:quartz_block'},
	}
})


minetest.register_craft({
	type = "cooking",
	output = 'mcl_core:gold_ingot',
	recipe = 'mcl_blackstone:nether_gold',
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = 'mcl_core:gold_ingot',
	recipe = 'mcl_blackstone:blackstone_gilded',
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = 'mcl_nether:quartz_smooth',
	recipe = 'mcl_nether:quartz_block',
	cooktime = 10,
})

--Generating


local specialstones = { "mcl_blackstone:blackstone", "mcl_blackstone:basalt", "mcl_blackstone:soul_soil" }
for s=1, #specialstones do
	local node = specialstones[s]
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"mcl_nether:netherrack"},
		clust_scarcity = 830,
		clust_num_ores = 28,
		clust_size     = 3,
		y_min          = mcl_vars.mg_nether_min,
		y_max          = mcl_vars.mg_nether_max,
		noise_params = {
			offset  = 0,
			scale   = 1,
			spread  = {x=250, y=250, z=250},
			seed    = 12345,
			octaves = 3,
			persist = 0.6,
			lacunarity = 2,
			flags = "defaults",
		},
	})
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"mcl_nether:netherrack"},
		clust_scarcity = 8*8*8,
		clust_num_ores = 40,
		clust_size     = 5,
		y_min          = mcl_vars.mg_nether_min,
		y_max          = mcl_vars.mg_nether_max,
		noise_params = {
			offset  = 0,
			scale   = 1,
			spread  = {x=250, y=250, z=250},
			seed    = 12345,
			octaves = 3,
			persist = 0.6,
			lacunarity = 2,
			flags = "defaults",
		},
	})
end

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_blackstone:blackstone_gilded",
		wherein        = "mcl_blackstone:blackstone",
		clust_scarcity = 4775,
		clust_num_ores = 2,
		clust_size     = 2,
		y_min          = mcl_vars.mg_nether_min,
		y_max          = mcl_vars.mg_nether_max,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_blackstone:nether_gold",
		wherein        = "mcl_nether:netherrack",
		clust_scarcity = 830,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = mcl_vars.mg_nether_min,
		y_max          = mcl_vars.mg_nether_max,
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_blackstone:nether_gold",
		wherein        = "mcl_nether:netherrack",
		clust_scarcity = 1660,
		clust_num_ores = 4,
		clust_size     = 2,
		y_min          = mcl_vars.mg_nether_min,
		y_max          = mcl_vars.mg_nether_max,
	})



--This is in progress

--[[
local specialstones = { "mcl_blackstone:blackstone"}
for s=1, #specialstones do
	local node = specialstones[s]
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"mcl_blackstone:basalt"},
		clust_scarcity = 8*8*8,
		clust_num_ores = 28,
		clust_size     = 3,
		y_min          = mcl_vars.mg_nether_min,
		y_max          = mcl_vars.mg_nether_max,
	})
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"mcl_blackstone:basalt"},
		clust_scarcity = 8*8*8,
		clust_num_ores = 40,
		clust_size     = 5,
		y_min          = mcl_vars.mg_nether_min,
		y_max          = mcl_vars.mg_nether_max,
	})
end






--Biomes



	minetest.register_biome({
		name = "Basalt_Deltas",
		node_filler = "mcl_blackstone:basalt",
		node_stone = "mcl_blackstone:basalt",
		node_water = "air",
		node_river_water = "air",
		y_min = mcl_vars.mg_nether_min,
		node_riverbed = "mcl_core:lava_source",
		depth_riverbed = 2,
		y_max = mcl_vars.mg_nether_max,
		humidity_point = 36,
		heat_point = 100,
		spread = {x = 1, y = 1, z = 1},
		humidity_point = 0,
		_mcl_biome_type = "hot",
		_mcl_palette_index = 12,
	})



	-- Magma blocks
	minetest.register_ore({
		ore_type       = "blob",
		ore            = "mcl_nether:magma",
		wherein         = {"mcl_blackstone:basalt", "mcl_core:stone"},
		clust_scarcity = 8*8*8,
		clust_num_ores = 45,
		clust_size     = 6,
		y_min          = mcl_worlds.layer_to_y(23, "nether"),
		y_max          = mcl_worlds.layer_to_y(37, "nether"),
	})
	minetest.register_ore({
		ore_type       = "blob",
		ore            = "mcl_nether:magma",
		wherein        = {"mcl_blackstone:basalt"},
		clust_scarcity = 10*10*10,
		clust_num_ores = 65,
		clust_size     = 8,
		y_min          = mcl_worlds.layer_to_y(23, "nether"),
		y_max          = mcl_worlds.layer_to_y(37, "nether"),
	})

	-- Glowstone
	minetest.register_ore({
		ore_type        = "blob",
		ore             = "mcl_nether:glowstone",
		wherein         = {"mcl_blackstone:basalt", "mcl_core:stone"},
		clust_scarcity  = 26 * 26 * 26,
		clust_size      = 5,
		y_min           = mcl_vars.mg_lava_nether_max + 10,
		y_max           = mcl_vars.mg_nether_max,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.1,
			spread = {x = 5, y = 5, z = 5},
			seed = 17676,
			octaves = 1,
			persist = 0.0
		},
	})

	-- Gravel (Nether)
	minetest.register_ore({
		ore_type        = "sheet",
		ore             = "mcl_core:gravel",
		wherein         = {"mcl_blackstone:basalt", "mcl_core:stone"},
		column_height_min = 1,
		column_height_max = 1,
		column_midpoint_factor = 0,
		y_min           = mcl_worlds.layer_to_y(63, "nether"),
		-- This should be 65, but for some reason with this setting, the sheet ore really stops at 65. o_O
		y_max           = mcl_worlds.layer_to_y(65+2, "nether"),
		noise_threshold = 0.2,
		noise_params    = {
			offset = 0.0,
			scale = 0.5,
			spread = {x = 20, y = 20, z = 20},
			seed = 766,
			octaves = 3,
			persist = 0.6,
		},
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:nether_lava_source",
		wherein         = {"mcl_blackstone:basalt", "mcl_core:stone"},
		clust_scarcity = 500,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min           = mcl_vars.mg_nether_min,
		y_max           = mcl_vars.mg_lava_nether_max + 1,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:nether_lava_source",
		wherein         = {"mcl_blackstone:basalt", "mcl_core:stone"},
		clust_scarcity = 1000,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min           = mcl_vars.mg_lava_nether_max + 2,
		y_max           = mcl_vars.mg_lava_nether_max + 12,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:nether_lava_source",
		wherein         = {"mcl_blackstone:basalt", "mcl_core:stone"},
		clust_scarcity = 2000,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min           = mcl_vars.mg_lava_nether_max + 13,
		y_max           = mcl_vars.mg_lava_nether_max + 48,
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:nether_lava_source",
		wherein         = {"mcl_blackstone:basalt", "mcl_core:stone"},
		clust_scarcity = 3500,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min           = mcl_vars.mg_lava_nether_max + 49,
		y_max           = mcl_vars.mg_nether_max,
	})


local specialstones = { "mcl_nether:netherrack"}
for s=1, #specialstones do
	local node = specialstones[s]
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"mcl_blackstone:basalt"},
		clust_scarcity = 8*8*8,
		clust_num_ores = 28,
		clust_size     = 3,
		y_min          = mcl_vars.mg_nether_min,
		y_max          = mcl_vars.mg_nether_max,
	})
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"mcl_blackstone:basalt"},
		clust_scarcity = 8*8*8,
		clust_num_ores = 40,
		clust_size     = 5,
		y_min          = mcl_vars.mg_nether_min,
		y_max          = mcl_vars.mg_nether_max,
	})
end
]]--

mcl_torches.register_torch({
	name = "soul_torch",
	description = S("Soul Torch"),
	doc_items_longdesc = S("Torches are light sources which can be placed at the side or on the top of most blocks."),
	doc_items_hidden = false,
	icon = "soul_torch_on_floor.png",
	tiles = {{
		name = "soul_torch_on_floor_animated.png",
		animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
	}},
	light = 10,
	groups = {dig_immediate = 3, deco_block = 1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	particles = true
})

minetest.register_craft({
	output = "mcl_blackstone:soul_torch 4",
	recipe = {
		{ "mcl_nether:soul_sand" },
		{ "mcl_core:stick" },
	}
})

mcl_blackstone = {}

function mcl_blackstone.register_lantern(name, def)
	local itemstring_floor = "mcl_blackstone:"..name.."_floor"
	local itemstring_ceiling = "mcl_blackstone:"..name.."_ceiling"

	local sounds = mcl_sounds.node_sound_metal_defaults()

	minetest.register_node(itemstring_floor, {
		description = def.description,
		_doc_items_longdesc = def.longdesc,
		drawtype = "mesh",
		mesh = "mcl_blackstone_lantern_floor.obj",
		inventory_image = def.texture_inv,
		wield_image = def.texture_inv,
		tiles = {
			{
				name = def.texture,
				animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
			}
		},
		use_texture_alpha = "clip",
		paramtype = "light",
		paramtype2 = "wallmounted",
		place_param2 = 1,
		node_placement_prediction = "",
		sunlight_propagates = true,
		light_source = def.light_level,
		groups = {pickaxey = 1, attached_node = 1, deco_block = 1, lantern = 1},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.1875, -0.5, -0.1875, 0.1875, -0.0625, 0.1875},
				{-0.125, -0.0625, -0.125, 0.125, 0.0625, 0.125},
				{-0.0625, -0.5, -0.0625, 0.0625, 0.1875, 0.0625},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.1875, -0.5, -0.1875, 0.1875, -0.0625, 0.1875},
				{-0.125, -0.0625, -0.125, 0.125, 0.0625, 0.125},
				{-0.0625, -0.5, -0.0625, 0.0625, 0.1875, 0.0625},
			},
		},
		sounds = sounds,
		on_place = function(itemstack, placer, pointed_thing)
			local new_stack = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
			if new_stack then
				return new_stack
			end

			local under = pointed_thing.under
			local above = pointed_thing.above

			local wdir = minetest.dir_to_wallmounted(vector.subtract(under, above))
			local fakestack = itemstack
			if wdir == 0 then
				fakestack:set_name(itemstring_ceiling)
			elseif wdir == 1 then
				fakestack:set_name(itemstring_floor)
			end

			local success
			itemstack, success = minetest.item_place(fakestack, placer, pointed_thing, wdir)
			itemstack:set_name(itemstring_floor)

			if success then
				minetest.sound_play(sounds.place, {pos = under, gain = 1}, true)
			end

			return itemstack
		end,
		on_rotate = false,
		_mcl_hardness = 3.5,
		_mcl_blast_resistance = 3.5,
	})

	minetest.register_node(itemstring_ceiling, {
		description = def.description,
		_doc_items_create_entry = false,
		drawtype = "mesh",
		mesh = "mcl_blackstone_lantern_ceiling.obj",
		tiles = {
			{
				name = def.texture,
				animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
			}
		},
		use_texture_alpha = "clip",
		paramtype = "light",
		paramtype2 = "wallmounted",
		place_param2 = 0,
		node_placement_prediction = "",
		sunlight_propagates = true,
		light_source = def.light_level,
		groups = {pickaxey = 1, attached_node = 1, deco_block = 1, lantern = 1, not_in_creative_inventory = 1},
		drop = itemstring_floor,
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.1875, 0, -0.1875, 0.1875, 0.4375, 0.1875},
				{-0.125, -0.125, -0.125, 0.125, 0, 0.125},
				{-0.0625, -0.5, -0.0625, 0.0625, -0.125, 0.0625},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.1875, 0, -0.1875, 0.1875, 0.4375, 0.1875},
				{-0.125, -0.125, -0.125, 0.125, 0, 0.125},
				{-0.0625, -0.5, -0.0625, 0.0625, -0.125, 0.0625},
			},
		},
		sounds = sounds,
		on_rotate = false,
		_mcl_hardness = 3.5,
		_mcl_blast_resistance = 3.5,
	})
end

mcl_blackstone.register_lantern("soul_lantern", {
	description = S("Soul Lantern"),
	longdesc = S("Lanterns are light sources which can be placed on the top or the bottom of most blocks."),
	texture = "mcl_blackstone_soul_lantern.png",
	texture_inv = "mcl_blackstone_soul_lantern_inv.png",
	light_level = 10,
})

minetest.register_craft({
	output = "mcl_blackstone:soul_lantern_floor",
	recipe = {
		{"mcl_core:iron_nugget", "mcl_core:iron_nugget", "mcl_core:iron_nugget"},
		{"mcl_core:iron_nugget", "mcl_blackstone:soul_torch", "mcl_core:iron_nugget"},
		{"mcl_core:iron_nugget", "mcl_core:iron_nugget", "mcl_core:iron_nugget"},
	},
})

minetest.register_alias("mcl_blackstone:soul_lantern", "mcl_blackstone:soul_lantern_floor")
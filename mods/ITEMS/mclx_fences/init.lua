local S = minetest.get_translator(minetest.get_current_modname())

-- Red Nether Brick Fence and Fence Gate

mcl_fences.register_fence_and_fence_gate(
	"red_nether_brick_fence",
	S("Red Nether Brick Fence"), S("Red Nether Brick Fence Gate"),
	"mcl_fences_fence_red_nether_brick.png",
	{pickaxey=1, deco_block=1, fence_nether_brick=1},
	minetest.registered_nodes["mcl_nether:red_nether_brick"]._mcl_hardness,
	minetest.registered_nodes["mcl_nether:red_nether_brick"]._mcl_blast_resistance,
	{"group:fence_nether_brick"},
	mcl_sounds.node_sound_stone_defaults(), "mcl_fences_nether_brick_fence_gate_open", "mcl_fences_nether_brick_fence_gate_close", 1, 1,
	"mcl_fences_fence_gate_red_nether_brick.png")

-- Nether Brick Fence Gate

mcl_fences.register_fence_gate(
	"nether_brick_fence",
	S("Nether Brick Fence Gate"),
	"mcl_fences_fence_gate_nether_brick.png",
	{pickaxey=1, deco_block=1, fence_nether_brick=1},
	minetest.registered_nodes["mcl_nether:nether_brick"]._mcl_hardness,
	minetest.registered_nodes["mcl_nether:nether_brick"]._mcl_blast_resistance,
	mcl_sounds.node_sound_stone_defaults(), "mcl_fences_nether_brick_fence_gate_open", "mcl_fences_nether_brick_fence_gate_close", 1, 1)

-- Crimson Wood Fence and Fence Gate

mcl_fences.register_fence_and_fence_gate(
	"crimson_wood_fence",
	S("Crimson Hyphae Wood Fence"), S("Crimson Hyphae Wood Fence Gate"),
	"mcl_fences_fence_crimson.png",
	{handy=1,axey=1, fence_wood=1},
	minetest.registered_nodes["mcl_core:wood"]._mcl_hardness,
	minetest.registered_nodes["mcl_core:wood"]._mcl_blast_resistance,
	{"group:fence_wood"},
	mcl_sounds.node_sound_wood_defaults(), "mcl_fences_nether_brick_gate_open", "mcl_fences_nether_brick_fence_gate_close", 1, 1,
	"mcl_fences_fence_gate_crimson.png")

-- Warped Wood Fence and Fence Gate

mcl_fences.register_fence_and_fence_gate(
	"warped_wood_fence",
	S("Warped Hyphae Wood Fence"), S("Warped Hyphae Wood Fence Gate"),
	"mcl_fences_fence_warped.png",
	{handy=1,axey=1, fence_wood=1},
	minetest.registered_nodes["mcl_core:wood"]._mcl_hardness,
	minetest.registered_nodes["mcl_core:wood"]._mcl_blast_resistance,
	{"group:fence_wood"},
	mcl_sounds.node_sound_wood_defaults(), "mcl_fences_nether_brick_fence_gate_open", "mcl_fences_nether_brick_fence_gate_close", 1, 1,
	"mcl_fences_fence_gate_warped.png")


-- Crafting

minetest.register_craft({
	output = "mclx_fences:red_nether_brick_fence 6",
	recipe = {
		{"mcl_nether:red_nether_brick", "mcl_nether:netherbrick", "mcl_nether:red_nether_brick"},
		{"mcl_nether:red_nether_brick", "mcl_nether:netherbrick", "mcl_nether:red_nether_brick"},
	}
})

minetest.register_craft({
	output = "mclx_fences:crimson_wood_fence 3",
	recipe = {
		{"mcl_mushroom:crimson_hyphae_wood", "mcl_core:stick", "mcl_mushroom:crimson_hyphae_wood"},
		{"mcl_mushroom:crimson_hyphae_wood", "mcl_core:stick", "mcl_mushroom:crimson_hyphae_wood"},
	}
})

minetest.register_craft({
	output = "mclx_fences:warped_wood_fence 3",
	recipe = {
		{"mcl_mushroom:warped_hyphae_wood", "mcl_core:stick", "mcl_mushroom:warped_hyphae_wood"},
		{"mcl_mushroom:warped_hyphae_wood", "mcl_core:stick", "mcl_mushroom:warped_hyphae_wood"},
	}
})

minetest.register_craft({
	output = "mclx_fences:red_nether_brick_fence_gate 2",
	recipe = {
		{"mcl_nether:netherbrick", "mcl_nether:red_nether_brick", "mcl_nether:nether_wart_item"},
		{"mcl_nether:nether_wart_item", "mcl_nether:red_nether_brick", "mcl_nether:netherbrick"},
	}
})

minetest.register_craft({
	output = "mclx_fences:nether_brick_fence_gate 2",
	recipe = {
		{"mcl_nether:netherbrick", "mcl_nether:nether_brick", "mcl_nether:netherbrick"},
		{"mcl_nether:netherbrick", "mcl_nether:nether_brick", "mcl_nether:netherbrick"},
	}
})

minetest.register_craft({
	output = "mclx_fences:crimson_wood_fence_gate",
	recipe = {
		{"mcl_core:stick", "mcl_mushroom:crimson_hyphae_wood", "mcl_core:stick"},
		{"mcl_core:stick", "mcl_mushroom:crimson_hyphae_wood", "mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mclx_fences:warped_wood_fence_gate",
	recipe = {
		{"mcl_core:stick", "mcl_mushroom:warped_hyphae_wood", "mcl_core:stick"},
		{"mcl_core:stick", "mcl_mushroom:warped_hyphae_wood", "mcl_core:stick"},
	}
})

-- Aliases for mcl_supplemental
minetest.register_alias("mcl_supplemental:red_nether_brick_fence", "mclx_fences:red_nether_brick_fence")

minetest.register_alias("mcl_supplemental:nether_brick_fence_gate", "mclx_fences:nether_brick_fence_gate")
minetest.register_alias("mcl_supplemental:nether_brick_fence_gate_open", "mclx_fences:nether_brick_fence_gate_open")

minetest.register_alias("mcl_supplemental:red_nether_brick_fence_gate", "mclx_fences:red_nether_brick_fence_gate")
minetest.register_alias("mcl_supplemental:red_nether_brick_fence_gate_open", "mclx_fences:red_nether_brick_fence_gate_open")

minetest.register_alias("mcl_supplemental:crimson_wood_fence", "mclx_fences:crimson_wood_fence")

minetest.register_alias("mcl_supplemental:crimson_wood_fence_gate", "mclx_fences:crimson_wood_fence_gate")
minetest.register_alias("mcl_supplemental:crimson_wood_fence_gate_open", "mclx_fences:crimson_wood_fence_gate_open")

minetest.register_alias("mcl_supplemental:warped_wood_fence", "mclx_fences:warped_wood_fence")

minetest.register_alias("mcl_supplemental:warped_wood_fence_gate", "mclx_fences:warped_wood_fence_gate")
minetest.register_alias("mcl_supplemental:warped_wood_fence_gate_open", "mclx_fences:warped_wood_fence_gate_open")
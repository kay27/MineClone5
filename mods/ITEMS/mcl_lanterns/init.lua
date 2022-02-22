local S = minetest.get_translator("mcl_lanterns")
local N = function(s) return s end

minetest.register_node("mcl_lanterns:lantern", {
	tiles = {
		"lantern_top.png",
		"lantern_bottom.png",
		"lantern.png",
		"lantern.png",
		"lantern.png",
		"lantern.png",
	},
	groups = {pickaxey=3},
	inventory_image = "lantern.png",
	light_source = 15,
	description = S("Lantern"),
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	_mcl_hardness = 1,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.1875, -0.5000, -0.1875, 0.1875, -0.06250, 0.1875},
			{-0.1250, -0.06250, -0.1250, 0.1250, 0.06250, 0.1250},
			{-0.06250, 0.1250, -0.006250, 0.06250, 0.1875, 0.006250},
			{-0.06250, 0.06250, -0.006250, -0.03125, 0.1250, 0.006250},
			{0.03125, 0.06250, -0.006250, 0.06250, 0.1250, 0.006250},
		}
	},
	stack_max = 64,
})



minetest.register_craft({
	type = "shaped",
	output = "mcl_lanterns:lantern",
	recipe = {
		{"mcl_core:iron_nugget", "mcl_core:iron_nugget","mcl_core:iron_nugget"},
		{"mcl_core:iron_nugget", "mcl_core:torch",  "mcl_core:iron_nugget"},
		{"mcl_core:iron_nugget", "mcl_core:iron_nugget",  "mcl_core:iron_nugget"}
	}
})
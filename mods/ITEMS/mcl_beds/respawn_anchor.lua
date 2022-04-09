--TODO: Add sounds for the respawn anchor

--Nether ends at y -29077
--Nether roof at y -28933
local S = minetest.get_translator(minetest.get_current_modname())
--local mod_doc = minetest.get_modpath("doc") -> maybe add documentation ?

minetest.register_node("mcl_beds:respawn_anchor",{
	description=S("Respawn Anchor"),
	tiles = {
		"respawn_anchor_top_off.png",
		"respawn_anchor_bottom.png",
		"respawn_anchor_side0.png"
	},
	drawtype = "nodebox",
	node_box=  { --Reused the composter nodebox, since it is basicly the same
		type = "fixed",
		fixed = {
			{-0.5,   -0.5, -0.5,  -0.375, 0.5,   0.5},   -- Left wall
			{ 0.375, -0.5, -0.5,   0.5,   0.5,   0.5},   -- Right wall
			{-0.375, -0.5,  0.375, 0.375, 0.5,   0.5},   -- Back wall
			{-0.375, -0.5, -0.5,   0.375, 0.5,  -0.375}, -- Front wall
			{-0.5,   -0.5, -0.5,   0.5,   -0.47, 0.5},   -- Bottom level, -0.47 because -0.5 is so low that you can see the texture of the block below through
		}
	},
	on_rightclick = function(pos, node, player, itemstack)
		if itemstack.get_name(itemstack) == "mcl_nether:glowstone" then
			minetest.set_node(pos, {name="mcl_beds:respawn_anchor_charged_1"})
			itemstack:take_item()
		else
			if pos.y < -29077 or pos.y > -28933 then
				mcl_explosions.explode(pos, 5, {drop_chance = 0, fire = true})
			end
		end
	end,
	groups = {pickaxey=1, material_stone=1},
	_mcl_hardness = 22.5
})
minetest.register_node("mcl_beds:respawn_anchor_charged_1",{
	description=S("Respawn Anchor"),
	tiles = {
		"portal.png",
		"respawn_anchor_bottom.png",
		"respawn_anchor_side1.png"
	},
	drawtype = "nodebox",
	node_box=  { --Reused the composter nodebox, since it is basicly the same
		type = "fixed",
		fixed = {
			{-0.5,   -0.5, -0.5,  -0.375, 0.5,   0.5},   -- Left wall
			{ 0.375, -0.5, -0.5,   0.5,   0.5,   0.5},   -- Right wall
			{-0.375, -0.5,  0.375, 0.375, 0.5,   0.5},   -- Back wall
			{-0.375, -0.5, -0.5,   0.375, 0.5,  -0.375}, -- Front wall
			{-0.5,   -0.5, -0.5,   0.5,   0.5, 0.5},   -- Bottom level
		}
	},
	on_rightclick = function(pos, node, player, itemstack)
		if itemstack.get_name(itemstack) == "mcl_nether:glowstone" then
			minetest.set_node(pos, {name="mcl_beds:respawn_anchor_charged_2"})
			itemstack:take_item()
		else
			if pos.y < -29077 or pos.y > -28933 then
				mcl_explosions.explode(pos, 5, {drop_chance = 0, fire = true})
			else
				mcl_spawn.set_spawn_pos(player, pos, nil)
			end
		end
	end,
	groups = {pickaxey=1, material_stone=1, not_in_creative_inventory=1},
	_mcl_hardness = 22.5
})

minetest.register_node("mcl_beds:respawn_anchor_charged_2",{
	description=S("Respawn Anchor"),
	tiles = {
		"portal.png",
		"respawn_anchor_bottom.png",
		"respawn_anchor_side2.png"
	},
	drawtype = "nodebox",
	node_box=  { --Reused the composter nodebox, since it is basicly the same
		type = "fixed",
		fixed = {
			{-0.5,   -0.5, -0.5,  -0.375, 0.5,   0.5},   -- Left wall
			{ 0.375, -0.5, -0.5,   0.5,   0.5,   0.5},   -- Right wall
			{-0.375, -0.5,  0.375, 0.375, 0.5,   0.5},   -- Back wall
			{-0.375, -0.5, -0.5,   0.375, 0.5,  -0.375}, -- Front wall
			{-0.5,   -0.5, -0.5,   0.5,   0.5, 0.5},   -- Bottom level
		}
	},
	on_rightclick = function(pos, node, player, itemstack)
		if itemstack.get_name(itemstack) == "mcl_nether:glowstone" then
			minetest.set_node(pos, {name="mcl_beds:respawn_anchor_charged_3"})
			itemstack:take_item()
		else
			if pos.y < -29077 or pos.y > -28933 then
				mcl_explosions.explode(pos, 5, {drop_chance = 0, fire = true})
		else
				mcl_spawn.set_spawn_pos(player, pos, nil)
			end
		end
	end,
	groups = {pickaxey=1, material_stone=1, not_in_creative_inventory=1},
	_mcl_hardness = 22.5
})

minetest.register_node("mcl_beds:respawn_anchor_charged_3",{
	description=S("Respawn Anchor"),
	tiles = {
		"portal.png",
		"respawn_anchor_bottom.png",
		"respawn_anchor_side3.png"
	},
	drawtype = "nodebox",
	node_box=  { --Reused the composter nodebox, since it is basicly the same
		type = "fixed",
		fixed = {
			{-0.5,   -0.5, -0.5,  -0.375, 0.5,   0.5},   -- Left wall
			{ 0.375, -0.5, -0.5,   0.5,   0.5,   0.5},   -- Right wall
			{-0.375, -0.5,  0.375, 0.375, 0.5,   0.5},   -- Back wall
			{-0.375, -0.5, -0.5,   0.375, 0.5,  -0.375}, -- Front wall
			{-0.5,   -0.5, -0.5,   0.5,   0.5, 0.5},   -- Bottom level
		}
	},
	on_rightclick = function(pos, node, player, itemstack)
		if itemstack.get_name(itemstack) == "mcl_nether:glowstone" then
			minetest.set_node(pos, {name="mcl_beds:respawn_anchor_charged_4"})
			itemstack:take_item()
		else
			if pos.y < -29077 or pos.y > -28933 then
				mcl_explosions.explode(pos, 5, {drop_chance = 0, fire = true})
			else
				mcl_spawn.set_spawn_pos(player, pos, nil)
			end
		end
	end,
	groups = {pickaxey=1, material_stone=1, not_in_creative_inventory=1},
	_mcl_hardness = 22.5
})

minetest.register_node("mcl_beds:respawn_anchor_charged_4",{
	description=S("Respawn Anchor"),
	tiles = {
		"portal.png",
		"respawn_anchor_bottom.png",
		"respawn_anchor_side4.png"
	},
	drawtype = "nodebox",
	node_box=  { --Reused the composter nodebox, since it is basicly the same
		type = "fixed",
		fixed = {
		  {-0.5,   -0.5, -0.5,  -0.375, 0.5,   0.5},   -- Left wall
			{ 0.375, -0.5, -0.5,   0.5,   0.5,   0.5},   -- Right wall
			{-0.375, -0.5,  0.375, 0.375, 0.5,   0.5},   -- Back wall
			{-0.375, -0.5, -0.5,   0.375, 0.5,  -0.375}, -- Front wall
			{-0.5,   -0.5, -0.5,   0.5,   0.5, 0.5},   -- Bottom level
		}
	},
	on_rightclick = function(pos, node, player, itemstack)
		if pos.y < -29077 or pos.y > -28933 then
			mcl_explosions.explode(pos, 5, {drop_chance = 0, fire = true})
		else
			mcl_spawn.set_spawn_pos(player, pos, nil)
			awards.unlock(player:get_player_name(), "mcl:notQuiteNineLives")
		end
	end,
	groups = {pickaxey=1, material_stone=1, not_in_creative_inventory=1},
	_mcl_hardness = 22.5
})

minetest.register_craft({ output = "mcl_beds:respawn_anchor",
	recipe = { 
			{"mcl_core:crying_obsidian", "mcl_core:crying_obsidian", "mcl_core:crying_obsidian"},
			{"mcl_nether:glowstone", "mcl_nether:glowstone", "mcl_nether:glowstone"},
			{"mcl_core:crying_obsidian", "mcl_core:crying_obsidian", "mcl_core:crying_obsidian"} 
		} 
	}) 

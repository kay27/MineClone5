local S = minetest.get_translator("mcl_composter")

-- Composter mod, adds composters.

-- Convenience function because the composer nodeboxes are very similar
local create_composter_nodebox = function(compost_level)
	local f_y
	f_y = (compost_level+1)/8 - (1/2)	-- compost_level goes from 0 to 7
	return {
		type = "fixed",
		fixed = {
			{-1/2, -1/2, -1/2, -3/8,  1/2,  1/2},	-- left
			{ 3/8, -1/2, -1/2,  1/2,  1/2,  1/2},	-- right
			{-3/8, -1/2,  3/8,  3/8,  1/2,  1/2},	-- back
			{-3/8, -1/2, -1/2,  3/8,  1/2, -3/8},	-- front
			{-1/2, -1/2, -1/2,  1/2,  f_y,  1/2},	-- floor
		}
	}
end

local composter_nodeboxes = {}
for w=0,7 do
	composter_nodeboxes[w] = create_composter_nodebox(w)
end

-- Empty composter
minetest.register_node("mcl_composters:composter", {
	description = S("Composter"),
	_doc_items_longdesc = S("Composters convert food and plant material into bone meal."),
	_doc_items_usagehelp = S("Place food or plant matter into the cauldron to fill it with compost. When it is full, you can retrieve bone meal."),
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	groups = {handy=1, axey=1, deco_block=1, material_wood=1, composter=1},
	node_box = composter_nodeboxes[0],
	selection_box = { type = "regular" },
	tiles = {
		"default_wood.png^default_wood.png",	-- inner^top
		"default_wood.png^default_wood.png",	-- inner^bottom
		"default_wood.png",	-- side
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_hardness = 2,
	_mcl_blast_resistance = 10
})

-- Template function for composters with compost
local register_filled_composter = function(compost_level, description)
	local id = "mcl_composters:composter_"..compost_level
	local dirt_tex
	dirt_tex = "default_dirt.png"
	minetest.register_node(id, {
		description = description,
		_doc_items_create_entry = false,
		drawtype = "nodebox",
		paramtype = "light",
		is_ground_content = false,
		groups = {handy=1, axey=1, deco_block=1, material_wood=1, compost=(1+compost_level), comparator_signal=compost_level},
		node_box = composter_nodeboxes[compost_level],
		collision_box = composter_nodeboxes[0],
		selection_box = { type = "regular" },
		tiles = {
			"("..dirt_tex..")^default_wood.png",
			"default_wood.png^default_wood.png",
			"default_wood.png"
		},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		drop = "mcl_composters:composter",
		_mcl_hardness = 2,
		_mcl_blast_resistance = 10,
	})

	-- Add entry aliases for the help
	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", "mcl_composters:composter", "nodes", id)
	end
end

-- Filled composter (7 levels)
register_filled_composter(1, S("Composter (1/8 compost)"))
register_filled_composter(1, S("Composter (2/8 compost)"))
register_filled_composter(1, S("Composter (3/8 compost)"))
register_filled_composter(1, S("Composter (4/8 compost)"))
register_filled_composter(1, S("Composter (5/8 compost)"))
register_filled_composter(1, S("Composter (6/8 compost)"))
register_filled_composter(1, S("Composter (7/8 compost)"))

minetest.register_craft({
	output = "mcl_composters:composter",
	recipe = {
		{ "group:wood_slab", "", "group:wood_slab" },
		{ "group:wood_slab", "", "group:wood_slab" },
		{ "group:wood_slab", "group:wood_slab", "group:wood_slab" },
	}
})

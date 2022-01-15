local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local schematic_file = modpath .. "/schematics/mcl_structures_desert_temple.mts"

local temple_schematic_lua = minetest.serialize_schematic(schematic_file, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}) .. " return schematic"
local temple_schematic = loadstring(temple_schematic_lua)()

local red_temple_schematic_lua = minetest.serialize_schematic(schematic_file, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}) .. " return schematic"
red_temple_schematic_lua = red_temple_schematic_lua:gsub("mcl_colorblocks:hardened_clay_orange", "mcl_colorblocks:hardened_clay_red")
red_temple_schematic_lua = red_temple_schematic_lua:gsub("mcl_core:sand_stone", "mcl_colorblocks:hardened_clay_orange")
red_temple_schematic_lua = red_temple_schematic_lua:gsub("mcl_core:sand", "mcl_core:redsand")
red_temple_schematic_lua = red_temple_schematic_lua:gsub("mcl_stairs:stair_sandstone", "mcl_stairs:stair_redsandstone")
red_temple_schematic_lua = red_temple_schematic_lua:gsub("mcl_stairs:slab_sandstone", "mcl_stairs:slab_redsandstone")
red_temple_schematic_lua = red_temple_schematic_lua:gsub("mcl_colorblocks:hardened_clay_yellow", "mcl_colorblocks:hardened_clay_pink")
local red_temple_schematic = loadstring(red_temple_schematic_lua)()

function place(pos, rotation, pr)
	local pos_below  = {x = pos.x, y = pos.y -  1, z = pos.z}
	local pos_temple = {x = pos.x, y = pos.y - 12, z = pos.z}
	local node_below = minetest.get_node(pos_below)
	local nn = node_below.name
	if string.find(nn, "red") then
		mcl_structures.place_schematic({pos = pos_temple, schematic = red_temple_schematic, pr = pr})
	else
		mcl_structures.place_schematic({pos = pos_temple, schematic = temple_schematic, pr = pr})
	end
end

local node_list = {"mcl_core:sand", "mcl_core:sandstone", "mcl_core:redsand", "mcl_colorblocks:hardened_clay_orange"}

local function node_counter(pos)
	local pos_list = minetest.find_nodes_in_area(
		{x = pos.x +  1, y = pos.y - 1, z = pos.z +  1},
		{x = pos.x + 20, y = pos.y - 1, z = pos.z + 20},
		node_list, false
	)
	return #pos_list
end

mcl_structures.register_structure({
	name = "desert_temple",
	decoration = {
		deco_type = "simple",
		place_on = node_list,
		flags = "all_floors",
		fill_ratio = 0.00001,
		y_min = 3,
		y_max = mcl_mapgen.overworld.max,
		height = 1,
		biomes = {
			"ColdTaiga_beach",
			"ColdTaiga_beach_water",
			"Desert",
			"Desert_ocean",
			"ExtremeHills_beach",
			"FlowerForest_beach",
			"Forest_beach",
			"MesaBryce_sandlevel",
			"MesaPlateauF_sandlevel",
			"MesaPlateauFM_sandlevel",
			"Savanna",
			"Savanna_beach",
			"StoneBeach",
			"StoneBeach_ocean",
			"Taiga_beach",
		},
	},
	on_generated = function(minp, maxp, seed, vm_context, pos_list)
		local pos = pos_list[1]
		if #pos_list > 1 then
			local count = node_counter(pos)
			for i = 2, #pos_list do
				local pos_i = pos_list[i]
				local count_i = node_counter(pos_i)
				if count_i > count then
					count = count_i
					pos = pos_i
				end
			end
		end
		local pr = PseudoRandom(vm_context.chunkseed)
		place(pos, nil, pr)
	end,
	on_place = place,
})

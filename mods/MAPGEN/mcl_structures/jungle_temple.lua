local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local node_list = {"mcl_core:dirt_with_grass", "mcl_core:dirt", "mcl_core:stone", "mcl_core:granite", "mcl_core:gravel", "mcl_core:diorite"}

local schematic_file = modpath .. "/schematics/mcl_structures_jungle_temple.mts"

local temple_schematic_lua = minetest.serialize_schematic(schematic_file, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}) .. " return schematic"
local temple_schematic = loadstring(temple_schematic_lua)()
local size = temple_schematic.size
local offset = vector.round(vector.divide(size, 2))
offset.y = 5

local function on_placed(p1, rotation, pr, size)
	local p2 = {x = p1.x + size.x - 1, y = p1.y + size.y - 1, z = p1.z + size.z - 1}

	-- Find chests.
	local chests = minetest.find_nodes_in_area(p1, {x = p2.x, y = p1.y + 5, z = p2.z}, "mcl_chests:chest")

	-- Add desert temple loot into chests
	for c=1, #chests do
		local lootitems = mcl_loot.get_multi_loot({
		{
			stacks_min = 2,
			stacks_max = 4,
			items = {
				{ itemstring = "mcl_mobitems:bone", weight = 25, amount_min = 4, amount_max=6 },
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 25, amount_min = 3, amount_max=7 },
				{ itemstring = "mcl_mobitems:spider_eye", weight = 25, amount_min = 1, amount_max=3 },
				{ itemstring = "mcl_books:book", weight = 20, func = function(stack, pr)
					mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "mcl_mobitems:saddle", weight = 20, },
				{ itemstring = "mcl_core:apple_gold", weight = 20, },
				{ itemstring = "mcl_core:gold_ingot", weight = 15, amount_min = 2, amount_max = 7 },
				{ itemstring = "mcl_core:iron_ingot", weight = 15, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:emerald", weight = 15, amount_min = 1, amount_max = 3 },
				{ itemstring = "", weight = 15, },
				{ itemstring = "mobs_mc:iron_horse_armor", weight = 15, },
				{ itemstring = "mobs_mc:gold_horse_armor", weight = 10, },
				{ itemstring = "mobs_mc:diamond_horse_armor", weight = 5, },
				{ itemstring = "mcl_core:diamond", weight = 5, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_core:apple_gold_enchanted", weight = 2, },
			}
		},
		{
			stacks_min = 4,
			stacks_max = 4,
			items = {
				{ itemstring = "mcl_mobitems:bone", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_mobitems:gunpowder", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_core:sand", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_mobitems:string", weight = 10, amount_min = 1, amount_max = 8 },
			}
		}}, pr)
		mcl_structures.init_node_construct(chests[c])
		local meta = minetest.get_meta(chests[c])
		local inv = meta:get_inventory()
		mcl_loot.fill_inventory(inv, "main", lootitems, pr)
	end

end

local function place(pos, rotation, pr)
	mcl_structures.place_schematic({pos = vector.subtract(pos, offset), schematic = temple_schematic, pr = pr, on_placed = on_placed})
end

local function get_place_rank(pos)
	local x, y, z = pos.x, pos.y, pos.z
	local p1 = {x = x - 6, y = y, z = z - 6}
	local p2 = {x = x + 6, y = y, z = z + 6}
	local pos_list_air = minetest.find_nodes_in_area(p1, p2, {"air", "group:buildable_to", "group:deco_block", "group:water"}, false)
	p1.y = y - 1
	p2.y = y - 1
	local pos_list_ground = minetest.find_nodes_in_area(p1, p2, node_list, false)
	return #pos_list_ground + #pos_list_air
end

mcl_structures.register_structure({
	name = "jungle_temple",
	decoration = {
		deco_type = "simple",
		place_on = node_list,
		flags = "all_floors",
		--fill_ratio = 0.00003,
		fill_ratio = 0.003,
		y_min = 3,
		y_max = mcl_mapgen.overworld.max,
		height = 1,
		biomes =
			mcl_mapgen.v6 and {
				"Jungle"
			} or {
				"Jungle",
				"JungleEdge",
				"JungleEdgeM",
				"JungleEdgeM_ocean",
				"JungleEdge_ocean",
				"JungleM",
				"JungleM_ocean",
				"JungleM_shore",
				"Jungle_ocean",
				"Jungle_shore",
		},
	},
	on_finished_chunk = function(minp, maxp, seed, vm_context, pos_list)
--		local a = seed % 14
--		local b = (math.floor(seed / 39) + 4) % 12
--		minetest.chat_send_all("seed=" .. tostring(seed) .. ", a=" .. tostring(a) .. ", b=" ..tostring(b))
--		if a ~= b then return end
		local pos = pos_list[1]
		if #pos_list > 1 then
			local count = get_place_rank(pos)
			for i = 2, #pos_list do
				local pos_i = pos_list[i]
				local count_i = get_place_rank(pos_i)
				if count_i > count then
					count = count_i
					pos = pos_i
				end
			end
		end
		local pr = PseudoRandom(vm_context.chunkseed)
		place(pos, nil, pr)
	end,
	place_function = place,
})

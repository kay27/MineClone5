local get_node = minetest.get_node

-------------------------------------------------------------------------------
-- function to copy tables
-------------------------------------------------------------------------------
function settlements.shallowCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end
--
--
--
function settlements.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

-------------------------------------------------------------------------------
-- function to find surface block y coordinate
-- returns surface postion
-------------------------------------------------------------------------------
function settlements.find_surface(pos)
	local p6 = vector.new(pos)
	p6.y = mcl_mapgen.get_chunk_ending(p6.y)
	local ymin = mcl_mapgen.get_chunk_beginning(p6.y)
	local node = get_node(p6)
	minetest.chat_send_all(node.name)
	if node.name ~= "air" then return end
	while true do
		p6.y = p6.y - 1
		if p6.y < ymin then return end
		node = get_node(p6)
		if settlements.surface_mat[node.name] then
			break
		end
	end
	minetest.chat_send_all(node.name)

	local prev_node = minetest.get_node(vector.new(p6.x, p6.y + 1, p6.z))
	local name = prev_node.name
	if (string.find(name, "air")
		or string.find(name, "snow")
		or string.find(name, "fern")
		or string.find(name, "flower")
		or string.find(name, "bush")
		or string.find(name, "tree")
		or string.find(name, "grass")
	) then
		minetest.chat_send_all("found! "..node.name..", "..minetest.pos_to_string(p6))
		return p6, node.name
	end
end
-------------------------------------------------------------------------------
-- check distance for new building
-------------------------------------------------------------------------------
function settlements.check_distance(settlement_info, building_pos, building_size)
	local distance
	for i, built_house in ipairs(settlement_info) do
		distance = math.sqrt(
			((building_pos.x - built_house["pos"].x)*(building_pos.x - built_house["pos"].x))+
			((building_pos.z - built_house["pos"].z)*(building_pos.z - built_house["pos"].z)))
		if distance < building_size or distance < built_house["hsize"] then
			return false
		end
	end
	return true
end
-------------------------------------------------------------------------------
-- save list of generated settlements
-------------------------------------------------------------------------------
function settlements.save()
	local file = io.open(minetest.get_worldpath().."/settlements.txt", "w")
	if file then
		file:write(minetest.serialize(settlements_in_world))
		file:close()
	end
end
-------------------------------------------------------------------------------
-- load list of generated settlements
-------------------------------------------------------------------------------
function settlements.load()
	local file = io.open(minetest.get_worldpath().."/settlements.txt", "r")
	if file then
		local table = minetest.deserialize(file:read("*all"))
		if type(table) == "table" then
			return table
		end
	end
	return {}
end
-------------------------------------------------------------------------------
-- fill chests
-------------------------------------------------------------------------------
function settlements.fill_chest(pos, pr)
	-- initialize chest (mts chests don't have meta)
	local meta = minetest.get_meta(pos)
	if meta:get_string("infotext") ~= "Chest" then
		-- For MineClone2 0.70 or before
		-- minetest.registered_nodes["mcl_chests:chest"].on_construct(pos)
		--
		-- For MineClone2 after commit 09ab1482b5 (the new entity chests)
		minetest.registered_nodes["mcl_chests:chest_small"].on_construct(pos)
	end
	-- fill chest
	local inv = minetest.get_inventory( {type="node", pos=pos} )

	local function get_treasures(prand)
		local loottable = {{
			stacks_min = 3,
			stacks_max = 8,
			items = {
				{ itemstring = "mcl_core:diamond", weight = 3, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_core:iron_ingot", weight = 10, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:gold_ingot", weight = 5, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_farming:bread", weight = 15, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_core:apple", weight = 15, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_tools:pick_iron", weight = 5 },
				{ itemstring = "mcl_tools:sword_iron", weight = 5 },
				{ itemstring = "mcl_armor:chestplate_iron", weight = 5 },
				{ itemstring = "mcl_armor:helmet_iron", weight = 5 },
				{ itemstring = "mcl_armor:leggings_iron", weight = 5 },
				{ itemstring = "mcl_armor:boots_iron", weight = 5 },
				{ itemstring = "mcl_core:obsidian", weight = 5, amount_min = 3, amount_max = 7 },
				{ itemstring = "mcl_core:sapling", weight = 5, amount_min = 3, amount_max = 7 },
				{ itemstring = "mcl_mobitems:saddle", weight = 3 },
				{ itemstring = "mobs_mc:iron_horse_armor", weight = 1 },
				{ itemstring = "mobs_mc:gold_horse_armor", weight = 1 },
				{ itemstring = "mobs_mc:diamond_horse_armor", weight = 1 },
			}
		}}
		local items = mcl_loot.get_multi_loot(loottable, prand)
		return items
	end

	local items = get_treasures(pr)
	mcl_loot.fill_inventory(inv, "main", items, pr)
end

-------------------------------------------------------------------------------
-- initialize furnace
-------------------------------------------------------------------------------
function settlements.initialize_furnace(pos)
  -- find chests within radius
  local furnacepos = minetest.find_node_near(pos,
    7, --radius
    {"mcl_furnaces:furnace"})
  -- initialize furnacepos (mts furnacepos don't have meta)
  if furnacepos
  then
    local meta = minetest.get_meta(furnacepos)
    if meta:get_string("infotext") ~= "furnace"
    then
      minetest.registered_nodes["mcl_furnaces:furnace"].on_construct(furnacepos)
    end
  end
end
-------------------------------------------------------------------------------
-- initialize anvil
-------------------------------------------------------------------------------
function settlements.initialize_anvil(pos)
  -- find chests within radius
  local anvilpos = minetest.find_node_near(pos,
    7, --radius
    {"mcl_anvils:anvil"})
  -- initialize anvilpos (mts anvilpos don't have meta)
  if anvilpos
  then
    local meta = minetest.get_meta(anvilpos)
    if meta:get_string("infotext") ~= "anvil"
    then
      minetest.registered_nodes["mcl_anvils:anvil"].on_construct(anvilpos)
    end
  end
end
-------------------------------------------------------------------------------
-- randomize table
-------------------------------------------------------------------------------
function shuffle(tbl, pr)
	local table = settlements.shallowCopy(tbl)
	local size = #table
	for i = size, 1, -1 do
		local rand = pr:next(1, size)
		table[i], table[rand] = table[rand], table[i]
	end
	return table
end
-------------------------------------------------------------------------------
-- Set array to list
-- https://stackoverflow.com/questions/656199/search-for-an-item-in-a-lua-list
-------------------------------------------------------------------------------
function settlements.Set (list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

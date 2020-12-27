local c_dirt_with_grass             = minetest.get_content_id("mcl_core:dirt_with_grass")
local c_dirt_with_snow              = minetest.get_content_id("mcl_core:dirt_with_grass_snow")
--local c_dirt_with_dry_grass         = minetest.get_content_id("mcl_core:dirt_with_dry_grass")
local c_podzol = minetest.get_content_id("mcl_core:podzol")
local c_sand                        = minetest.get_content_id("mcl_core:sand")
local c_desert_sand                 = minetest.get_content_id("mcl_core:redsand")
--local c_silver_sand                 = minetest.get_content_id("mcl_core:silver_sand")
--
local c_air                         = minetest.get_content_id("air")
local c_snow                        = minetest.get_content_id("mcl_core:snowblock")
local c_fern_1                      = minetest.get_content_id("mcl_core:fern")
local c_fern_2                      = minetest.get_content_id("mcl_core:fern")
local c_fern_3                      = minetest.get_content_id("mcl_core:fern")
local c_rose                        = minetest.get_content_id("mcl_flowers:poppy")
local c_viola                       = minetest.get_content_id("mcl_flowers:blue_orchid")
local c_geranium                    = minetest.get_content_id("mcl_flowers:allium")
local c_tulip                       = minetest.get_content_id("mcl_flowers:tulip_orange")
local c_dandelion_y                 = minetest.get_content_id("mcl_flowers:dandelion")
local c_dandelion_w                 = minetest.get_content_id("mcl_flowers:oxeye_daisy")
local c_bush_leaves                 = minetest.get_content_id("mcl_core:leaves")
local c_bush_stem                   = minetest.get_content_id("mcl_core:tree")
local c_a_bush_leaves               = minetest.get_content_id("mcl_core:acacialeaves")
local c_a_bush_stem                 = minetest.get_content_id("mcl_core:acaciatree")
local c_water_source                = minetest.get_content_id("mcl_core:water_source")
local c_water_flowing                = minetest.get_content_id("mcl_core:water_flowing")
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
-------------------------------------------------------------------------------
function settlements.find_surface_lvm(pos, minp)
  --ab hier altes verfahren
  local p6 = settlements.shallowCopy(pos)
  local surface_mat = {
    c_dirt_with_grass,            
    c_dirt_with_snow,            
    --c_dirt_with_dry_grass,        
    c_podzol,
    c_sand,                       
    c_desert_sand
  }
  local cnt = 0
  local itter -- count up or down
  local cnt_max = 200
  -- starting point for looking for surface
  local vi = va:index(p6.x, p6.y, p6.z)
  if data[vi] == nil then return nil end
  local tmp = minetest.get_name_from_content_id(data[vi])
  if data[vi] == c_air then
    itter = -1
  else
    itter = 1
  end
  while cnt < cnt_max do
    cnt = cnt+1
    local vi = va:index(p6.x, p6.y, p6.z)
--    local tmp = minetest.get_name_from_content_id(data[vi])
--    if vi == nil 
--    then 
--      return nil 
--    end
    for i, mats in ipairs(surface_mat) do
      local node_check = va:index(p6.x, p6.y+1, p6.z)
      if node_check and vi and data[vi] == mats and 
      (data[node_check] ~= c_water_source and
        data[node_check] ~= c_water_flowing
      ) 
      then 
        local tmp = minetest.get_name_from_content_id(data[node_check])
        return p6, mats
      end
    end
    p6.y = p6.y + itter
    if p6.y < 0 then return nil end
  end
  return nil  --]]
end
-------------------------------------------------------------------------------
-- function to find surface block y coordinate
-- returns surface postion
-------------------------------------------------------------------------------
function settlements.find_surface(pos)
  local p6 = settlements.shallowCopy(pos)
  local cnt = 0
  local itter -- count up or down
  local cnt_max = 200
-- check, in which direction to look for surface
  local surface_node = minetest.get_node_or_nil(p6)
  if surface_node and string.find(surface_node.name,"air") then 
    itter = -1
  else
    itter = 1
  end
  -- go through nodes an find surface
  while cnt < cnt_max do
    cnt = cnt+1
    minetest.forceload_block(p6)
    surface_node = minetest.get_node_or_nil(p6)
    
    if not surface_node then
    -- Load the map at pos and try again
      minetest.get_voxel_manip():read_from_map(p6, p6)
      surface_node = minetest.get_node(p6)
      if surface_node.name == "ignore" then
         if settlements.debug == true then
           minetest.chat_send_all("find_surface1: nil or ignore")
         end
         return nil
      end
    end
    
--    if surface_node == nil or surface_node.name == "ignore" then 
--      --return nil 
--      local fl = minetest.forceload_block(p6)
--      if not fl then
--      
--        return nil
--      end
--    end
    --
    -- Check Surface_node and Node above
    --
      if settlements.surface_mat[surface_node.name] then
         local surface_node_plus_1 = minetest.get_node_or_nil({ x=p6.x, y=p6.y+1, z=p6.z})
         if surface_node_plus_1 and surface_node and 
         (string.find(surface_node_plus_1.name,"air") or
           string.find(surface_node_plus_1.name,"snow") or
           string.find(surface_node_plus_1.name,"fern") or
           string.find(surface_node_plus_1.name,"flower") or
           string.find(surface_node_plus_1.name,"bush") or
           string.find(surface_node_plus_1.name,"tree") or
           string.find(surface_node_plus_1.name,"grass")) 
         then 
           if settlements.debug == true then
             minetest.chat_send_all("find_surface7: " ..surface_node.name.. " " .. surface_node_plus_1.name)
           end
           return p6, surface_node.name 
         else
           if settlements.debug == true then
             minetest.chat_send_all("find_surface2: wrong surface+1")
           end
         end
      else
        if settlements.debug == true then
          if string.find(surface_node.name,"air") then
            local a=1
          else
             minetest.chat_send_all("find_surface3: wrong surface "..surface_node.name)
          end
        end
      end
   -- end
    p6.y = p6.y + itter
    if p6.y < 0 then 
      if settlements.debug == true then
        minetest.chat_send_all("find_surface4: y<0")
      end
      return nil 
    end
  end
  if settlements.debug == true then
     minetest.chat_send_all("find_surface5: cnt_max overflow")
  end
  return nil
end
-------------------------------------------------------------------------------
-- check distance for new building
-------------------------------------------------------------------------------
function settlements.check_distance(building_pos, building_size)
  local distance
  for i, built_house in ipairs(settlement_info) do
    distance = math.sqrt(
      ((building_pos.x - built_house["pos"].x)*(building_pos.x - built_house["pos"].x))+
      ((building_pos.z - built_house["pos"].z)*(building_pos.z - built_house["pos"].z)))
    if distance < building_size or 
    distance < built_house["hsize"] 
    then
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
-- check distance to other settlements
-------------------------------------------------------------------------------
function settlements.check_distance_other_settlements(center_new_chunk)
--  local min_dist_settlements = 300
  for i, pos in ipairs(settlements_in_world) do 
    local distance = vector.distance(center_new_chunk, pos)
--    minetest.chat_send_all("dist ".. distance)
    if distance < settlements.min_dist_settlements then
      return false
    end
  end  
  return true
end
-------------------------------------------------------------------------------
-- fill chests
-------------------------------------------------------------------------------
function settlements.fill_chest(pos)
  -- find chests within radius
  --local chestpos = minetest.find_node_near(pos, 6, {"mcl_core:chest"})
  local chestpos = pos
  -- initialize chest (mts chests don't have meta)
  local meta = minetest.get_meta(chestpos)
  if meta:get_string("infotext") ~= "Chest" then
    minetest.registered_nodes["mcl_chests:chest"].on_construct(chestpos)
  end
  -- fill chest
  local inv = minetest.get_inventory( {type="node", pos=chestpos} )
  -- always
  inv:add_item("main", "mcl_core:apple "..math.random(1,3))
  -- low value items
  if math.random(0,1) < 1 then
    inv:add_item("main", "mcl_farming:bread "..math.random(0,3))
    inv:add_item("main", "mcl_core:iron_ingot "..math.random(0,3))
    inv:add_item("main", "mcl_farming:melon_item "..math.random(0,3))
    inv:add_item("main", "mcl_farming:carrot_item "..math.random(0,3))
	--[[
    -- additional fillings when farmin mod enabled
    if minetest.get_modpath("farming") ~= nil and farming.mod == "redo" then
      if math.random(0,1) < 1 then
        inv:add_item("main", "mcl_farming:melon_item "..math.random(0,3))
        inv:add_item("main", "mcl_farming:carrot_item "..math.random(0,3))
        inv:add_item("main", "farming:corn "..math.random(0,3))
      end
    end
	--]]
  end
  -- medium value items
  if math.random(0,3) < 1 then
    inv:add_item("main", "mcl_tools:pick_iron "..math.random(0,1))
    inv:add_item("main", "mcl_tools:pick_stone "..math.random(0,1))
    inv:add_item("main", "mcl_fire:flint_and_steel "..math.random(0,1))
    inv:add_item("main", "mcl_buckets:bucket_empty "..math.random(0,1))
    inv:add_item("main", "mcl_tools:sword_iron "..math.random(0,1))
  end
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
-- initialize furnace, chests, anvil
-------------------------------------------------------------------------------
function settlements.initialize_nodes()
  for i, built_house in ipairs(settlement_info) do
    for j, schem in ipairs(schematic_table) do
      if settlement_info[i]["name"] == schem["name"]
      then
        building_all_info = schem
        break
      end
    end

    local width = building_all_info["hwidth"] 
    local depth = building_all_info["hdepth"] 
    local height = building_all_info["hheight"] 

    local p = settlement_info[i]["pos"]
    for yi = 1,height do
      for xi = 0,width do
        for zi = 0,depth do
          local ptemp = {x=p.x+xi, y=p.y+yi, z=p.z+zi}
          local node = minetest.get_node(ptemp) 
          if node.name == "mcl_furnaces:furnace" or
          node.name == "mcl_chests:chest" or
          node.name == "mcl_anvils:anvil"
          then
            minetest.registered_nodes[node.name].on_construct(ptemp)
          end
          -- when chest is found -> fill with stuff
          if node.name == "mcl_chests:chest" then
            minetest.after(3,settlements.fill_chest,ptemp)
          end
        end
      end
    end
  end
end
-------------------------------------------------------------------------------
-- randomize table
-------------------------------------------------------------------------------
function shuffle(tbl)
  local table = settlements.shallowCopy(tbl)
  local size = #table
  for i = size, 1, -1 do
    local rand = math.random(size)
    table[i], table[rand] = table[rand], table[i]
  end
  return table
end
-------------------------------------------------------------------------------
-- evaluate heightmap
-------------------------------------------------------------------------------
function settlements.evaluate_heightmap()
  -- max height and min height, initialize with impossible values for easier first time setting
  local max_y = -50000
  local min_y = 50000
  -- only evaluate the center square of heightmap 40 x 40
  local square_start = 1621
  local square_end = 1661
  for j = 1 , 40, 1 do
    for i = square_start, square_end, 1 do
      -- skip buggy heightmaps, return high value
      if heightmap[i] == -31000 or
      heightmap[i] == 31000
      then
        return max_height_difference + 1
      end
      if heightmap[i] < min_y
      then
        min_y = heightmap[i]
      end
      if heightmap[i] > max_y
      then
        max_y = heightmap[i]
      end
    end
    -- set next line
    square_start = square_start + 80
    square_end = square_end + 80
  end
  -- return the difference between highest and lowest pos in chunk
  local height_diff = max_y - min_y
  -- filter buggy heightmaps
  if height_diff <= 1 
  then
    return max_height_difference + 1
  end
  -- debug info
  if settlements.debug == true
  then
    minetest.chat_send_all("heightdiff ".. height_diff)
  end
  return height_diff
end
-------------------------------------------------------------------------------
-- get LVM of current chunk
-------------------------------------------------------------------------------
function settlements.getlvm(minp, maxp)
  local vm = minetest.get_voxel_manip()
  local emin, emax = vm:read_from_map(minp, maxp)
  local va = VoxelArea:new{
    MinEdge = emin,
    MaxEdge = emax
  }    
  local data = vm:get_data()
  return vm, data, va, emin, emax
end
-------------------------------------------------------------------------------
-- get LVM of current chunk
-------------------------------------------------------------------------------
function settlements.setlvm(vm, data)
  -- Write data
  vm:set_data(data)
  vm:write_to_map(true)
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

--
-- function to copy tables
--
function settlements.shallowCopy(original)
  local copy = {}
  for key, value in pairs(original) do
    copy[key] = value
  end
  return copy
end
--
-- function to find surface block y coordinate
-- returns surface postion
--
function settlements.find_surface(pos)
  local p6 = settlements.shallowCopy(pos)
  local cnt = 0
  local itter -- count up or down
  local cnt_max = 200
-- check, in which direction to look for surface
  local s = minetest.get_node_or_nil(p6)
  if s and string.find(s.name,"air") then 
    --p6.y = p6.y+50
    itter = -1
  else
    itter = 1
  end
  while cnt < cnt_max do
    cnt = cnt+1
    s = minetest.get_node_or_nil(p6)
    if s == nil or s.name == "ignore" then return nil end
    for i, mats in ipairs(surface_mat) do
--      if s and s.name == mats and not string.find(minetest.get_node_or_nil({ x=p6.x, y=p6.y+1, z=p6.z}).name,"water") then 
      if s and s.name == mats and 
      (string.find(minetest.get_node_or_nil({ x=p6.x, y=p6.y+1, z=p6.z}).name,"air") or
        string.find(minetest.get_node_or_nil({ x=p6.x, y=p6.y+1, z=p6.z}).name,"snow")) 
      then 
        return p6 
      end
    end
    p6.y = p6.y + itter
    if p6.y < 0 then return nil end
  end
  return nil
end
--
-- check distance for new building
--
function settlements.check_distance(building_pos, building_size)
  local distance
  for i, built_house in ipairs(settlement_info) do
    distance = math.sqrt(((building_pos.x - built_house["pos"].x)*(building_pos.x - built_house["pos"].x))+((building_pos.z - built_house["pos"].z)*(building_pos.z - built_house["pos"].z)))
    if distance < building_size or 
       distance < built_house["hsize"] 
    then
      return false
    end
  end
  return true
end
--
-- save list of generated settlements
--
function settlements.save()
  local file = io.open(minetest.get_worldpath().."/settlements.txt", "w")
  if file then
    file:write(minetest.serialize(settlements_in_world))
    file:close()
  end
end
--
-- load list of generated settlements
--
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
--
-- check distance to other settlements
--
function settlements.check_distance_other_settlements(center_new_chunk)
  local min_dist_settlements = 300
  for i, pos in ipairs(settlements_in_world) do 
    local distance = vector.distance(center_new_chunk, pos)
    if distance < min_dist_settlements then
      return false
    end
  end  
  return true
end
--
-- fill chests
--
function settlements.fill_chest(pos)
  -- find chests within radius
  local chestpos = minetest.find_node_near(pos, 6, {"default:chest"})
  -- initialize chest (mts chests don't have meta)
  local meta = minetest.get_meta(chestpos)
  if meta:get_string("infotext") ~= "Chest" then
    minetest.registered_nodes["default:chest"].on_construct(chestpos)
  end
  -- fill chest
  local inv = minetest.get_inventory( {type="node", pos=chestpos} )
  -- always
  inv:add_item("main", "default:apple "..math.random(1,3))
  -- low value items
  if math.random(0,1) < 1 then
    inv:add_item("main", "farming:bread "..math.random(0,3))
    inv:add_item("main", "default:steel_ingot "..math.random(0,3))
    -- additional fillings when farmin mod enabled
    if minetest.get_modpath("farming") ~= nil then
      if math.random(0,1) < 1 then
        inv:add_item("main", "farming:melon_slice "..math.random(0,3))
        inv:add_item("main", "farming:carrot "..math.random(0,3))
        inv:add_item("main", "farming:corn "..math.random(0,3))
      end
    end
  end
  -- medium value items
  if math.random(0,3) < 1 then
    inv:add_item("main", "default:pick_steel "..math.random(0,1))
    inv:add_item("main", "default:pick_bronze "..math.random(0,1))
    inv:add_item("main", "fire:flint_and_steel "..math.random(0,1))
    inv:add_item("main", "bucket:bucket_empty "..math.random(0,1))
    inv:add_item("main", "default:sword_steel "..math.random(0,1))
  end
end
--
-- initialize furnace
--
function settlements.initialize_furnace(pos)
  -- find chests within radius
  local furnacepos = minetest.find_node_near(pos, 
                                              7, --radius
                                              {"default:furnace"})
  -- initialize furnacepos (mts furnacepos don't have meta)
  if furnacepos 
  then
    local meta = minetest.get_meta(furnacepos)
    if meta:get_string("infotext") ~= "furnace" 
    then
      minetest.registered_nodes["default:furnace"].on_construct(furnacepos)
    end
  end
end
--
-- initialize furnace, chests, bookshelves
--
function settlements.initialize_nodes(pos, width, depth, height)
  local p = settlements.shallowCopy(pos)
  for yi = 1,height do
    for xi = 0,width do
      for zi = 0,depth do
        local ptemp = {x=p.x+xi, y=p.y+yi, z=p.z+zi}
        local node = minetest.get_node(ptemp) 
        if node.name == "default:furnace" or
          node.name == "default:chest" or
          node.name == "default:bookshelf"
        then
          minetest.registered_nodes[node.name].on_construct(ptemp)
        end
        -- when chest is found -> fill with stuff
        if node.name == "default:chest" then
          minetest.after(3,settlements.fill_chest,pos)
        end
      end
    end
  end
end
--
-- randomize table
--
function shuffle(tbl)
  local table = settlements.shallowCopy(tbl)
  local size = #table
  for i = size, 1, -1 do
    local rand = math.random(size)
    table[i], table[rand] = table[rand], table[i]
  end
  return table
end
--
-- Function to copy tables
--
function settlements.shallowCopy(original)
  local copy = {}
  for key, value in pairs(original) do
    copy[key] = value
  end
  return copy
end
--
-- Function to find surface block y coordinate
-- returns surface postion
--
function settlements.find_surface(pos)
  local p6 = settlements.shallowCopy(pos)
  local cnt = 0
  local itter -- nach oben oder nach unten zählen
  local cnt_max = 200
-- check, ob zu weit unten mit der Suche begonnen wird
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
      if s and s.name == mats then 
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
  for i, built_house in ipairs(settlement_info) do
    local distance = math.sqrt(((building_pos.x - built_house["pos"].x)*(building_pos.x - built_house["pos"].x))+((building_pos.z - built_house["pos"].z)*(building_pos.z - built_house["pos"].z)))
    if distance < building_size and distance < built_house["hsize"] then
      return false
    end
  end
  return true
end
--
function settlements.save()
  local file = io.open(minetest.get_worldpath().."/settlements.txt", "w")
  if file then
    file:write(minetest.serialize(settlements_in_world))
    file:close()
  end
end

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

function settlements.fill_chest(pos)
  -- find chest in currently placed building
  local chestpos = minetest.find_node_near(pos, 10, {"default:chest"})
  -- initialize chest (mts chests don't have meta)
  local meta = minetest.get_meta(pos)
  if meta:get_string("infotext") ~= "Chest" then
    minetest.registered_nodes["default:chest"].on_construct(chestpos)
  end
  -- fill chest
  local inv = minetest.get_inventory( {type="node", pos=chestpos} )
  inv:add_item("main", "default:apple 3")
  inv:add_item("main", "farming:bread")
  inv:add_item("main", "default:steel_ingot")
  inv:add_item("main", "default:pick_steel")
  inv:add_item("main", "default:pick_bronze")
  inv:add_item("main", "fire:flint_and_steel")
  inv:add_item("main", "bucket:bucket_empty")
  inv:add_item("main", "default:sword_steel")
  
end
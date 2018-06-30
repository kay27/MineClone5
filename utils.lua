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
    local distance = vector.distance(building_pos, built_house["pos"])
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
  local min_dist_settlements = 1000
  for i, pos in ipairs(settlements_in_world) do 
    local distance = vector.distance(center_new_chunk, pos)
    if distance < min_dist_settlements then
      return false
    end
  end  
  return true
end
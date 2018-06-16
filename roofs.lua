local c_roof_material = "default:wood"

function settlements.random_roof(pos, height, width, depth)
  local roof_function_table = {settlements.pyramid_roof, settlements.saddle_roof, settlements.funny_roof}
  local random_index = math.random(1, #roof_function_table) --pick random index from 1 to #f_tbl
  roof_function_table[random_index](pos, height, width, depth) --execute function at the random_index we've picked
end

function settlements.pyramid_roof(pos, height, width, depth)
  local material = c_roof_material
  local p4 = settlements.shallowCopy(pos)
  -- start roof offset to walls (for rainprotection) 
  p4.x = pos.x-1
  p4.z = pos.z-1
  -- so the size of the roof needs to be broader then the room itself
  local width = width + 2
  local depth = depth + 2
  --
  local nullpunktdach = 0 -- point zero of kartesisches koordinatensystem roof; x and z need to step up 
  local corner = 1 -- other corner of kartesisches koordinatensystem roof
  --
  local roofbeginning = height
  local roofend = height+5
  for yi = roofbeginning,roofend do
    for xi = nullpunktdach,width do
      for zi = nullpunktdach,depth do
        if xi < corner or xi > width-1 or zi < corner or zi > depth-1 then
          minetest.set_node({x=p4.x+xi, y=p4.y+yi, z=p4.z+zi}, {name=material})
--        else
--          minetest.remove_node({x=p4.x+xi, y=p4.y+yi, z=p4.z+zi}) foundation removed nodes already
        end
      end
    end
    width = width - 1
    depth = depth -1
    nullpunktdach = nullpunktdach + 1
    corner = corner + 1
  end
end

function settlements.saddle_roof(pos, height, width, depth)
  local material = c_roof_material
  local p4 = settlements.shallowCopy(pos)
  -- start roof offset to walls (for rainprotection) 
  p4.x = pos.x-1
  p4.z = pos.z-1
  -- so the size of the roof needs to be broader then the room itself
  local width = width + 2
  local depth = depth + 2
  --
  local nullpunktx = 0 
  local nullpunktz = 0 
  local cornerx = 1
  local cornerz = 1
  -- roof_dir
  local roof_dir = math.random(0,1)
  local roofbeginning = height
  local roofend = height+5
  for yi = roofbeginning,roofend do
    for xi = nullpunktx,width do
      for zi = nullpunktz,depth do
        if xi < cornerx or xi > width-1 or zi < cornerz or zi > depth-1 then
          minetest.set_node({x=p4.x+xi, y=p4.y+yi, z=p4.z+zi}, {name=material})
        end
      end
    end
    if roof_dir == 1 then
      width = width - 1
      nullpunktx = nullpunktx + 1
      cornerx = cornerx + 1
    else
      depth = depth -1
      nullpunktz = nullpunktz + 1
      cornerz = cornerz + 1
    end
  end
end
--
--
--
function settlements.funny_roof(pos, height, width, depth)
  local material = c_roof_material
  local p4 = settlements.shallowCopy(pos)
  -- start roof offset to walls (for rainprotection) 
  p4.x = pos.x-1
  p4.z = pos.z-1
  -- so the size of the roof needs to be broader then the room itself
  local width = width + 2
  local depth = depth + 2
  --
  local nullpunktx = 0 
  local nullpunktz = 0 
  local cornerx = 1
  local cornerz = 1
  -- roof_dir
  local roof_dir = math.random(0,1)
  local roofbeginning = height
  local roofend = height+5
  for yi = roofbeginning,roofend do
    for xi = nullpunktx,width do
      for zi = nullpunktz,depth do
        if xi == cornerx or xi == width-1 or zi == cornerz or zi == depth-1 then
          minetest.set_node({x=p4.x+xi, y=p4.y+yi, z=p4.z+zi}, {name=material})
        end
      end
    end
    if roof_dir == 1 then
      width = width - 1
      nullpunktx = nullpunktx + 1
      cornerx = cornerx + 1
    else
      depth = depth -1
      nullpunktz = nullpunktz + 1
      cornerz = cornerz + 1
    end
  end
end

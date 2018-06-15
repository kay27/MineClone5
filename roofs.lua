local c_roof_material = "default:wood"


function settlements.roof(pos, height, width, depth)
  local material = c_roof_material
  local p4 = settlements.shallowCopy(pos)
  p4.x = pos.x-1
  p4.z = pos.z-1
  local width = width + 2
  local depth = depth + 2
  local nullpunktdach = 0 
  local temp = 1
  local roofbeginning = height
  local roofend = height+5
  for yi = roofbeginning,roofend do
    for xi = nullpunktdach,width do
      for zi = nullpunktdach,depth do
        if xi < temp or xi > width-1 or zi < temp or zi > depth-1 then
          minetest.set_node({x=p4.x+xi, y=p4.y+yi, z=p4.z+zi}, {name=material})
        else
          minetest.remove_node({x=p4.x+xi, y=p4.y+yi, z=p4.z+zi})
        end
      end
    end
    width = width - 1
    depth = depth -1
    nullpunktdach = nullpunktdach + 1
    temp = temp + 1
  end
end


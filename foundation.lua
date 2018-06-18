local function can_replace(pos)
  local n = minetest.get_node_or_nil(pos)
  if n and n.name and minetest.registered_nodes[n.name] and not minetest.registered_nodes[n.name].walkable then
    return true
  elseif not n then
    return true
  else
    return false
  end
end
--
-- Function to fill empty space below baseplate when building on a hill
--
function settlements.ground(pos) -- Wendelsteinkircherl, Brannenburg
  local p2 = pos
  local cnt = 0
  local mat = "dirt"
  p2.y = p2.y-1
  while can_replace(p2)==true do--minetest.get_node(p2).name == "air" do
    cnt = cnt+1
    if cnt > 200 then break end
    if cnt>math.random(2,4) then mat = "stone"end
    minetest.set_node(p2, {name="default:"..mat})
    p2.y = p2.y-1
  end
end
--
-- 1. create baseplate and below 
-- 2. remove everything above baseplate until height
--
function settlements.foundation(pos, height, width, depth)
  local c_balcony_material =  minetest.get_node_or_nil(pos).name
  local c_floor_material = "default:wood"
  local p5 = settlements.shallowCopy(pos)
  p5.x = pos.x-1
  p5.z = pos.z-1
  local width = width + 2
  local depth = depth + 2
  local height = height * 3 -- make room for roof
  for yi = 0,height do
    for xi = 0,width do
      for zi = 0,depth do
        if yi == 0 then
          local material
          -- 1 block surrounding the baseplate
          if xi < 1 or xi >= width or zi < 1 or zi >= depth then
            material = c_balcony_material
          else
            material = c_floor_material
          end
          local p = {x=p5.x+xi, y=p5.y, z=p5.z+zi}
          minetest.set_node(p, {name=material})
          minetest.after(1,settlements.ground,p)--(p)
        else
          -- make room for walls an interior
          minetest.remove_node({x=p5.x+xi, y=p5.y+yi, z=p5.z+zi})
        end
      end
    end
  end
end


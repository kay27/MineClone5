--
-- function to fill empty space below baseplate when building on a hill
--
function settlements.ground(vm, data, va, pos) -- role model: Wendelsteinkircherl, Brannenburg
  local c_dirt  = minetest.get_content_id("default:dirt")
  local c_stone = minetest.get_content_id("default:stone")
  --
  local p2 = pos
  local cnt = 0
  local mat = c_dirt
  p2.y = p2.y-1
  while true do
    cnt = cnt+1
    if cnt > 20 then break end
    if cnt>math.random(2,4) then mat = c_stone end
    --minetest.swap_node(p2, {name="default:"..mat})
    local vi = va:index(p2.x, p2.y, p2.z)
    data[vi] = mat
    p2.y = p2.y-1
  end
  return data
end
--
-- function to fill empty space below baseplate when building on a hill
--
function settlements.foundation(vm, data, va, pos, width, depth, height, rotation)
  local c_air = minetest.get_content_id("air")
  local p5 = settlements.shallowCopy(pos)
  local fheight = height * 3 -- remove trees and leaves above
  local fwidth
  local fdepth
  if rotation == "0" or rotation == "180" then
    fwidth = width
    fdepth = depth
  else
    fwidth = depth
    fdepth = width
  end
  for yi = 0,fheight do
    for xi = 0,fwidth-1 do
      for zi = 0,fdepth-1 do
        if yi == 0 then
          local p = {x=p5.x+xi, y=p5.y, z=p5.z+zi}
          data = settlements.ground(vm, data, va, p)
        else
          -- write ground
          local vi = va:index(p5.x+xi, p5.y+yi, p5.z+zi)
          if data[vi] ~= c_air
          --local node = minetest.get_node_or_nil({x=p5.x+xi, y=p5.y+yi, z=p5.z+zi})
          --if node then
            --if node.name ~= "air"
          then
              --minetest.swap_node({x=p5.x+xi, y=p5.y+yi, z=p5.z+zi},{name="air"}) 
           data[vi] = c_air
          end
        end
      end
    end
  end
  settlements.setlvm(vm, data)
end
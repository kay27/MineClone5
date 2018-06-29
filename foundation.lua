--
-- Function to fill empty space below baseplate when building on a hill
--
function settlements.ground(pos) -- Wendelsteinkircherl, Brannenburg
  local p2 = pos
  local cnt = 0
  local mat = "dirt"
  p2.y = p2.y-1
  while true do
    cnt = cnt+1
    if cnt > 100 then break end
    if cnt>math.random(2,4) then mat = "stone"end
    minetest.set_node(p2, {name="default:"..mat})
    p2.y = p2.y-1
  end
end
--
-- Function to fill empty space below baseplate when building on a hill
--
function settlements.foundation(pos, width, depth, height)
  local p5 = settlements.shallowCopy(pos)
  local height = height * 3 -- remove trees and leaves above
  for yi = 0,height do
    for xi = 0,width-1 do
      for zi = 0,depth-1 do
        if yi == 0 then
          local p = {x=p5.x+xi, y=p5.y, z=p5.z+zi}
          minetest.after(1,settlements.ground,p)--(p)
        else
          minetest.remove_node({x=p5.x+xi, y=p5.y+yi, z=p5.z+zi})
        end
      end
    end
  end
end


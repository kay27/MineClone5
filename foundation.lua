--
-- function to fill empty space below baseplate when building on a hill
--
function settlements.ground(pos) -- role model: Wendelsteinkircherl, Brannenburg
  local p2 = pos
  local cnt = 0
  local mat = "dirt"
  p2.y = p2.y-1
  while true do
    cnt = cnt+1
    if cnt > 50 then break end
    if cnt>math.random(2,4) then mat = "stone" end
    minetest.swap_node(p2, {name="default:"..mat})
    p2.y = p2.y-1
  end
end
--
-- function to fill empty space below baseplate when building on a hill
--
function settlements.foundation(pos, width, depth, height, rotation)
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
          minetest.after(1,settlements.ground,p)--(p)
        else
--          minetest.remove_node({x=p5.x+xi, y=p5.y+yi, z=p5.z+zi})
          if minetest.get_node_or_nil({x=p5.x+xi, y=p5.y+yi, z=p5.z+zi}).name ~= "air"
          then
            minetest.swap_node({x=p5.x+xi, y=p5.y+yi, z=p5.z+zi},{name="air"}) 
          end                  
        end
      end
    end
  end
end


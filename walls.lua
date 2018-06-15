function settlements.walls(pos, height, width, depth, material)
local c_floor_material = "default:wood"
 for yi = 0,height do
    for xi = 0,width do
      for zi = 0,depth do
-- floor
        if yi == 0 then
          local p = {x=pos.x+xi, y=pos.y, z=pos.z+zi}
          minetest.set_node(p, {name=c_floor_material})
          minetest.after(1,settlements.ground,p)--(p)
--				elseif yi == height then
--					local p = {x=pos.x+xi, y=pos.y+yi, z=pos.z+zi}
--					minetest.set_node(p, {name="default:cobble"})
        else
-- walls 
          if xi < 1 or xi > width-1 or zi < 1 or zi > depth-1 then
            -- four corners of the house are tree trunks
            local new
            if (xi == 0 and zi == 0) or 
            (xi == width and zi == depth) or 
            (xi == 0 and zi == depth) or
            (zi == 0 and xi == width) 
            then 
              new = "default:tree" 
            else
              new = material
            end
            if yi == 2 and math.random(1,10) > 8 then new = "default:glass" end
            local n = minetest.get_node_or_nil({x=pos.x+xi, y=pos.y+yi-1, z=pos.z+zi})
--						if n and n.name ~= "air" then
            minetest.set_node({x=pos.x+xi, y=pos.y+yi, z=pos.z+zi}, {name=new})
            --					end
--					end
          else
            minetest.remove_node({x=pos.x+xi, y=pos.y+yi, z=pos.z+zi})
-- torch
-- three blocks above floor
            if yi == 3 then
-- inside the walls                            
--         				    if xi == 1 or xi == width-1 or zi == 1 or zi == depth-1 then
-- in two corners
              if (xi == 1 and zi == 1) or (xi == width-1 and zi == depth-1) then
--direction
                if xi == 1 then wallmounted = 3
                elseif xi == width-1 then wallmounted = 2
                elseif zi == 1 then wallmounted = 5
                elseif depth-1 then wallmounted = 4
                end
                minetest.set_node({x=pos.x+xi, y=pos.y+yi, z=pos.z+zi},{name = "default:torch_wall",
                    param2 = wallmounted})
              end
            end
          end
        end
      end
    end
  end
end

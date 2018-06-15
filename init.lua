package.cpath = package.cpath .. ";/usr/share/lua/5.2/?.so"
package.path = package.path .. ";/usr/share/zbstudio/lualibs/mobdebug/?.lua"
require('mobdebug').start()

settlements = {}

settlements.modpath = minetest.get_modpath("settlements");

dofile(settlements.modpath.."/roofs.lua")
dofile(settlements.modpath.."/utils.lua")
dofile(settlements.modpath.."/ground.lua")
dofile(settlements.modpath.."/doors.lua")
dofile(settlements.modpath.."/walls.lua")


local last_time = os.time()




local function make(pos,material)
--  local baumaterial = material
  local height = math.random(4,4)
  local width = math.random(4,5)
  local depth = math.random(4,5)
--    if math.random(1,10) > 8 then material = "wood" end
  settlements.walls(pos, height, width, depth, material)
  settlements.roof(pos, height, width, depth)
  settlements.door(pos, width, depth)
  settlements.space_around_house(pos, height, width, depth)

end


minetest.register_on_generated(function(minp, maxp, seed)

    if maxp.y < 0 then return end
--    minetest.chat_send_all(last_time.." "..os.time())
    if math.random(0,10)<9 or os.time() < last_time then return end
-- wartezeit bis zum nächsten Buildversuch 
    last_time = os.time() +30
    local location_list = settlements.find_locations(minp, maxp)
    if location_list then
      local baumaterial = {"default:junglewood", "default:pine_wood", "default:wood", "default:aspen_wood", "default:acacia_wood", 
        "default:stonebrick", "default:cobble", "default:desert_stonebrick", "default:desert_cobble", "default:sandstone",
        "default:junglewood", "default:pine_wood", "default:wood", "default:aspen_wood", "default:acacia_wood", 
        "default:stonebrick", "default:cobble", "default:desert_stonebrick", "default:desert_cobble", "default:sandstone" }

--		local mpos = {x=math.random(minp.x,maxp.x), y=math.random(minp.y,maxp.y), z=math.random(minp.z,maxp.z)}
      for i, mpos in ipairs(location_list) do
        local material = baumaterial[i]
        minetest.chat_send_all(minetest.pos_to_string(mpos).." "..material)
        minetest.after(0.5, function()
--	        	 p2 = minetest.find_node_near(mpos, 25, {"default:dirt_with_grass"})	
--	        	 if not p2 or p2 == nil or p2.y < 0 then return end
            make(mpos,material)
          end)
      end
    end
  end)


minetest.register_craftitem("settlements:tool", {
    description = "settlements build tool",
    inventory_image = "default_tool_woodshovel.png",
    on_use = function(itemstack, placer, pointed_thing)
      local p = pointed_thing.under
      if p then
        make(p,material)
      end
    end
  })


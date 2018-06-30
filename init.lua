package.cpath = package.cpath .. ";/usr/share/lua/5.2/?.so"
package.path = package.path .. ";/usr/share/zbstudio/lualibs/mobdebug/?.lua"
require('mobdebug').start()

settlements = {}
settlements.modpath = minetest.get_modpath("settlements");

dofile(settlements.modpath.."/const.lua")
dofile(settlements.modpath.."/utils.lua")
dofile(settlements.modpath.."/foundation.lua")
dofile(settlements.modpath.."/buildings.lua")
-- load settlements on server
settlements_in_world = settlements.load()

--
-- on map generation, try to build a settlement
--
minetest.register_on_generated(function(minp, maxp)
    if maxp.y < 0 then 
      return 
    end
    if math.random(0,10)<9 then 
      -- check if too close to other settlements
      local center_of_chunk = {x=maxp.x-40, y=maxp.y-40, z=maxp.z-40} 
      local dist_ok = settlements.check_distance_other_settlements(center_of_chunk)
      if dist_ok == false then
        return
      end
      settlements.place_settlement_circle(minp, maxp)
    end
  end)

--
-- manually place buildings, for debugging
--
minetest.register_craftitem("settlements:tool", {
    description = "settlements build tool",
    inventory_image = "default_tool_woodshovel.png",
    on_use = function(itemstack, placer, pointed_thing)
      local center_surface = pointed_thing.under
      if center_surface then
        building_all_info = {name = "hut", mts = schem_path.."hut.mts", hsize = 10, max_num = 0.9, rplc = "y"}
        settlements.build_schematic(center_surface, building_all_info["mts"],building_all_info["rplc"])

--        settlements.convert_mts_to_lua()
--        settlements.mts_save()
      end
    end
  })


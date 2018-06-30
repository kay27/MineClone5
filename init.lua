package.cpath = package.cpath .. ";/usr/share/lua/5.2/?.so"
package.path = package.path .. ";/usr/share/zbstudio/lualibs/mobdebug/?.lua"
require('mobdebug').start()

settlements = {}
settlements.modpath = minetest.get_modpath("settlements");

dofile(settlements.modpath.."/const.lua")
dofile(settlements.modpath.."/utils.lua")
dofile(settlements.modpath.."/foundation.lua")
--dofile(settlements.modpath.."/doors.lua")
dofile(settlements.modpath.."/buildings.lua")


local function place_settlement(minp, maxp)
  -- wait xx seconds until building a new settlement 
  last_time = os.time() + 30
  -- find locations for buildings
  local location_list = settlements.find_locations(minp, maxp)
  if location_list then
    minetest.chat_send_all("Dorf")
    -- for each location, build something
    for i, mpos in ipairs(location_list) do
      minetest.after(0.5, function()
          settlements.build_schematic(mpos)
        end)
    end
  end
end
--
-- on map generation, try to build a settlement
--
minetest.register_on_generated(function(minp, maxp, seed)
  if maxp.y < 0 then 
      return 
    end
    if math.random(0,10)<9 or os.time() < last_time then 
      return 
    end
--    place_settlement(minp, maxp)
    settlements.place_settlement_circle(minp, maxp)
  end)

--
-- manually place buildings, for debugging
--
minetest.register_craftitem("settlements:tool", {
    description = "settlements build tool",
    inventory_image = "default_tool_woodshovel.png",
    on_use = function(itemstack, placer, pointed_thing)
      local p = pointed_thing.under
      if p then
        settlements.build_schematic(p)
--        settlements.convert_mts_to_lua()
--        settlements.mts_save()
      end
    end
  })


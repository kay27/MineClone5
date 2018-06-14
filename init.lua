package.cpath = package.cpath .. ";/usr/share/lua/5.2/?.so"
package.path = package.path .. ";/usr/share/zbstudio/lualibs/mobdebug/?.lua"
require('mobdebug').start()

settlements = {}

settlements.modpath = minetest.get_modpath("settlements");

dofile(settlements.modpath.."/roofs.lua")
dofile(settlements.modpath.."/utils.lua")
dofile(settlements.modpath.."/ground.lua")
dofile(settlements.modpath.."/doors.lua")


local last_time = os.time()




local function make(pos,material)
	local baumaterial = material
  local c_floor_material = "default:wood"
	local height = math.random(4,4)
	local width = math.random(4,5)
	local depth = math.random(4,5)
--    if math.random(1,10) > 8 then material = "wood" end
    
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
							 new = baumaterial
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


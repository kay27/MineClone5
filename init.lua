--package.cpath = package.cpath .. ";/usr/share/lua/5.2/?.so"
--package.path = package.path .. ";/usr/share/zbstudio/lualibs/mobdebug/?.lua"
--require('mobdebug').start()

local c_floor_material = "default:brick"
local c_roof_material = "default:wood"
local c_balcony_material = "default:dirt_with_grass"
local last_time = os.time()




local function shallowCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end

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

local function ground(pos)
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

local function door(pos, width, depth)
	local p3 = shallowCopy(pos)
	p3.y = p3.y+1
	if math.random(0,1) > 0 then
		if math.random(0,1)>0 then p3.x=p3.x+width end
		p3.z = p3.z + depth/2
	else
		if math.random(0,1)>0 then p3.z=p3.z+depth end
		p3.x = p3.x + width/2
	end
-- cut out door
    minetest.remove_node(p3)
	p3.y = p3.y+1
	minetest.remove_node(p3)
    
-- find door facedir
    local door_dir

    local e = minetest.get_node_or_nil({x=p3.x+1, y=p3.y-2, z=p3.z})
    local w = minetest.get_node_or_nil({x=p3.x-1, y=p3.y-2, z=p3.z})
    local n = minetest.get_node_or_nil({x=p3.x, y=p3.y-2, z=p3.z+1})
    local s = minetest.get_node_or_nil({x=p3.x, y=p3.y-2, z=p3.z-1})
    if e and e.name ~= c_floor_material then
--        minetest.chat_send_all('e')
--        minetest.chat_send_all(e.name)
        door_dir = minetest.dir_to_facedir({x = 1, y = 0, z = 0})
    end
--
    if w and w.name ~= c_floor_material then
--        minetest.chat_send_all('w')
--        minetest.chat_send_all(w.name)
        door_dir = minetest.dir_to_facedir({x = -1, y = 0, z = 0})
    end
--
    if n and n.name ~= c_floor_material then
--        minetest.chat_send_all('n')
--        minetest.chat_send_all(n.name)
        door_dir = minetest.dir_to_facedir({x = 0, y = 0, z = 1})
    end
--
    if s and s.name ~= c_floor_material then
--        minetest.chat_send_all('s')
--        minetest.chat_send_all(s.name)
        door_dir = minetest.dir_to_facedir({x = 0, y = 0, z = -1})
    end
-- place door
    
	p3.y = p3.y-1
    
	minetest.set_node(p3, {name = "doors:door_wood_b",
		                             param2 = door_dir})

end

local function roof(pos, height, width, depth)
	local material = c_roof_material
	local p4 = shallowCopy(pos)
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

local function space_around_house(pos, height, width, depth)
	local p5 = shallowCopy(pos)
	p5.x = pos.x-1
	p5.z = pos.z-1
	local width = width + 2
	local depth = depth + 2
	local height = height - 1
 	for yi = 0,height do
		for xi = 0,width do
			for zi = 0,depth do
				if xi < 1 or xi >= width or zi < 1 or zi >= depth then
                    if yi == 0 then
				       local p = {x=p5.x+xi, y=p5.y, z=p5.z+zi}
				       minetest.set_node(p, {name=c_balcony_material})
       				   minetest.after(1,ground,p)--(p)
                    else
					   minetest.remove_node({x=p5.x+xi, y=p5.y+yi, z=p5.z+zi})
                    end
				end
			end
		end
	 end
end


local function make(pos,material)
	local baumaterial = material
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
					minetest.after(1,ground,p)--(p)
--				elseif yi == height then
--					local p = {x=pos.x+xi, y=pos.y+yi, z=pos.z+zi}
--					minetest.set_node(p, {name="default:cobble"})
				else
-- walls 
					if xi < 1 or xi > width-1 or zi < 1 or zi > depth-1 then
--					if math.random(1,yi) == 1 then
						-- four corners of the house are tree trunks
--[[						if (xi == 0 and zi == 0) or 
							(xi == width and zi == depth) or 
							(xi == 0 and zi == depth) or
							(zi == 0 and xi == width) 
						then 
							material = "tree" 
						else
							material = "cobble"
						end
--]]					
						local new = baumaterial
 --                           minetest.chat_send_all(new)


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
	roof(pos, height, width, depth)
	door(pos, width, depth)
    space_around_house(pos, height, width, depth)

end

local function find_locations(minp, maxp)
-- Anzahl Gebäude
    local amount_of_buildings = 5 --math.random(5,10) 
    local location_list = {}
-- Mindest und maxi Abstand
    local radius = 20
    local housemindist = 9
    local housemaxdist = 50
    local centeroftown -- Erste location ist Mittelpunkt des Dorfes
--
    for i = 1,amount_of_buildings do
-- Zufallslocation finden
        ::neuerversuch:: -- Sprungpunkt, falls Abstand nicht passt
        local mpos = {x=math.random(minp.x,maxp.x), y=math.random(minp.y,maxp.y), z=math.random(minp.z,maxp.z)}  
-- vor dem Ablegen in die Liste, Abstand zu bisherigen locations finden, sobald mehr als eine location gefunden wurde
        if i > 1 then
-- bisherige Liste durchgehen und mit aktueller mpos vergleichen
            for j, saved_location in ipairs(location_list) do
                local distanceToCenter = math.sqrt(((centeroftown.x - mpos.x)*(centeroftown.x - mpos.x))+((centeroftown.y - mpos.y)*(centeroftown.y - mpos.y)))
                local distanceTohouses = math.sqrt(((saved_location.x - mpos.x)*(saved_location.x - mpos.x))+((saved_location.y - mpos.y)*(saved_location.y - mpos.y)))

-- nicht weiter als 
                if distanceToCenter > radius or distanceTohouses < housemindist or distanceTohouses > housemaxdist then
                    goto neuerversuch
                end
            end
            

            location_list[i] = mpos
        else
            location_list[i] = mpos
            centeroftown = mpos
        end
   end
   return location_list
end



minetest.register_on_generated(function(minp, maxp, seed)

	if maxp.y < 0 then return end
--    minetest.chat_send_all(last_time.." "..os.time())
	if math.random(0,10)<9 or os.time() < last_time then return end
-- wartezeit bis zum nächsten Buildversuch 
        last_time = os.time() +30
        local location_list = find_locations(minp, maxp)
        local baumaterial = {"default:junglewood", "default:pine_wood", "default:wood",
            "default:aspen_wood", "default:acacia_wood", "default:junglewood", "default:pine_wood", "default:wood",
            "default:aspen_wood", "default:acacia_wood","default:junglewood", "default:pine_wood", "default:wood",
            "default:aspen_wood", "default:acacia_wood","default:junglewood", "default:pine_wood", "default:wood",
            "default:aspen_wood", "default:acacia_wood"  }
        
--		local mpos = {x=math.random(minp.x,maxp.x), y=math.random(minp.y,maxp.y), z=math.random(minp.z,maxp.z)}
        for i, mpos in ipairs(location_list) do
            local material = baumaterial[i]
            minetest.chat_send_all(minetest.pos_to_string(mpos).." "..material)
            minetest.after(0.5, function()
	        	 p2 = minetest.find_node_near(mpos, 25, {"default:dirt_with_grass"})	
	        	 if not p2 or p2 == nil or p2.y < 0 then return end
	             make(p2,material)
	    	end)
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


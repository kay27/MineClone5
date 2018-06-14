--
-- Function to place a door
--
function settlements.door(pos, width, depth)
	local p3 = settlements.shallowCopy(pos)
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


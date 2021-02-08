function mcl_minecarts:velocity_to_dir(v)
	if math.abs(v.x) > math.abs(v.z) then
		return {x=v.x>0 and 1 or v.x<0 and -1 or 0, y=v.y>0 and 1 or v.y<0 and -1 or 0, z=0}
	end
	return {x=0, y=v.y>0 and 1 or v.y<0 and -1 or 0, z=v.z>0 and 1 or v.z<0 and -1 or 0}
end

function mcl_minecarts:get_node_name(pos)
	local node = minetest.get_node(pos).name
	if node ~= "ignore" then return node end

	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map(pos, pos)
	local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
	local data = vm:get_data()
	local vi = area:indexp(pos)
	return minetest.get_name_from_content_id(data[vi])
end

function mcl_minecarts:is_rail(pos)
	return (minetest.get_item_group(mcl_minecarts:get_node_name(pos), "rail") > 0)
end

function mcl_minecarts:check_front_up_down(pos, dir, check_down)
	-- Front
	if mcl_minecarts:is_rail({x=pos.x+dir.x, y=pos.y, z=pos.z+dir.z}) then
		return {x=dir.x, y=0, z=dir.z}
	end
	-- Down
	if check_down and mcl_minecarts:is_rail({x=pos.x+dir.x, y=pos.y-1, z=pos.z+dir.z}) then
		return {x=dir.x, y=1, z=dir.z}
	end
	-- Up
	if check_down and mcl_minecarts:is_rail({x=pos.x+dir.x, y=pos.y+1, z=pos.z+dir.z}) then
		return {x=dir.x, y=1, z=dir.z}
	end
end

function mcl_minecarts:get_rail_direction(pos, dir)
	-- Normal
	local cur = mcl_minecarts:check_front_up_down(pos, dir, true)
	if cur then return cur end

	-- Check left and right
	local left, right = {x=0, y=0, z=0}, {x=0, y=0, z=0}
	if dir.z ~= 0 and dir.x == 0 then
		left.x = -dir.z
		right.x = dir.z
		cur = mcl_minecarts:check_front_up_down(pos, left, false) or mcl_minecarts:check_front_up_down(pos, right, false)
	elseif dir.x ~= 0 and dir.z == 0 then
		left.z = dir.x
		right.z = -dir.x
		cur = mcl_minecarts:check_front_up_down(pos, left, false) or mcl_minecarts:check_front_up_down(pos, right, false)
	end
	if cur then return cur end
	
	-- Backwards
	cur = mcl_minecarts:check_front_up_down(pos, { x = -dir.x, y = dir.y, z = -dir.z }, true)
	if cur then return cur end
	
	return {x=0, y=0, z=0}
end

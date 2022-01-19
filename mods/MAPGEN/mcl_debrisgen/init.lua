local minetest_find_nodes_in_area = minetest.find_nodes_in_area
local minetest_get_node = minetest.get_node
local minetest_set_node = minetest.set_node
local debris_name = "mcl_nether:ancient_debris"
local netherrack_name = "mcl_nether:netherrack"
local air_name = "air"

local min, max = mcl_mapgen.nether.min, mcl_mapgen.nether.max

mcl_mapgen.register_mapgen_block(function(minp, maxp)
	local minp = minp
	local minp_y = minp.y
	if minp_y > max then return end
	local maxp = maxp
	local maxp_y = maxp.y
	if maxp_y < min then return end
	local nodes = minetest_find_nodes_in_area(minp, maxp, debris_name)
	if nodes then
		for _, pos in pairs(nodes) do
			minetest.log("warning","debris found at "..minetest.pos_to_string(pos))
			local x, y, z = pos.x, pos.y, pos.z
			if minetest_get_node({x = x-1, y = y, z = z}) == air_name
			or minetest_get_node({x = x+1, y = y, z = z}) == air_name
			or minetest_get_node({x = x, y = y-1, z = z}) == air_name
			or minetest_get_node({x = x, y = y+1, z = z}) == air_name
			or minetest_get_node({x = x, y = y, z = z-1}) == air_name
			or minetest_get_node({x = x, y = y, z = z+1}) == air_name then
				minetest_set_node(pos, netherrack_name)
				minetest.log("warning","debris at "..minetest.pos_to_string(pos) .. " replaced to netherrack")
			end
		end
	end
end)

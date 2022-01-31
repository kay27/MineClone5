
		-- Nether block fixes:
		-- * Replace water with Nether lava.
		-- * Replace stone, sand dirt in v6 so the Nether works in v6.
		elseif minp.y <= mcl_mapgen.nether.max and maxp.y >= mcl_mapgen.nether.min then
			if c_nether then
				if v6 then
					local nodes = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:water_source", "mcl_core:stone", "mcl_core:sand", "mcl_core:dirt"})
					for n=1, #nodes do
						local p_pos = area:index(nodes[n].x, nodes[n].y, nodes[n].z)
						if data[p_pos] == c_water then
							data[p_pos] = c_nether.lava
							lvm_used = true
						elseif data[p_pos] == c_stone then
							data[p_pos] = c_netherrack
							lvm_used = true
						elseif data[p_pos] == c_sand or data[p_pos] == c_dirt then
							data[p_pos] = c_soul_sand
							lvm_used = true
						end
					end
				else
					local nodes = minetest.find_nodes_in_area(minp, maxp, {"group:water"})
					for _, n in pairs(nodes) do
						data[area:index(n.x, n.y, n.z)] = c_nether.lava
					end
				end
			end

		-- End block fixes:
		-- * Replace water with end stone or air (depending on height).
		-- * Remove stone, sand, dirt in v6 so our End map generator works in v6.
		-- * Generate spawn platform (End portal destination)
		elseif minp.y <= mcl_mapgen.end_.max and maxp.y >= mcl_mapgen.end_.min then
			local nodes
			if v6 then
				nodes = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:water_source", "mcl_core:stone", "mcl_core:sand", "mcl_core:dirt"})
			else
				nodes = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:water_source"})
			end
			if #nodes > 0 then
				lvm_used = true
				for _,n in pairs(nodes) do
					data[area:index(n.x, n.y, n.z)] = c_air
				end
			end

			-- Obsidian spawn platform
			if minp.y <= mcl_mapgen.end_.platform_pos.y and maxp.y >= mcl_mapgen.end_.platform_pos.y and
				minp.x <= mcl_mapgen.end_.platform_pos.x and maxp.x >= mcl_mapgen.end_.platform_pos.z and
				minp.z <= mcl_mapgen.end_.platform_pos.z and maxp.z >= mcl_mapgen.end_.platform_pos.z then

				--local pos1 = {x = math.max(minp.x, mcl_mapgen.end_.platform_pos.x-2), y = math.max(minp.y, mcl_mapgen.end_.platform_pos.y),   z = math.max(minp.z, mcl_mapgen.end_.platform_pos.z-2)}
				--local pos2 = {x = math.min(maxp.x, mcl_mapgen.end_.platform_pos.x+2), y = math.min(maxp.y, mcl_mapgen.end_.platform_pos.y+2), z = math.min(maxp.z, mcl_mapgen.end_.platform_pos.z+2)}

				for x=math.max(minp.x, mcl_mapgen.end_.platform_pos.x-2), math.min(maxp.x, mcl_mapgen.end_.platform_pos.x+2) do
				for z=math.max(minp.z, mcl_mapgen.end_.platform_pos.z-2), math.min(maxp.z, mcl_mapgen.end_.platform_pos.z+2) do
				for y=math.max(minp.y, mcl_mapgen.end_.platform_pos.y), math.min(maxp.y, mcl_mapgen.end_.platform_pos.y+2) do
					local p_pos = area:index(x, y, z)
					if y == mcl_mapgen.end_.platform_pos.y then
						data[p_pos] = c_obsidian
					else
						data[p_pos] = c_air
					end
				end
				end
				end
				lvm_used = true
			end
		end
	end


	if not singlenode then
		-- Generate special decorations
		generate_underground_mushrooms(minp, maxp, blockseed)
		generate_nether_decorations(minp, maxp, blockseed)
	end

end, 1)

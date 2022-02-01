local v6 = mcl_mapgen.v6

local mcl_mushrooms = minetest.get_modpath("mcl_mushrooms")

local c_nether = minetest.get_modpath("mcl_nether") and {
	soul_sand = minetest.get_content_id("mcl_nether:soul_sand"),
	netherrack = minetest.get_content_id("mcl_nether:netherrack"),
	lava = minetest.get_content_id("mcl_nether:nether_lava_source")
}

-- Generate mushrooms in caves manually.
-- Minetest's API does not support decorations in caves yet. :-(
local function generate_underground_mushrooms(minp, maxp, seed)
	if not mcl_mushrooms then return end

	local pr_shroom = PseudoRandom(seed-24359)
	-- Generate rare underground mushrooms
	-- TODO: Make them appear in groups, use Perlin noise
	local min, max = mcl_mapgen.overworld.lava_max + 4, 0
	if minp.y > max or maxp.y < min then
		return
	end

	local bpos
	local stone = minetest.find_nodes_in_area_under_air(minp, maxp, {"mcl_core:stone", "mcl_core:dirt", "mcl_core:mycelium", "mcl_core:podzol", "mcl_core:andesite", "mcl_core:diorite", "mcl_core:granite", "mcl_core:stone_with_coal", "mcl_core:stone_with_iron", "mcl_core:stone_with_gold"})

	for n = 1, #stone do
		bpos = {x = stone[n].x, y = stone[n].y + 1, z = stone[n].z }

		local l = minetest.get_node_light(bpos, 0.5)
		if bpos.y >= min and bpos.y <= max and l and l <= 12 and pr_shroom:next(1,1000) < 4 then
			if pr_shroom:next(1,2) == 1 then
				minetest.set_node(bpos, {name = "mcl_mushrooms:mushroom_brown"})
			else
				minetest.set_node(bpos, {name = "mcl_mushrooms:mushroom_red"})
			end
		end
	end
end

-- Generate Nether decorations manually: Eternal fire, mushrooms
-- Minetest's API does not support decorations in caves yet. :-(
local function generate_nether_decorations(minp, maxp, seed)
	if c_nether == nil then
		return
	end

	local pr_nether = PseudoRandom(seed+667)

	if minp.y > mcl_mapgen.nether.max or maxp.y < mcl_mapgen.nether.min then
		return
	end

	minetest.log("action", "[mcl_mapgen_core] Nether decorations " .. minetest.pos_to_string(minp) .. " ... " .. minetest.pos_to_string(maxp))

	-- TODO: Generate everything based on Perlin noise instead of PseudoRandom

	local bpos
	local rack = minetest.find_nodes_in_area_under_air(minp, maxp, {"mcl_nether:netherrack"})
	local magma = minetest.find_nodes_in_area_under_air(minp, maxp, {"mcl_nether:magma"})
	local ssand = minetest.find_nodes_in_area_under_air(minp, maxp, {"mcl_nether:soul_sand"})

	-- Helper function to spawn “fake” decoration
	local function special_deco(nodes, spawn_func)
		for n = 1, #nodes do
			bpos = {x = nodes[n].x, y = nodes[n].y + 1, z = nodes[n].z }

			spawn_func(bpos)
		end

	end

	-- Eternal fire on netherrack
	special_deco(rack, function(bpos)
		-- Eternal fire on netherrack
		if pr_nether:next(1,100) <= 3 then
			minetest.set_node(bpos, {name = "mcl_fire:eternal_fire"})
		end
	end)

	-- Eternal fire on magma cubes
	special_deco(magma, function(bpos)
		if pr_nether:next(1,150) == 1 then
			minetest.set_node(bpos, {name = "mcl_fire:eternal_fire"})
		end
	end)

	-- Mushrooms on netherrack
	-- Note: Spawned *after* the fire because of light level checks
	if mcl_mushrooms then
		special_deco(rack, function(bpos)
			local l = minetest.get_node_light(bpos, 0.5)
			if bpos.y > mcl_mapgen.nether.lava_max + 6 and l and l <= 12 and pr_nether:next(1,1000) <= 4 then
				-- TODO: Make mushrooms appear in groups, use Perlin noise
				if pr_nether:next(1,2) == 1 then
					minetest.set_node(bpos, {name = "mcl_mushrooms:mushroom_brown"})
				else
					minetest.set_node(bpos, {name = "mcl_mushrooms:mushroom_red"})
				end
			end
		end)
	end
end

mcl_mapgen.register_mapgen(function(minp, maxp, seed, vm_context)
	local min_y, max_y = minp.y, maxp.y

	-- Nether block fixes:
	-- * Replace water with Nether lava.
	-- * Replace stone, sand dirt in v6 so the Nether works in v6.
	if min_y <= mcl_mapgen.nether.max and max_y >= mcl_mapgen.nether.min then
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
		generate_underground_mushrooms(minp, maxp, chunkseed)
		generate_nether_decorations(minp, maxp, chunkseed)
	end

end, 1)


local END_EXIT_PORTAL_POS = vector.new(-3, -27003, -3) -- End exit portal position
local WITCH_HUT_HEIGHT = 3 -- Exact Y level to spawn witch huts at. This height refers to the height of the floor
local OVERWORLD_STRUCT_MIN, OVERWORLD_STRUCT_MAX = mcl_mapgen.overworld.min, mcl_mapgen.overworld.max
local END_STRUCT_MIN, END_STRUCT_MAX = mcl_mapgen.end_.min, mcl_mapgen.end_.max
local DIVLEN = 5
local V6 = mcl_mapgen.v6

local math_min, math_max = math.min, math.max
local math_floor, math_ceil = math.floor, math.ceil
local minetest_get_node = minetest.get_node
local minetest_get_mapgen_object = minetest.get_mapgen_object
local minetest_find_nodes_in_area = minetest.find_nodes_in_area
local minetest_get_item_group = minetest.get_item_group

local perlin_structures

local schematic_path = minetest.get_modpath('mcl_structures')

local function determine_ground_level(p, vm_context)
	local maxp = vm_context.maxp
	local maxp_y = maxp.y
	local y = math_min(OVERWORLD_STRUCT_MAX, maxp_y)
	if y < maxp_y then
		y = y + 1
	end
	p.y = y

	local checknode = minetest_get_node(p)
	local nn = checknode.name
	if nn ~= "air" and minetest_get_item_group(nn, "attached_node") == 0 and minetest_get_item_group(nn, "deco_block") == 0 then return end

	for y = y - 1, math_max(OVERWORLD_STRUCT_MIN, vm_context.minp.y), -1 do
		p.y = y
		local checknode = minetest_get_node(p)
		if checknode then
			local nn = checknode.name
			local def = minetest.registered_nodes[nn]
			if def and def.walkable then
				return p, y, nn
			end
		end
	end
end

-- Helper function for converting a MC probability to MT, with
-- regards to MapBlocks.
-- Some MC generated structures are generated on per-chunk
-- probability.
-- The MC probability is 1/x per Minecraft chunk (16×16).

-- x: The MC probability is 1/x.
-- minp, maxp: MapBlock limits
-- returns: Probability (1/return_value) for a single MT mapblock
local function minecraft_chunk_probability(x, minp, maxp)
	-- 256 is the MC chunk height
	return x * (((maxp.x-minp.x+1)*(maxp.z-minp.z+1)) / 256)
end

-- Takes x and z coordinates and minp and maxp of a generated chunk
-- (in on_generated callback) and returns a biomemap index)
-- Inverse function of biomemap_to_xz
local function xz_to_biomemap_index(x, z, minp, maxp)
	local zstride = maxp.z - minp.z + 1
	return (z - minp.z) * zstride + (x - minp.x) + 1
end

--local chunk_has_desert_struct
--local chunk_has_desert_temple
--local chunk_has_igloo

local octaves = 3
local persistence = 0.6
local offset = 0
local scale = 1
local max_noise = 0
for i = 1, octaves do
	local noise = 1 * (persistence ^ (i - 1))
	max_noise = max_noise + noise
end
max_noise = max_noise * octaves
max_noise = offset + scale * max_noise

local function spawn_desert_temple(p, nn, pr, vm_context)
	if p.y < 5 then return end
	if nn ~= "mcl_core:sand" and nn ~= "mcl_core:sandstone" then return end
	-- if pr:next(1,12000) ~= 1 then return end
	mcl_structures.call_struct(p, "desert_temple", nil, pr)
	return true
end

local function spawn_desert_well(p, nn, pr, vm_context)
	if p.y < 5 then return end
	if nn ~= "mcl_core:sand" and nn ~= "mcl_core:sandstone" then return end
	local desert_well_prob = minecraft_chunk_probability(1000, vm_context.minp, vm_context.maxp)
	-- if pr:next(1, desert_well_prob) ~= 1 then return end
	local surface = minetest_find_nodes_in_area({x=p.x,y=p.y-1,z=p.z}, {x=p.x+5, y=p.y-1, z=p.z+5}, "mcl_core:sand")
	if #surface < 25 then return end
	mcl_structures.call_struct(p, "desert_well", nil, pr)
	return true
end

local function spawn_igloo(p, nn, pr, vm_context)
	if nn ~= "mcl_core:snowblock" and nn ~= "mcl_core:snow" and minetest_get_item_group(nn, "grass_block_snow") ~= 1 then return end
	-- if pr:next(1, 4400) ~= 1 then return end
	-- Check surface
	local floor = {x=p.x+9, y=p.y-1, z=p.z+9}
	local surface = minetest_find_nodes_in_area({x=p.x,y=p.y-1,z=p.z}, floor, {"mcl_core:snowblock", "mcl_core:dirt_with_grass_snow"})
	if #surface < 63 then return end
	mcl_structures.call_struct(p, "igloo", nil, pr)
	-- chunk_has_igloo = true
	return true
end

local function spawn_fossil(p, nn, pr, vm_context)
	-- if chunk_has_desert_temple or p.y < 4 then return end
	if p.y < 4 then return end
	if nn ~= "mcl_core:sandstone" and nn ~= "mcl_core:sand" then return end
	local fossil_prob = minecraft_chunk_probability(64, vm_context.minp, vm_context.maxp)
	if pr:next(1, fossil_prob) ~= 1 then return end
	-- Spawn fossil below desert surface between layers 40 and 49
	local p1 = {x=p.x, y=pr:next(mcl_worlds.layer_to_y(40), mcl_worlds.layer_to_y(49)), z=p.z}
	-- Very rough check of the environment (we expect to have enough stonelike nodes).
	-- Fossils may still appear partially exposed in caves, but this is O.K.
	local p2 = vector.add(p1, 4)
	local nodes = minetest_find_nodes_in_area(p1, p2, {"mcl_core:sandstone", "mcl_core:stone", "mcl_core:diorite", "mcl_core:andesite", "mcl_core:granite", "mcl_core:stone_with_coal", "mcl_core:dirt", "mcl_core:gravel"})
	if #nodes < 100 then return end
	-- >= 80%
	mcl_structures.call_struct(p1, "fossil", nil, pr)
end

local witch_hut_offsets = {
	["0"] = {
		{x=1, y=0, z=1}, {x=1, y=0, z=5}, {x=6, y=0, z=1}, {x=6, y=0, z=5},
	},
	["180"] = {
		{x=2, y=0, z=1}, {x=2, y=0, z=5}, {x=7, y=0, z=1}, {x=7, y=0, z=5},
	},
	["270"] = {
		{x=1, y=0, z=1}, {x=5, y=0, z=1}, {x=1, y=0, z=6}, {x=5, y=0, z=6},
	},
	["90"] = {
		{x=1, y=0, z=2}, {x=5, y=0, z=2}, {x=1, y=0, z=7}, {x=5, y=0, z=7},
	},
}

local function spawn_witch_hut(p, nn, pr, vm_context)
	minetest.log("warning", "p="..minetest.pos_to_string(p)..", nn="..nn)
	-- if p.y > 1 or minetest_get_item_group(nn, "dirt") == 0 then return end
	local minp, maxp = vm_context.minp, vm_context.maxp
	local prob = minecraft_chunk_probability(48, minp, maxp)
	minetest.log("warning", "prob="..tostring(prob))
	-- if pr:next(1, prob) ~= 1 then return end

	-- Where do witches live?
	if V6 then
		-- v6: In Normal biome
		if biomeinfo.get_v6_biome(p) ~= "Normal" then return end
	else
		-- Other mapgens: In swampland biome
		local biomemap = vm_context.biomemap
		if not biomemap then
			vm_context.biomemap = minetest_get_mapgen_object('biomemap')
			biomemap = vm_context.biomemap
		end
		-- minetest.chat_send_all(minetest.serialize(biomemap))
		local swampland = minetest.get_biome_id("Swampland")
		local swampland_shore = minetest.get_biome_id("Swampland_shore")
		local bi = xz_to_biomemap_index(p.x, p.z, vm_context.minp, vm_context.maxp)
		if (biomemap[bi] == swampland) then
			minetest.chat_send_all('swampland')
		end
		if (biomemap[bi] == swampland_shore) then
			minetest.chat_send_all('swampland_shore')
		end
		-- if biomemap[bi] ~= swampland and biomemap[bi] ~= swampland_shore then return end
	end

	local r = tostring(pr:next(0, 3) * 90) -- "0", "90", "180" or 270"
	local p1 = {x=p.x-1, y=WITCH_HUT_HEIGHT+2, z=p.z-1}
	local size
	if r == "0" or r == "180" then
		size = {x=10, y=4, z=8}
	else
		size = {x=8, y=4, z=10}
	end
	local p2 = vector.add(p1, size)

	-- This checks free space at the “body” of the hut and a bit around.
	-- ALL nodes must be free for the placement to succeed.
	local free_nodes = minetest_find_nodes_in_area(p1, p2, {"air", "mcl_core:water_source", "mcl_flowers:waterlily"})
	if #free_nodes < ((size.x+1)*(size.y+1)*(size.z+1)) then return end

	local place = {x=p.x, y=WITCH_HUT_HEIGHT-1, z=p.z}

	-- FIXME: For some mysterious reason (black magic?) this
	-- function does sometimes NOT spawn the witch hut. One can only see the
	-- oak wood nodes in the water, but no hut. :-/
	mcl_structures.call_struct(place, "witch_hut", r, pr)

	-- TODO: Spawn witch in or around hut when the mob sucks less.

	local function place_tree_if_free(pos, prev_result)
		local nn = minetest.get_node(pos).name
		if nn == "mcl_flowers:waterlily" or nn == "mcl_core:water_source" or nn == "mcl_core:water_flowing" or nn == "air" then
			minetest.set_node(pos, {name="mcl_core:tree", param2=0})
			return prev_result
		else
			return false
		end
	end

	local offsets = witch_hut_offsets[r]
	for o=1, #offsets do
		local ok = true
		for y=place.y-1, place.y-64, -1 do
			local tpos = vector.add(place, offsets[o])
			tpos.y = y
			ok = place_tree_if_free(tpos, ok)
			if not ok then
				break
			end
		end
	end
end

-- TODO: Check spikes sizes, it looks like we have to swap them:

local function spawn_ice_spike_large(p, pr)
	-- Check surface
	local floor = {x=p.x+4, y=p.y-1, z=p.z+4}
	local surface = minetest_find_nodes_in_area({x=p.x+1,y=p.y-1,z=p.z+1}, floor, {"mcl_core:snowblock"})
	if #surface < 9 then return end

	-- Check for collision with spruce
	local spruce_collisions = minetest_find_nodes_in_area({x=p.x+1,y=p.y+2,z=p.z+1}, {x=p.x+4, y=p.y+6, z=p.z+4}, {"mcl_core:sprucetree", "mcl_core:spruceleaves"})
	if #spruce_collisions > 0 then return end

	mcl_structures.call_struct(p, "ice_spike_large", nil, pr)
	return true
end

local function spawn_ice_spike_small(p, pr)
	-- Check surface
	local floor = {x=p.x+6, y=p.y-1, z=p.z+6}
	local surface = minetest_find_nodes_in_area({x=p.x+1,y=p.y-1,z=p.z+1}, floor, {"mcl_core:snowblock", "mcl_core:dirt_with_grass_snow"})
	if #surface < 25 then return end

	-- Check for collision with spruce
	local spruce_collisions = minetest_find_nodes_in_area({x=p.x+1,y=p.y+1,z=p.z+1}, {x=p.x+6, y=p.y+6, z=p.z+6}, {"mcl_core:sprucetree", "mcl_core:spruceleaves"})

	if #spruce_collisions > 0 then return end

	mcl_structures.call_struct(p, "ice_spike_small", nil, pr)
	return true
end

local function spawn_spikes_in_v6(p, nn, pr)
	-- In other mapgens, ice spikes are generated as decorations.
	-- if chunk_has_igloo or nn ~= "mcl_core:snowblock" then return end
	if nn ~= "mcl_core:snowblock" then return end
	local spike = pr:next(1,58000)
	if spike < 3 then
		return spawn_ice_spike_large(p, pr)
	elseif spike < 100 then
		return spawn_ice_spike_small(p, pr)
	end
end

local function generate_structures(vm_context)
	local pr = PcgRandom(vm_context.chunkseed)
	-- chunk_has_desert_struct = false
	-- chunk_has_desert_temple = false
	-- chunk_has_igloo = false
	local minp, maxp = vm_context.minp, vm_context.maxp

	perlin_structures = perlin_structures or minetest.get_perlin(329, 3, 0.6, 100)

	-- Assume X and Z lengths are equal
	local DIVLEN = 5
	for x0 = minp.x, maxp.x, DIVLEN do for z0 = minp.z, maxp.z, DIVLEN do
		-- Determine amount from perlin noise
		-- Find random positions based on this random
		local p, ground_y, nn
		for i = 0, 24 do
		--for i=0, amount do
			-- p = {x = pr:next(x0, x0 + DIVLEN - 1), y = 0, z = pr:next(z0, z0 + DIVLEN - 1)}
			p = {x = x0 + i % 5, z = z0 + math_floor(i/5)}
			p, ground_y, nn = determine_ground_level(p, vm_context)
			if ground_y then
				p.y = ground_y + 1
				local nn0 = minetest.get_node(p).name
				-- Check if the node can be replaced
				if minetest.registered_nodes[nn0] and minetest.registered_nodes[nn0].buildable_to then
					--spawn_desert_temple(p, nn, pr, vm_context)
					--spawn_desert_well(p, nn, pr, vm_context)
					--spawn_igloo(p, nn, pr, vm_context)
					--spawn_fossil(p, nn, pr, vm_context)
					--spawn_witch_hut(p, nn, pr, vm_context)
					if V6 then
						spawn_spikes_in_v6(p, nn, pr, vm_context)
					end
				end
			end
		end
	end end
	return vm_context
end

local function generate_end_structures(vm_context)
	local minp, maxp = vm_context.minp, vm_context.maxp
	if	minp.y <= END_EXIT_PORTAL_POS.y and maxp.y >= END_EXIT_PORTAL_POS.y
	and	minp.x <= END_EXIT_PORTAL_POS.x and maxp.x >= END_EXIT_PORTAL_POS.x
	and	minp.z <= END_EXIT_PORTAL_POS.z and maxp.z >= END_EXIT_PORTAL_POS.z
	then
		local p = {x=END_EXIT_PORTAL_POS.x, z=END_EXIT_PORTAL_POS.z}
		for y = maxp.y, minp.y, -1 do
			p.y = y
			if minetest.get_node(p).name == "mcl_end:end_stone" then
				mcl_mapgen_core.generate_end_exit_portal(p)
				break
			end
		end
	end
	return vm_context
end

if not mcl_mapgen.singlenode then
	mcl_mapgen.register_mapgen(function(minp, maxp, seed, vm_context)
	-- mcl_mapgen.register_on_generated(function(vm_context)
		-- local minp, maxp = vm_context.minp, vm_context.maxp
		local minp, maxp = minp, maxp
		local minp_y, maxp_y = minp.y, maxp.y
		generate_structures(vm_context)
--		if maxp_y >= OVERWORLD_STRUCT_MIN and minp_y <= OVERWORLD_STRUCT_MAX then
--			return generate_structures(vm_context)
		-- End exit portal
--		elseif maxp_y >= END_STRUCT_MIN and minp_y <= END_STRUCT_MAX then
--			return generate_end_structures(vm_context)
--		end
--		return vm_context
	end)
end

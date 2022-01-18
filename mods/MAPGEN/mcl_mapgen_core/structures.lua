local END_EXIT_PORTAL_POS = vector.new(-3, -27003, -3) -- End exit portal position
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

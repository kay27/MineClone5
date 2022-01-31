local c_dirt_with_grass_snow = minetest.get_content_id("mcl_core:dirt_with_grass_snow")
local c_top_snow             = minetest.get_content_id("mcl_core:snow")
local c_snow_block           = minetest.get_content_id("mcl_core:snowblock")

mcl_mapgen.register_on_generated(function(vm_context)
	local minp, maxp = vm_context.minp, vm_context.maxp
	local min_y = minp.y
	if min_y > mcl_mapgen.overworld.max or maxp.y < mcl_mapgen.overworld.min then return end
	vm_context.param2_data = vm_context.param2_data or vm:get_param2_data(vm_context.lvm_param2_buffer)
	vm_context.biomemap    = vm_context.biomemap or minetest.get_mapgen_object("biomemap")
	local param2_data      = vm_context.param2_data
	local biomemap         = vm_context.biomemap
	local vm, data, area   = vm_context.vm, vm_context.data, vm_context.area

	----- Interactive block fixing section -----
	----- The section to perform basic block overrides of the core mapgen generated world. -----

	-- Snow and sand fixes. This code implements snow consistency
	-- and fixes floating sand and cut plants.
	-- A snowy grass block must be below a top snow or snow block at all times.

	-- Set param2 (=color) of grass blocks.
	-- Clear snowy grass blocks without snow above to ensure consistency.
	local nodes = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:dirt_with_grass", "mcl_core:dirt_with_grass_snow"})

	-- Flat area at y=0 to read biome 3 times faster than 5.3.0.get_biome_data(pos).biome: 43us vs 125us per iteration:
	local aream = VoxelArea:new({MinEdge={x=minp.x, y=min_y, z=minp.z}, MaxEdge={x=maxp.x, y=min_y, z=maxp.z}})
	for n=1, #nodes do
		local n = nodes[n]
		local p_pos = area:index(n.x, n.y, n.z)
		local p_pos_above = area:index(n.x, n.y+1, n.z)
		local b_pos = aream:index(n.x, min_y, n.z)
		local bn = minetest.get_biome_name(biomemap[b_pos])
		if bn then
			local biome = minetest.registered_biomes[bn]
			if biome and biome._mcl_biome_type then
				param2_data[p_pos] = biome._mcl_palette_index
				vm_context.write_param2 = true
			end
		end
		if data[p_pos] == c_dirt_with_grass_snow and p_pos_above and data[p_pos_above] ~= c_top_snow and data[p_pos_above] ~= c_snow_block then
			data[p_pos] = c_dirt_with_grass
			vm_context.write = true
		end
	end
end, 999999999)

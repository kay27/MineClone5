local c_water = minetest.get_content_id("mcl_core:water_source")
local c_dirt = minetest.get_content_id("mcl_core:dirt")
local c_clay = minetest.get_content_id("mcl_core:clay")

local perlin_clay

mcl_mapgen.register_mapgen_lvm(function(c)
	local minp, maxp, blockseed, voxelmanip_data, voxelmanip_area, lvm_used = c.minp, c.maxp, c.chunkseed, c.data, c.area, c.write or false
	-- TODO: Make clay generation reproducible for same seed.
	if maxp.y < -5 or minp.y > 0 then
		return c
	end
	c.vm = c.vm or mcl_mapgen.get_voxel_manip(c)

	minetest.log("warning", "CLAY!")

	local pr = PseudoRandom(blockseed)

	perlin_clay = perlin_clay or minetest.get_perlin({
		offset = 0.5,
		scale = 0.2,
		spread = {x = 5, y = 5, z = 5},
		seed = -316,
		octaves = 1,
		persist = 0.0
	})

	for y=math.max(minp.y, 0), math.min(maxp.y, -8), -1 do
		-- Assume X and Z lengths are equal
		local divlen = 4
		local divs = (maxp.x-minp.x)/divlen+1;
		for divx=0+1,divs-2 do
		for divz=0+1,divs-2 do
			-- Get position and shift it a bit randomly so the clay do not obviously appear in a grid
			local cx = minp.x + math.floor((divx+0.5)*divlen) + pr:next(-1,1)
			local cz = minp.z + math.floor((divz+0.5)*divlen) + pr:next(-1,1)

			local water_pos = voxelmanip_area:index(cx, y+1, cz)
			local waternode = voxelmanip_data[water_pos]
			local surface_pos = voxelmanip_area:index(cx, y, cz)
			local surfacenode = voxelmanip_data[surface_pos]

			local genrnd = pr:next(1, 20)
			if genrnd == 1 and perlin_clay:get_3d({x=cx,y=y,z=cz}) > 0 and waternode == c_water and
					(surfacenode == c_dirt or minetest.get_item_group(minetest.get_name_from_content_id(surfacenode), "sand") == 1) then
				local diamondsize = pr:next(1, 3)
				for x1 = -diamondsize, diamondsize do
				for z1 = -(diamondsize - math.abs(x1)), diamondsize - math.abs(x1) do
					local ccpos = voxelmanip_area:index(cx+x1, y, cz+z1)
					local claycandidate = voxelmanip_data[ccpos]
					if voxelmanip_data[ccpos] == c_dirt or minetest.get_item_group(minetest.get_name_from_content_id(claycandidate), "sand") == 1 then
						voxelmanip_data[ccpos] = c_clay
						minetest.log("warning", "CLAY! "..minetest.pos_to_string({x=cx+x1,y=y,z=cz+z1}))
						lvm_used = true
					end
				end
				end
			end
		end
		end
	end
	c.write = lvm_used
	return c
end)

local c_debris = minetest.get_content_id("mcl_nether:ancient_debris")
local c_netherrack = minetest.get_content_id("mcl_nether:netherrack")
local c_air = minetest.get_content_id("air")

local facedir = {
  vector.new(0, 0, 1),
  vector.new(0, 1, 0),
  vector.new(1, 0, 0),
  vector.new(0, 0, -1),
  vector.new(0, -1, 0),
  vector.new(-1, 0, 0),
}

local min, max = mcl_mapgen.nether.min, mcl_mapgen.nether.max

minetest.register_on_generated(function(minp, maxp)
  if maxp.y < min or minp.y > max then
    return
  end

  local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
  local data = vm:get_data()
  local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})

  for idx in area:iter(minp.x, math.max(minp.y, min), minp.z, maxp.x, math.min(maxp.y, max), maxp.z) do
    if data[idx] == c_debris then
      local pos = area:position(idx)
      local exposed = false
      for _, dir in pairs(facedir) do
        if data[area:indexp(vector.add(pos, dir))] == c_air then
          exposed = true
          break
        end
      end
      if exposed then
        data[idx] = c_netherrack
      end
    end
  end

  vm:set_data(data)
  vm:calc_lighting()
  vm:update_liquids()
  vm:write_to_map()
end)

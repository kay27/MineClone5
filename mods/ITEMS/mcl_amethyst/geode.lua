local radius_min = 3
local radius_max = mcl_mapgen.HALF_BS
local layers = {
	{
		[100] = "mcl_core:andesite",
	},
	{
		[100] = "mcl_amethyst:calcite",
	},
	{
		[95] = "mcl_amethyst:amethyst_block",
		[5] = "mcl_amethyst:budding_amethyst_block",
	},
	{
		[100] = "air",
	}
}

local function place(pos, rotation, pr)
	local radius = pr:next(radius_min, radius_max)
	local pos = vector.add(pos, radius)
	for x = pos.x - radius, pos.x + radius do
		for y = pos.y - radius, pos.y + radius do
			for z = pos.z - radius, pos.z + radius do
				local node_pos = vector.new(x, y, z)
				local inverted_layer = vector.round(vector.distance(node_pos, pos))
				if inverted_layer <= radius then
					local layer = math.max(radius - inverted_layer + 1, #layers)
					local node_candidates = layers[layer]
					local node_name
					local chance_index = pr:next(1, 100)
					local current_weight = 0
					for chance, node_name_iterated in pairs(node_candidates) do
						if chance_index < current_weight + chance then
							node_name = node_name_iterated
							break
						end
						current_weight = current_weight + chance
					end
					minetest.swap_node(node_pos, {name = node_name})
				end
			end
		end
	end
end

mcl_structures.register_structure({
	name = "amethyst_geode",
	place_function = place,
})

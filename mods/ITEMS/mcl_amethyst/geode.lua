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

local function round(v)
	if v < 0 then
		return math.ceil(v - 0.5)
	end
	return math.floor(v + 0.5)
end

local function place(pos, rotation, pr)
	local radius1 = vector.new(
		-pr:next(radius_min, radius_max),
		-pr:next(radius_min, radius_max),
		-pr:next(radius_min, radius_max)
	)
	local radius2 = vector.new(
		pr:next(radius_min, radius_max),
		pr:next(radius_min, radius_max),
		pr:next(radius_min, radius_max)
	)
	local layer_radius = pr:next(radius_min, radius_max)
	local radius1_normalized = vector.normalize(radius1)
	local radius2_normalized = vector.normalize(radius2)
	local pos = vector.subtract(pos, radius1)
	for x = radius1.x, radius2.x do
		local max_x = (x < 0) and radius1.x or radius2.x
		for y = radius1.y, radius2.y do
			local max_y = (y < 0) and radius1.y or radius2.y
			for z = radius1.z, radius2.z do
				local max_z = (z < 0) and radius1.z or radius2.z
				local normal_abs = vector.new(x / max_x, y / max_y, z / max_z)
				local inverted_layer = round(vector.length(normal_abs) * layer_radius)
				if inverted_layer <= layer_radius then
					local layer = math.min(math.max(1, layer_radius - inverted_layer + 1), #layers)
					local offset = vector.new(x, y, z)
					local node_pos = pos + offset
					local node_candidates = layers[layer]
					local node_name
					local chance_index = pr:next(1, 100)
					local current_weight = 0
					for chance, node_name_iterated in pairs(node_candidates) do
						if chance_index <= current_weight + chance then
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

local radius_min = 3
local radius_max = mcl_mapgen.HALF_BS
local layers = {
	{
		[8] = "mcl_blackstone:basalt_polished",
		[92] = "mcl_deepslate:deepslate",
	},
	{
		[100] = "mcl_amethyst:calcite",
	},
	{
		[85] = "mcl_amethyst:amethyst_block",
		[15] = "mcl_amethyst:budding_amethyst_block",
	},
	{
		[98] = "mcl_amethyst:amethyst_block",
		[2] = "mcl_amethyst:budding_amethyst_block",
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

local decrease_scan_area = 1
local mapblock_opacity_placement_threshold = 0.98
local threshold = math.floor(((mcl_mapgen.BS - 2 * decrease_scan_area)^3) * mapblock_opacity_placement_threshold)
local upper_than = mcl_mapgen.overworld.bedrock_max
mcl_mapgen.register_mapgen_block(function(minp, maxp, blockseed)
	local y = minp.y
	if y <= upper_than then return end
	local pr = PseudoRandom(blockseed + 143)
	if pr:next(1, 120) ~= 54 then return end
	local opacity_counter = #minetest.find_nodes_in_area(vector.add(minp, decrease_scan_area), vector.subtract(maxp, decrease_scan_area), "group:opaque")
	if opacity_counter < threshold then return end
	place(minp, nil, pr)
end)

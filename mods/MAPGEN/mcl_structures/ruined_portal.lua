local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local chance_per_chunk = 400
local noise_multiplier = 2.5
local random_offset    = 9159
local scanning_ratio   = 0.001
local struct_threshold = 396

local mcl_structures_get_perlin_noise_level = mcl_structures.get_perlin_noise_level
local minetest_find_nodes_in_area = minetest.find_nodes_in_area
local minetest_swap_node = minetest.swap_node
local math_round = math.round
local math_abs = math.abs


local rotation_to_orientation = {
	["0"]   = 1,
	["90"]  = 0,
	["180"] = 1,
	["270"] = 0,
}

local rotation_to_param2 = {
	["0"]   = 3,
	["90"]  = 0,
	["180"] = 1,
	["270"] = 2,
}

local node_top = {
	"mcl_core:goldblock",
	"mcl_core:stone_with_gold",
	"mcl_core:goldblock",
}

local node_garbage = {
	"mcl_nether:netherrack",
	"mcl_core:lava_source",
	"mcl_nether:netherrack",
	"mcl_nether:netherrack",
	"mcl_nether:magma",
	"mcl_nether:netherrack",
}

local stone1 = {name = "mcl_core:stonebrickcracked"}
local stone2 = {name = "mcl_core:stonebrickmossy"}
local stone3 = {name = "mcl_nether:magma"}
local stone4 = {name = "mcl_core:stonebrick"}

local slab1 = {name = "mcl_stairs:slab_stonebrickcracked_top"}
local slab2 = {name = "mcl_stairs:slab_stonebrickmossy_top"}
local slab3 = {name = "mcl_stairs:slab_stone_top"}
local slab4 = {name = "mcl_stairs:slab_stonebrick_top"}

local stair1 = "mcl_stairs:stair_stonebrickcracked"
local stair2 = "mcl_stairs:stair_stonebrickmossy"
local stair3 = "mcl_stairs:stair_stone_rough"
local stair4 = "mcl_stairs:stair_stonebrick"


local function draw_frame(frame_pos, frame_width, frame_height, orientation, pr, is_chain, rotation)
	local param2 = rotation_to_param2[rotation]

	local function set_ruined_node(pos, node)
		if pr:next(1, 5) == 4 then return end
		minetest_swap_node(pos, node)
	end

	local function get_random_stone_material()
		local rnd = pr:next(1, 15)
		if rnd < 4 then	return stone1 end
		if rnd == 4 then return stone2 end
		if rnd == 5 then return stone3 end
		return stone4
	end

	local function get_random_slab()
		local rnd = pr:next(1, 15)
		if rnd < 4 then	return slab1 end
		if rnd == 4 then return slab2 end
		if rnd == 5 then return slab3 end
		return slab4
	end

	local function get_random_stair(param2_offset)
		local param2 = (param2 + (param2_offset or 0)) % 4
		local rnd = pr:next(1, 15)
		if rnd < 4 then	return {name = stair1, param2 = param2} end
		if rnd == 4 then return {name = stair2, param2 = param2} end
		if rnd == 5 then return {name = stair3, param2 = param2} end
		return {name = stair4, param2 = param2}
	end

	local function set_frame_stone_material(pos)
		minetest_swap_node(pos, get_random_stone_material())
	end

	local function set_ruined_frame_stone_material(pos)
		set_ruined_node(pos, get_random_stone_material())
	end

	local is_chain = is_chain
	local orientation = orientation
	local x1 = frame_pos.x
	local y1 = frame_pos.y
	local z1 = frame_pos.z
	local slide_x = (1 - orientation)
	local slide_z = orientation
	local last_x = x1 + (frame_width - 1) * slide_x
	local last_z = z1 + (frame_width - 1) * slide_z
	local last_y = y1 + frame_height - 1

	-- it's about the portal frame itself, what it will consist of
	local frame_nodes = 2 * (frame_height + frame_width) - 4
	local obsidian_nodes = pr:next(math_round(frame_nodes * 0.5), math_round(frame_nodes * 0.73))
	local crying_obsidian_nodes = pr:next(math_round(obsidian_nodes * 0.09), math_round(obsidian_nodes * 0.5))
	local air_nodes = frame_nodes - obsidian_nodes

	local function set_frame_node(pos)
		-- local node_choice = pr:next(1, air_nodes + obsidian_nodes)
		local node_choice = math_round(mcl_structures_get_perlin_noise_level(pos) * (air_nodes + obsidian_nodes))
		if node_choice > obsidian_nodes and air_nodes > 0 then
			air_nodes = air_nodes - 1
			return
		end
		obsidian_nodes = obsidian_nodes - 1
		if node_choice >= crying_obsidian_nodes then
			minetest_swap_node(pos, {name = "mcl_core:obsidian"})
			return 1
		end
		minetest_swap_node(pos, {name = "mcl_core:crying_obsidian"})
		crying_obsidian_nodes = crying_obsidian_nodes - 1
		return 1
	end

	local function set_outer_frame_node(def)
		local is_top = def.is_top
		if is_chain then
			local pos2 = def.pos_outer2
			local is_top_hole = is_top and frame_width > 5 and ((pos2.x == x1 + slide_x * 2 and pos2.z == z1 + slide_z * 2) or (pos2.x == last_x - slide_x * 2 and pos2.z == last_z - slide_z * 2))
			if is_top_hole then
				if pr:next(1, 7) > 1 then
					minetest_swap_node(pos2, {name = "xpanes:bar_flat", param2 = orientation})
				end
			else
				set_frame_stone_material(pos2)
			end
		end
		local is_obsidian = def.is_obsidian
		if not is_obsidian and pr:next(1, 2) == 1 then return end
		local pos = def.pos_outer1
		local is_decor_here = not is_top and pos.y % 3 == 2
		if is_decor_here then
			minetest_swap_node(pos, {name = "mcl_core:stonebrickcarved"})
		elseif is_chain then
			if not is_top and not is_obsidian then
				minetest_swap_node(pos, {name = "xpanes:bar"})
			else
				minetest_swap_node(pos, {name = "xpanes:bar_flat", param2 = orientation})
			end
		else
			if pr:next(1, 5) == 3 then
				minetest_swap_node(pos, {name = "mcl_core:stonebrickcracked"})
			else
				minetest_swap_node(pos, {name = "mcl_core:stonebrick"})
			end
		end
	end

	local function draw_roof(pos, length)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local number_of_roof_nodes = length
		if number_of_roof_nodes > 1 then
			set_ruined_node({x = x, y = y, z = z}, get_random_stair((param2 == 1 or param2 == 2) and -1 or 1))
			set_ruined_node({x = x + (length - 1) * slide_x, y = y, z = z + (length - 1) * slide_z}, get_random_stair((param2 == 1 or param2 == 2) and 1 or -1))
			number_of_roof_nodes = number_of_roof_nodes - 2
			x = x + slide_x
			z = z + slide_z
		end
		while number_of_roof_nodes > 0 do
			set_ruined_node({x = x, y = y, z = z}, get_random_stair((param2 == 1 or param2 == 2) and 2 or 0))
			x = x + slide_x
			z = z + slide_z
			number_of_roof_nodes = number_of_roof_nodes - 1
		end
	end

	-- bottom corners
	set_frame_node({x = x1, y = y1, z = z1})
	set_frame_node({x = last_x, y = y1, z = last_z})

	-- top corners
	local is_obsidian_top_left = set_frame_node({x = x1, y = last_y, z = z1})
	local is_obsidian_top_right = set_frame_node({x = last_x, y = last_y, z = last_z})

	if is_chain then
		if is_obsidian_top_left and pr:next(1, 4) ~= 2 then
			set_frame_stone_material({x = x1 - slide_x * 2, y = last_y + 2, z = z1 - slide_z * 2})
		end
		if is_obsidian_top_left and pr:next(1, 4) ~= 2 then
			set_frame_stone_material({x = x1 - slide_x * 2, y = last_y + 1, z = z1 - slide_z * 2})
		end
		if is_obsidian_top_left and pr:next(1, 4) ~= 2 then
			set_frame_stone_material({x = last_x + slide_x * 2, y = last_y + 2, z = last_z + slide_z * 2})
		end
		if is_obsidian_top_left and pr:next(1, 4) ~= 2 then
			set_frame_stone_material({x = last_x + slide_x * 2, y = last_y + 1, z = last_z + slide_z * 2})
		end
	end

	for y = y1, last_y do
		local begin_or_end = y == y1 or y == last_y
		local is_obsidian_left  = begin_or_end and is_obsidian_top_left  or set_frame_node({x = x1    , y = y, z = z1    })
		local is_obsidian_right = begin_or_end and is_obsidian_top_right or set_frame_node({x = last_x, y = y, z = last_z})
		set_outer_frame_node({
			pos_outer1 = {x = x1 - slide_x    , y = y, z = z1 - slide_z    },
			pos_outer2 = {x = x1 - slide_x * 2, y = y, z = z1 - slide_z * 2},
			is_obsidian = is_obsidian_left,
		})
		set_outer_frame_node({
			pos_outer1 = {x = last_x + slide_x    , y = y, z = last_z + slide_z    },
			pos_outer2 = {x = last_x + slide_x * 2, y = y, z = last_z + slide_z * 2},
			is_obsidian = is_obsidian_right,
		})
	end

	for i = 0, 1 do
		set_outer_frame_node({
			pos_outer1  = {x = x1 - slide_x * i, y = last_y + 1, z = z1 - slide_z * i},
			pos_outer2  = {x = x1 - slide_x * i, y = last_y + 2, z = z1 - slide_z * i},
			is_obsidian = is_obsidian_top_left,
			is_top      = true,
		})
		set_outer_frame_node({
			pos_outer1  = {x = last_x + slide_x * i, y = last_y + 1, z = last_z + slide_z * i},
			pos_outer2  = {x = last_x + slide_x * i, y = last_y + 2, z = last_z + slide_z * i},
			is_obsidian = is_obsidian_top_right,
			is_top      = true,
		})
	end

	for x = x1 + slide_x, last_x - slide_x do for z = z1 + slide_z, last_z - slide_z do
		set_frame_node({x = x, y = y1, z = z})
		local is_obsidian_top = set_frame_node({x = x, y = last_y, z = z})
		set_outer_frame_node({
			pos_outer1  = {x = x, y = last_y + 1, z = z},
			pos_outer2  = {x = x, y = last_y + 2, z = z},
			is_obsidian = is_obsidian_top,
			is_top      = true
		})
	end end

	local node_top = {name = node_top[pr:next(1, #node_top)]}
	if is_chain then
		set_ruined_frame_stone_material({x = x1     + slide_x * 2, y = last_y + 3, z = z1     + slide_z * 2})
		set_ruined_frame_stone_material({x = x1     + slide_x    , y = last_y + 3, z = z1     + slide_z    })
		set_ruined_frame_stone_material({x = last_x - slide_x    , y = last_y + 3, z = last_z - slide_z    })
		set_ruined_frame_stone_material({x = last_x - slide_x * 2, y = last_y + 3, z = last_z - slide_z * 2})
		for x = x1 + slide_x * 3, last_x - slide_x * 3 do for z = z1 + slide_z * 3, last_z - slide_z * 3 do
			set_ruined_node({x = x, y = last_y + 3, z = z}, node_top)
			set_ruined_node({x = x - slide_z, y = last_y + 3, z = z - slide_x}, get_random_slab())
			set_ruined_node({x = x + slide_z, y = last_y + 3, z = z + slide_x}, get_random_slab())
		end end
		draw_roof({x = x1 + slide_x * 3, y = last_y + 4, z = z1 + slide_z * 3}, frame_width - 6)
	else
		set_ruined_frame_stone_material({x = x1     + slide_x * 3, y = last_y + 2, z = z1     + slide_z * 3})
		set_ruined_frame_stone_material({x = x1     + slide_x * 2, y = last_y + 2, z = z1     + slide_z * 2})
		set_ruined_frame_stone_material({x = last_x - slide_x * 2, y = last_y + 2, z = last_z - slide_z * 2})
		set_ruined_frame_stone_material({x = last_x - slide_x * 3, y = last_y + 2, z = last_z - slide_z * 3})
		for x = x1 + slide_x * 4, last_x - slide_x * 4 do for z = z1 + slide_z * 4, last_z - slide_z * 4 do
			set_ruined_node({x = x, y = last_y + 2, z = z}, node_top)
			set_ruined_node({x = x - slide_z, y = last_y + 2, z = z - slide_x}, get_random_slab())
			set_ruined_node({x = x + slide_z, y = last_y + 2, z = z + slide_x}, get_random_slab())
		end end
		draw_roof({x = x1 + slide_x * 3, y = last_y + 3, z = z1 + slide_z * 3}, frame_width - 6)
	end
end

local possible_rotations = {"0", "90", "180", "270"}

local function draw_trash(pos, width, height, lift, orientation, pr)
	local slide_x = (1 - orientation)
	local slide_z = orientation
	local x1 = pos.x - lift - 1
	local x2 = pos.x + (width - 1) * slide_x + lift + 1
	local z1 = pos.z - lift - 1
	local z2 = pos.z + (width - 1) * slide_z + lift + 1
	local y1 = pos.y - pr:next(1, height) - 1
	local y2 = pos.y
	local opacity_layers = math.floor((y2 - y1) / 2)
	local opacity_layer = -opacity_layers
	for y = y1, y2 do
		local inverted_opacity_0_5 = math_round(math_abs(opacity_layer) / opacity_layers * 5)
		for x = x1 + pr:next(0, 2), x2 - pr:next(0, 2) do
			for z = z1 + pr:next(0, 2), z2 - pr:next(0, 2) do
				if inverted_opacity_0_5 == 0 or (x % inverted_opacity_0_5 ~= pr:next(0, 1) and z % inverted_opacity_0_5 ~= pr:next(0, 1)) then
					minetest_swap_node({x = x, y = y, z = z}, {name = node_garbage[pr:next(1, #node_garbage)]})
				end
			end
		end
		opacity_layer = opacity_layer + 1
	end
end

local stair_replacement_list = {
	"air",
	"group:water",
	"group:lava",
	"group:buildable_to",
	"group:deco_block",
}

local stair_names = {
	"mcl_stairs:stair_stonebrickcracked",
	"mcl_stairs:stair_stonebrickmossy",
	"mcl_stairs:stair_stone_rough",
	"mcl_stairs:stair_stone_rough",
	"mcl_stairs:stair_stone_rough",
	"mcl_stairs:stair_stone_rough",
	"mcl_stairs:stair_stone_rough",
	"mcl_stairs:stair_stone_rough",
	"mcl_stairs:stair_stone_rough",
	"mcl_stairs:stair_stonebrick",
	"mcl_stairs:stair_stonebrick",
	"mcl_stairs:stair_stonebrick",
}
local stair_outer_names = {
	"mcl_stairs:stair_stonebrickcracked_outer",
	"mcl_stairs:stair_stonebrickmossy_outer",
	"mcl_stairs:stair_stone_rough_outer",
	"mcl_stairs:stair_stonebrick_outer",
}

local stair_content = {
	{name = "mcl_core:lava_source"},
	{name = "mcl_core:stone"},
	{name = "mcl_core:stone"},
	{name = "mcl_core:stone"},
	{name = "mcl_core:stone"},
	{name = "mcl_core:stone"},
	{name = "mcl_core:stonebrick"},
	{name = "mcl_nether:magma"},
	{name = "mcl_nether:netherrack"},
	{name = "mcl_nether:netherrack"},
}

local stair_content_bottom = {
	{name = "mcl_nether:magma"},
	{name = "mcl_nether:magma"},
	{name = "mcl_nether:netherrack"},
	{name = "mcl_nether:netherrack"},
	{name = "mcl_nether:netherrack"},
	{name = "mcl_nether:netherrack"},
}

local slabs = {
	{name = "mcl_stairs:slab_stone"},
	{name = "mcl_stairs:slab_stone"},
	{name = "mcl_stairs:slab_stone"},
	{name = "mcl_stairs:slab_stone"},
	{name = "mcl_stairs:slab_stone"},
	{name = "mcl_stairs:slab_stonebrick"},
	{name = "mcl_stairs:slab_stonebrick"},
	{name = "mcl_stairs:slab_stonebrickcracked"},
	{name = "mcl_stairs:slab_stonebrickmossy"},
}

local stones = {
	{name = "mcl_core:stone"},
	{name = "mcl_core:stone"},
	{name = "mcl_core:stone"},
	{name = "mcl_core:cobble"},
	{name = "mcl_core:mossycobble"},
}

local stair_selector = {
	[-1] = {
		[-1] = {
			names = stair_outer_names,
			param2 = 1,
		},
		[0] = {
			names = stair_names,
			param2 = 1,
		},
		[1] = {
			names = stair_outer_names,
			param2 = 2,
		},
	},
	[0] = {
		[-1] = {
			names = stair_names,
			param2 = 0,
		},
		[0] = {
			names = stair_content,
		},
		[1] = {
			names = stair_names,
			param2 = 2,
		},
	},
	[1] = {
		[-1] = {
			names = stair_outer_names,
			param2 = 0,
		},
		[0] = {
			names = stair_names,
			param2 = 3,
		},
		[1] = {
			names = stair_outer_names,
			param2 = 3,
		},
	},
}

local stair_offset_from_bottom = 2

local function draw_stairs(pos, width, height, lift, orientation, pr, is_chain, param2)

	local current_stair_content = stair_content
	local current_stones = stones

	local function set_ruined_node(pos, node)
		if pr:next(1, 7) < 3 then return end
		minetest_swap_node(pos, node)
		return true
	end

	local param2 = param2
	local mirror = param2 == 1 or param2 == 2
	if mirror then
		param2 = (param2 + 2) % 4
	end

	local chain_offset = is_chain and 1 or 0

	local lift = lift + stair_offset_from_bottom
	local slide_x = (1 - orientation)
	local slide_z = orientation
	local width = width + 2
	local x1 = pos.x - (chain_offset + 1    ) * slide_x - 1
	local x2 = pos.x + (chain_offset + width) * slide_x + 1
	local z1 = pos.z - (chain_offset + 1    ) * slide_z - 1
	local z2 = pos.z + (chain_offset + width) * slide_z + 1
	local y1 = pos.y - stair_offset_from_bottom
	local y2 = pos.y + lift - stair_offset_from_bottom
	local stair_layer = true
	local y = y2
	local place_slabs = true
	local x_key, z_key
	local need_to_place_chest = true
	local chest_pos
	local bad_nodes_ratio = 0
	while (y >= y1) or (bad_nodes_ratio > 0.07) do
		local good_nodes_counter = 0
		for x = x1, x2 do
			x_key = (x == x1) and -1 or (x == x2) and 1 or 0
			for z = z1, z2 do
				local pos = {x = x, y = y, z = z}
				if #minetest_find_nodes_in_area(pos, pos, stair_replacement_list, false) > 0 then
					z_key = (z == z1) and -1 or (z == z2) and 1 or 0
					local stair_coverage = (x_key ~= 0) or (z_key ~= 0)
					if stair_coverage then
						if stair_layer then
							local stair = stair_selector[x_key][z_key]
							local names = stair.names
							set_ruined_node(pos, {name = names[pr:next(1, #names)], param2 = stair.param2})
						elseif place_slabs then
							set_ruined_node(pos, slabs[pr:next(1, #slabs)])
						else
							local placed = set_ruined_node(pos, current_stones[pr:next(1, #current_stones)])
							if need_to_place_chest and placed then
								chest_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
								minetest_swap_node(chest_pos, {name = "mcl_chests:chest_small"})
								need_to_place_chest = false
							end
						end
					elseif not stair_layer then
						set_ruined_node(pos, current_stair_content[pr:next(1, #current_stair_content)])
					end
				else
					good_nodes_counter = good_nodes_counter + 1
				end
			end
		end
		bad_nodes_ratio = 1 - good_nodes_counter / ((x2 - x1 + 1) * (z2 - z1 + 1))
		if y >= y1 then
			x1 = x1 - 1
			x2 = x2 + 1
			z1 = z1 - 1
			z2 = z2 + 1
			if (stair_layer or place_slabs) then
				y = y - 1
				if y <= y1 then
					current_stair_content = stair_content_bottom
					current_stones = stair_content_bottom
				end
			end
			place_slabs = not place_slabs
			stair_layer = false
		else
			place_slabs = false
			y = y - 1
			local dx1 = pr:next(0, 10)
			if dx1 < 3 then x1 = x1 + dx1 end
			local dx2 = pr:next(0, 10)
			if dx2 < 3 then x2 = x2 - dx1 end
			if x1 >= x2 then return chest_pos end
			local dz1 = pr:next(0, 10)
			if dz1 < 3 then z1 = z1 + dz1 end
			local dz2 = pr:next(0, 10)
			if dz2 < 3 then z2 = z2 - dz1 end
			if z1 >= z2 then return chest_pos end
		end
	end
	return chest_pos
end

local function enchant(stack, pr)
	-- 75%-100% damage
	mcl_enchanting.enchant_randomly(stack, 30, true, false, false, pr)
end

local function enchant_armor(stack, pr)
	-- itemstack, enchantment_level, treasure, no_reduced_bonus_chance, ignore_already_enchanted, pr)
	mcl_enchanting.enchant_randomly(stack, 30, false, false, false, pr)
end

local function place(pos, rotation, pr)
	local width = pr:next(2, 10)
	local height = pr:next(((width < 3) and 3 or 2), 10)
	local lift = pr:next(0, 4)
	local rotation = rotation or possible_rotations[pr:next(1, #possible_rotations)]
	local orientation = rotation_to_orientation[rotation]
	assert(orientation)
	local param2 = rotation_to_param2[rotation]
	assert(param2)
	local is_chain = pr:next(1, 3) > 1
	draw_trash(pos, width, height, lift, orientation, pr)
	local chest_pos = draw_stairs(pos, width, height, lift, orientation, pr, is_chain, param2)
	draw_frame({x = pos.x, y = pos.y + lift, z = pos.z}, width + 2, height + 2, orientation, pr, is_chain, rotation)
	if not chest_pos then return end

	local lootitems = mcl_loot.get_loot(
		{
			stacks_min = 4,
			stacks_max = 8,
			items = {
				{itemstring = "mcl_core:iron_nugget",                            weight = 40, amount_min = 9, amount_max = 18},
				{itemstring = "mcl_core:flint",                                  weight = 40, amount_min = 9, amount_max = 18},
				{itemstring = "mcl_core:obsidian",                               weight = 40, amount_min = 1, amount_max =  2},
				{itemstring = "mcl_fire:fire_charge",                            weight = 40, amount_min = 1, amount_max =  1},
				{itemstring = "mcl_fire:flint_and_steel",                        weight = 40, amount_min = 1, amount_max =  1},
				{itemstring = "mcl_core:gold_nugget",                            weight = 15, amount_min = 4, amount_max = 24},
				{itemstring = "mcl_core:apple_gold",                             weight = 15},
				{itemstring = "mcl_tools:axe_gold",                              weight = 15, func = enchant},
				{itemstring = "mcl_farming:hoe_gold",                            weight = 15, func = enchant},
				{itemstring = "mcl_tools:pick_gold",                             weight = 15, func = enchant},
				{itemstring = "mcl_tools:shovel_gold",                           weight = 15, func = enchant},
				{itemstring = "mcl_tools:sword_gold",                            weight = 15, func = enchant},
				{itemstring = "mcl_armor:helmet_gold",                           weight = 15, func = enchant_armor},
				{itemstring = "mcl_armor:chestplate_gold",                       weight = 15, func = enchant_armor},
				{itemstring = "mcl_armor:leggings_gold",                         weight = 15, func = enchant_armor},
				{itemstring = "mcl_armor:boots_gold",                            weight = 15, func = enchant_armor},
				{itemstring = "mcl_potions:speckled_melon",                      weight =  5, amount_min = 4, amount_max = 12},
				{itemstring = "mcl_farming:carrot_item_gold",                    weight =  5, amount_min = 4, amount_max = 12},
				{itemstring = "mcl_core:gold_ingot",                             weight =  5, amount_min = 2, amount_max =  8},
				{itemstring = "mcl_clock:clock",                                 weight =  5},
				{itemstring = "mesecons_pressureplates:pressure_plate_gold_off", weight =  5},
				{itemstring = "mobs_mc:gold_horse_armor",                        weight =  5},
				{itemstring = "mcl_core:goldblock",                              weight =  1, amount_min = 1, amount_max =  2},
				{itemstring = "mcl_bells:bell",                                  weight =  1},
				{itemstring = "mcl_core:apple_gold_enchanted",                   weight =  1},
			}
		},
		pr
	)
	mcl_structures.init_node_construct(chest_pos)
	local meta = minetest.get_meta(chest_pos)
	local inv = meta:get_inventory()
	mcl_loot.fill_inventory(inv, "main", lootitems, pr)
end

local function get_place_rank(pos)
	local x, y, z = pos.x, pos.y, pos.z
	local p1 = {x = x    , y = y, z = z    }
	local p2 = {x = x + 7, y = y, z = z + 7}
	local air_pos_list_surface = #minetest_find_nodes_in_area(p1, p2, "air", false)
	p1.y = p1.y - 1
	p2.y = p2.y - 1
	local opaque_pos_list_surface = #minetest_find_nodes_in_area(p1, p2, "group:opaque", false)
	return air_pos_list_surface + 3 * opaque_pos_list_surface
end

mcl_structures.register_structure({
	name = "ruined_portal",
	decoration = {
		deco_type = "simple",
		flags = "all_floors",
		fill_ratio = scanning_ratio,
		height = 1,
		place_on = {"mcl_core:sand", "mcl_core:dirt_with_grass", "mcl_core:water_source", "mcl_core:dirt_with_grass_snow"},
	},
	on_finished_chunk = function(minp, maxp, seed, vm_context, pos_list)
		if maxp.y < mcl_mapgen.overworld.min then return end
		local pr = PseudoRandom(seed + random_offset)
		local random_number = pr:next(1, chance_per_chunk)
		local noise = mcl_structures_get_perlin_noise_level(minp) * noise_multiplier
		if (random_number + noise) < struct_threshold then return end
		local pos = pos_list[1]
		if #pos_list > 1 then
			local count = get_place_rank(pos)
			for i = 2, #pos_list do
				local pos_i = pos_list[i]
				local count_i = get_place_rank(pos_i)
				if count_i > count then
					count = count_i
					pos = pos_i
				end
			end
		end
		place(pos, nil, pr)
	end,
	place_function = place,
})

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local chance_per_chunk = 400
local noise_multiplier = 2.5
local random_offset    = 9159
local scanning_ratio   = 0.01
local struct_threshold = 390

local mcl_structures_get_perlin_noise_level = mcl_structures.get_perlin_noise_level

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
		minetest.set_node(pos, node)
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
		minetest.swap_node(pos, get_random_stone_material())
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
	local obsidian_nodes = pr:next(math.round(frame_nodes * 0.5), math.round(frame_nodes * 0.73))
	local crying_obsidian_nodes = pr:next(math.round(obsidian_nodes * 0.09), math.round(obsidian_nodes * 0.5))
	local air_nodes = frame_nodes - obsidian_nodes

	local function set_frame_node(pos)
		-- local node_choice = pr:next(1, air_nodes + obsidian_nodes)
		local node_choice = math.round(mcl_structures_get_perlin_noise_level(pos) * (air_nodes + obsidian_nodes))
		if node_choice > obsidian_nodes and air_nodes > 0 then
			air_nodes = air_nodes - 1
			return
		end
		obsidian_nodes = obsidian_nodes - 1
		if node_choice >= crying_obsidian_nodes then
			minetest.swap_node(pos, {name = "mcl_core:obsidian"})
			return 1
		end
		minetest.swap_node(pos, {name = "mcl_core:crying_obsidian"})
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
					minetest.swap_node(pos2, {name = "xpanes:bar_flat", param2 = orientation})
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
			minetest.swap_node(pos, {name = "mcl_core:stonebrickcarved"})
		elseif is_chain then
			if not is_top and not is_obsidian then
				minetest.swap_node(pos, {name = "xpanes:bar"})
			else
				minetest.swap_node(pos, {name = "xpanes:bar_flat", param2 = orientation})
			end
		else
			if pr:next(1, 5) == 3 then
				minetest.swap_node(pos, {name = "mcl_core:stonebrickcracked"})
			else
				minetest.swap_node(pos, {name = "mcl_core:stonebrick"})
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
		local begin_or_end = y == y1 or y == lasy_y
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
		local is_obsitian_top = set_frame_node({x = x, y = last_y, z = z})
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
		local inverted_opacity_0_5 = math.round(math.abs(opacity_layer) / opacity_layers * 5)
		for x = x1 + pr:next(0, 2), x2 - pr:next(0, 2) do
			for z = z1 + pr:next(0, 2), z2 - pr:next(0, 2) do
				if inverted_opacity_0_5 == 0 or (x % inverted_opacity_0_5 ~= pr:next(0, 1) and z % inverted_opacity_0_5 ~= pr:next(0, 1)) then
					minetest.swap_node({x = x, y = y, z = z}, {name = node_garbage[pr:next(1, #node_garbage)]})
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

local stair_offset_from_bottom = 3
local function draw_stairs(pos, width, height, lift, orientation, pr, is_chain)
	local lift = lift + stair_offset_from_bottom
	local slide_x = (1 - orientation)
	local slide_z = orientation
	local width = width + (is_chain and 2 or 0)
	local x1 = pos.x - lift - (is_chain and 1 or 0) - 1
	local x2 = pos.x + lift + width * slide_x + 1
	local z1 = pos.z - lift - (is_chain and 1 or 0) - 1
	local z2 = pos.z + lift + width * slide_z + 1
	local y1 = pos.y - stair_offset_from_bottom
	local y2 = pos.y + lift - stair_offset_from_bottom
	local current_radius = lift
	for y = y1, y2 do
		for x = x1, x2 do
			for z = z1, z2 do
--local stair1 = "mcl_stairs:stair_stonebrickcracked"
--local stair2 = "mcl_stairs:stair_stonebrickmossy"
--local stair3 = "mcl_stairs:stair_stone_rough"
--local stair4 = "mcl_stairs:stair_stonebrick"
				local pos = {x = x, y = y, z = z}
				if #minetest.find_nodes_in_area(pos, pos, stair_replacement_list, false) > 0 then
					minetest.swap_node(pos, {name = "mcl_stairs:stair_stone_rough"})
				end
			end
		end
		x1 = x1 + 1
		x2 = x2 - 1
		z1 = z1 + 1
		z2 = z2 - 1
	end
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
	draw_stairs(pos, width, height, lift, orientation, pr, is_chain)
	draw_frame({x = pos.x, y = pos.y + lift, z = pos.z}, width + 2, height + 2, orientation, pr, is_chain, rotation)
end

local function get_place_rank(pos)
	local x, y, z = pos.x, pos.y, pos.z
	local p1 = {x = x    , y = y, z = z    }
	local p2 = {x = x + 7, y = y, z = z + 7}
	local air_pos_list_surface = #minetest.find_nodes_in_area(p1, p2, "air", false)
	p1.y = p1.y - 1
	p2.y = p2.y - 1
	local opaque_pos_list_surface = #minetest.find_nodes_in_area(p1, p2, "group:opaque", false)
	return air_pos_list_surface + 3 * opaque_pos_list_surface
end

mcl_structures.register_structure({
	name = "ruined_portal",
	decoration = {
		deco_type = "simple",
		flags = "all_floors",
		fill_ratio = scanning_ratio,
		height = 1,
		place_on = {"mcl_core:sand", "mcl_core:dirt_with_grass", "mcl_core:water_source"},
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

-- Liquids: Water and lava

local S = minetest.get_translator(minetest.get_current_modname())

local vector = vector
local math = math

--local WATER_ALPHA = 179
local WATER_VISC = 1
local LAVA_VISC = 7
local LIGHT_LAVA = minetest.LIGHT_MAX
local USE_TEXTURE_ALPHA = true
local BUBBLE_COLUMN_SPEED = 1
local BUBBLE_ABM_INTERVAL = 2
local BUBBLE_AMOUNT = math.floor(BUBBLE_ABM_INTERVAL / math.abs(BUBBLE_COLUMN_SPEED) + 0.5)

if minetest.features.use_texture_alpha_string_modes then
	USE_TEXTURE_ALPHA = "blend"
end

function mcl_core.register_liquid(def)
	local base_name             = def.base_name
	local description_flowing   = def.description_flowing
	local description_source    = def.description_source
	local _doc_items_entry_name = def._doc_items_entry_name
	local _doc_items_longdesc   = def._doc_items_longdesc
	local wield_image           = def.wield_image
	local tiles_flowing         = def.tiles_flowing
	local tiles_source          = def.tiles_source
	local special_tiles_flowing = def.special_tiles_flowing
	local special_tiles_source  = def.special_tiles_source
	local sounds                = def.sounds
	local use_texture_alpha     = def.use_texture_alpha
	local drowning              = def.drowning
	local liquid_viscosity      = def.liquid_viscosity
	local liquid_range          = def.liquid_range
	local post_effect_color     = def.post_effect_color
	local groups                = def.groups

	local source_node_name = string.format("mcl_core:%s_source", base_name)
	local flowing_node_name = string.format("mcl_core:%s_flowing", base_name)
	local mandatory_liquid_groups = {liquid=3, not_in_creative_inventory=1, dig_by_piston=1}
	for group_id, group_level in pairs(mandatory_liquid_groups) do
		if not groups[group_id] then
			groups[group_id] = group_level
		elseif groups[group_id] == false then
			groups[group_id] = nil
		end
	end
	minetest.register_node(flowing_node_name, {
		description                = description_flowing,
		_doc_items_create_entry    = false,
		wield_image                = wield_image,
		drawtype                   = "flowingliquid",
		tiles                      = tiles_flowing,
		special_tiles              = special_tiles_flowing,
		sounds                     = sounds,
		is_ground_content          = false,
		use_texture_alpha          = use_texture_alpha,
		paramtype                  = "light",
		paramtype2                 = "flowingliquid",
		walkable                   = false,
		pointable                  = false,
		diggable                   = false,
		buildable_to               = true,
		drop                       = "",
		drowning                   = drowning,
		liquidtype                 = "flowing",
		liquid_alternative_flowing = flowing_node_name,
		liquid_alternative_source  = source_node_name,
		liquid_viscosity           = liquid_viscosity,
		liquid_range               = liquid_range,
		post_effect_color          = post_effect_color,
		groups                     = groups,
		_mcl_blast_resistance      = 100,
		-- Hardness intentionally set to infinite instead of 100 (Minecraft value) to avoid problems in creative mode
		_mcl_hardness              = -1,
	})

	minetest.register_node(source_node_name, {
		description                = description_source,
		_doc_items_entry_name      = _doc_items_entry_name,
		_doc_items_longdesc        = _doc_items_longdesc,
		_doc_items_hidden          = false,
		drawtype                   = "liquid",
		tiles                      = tiles_source,
		special_tiles              = special_tiles_source,
		sounds                     = sounds,
		is_ground_content          = false,
		use_texture_alpha          = use_texture_alpha,
		paramtype                  = "light",
		paramtype2                 = "flowingliquid",
		walkable                   = false,
		pointable                  = false,
		diggable                   = false,
		buildable_to               = true,
		drop                       = "",
		drowning                   = drowning,
		liquidtype                 = "source",
		liquid_alternative_flowing = flowing_node_name,
		liquid_alternative_source  = source_node_name,
		liquid_viscosity           = liquid_viscosity,
		liquid_range               = liquid_range,
		post_effect_color          = post_effect_color,
		stack_max                  = 64,
		groups                     = groups,
		_mcl_blast_resistance      = 100,
		-- Hardness intentionally set to infinite instead of 100 (Minecraft value) to avoid problems in creative mode
		_mcl_hardness              = -1,
	})
end

mcl_core.register_liquid({
	base_name             = "water",
	description_flowing   = S("Flowing Water"),
	description_source    = S("Water Source"),
	_doc_items_entry_name = S("Water"),
	_doc_items_longdesc   =
		S("Water is abundant in oceans and also appears in a few springs in the ground. You can swim easily in water, but you need to catch your breath from time to time.").."\n\n"..
		S("Water interacts with lava in various ways:").."\n"..
		S("• When water is directly above or horizontally next to a lava source, the lava turns into obsidian.").."\n"..
		S("• When flowing water touches flowing lava either from above or horizontally, the lava turns into cobblestone.").."\n"..
		S("• When water is directly below lava, the water turns into stone."),
	wield_image           = "default_water_flowing_animated.png^[verticalframe:64:0",
	tiles_flowing         = {"default_water_flowing_animated.png^[verticalframe:64:0"},
	tiles_source          = {{name="default_water_source_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0}}},
	special_tiles_flowing = {
		{
			image="default_water_flowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=4.0}
		},
		{
			image="default_water_flowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=4.0}
		},
	},
	special_tiles_source  = {
		-- New-style water source material (mostly unused)
		{
			name="default_water_source_animated.png",
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0},
			backface_culling = false,
		}
	},
	sounds                = mcl_sounds.node_sound_water_defaults(),
	use_texture_alpha     = USE_TEXTURE_ALPHA,
	drowning              = 4,
	liquid_viscosity      = WATER_VISC,
	liquid_range          = 7,
	post_effect_color     = {a=209, r=0x03, g=0x3C, b=0x5C},
	groups                = {water=3, puts_out_fire=1, freezes=1, melt_around=1},
})

mcl_core.register_liquid({
	base_name             = "whirlpool",
	description_flowing   = S("Flowing Water"),
	description_source    = S("Whirlpool"),
	_doc_items_entry_name = S("Water"),
	_doc_items_longdesc   =
		S("A whirlpool, or downward bubble column, is originating from magma at the bottom of underwater canyons.").."\n"..
		S("They drag entities downward."),
	wield_image           = "default_water_flowing_animated.png^[verticalframe:64:0",
	tiles_flowing         = {"default_water_flowing_animated.png^[verticalframe:64:0"},
	tiles_source          = {{name="default_water_source_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0}}},
	special_tiles_flowing = {
		{
			image="default_water_flowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=4.0}
		},
		{
			image="default_water_flowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=4.0}
		},
	},
	special_tiles_source  = {
		{
			name="default_water_source_animated.png",
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0},
			backface_culling = false,
		}
	},
	sounds                = mcl_sounds.node_sound_water_defaults(),
	use_texture_alpha     = USE_TEXTURE_ALPHA,
	drowning              = 0,
	liquid_viscosity      = WATER_VISC,
	liquid_range          = 7,
	post_effect_color     = {a=209, r=0x03, g=0x3C, b=0x5C},
	groups                = {puts_out_fire=1, freezes=1, melt_around=1},
})

mcl_core.register_liquid({
	base_name             = "bubble_column",
	description_flowing   = S("Flowing Water"),
	description_source    = S("Bubble Column"),
	_doc_items_entry_name = S("Water"),
	_doc_items_longdesc   =
		S("A bubble column is generated above soul sand.").."\n"..
		S("It accelerates entities upward."),
	wield_image           = "default_water_flowing_animated.png^[verticalframe:64:0",
	tiles_flowing         = {"default_water_flowing_animated.png^[verticalframe:64:0"},
	tiles_source          = {{name="default_water_source_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0}}},
	special_tiles_flowing = {
		{
			image="default_water_flowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=4.0}
		},
		{
			image="default_water_flowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=4.0}
		},
	},
	special_tiles_source  = {
		{
			name="default_water_source_animated.png",
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0},
			backface_culling = false,
		}
	},
	sounds                = mcl_sounds.node_sound_water_defaults(),
	use_texture_alpha     = USE_TEXTURE_ALPHA,
	drowning              = 0,
	liquid_viscosity      = WATER_VISC,
	liquid_range          = 7,
	post_effect_color     = {a=209, r=0x03, g=0x3C, b=0x5C},
	groups                = {puts_out_fire=1, freezes=1, melt_around=1},
})


minetest.register_node("mcl_core:lava_flowing", {
	description = S("Flowing Lava"),
	_doc_items_create_entry = false,
	wield_image = "default_lava_flowing_animated.png^[verticalframe:64:0",
	drawtype = "flowingliquid",
	tiles = {"default_lava_flowing_animated.png^[verticalframe:64:0"},
	special_tiles = {
		{
			image="default_lava_flowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=6.6}
		},
		{
			image="default_lava_flowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=6.6}
		},
	},
	paramtype = "light",
	paramtype2 = "flowingliquid",
	light_source = LIGHT_LAVA,
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_lava_defaults(),
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	--[[ Drowning in Minecraft deals 2 damage per second.
	In Minetest, drowning damage is dealt every 2 seconds so this
	translates to 4 drowning damage ]]
	drowning = 4,
	liquidtype = "flowing",
	liquid_alternative_flowing = "mcl_core:lava_flowing",
	liquid_alternative_source = "mcl_core:lava_source",
	liquid_viscosity = LAVA_VISC,
	liquid_renewable = false,
	liquid_range = 3,
	damage_per_second = 4*2,
	post_effect_color = {a=245, r=208, g=73, b=10},
	groups = { lava=3, liquid=2, destroys_items=1, not_in_creative_inventory=1, dig_by_piston=1, set_on_fire=15},
	_mcl_blast_resistance = 100,
	-- Hardness intentionally set to infinite instead of 100 (Minecraft value) to avoid problems in creative mode
	_mcl_hardness = -1,
})

local fire_text
local fire_enabled = minetest.settings:get_bool("enable_fire", true)
if fire_enabled then
	fire_text = S("A lava source sets fire to a couple of air blocks above when they're next to a flammable block.")
else
	fire_text = ""
end

minetest.register_node("mcl_core:lava_source", {
	description = S("Lava Source"),
	_doc_items_entry_name = "Lava",
	_doc_items_longdesc =
S("Lava is hot and rather dangerous. Don't touch it, it will hurt you a lot and it is hard to get out.").."\n"..
fire_text.."\n\n"..
S("Lava interacts with water various ways:").."\n"..
S("• When a lava source is directly below or horizontally next to water, the lava turns into obsidian.").."\n"..
S("• When flowing water touches flowing lava either from above or horizontally, the lava turns into cobblestone.").."\n"..
S("• When lava is directly above water, the water turns into stone."),
	drawtype = "liquid",
	tiles = {
		{name="default_lava_source_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0}}
	},
	special_tiles = {
		-- New-style lava source material (mostly unused)
		{
			name="default_lava_source_animated.png",
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0},
			backface_culling = false,
		}
	},
	paramtype = "light",
	light_source = LIGHT_LAVA,
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_lava_defaults(),
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 4,
	liquidtype = "source",
	liquid_alternative_flowing = "mcl_core:lava_flowing",
	liquid_alternative_source = "mcl_core:lava_source",
	liquid_viscosity = LAVA_VISC,
	liquid_renewable = false,
	liquid_range = 3,
	damage_per_second = 4*2,
	post_effect_color = {a=245, r=208, g=73, b=10},
	stack_max = 64,
	groups = { lava=3, lava_source=1, liquid=2, destroys_items=1, not_in_creative_inventory=1, dig_by_piston=1, set_on_fire=15, fire_damage=1},
	_mcl_blast_resistance = 100,
	-- Hardness intentionally set to infinite instead of 100 (Minecraft value) to avoid problems in creative mode
	_mcl_hardness = -1,
})

local function emit_lava_particle(pos)
	local node = minetest.get_node(pos)
	if minetest.get_item_group(node.name, "lava_source") == 0 then
		return
	end
	local ppos = vector.add(pos, { x = math.random(-7, 7)/16, y = 0.45, z = math.random(-7, 7)/16})
	--local spos = vector.add(ppos, { x = 0, y = -0.2, z = 0 })
	local vel = { x = math.random(-3, 3)/10, y = math.random(4, 7), z = math.random(-3, 3)/10 }
	local acc = { x = 0, y = -9.81, z = 0 }
	-- Lava droplet
	minetest.add_particle({
		pos = ppos,
		velocity = vel,
		acceleration = acc,
		expirationtime = 2.5,
		collisiondetection = true,
		collision_removal = true,
		size = math.random(20, 30)/10,
		texture = "mcl_particles_lava.png",
		glow = LIGHT_LAVA,
	})
end

if minetest.settings:get("mcl_node_particles") == "full" then
	minetest.register_abm({
		label = "Lava particles",
		nodenames = {"group:lava_source"},
		interval = 8.0,
		chance = 20,
		action = function(pos, node)
			local apos = {x=pos.x, y=pos.y+1, z=pos.z}
			local anode = minetest.get_node(apos)
			-- Only emit partiles when directly below lava
			if anode.name ~= "air" then
				return
			end

			minetest.after(math.random(0, 800)*0.01, emit_lava_particle, pos)
		end,
	})
end

--if minetest.settings:get("mcl_node_particles") ~= "none" then
	local nether_node_to_check = {
		["mcl_core:whirlpool_source"] = "mcl_nether:magma",
		["mcl_core:bubble_column_source"] = "mcl_nether:soul_sand",
	}
	local nether_node_offset_y = {
		["mcl_core:whirlpool_source"] = 0.5,
		["mcl_core:bubble_column_source"] = -0.5,
	}
	local nether_node_speed_y = {
		["mcl_core:whirlpool_source"] = -BUBBLE_COLUMN_SPEED,
		["mcl_core:bubble_column_source"] = BUBBLE_COLUMN_SPEED,
	}
	minetest.register_abm({
		label = "Process bubble columns and whirlpools",
		nodenames = {"mcl_core:whirlpool_source", "mcl_core:bubble_column_source"},
		interval = BUBBLE_ABM_INTERVAL,
		chance = 1,
		catch_up = false,
		action = function(pos, node)
			local x, y, z, name = pos.x, pos.y, pos.z, node.name
			local check = nether_node_to_check[name]
			local below = minetest.get_node({x = x, y = y - 1, z = z}).name
			if below ~= name and below ~= check then
				minetest.swap_node(pos, {name = "mcl_core:water_source"})
				return
			end
			local upper_pos = {x = x, y = y + 1, z = z}
			local upper = minetest.get_node(upper_pos).name
			if upper == "mcl_core:water_source" then
				minetest.swap_node(upper_pos, {name = name})
			end
			local offset_y, speed_y = nether_node_offset_y[name], nether_node_speed_y[name]
			for _, obj in pairs(minetest.get_objects_inside_radius(pos, 12)) do
				if obj:is_player() then
					minetest.add_particlespawner({
						amount = BUBBLE_AMOUNT,
						minpos = {x = x - 0.2, y = y + offset_y, z = z - 0.2},
						maxpos = {x = x + 0.2, y = y + offset_y, z = z + 0.2},
						minvel = {x =  0  , y = speed_y, z =  0  },
						maxvel = {x =  0  , y = speed_y, z =  0  },
						minexptime = 0.95 / BUBBLE_COLUMN_SPEED,
						maxexptime = 1.05 / BUBBLE_COLUMN_SPEED,
						minsize = 0.6,
						maxsize = 1.9,
						collisiondetection = false,
						texture = "mcl_core_bubble.png",
						playername = obj:get_player_name(),
					})
				end
			end
		end,
	})
--end

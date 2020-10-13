local S = minetest.get_translator("mcl_observers")

mcl_observers = {}

local rules_flat = {
	{ x = 0, y = 0, z = -1, spread = true },
}
local get_rules_flat = function(node)
	local rules = rules_flat
	for i=1, node.param2 do
		rules = mesecon.rotate_rules_left(rules)
	end
	return rules
end

local rules_down = {{ x = 0, y = 1, z = 0, spread = true }}
local rules_up = {{ x = 0, y = -1, z = 0, spread = true }}

function mcl_observers.observer_activate(pos)
	minetest.after(mcl_vars.redstone_tick, function(pos)
		node = minetest.get_node(pos)
		if not node then
			return
		end
		local nn = node.name
		if nn == "mcl_observers:observer_off" then
			minetest.set_node(pos, {name = "mcl_observers:observer_on", param2 = node.param2})
			mesecon.receptor_on(pos, get_rules_flat(node))
		elseif nn == "mcl_observers:observer_down_off" then
			minetest.set_node(pos, {name = "mcl_observers:observer_down_on"})
			mesecon.receptor_on(pos, rules_down)
		elseif nn == "mcl_observers:observer_up_off" then
			minetest.set_node(pos, {name = "mcl_observers:observer_up_on"})
			mesecon.receptor_on(pos, rules_up)
		end
	end, {x=pos.x, y=pos.y, z=pos.z})
end

-- Vertical orientation (CURRENTLY DISABLED)
local observer_orientate = function(pos, placer)
	-- Not placed by player
	if not placer then return end

	-- Placer pitch in degrees
	local pitch = placer:get_look_vertical() * (180 / math.pi)

	local node = minetest.get_node(pos)
	if pitch > 55 then -- player looking upwards
		-- Observer looking downwards
		minetest.set_node(pos, {name="mcl_observers:observer_down_off"})
	elseif pitch < -55 then -- player looking downwards
		-- Observer looking upwards
		minetest.set_node(pos, {name="mcl_observers:observer_up_off"})
	end
end

mesecon.register_node("mcl_observers:observer",
{
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	paramtype2 = "facedir",
	on_rotate = false,
	_mcl_blast_resistance = 3.5,
	_mcl_hardness = 3.5,
},
{
	description = S("Observer"),
	_tt_help = S("Emits redstone pulse when block in front changes"),
	_doc_items_longdesc = S("An observer is a redstone component which observes the block in front of it and sends a very short redstone pulse whenever this block changes."),
	_doc_items_usagehelp = S("Place the observer directly in front of the block you want to observe with the “face” looking at the block. The arrow points to the side of the output, which is at the opposite side of the “face”. You can place your redstone dust or any other component here."),

	groups = {pickaxey=1, material_stone=1, not_opaque=1, },
	tiles = {
		"mcl_observers_observer_top.png^[transformR180", "default_furnace_bottom.png",
		"mcl_observers_observer_side.png", "mcl_observers_observer_side.png",
		"mcl_observers_observer_front.png", "mcl_observers_observer_back.png",
	},
	mesecons = { receptor = {
		state = mesecon.state.off,
		rules = get_rules_flat,
	}},
	after_place_node = observer_orientate,
},
{
	_doc_items_create_entry = false,
	groups = {pickaxey=1, material_stone=1, not_opaque=1, not_in_creative_inventory=1 },
	tiles = {
		"mcl_observers_observer_top.png^[transformR180", "default_furnace_bottom.png",
		"mcl_observers_observer_side.png", "mcl_observers_observer_side.png",
		"mcl_observers_observer_front.png", "mcl_observers_observer_back_lit.png",
	},
	mesecons = { receptor = {
		state = mesecon.state.on,
		rules = get_rules_flat,
	}},

	-- VERY quickly disable observer after construction
	on_construct = function(pos)
		local timer = minetest.get_node_timer(pos)
		timer:start(mcl_vars.redstone_tick)
	end,
	on_timer = function(pos, elapsed)
		local node = minetest.get_node(pos)
		minetest.set_node(pos, {name = "mcl_observers:observer_off", param2 = node.param2})
		mesecon.receptor_off(pos, get_rules_flat(node))
	end,
}
)

mesecon.register_node("mcl_observers:observer_down",
{
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	groups = {pickaxey=1, material_stone=1, not_opaque=1, not_in_creative_inventory=1 },
	on_rotate = false,
	_mcl_blast_resistance = 3.5,
	_mcl_hardness = 3.5,
	drop = "mcl_observers:observer_off",
},
{
	tiles = {
		"mcl_observers_observer_back.png", "mcl_observers_observer_front.png",
		"mcl_observers_observer_side.png^[transformR90", "mcl_observers_observer_side.png^[transformR90",
		"mcl_observers_observer_top.png", "mcl_observers_observer_top.png",
	},
	mesecons = { receptor = {
		state = mesecon.state.off,
		rules = rules_down,
	}},
},
{
	_doc_items_create_entry = false,
	tiles = {
		"mcl_observers_observer_back_lit.png", "mcl_observers_observer_front.png",
		"mcl_observers_observer_side.png^[transformR90", "mcl_observers_observer_side.png^[transformR90",
		"mcl_observers_observer_top.png", "mcl_observers_observer_top.png",
	},
	mesecons = { receptor = {
		state = mesecon.state.on,
		rules = rules_down,
	}},

	-- VERY quickly disable observer after construction
	on_construct = function(pos)
		local timer = minetest.get_node_timer(pos)
		timer:start(mcl_vars.redstone_tick)
	end,
	on_timer = function(pos, elapsed)
		local node = minetest.get_node(pos)
		minetest.set_node(pos, {name = "mcl_observers:observer_down_off", param2 = node.param2})
		mesecon.receptor_off(pos, rules_down)
	end,
})

mesecon.register_node("mcl_observers:observer_up",
{
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	groups = {pickaxey=1, material_stone=1, not_opaque=1, not_in_creative_inventory=1 },
	on_rotate = false,
	_mcl_blast_resistance = 3.5,
	_mcl_hardness = 3.5,
	drop = "mcl_observers:observer_off",
},
{
	tiles = {
		"mcl_observers_observer_front.png", "mcl_observers_observer_back.png",
		"mcl_observers_observer_side.png^[transformR270", "mcl_observers_observer_side.png^[transformR270",
		"mcl_observers_observer_top.png^[transformR180", "mcl_observers_observer_top.png^[transformR180",
	},
	mesecons = { receptor = {
		state = mesecon.state.off,
		rules = rules_up,
	}},
},
{
	_doc_items_create_entry = false,
	tiles = {
		"mcl_observers_observer_front.png", "mcl_observers_observer_back_lit.png",
		"mcl_observers_observer_side.png^[transformR270", "mcl_observers_observer_side.png^[transformR270",
		"mcl_observers_observer_top.png^[transformR180", "mcl_observers_observer_top.png^[transformR180",
	},
	mesecons = { receptor = {
		state = mesecon.state.on,
		rules = rules_up,
	}},

	-- VERY quickly disable observer after construction
	on_construct = function(pos)
		local timer = minetest.get_node_timer(pos)
		timer:start(mcl_vars.redstone_tick)
	end,
	on_timer = function(pos, elapsed)
		minetest.set_node(pos, {name = "mcl_observers:observer_up_off"})
		mesecon.receptor_off(pos, rules_up)
	end,
})

function mcl_observers.check_around(pos)
	local n, np, frontpos
	for _, v in ipairs(mesecon.rules.alldirs) do
		np = {x = pos.x+v.x, y = pos.y+v.y, z = pos.z+v.z}
		n = minetest.get_node(np)
		if n then
			nn = n.name
			if string.sub(nn, 1, 22) == "mcl_observers:observer" then
				-- Calculate front position and compare to position:
				if nn == "mcl_observers:observer_up_off" or nn == "mcl_observers:observer_up_on" then
					frontpos = {x=np.x, y=np.y+1, z=np.z}
				elseif nn == "mcl_observers:observer_down_off" or nn == "mcl_observers:observer_down_on" then
					frontpos = {x=np.x, y=np.y-1, z=np.z}
				else
					frontpos = vector.add(np, minetest.facedir_to_dir(n.param2))
				end
				if (pos.x == frontpos.x) and (pos.y == frontpos.y) and (pos.z == frontpos.z) then
					mcl_observers.observer_activate(np)
				end
			end
		end
	end
end

minetest.register_craft({
	output = "mcl_observers:observer_off",
	recipe = {
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
		{ "mcl_nether:quartz", "mesecons:redstone", "mesecons:redstone" },
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
	}
})
minetest.register_craft({
	output = "mcl_observers:observer_off",
	recipe = {
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
		{ "mesecons:redstone", "mesecons:redstone", "mcl_nether:quartz" },
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
	}
})

-- Dripping Water Mod
-- by kddekadenz
-- License of code, textures & sounds: CC0

local math_random = math.random

local all_dirs = {
	{x = 0, y = 0, z = 1},
	{x = 0, y = 1, z = 0},
	{x = 1, y = 0, z = 0},
	{x = 0, y = 0, z =-1},
	{x = 0, y =-1, z = 0},
	{x =-1, y = 0, z = 0},
}

local function register_drop_entity(substance, glow, sound, texture_file_name)
	minetest.register_entity("mcl_dripping:drop_" .. substance, {
		hp_max = 1,
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.01, -0.01, -0.01, 0.01, 0.01, 0.01},
		glow = glow,
		pointable = false,
		visual = "sprite",
		visual_size = {x = 0.1, y = 0.1},
		textures = {""},
		spritediv = {x = 1, y = 1},
		initial_sprite_basepos = {x = 0, y = 0},
		static_save = false,
		_dropped = false,
		on_activate = function(self)
			self.object:set_properties({
				textures = {
					"[combine:2x2:"
						.. -math_random(1, 16)
						.. ","
						.. -math_random(1, 16)
						.. "="
						.. (texture_file_name or ("default_" .. substance .. "_source_animated.png"))
				}
			})
		end,
		on_step = function(self, dtime)
			local k = math_random(1, 222)
			local ownpos = self.object:get_pos()
			if k == 1 then
				self.object:set_acceleration(vector.new(0, -5, 0))
			end
			if minetest.get_node(vector.offset(ownpos, 0, 0.5, 0)).name == "air" then
				self.object:set_acceleration(vector.new(0, -5, 0))
			end
			if minetest.get_node(vector.offset(ownpos, 0, -0.1, 0)).name ~= "air" then
				local ent = self.object:get_luaentity()
				if not ent._dropped then
					ent._dropped = true
					if sound then
						minetest.sound_play({name = "drippingwater_" .. sound .. "drip"}, {pos = ownpos, gain = 0.5, max_hear_distance = 8}, true)
					end
				end
				if k < 3 then
					self.object:remove()
				end
			end
		end,
	})
end

local function register_liquid_drop(liquid, glow, sound, nodes)
	register_drop_entity(liquid, glow, sound)
	minetest.register_abm({
		label = "Create drops",
		nodenames = nodes,
		neighbors = {"group:" .. liquid},
		interval = 2,
		chance = 22,
		action = function(pos)
			if minetest.get_item_group(minetest.get_node(vector.offset(pos, 0, 1, 0)).name, liquid) ~= 0
			and minetest.get_node(vector.offset(pos, 0, -1, 0)).name == "air" then
				local x, z = math_random(-45, 45) / 100, math_random(-45, 45) / 100
				minetest.add_entity(vector.offset(pos, x, -0.520, z), "mcl_dripping:drop_" .. liquid)
			end
		end,
	})
end

register_liquid_drop("water", 1, "", {"group:opaque", "group:leaves"})
register_liquid_drop("lava", math.max(7, minetest.registered_nodes["mcl_core:lava_source"].light_source - 3), "lava", {"group:opaque"})

register_drop_entity("crying_obsidian", 10, nil, "mcl_core_crying_obsidian.png")
minetest.register_abm({
	label = "Create crying obsidian drops",
	nodenames = {"mcl_core:crying_obsidian"},
	neighbors = {"air"},
	interval = 2,
	chance = 22,
	action = function(pos)
		local i0 = math_random(1, 6)
		for i = i0, i0 + 5 do
			local dir = all_dirs[(i % 6) + 1]
			if minetest.get_node(vector.add(pos, dir)).name == "air" then
				minetest.add_entity(vector.offset(pos, dir.x * 0.52, dir.y * 0.52, dir.z * 0.52), "mcl_dripping:drop_crying_obsidian")
				return
			end
		end
	end,
})

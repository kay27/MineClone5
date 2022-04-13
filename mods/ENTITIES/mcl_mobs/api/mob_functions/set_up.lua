local math_random = math.random

local minetest_settings = minetest.settings

-- CMI support check
local use_cmi = minetest.global_exists("cmi")

local vector_distance = vector.distance
local minetest_get_connected_players = minetest.get_connected_players
local math_random = math.random

mobs.can_despawn = function(self)
	if self.tamed or self.bred or self.nametag then return false end
	local mob_pos = self.object:get_pos()
	if not mob_pos then return true end
	local players = minetest_get_connected_players()
	if #players == 0 then return false end
	-- If no players, probably this is being called from get_staticdata() at server shutdown time
	-- Minetest is to buggy (as of 5.5) to delete entities at server shutdown time anyway
	
	local distance = 999
	for _, player in pairs(players) do
		if player and player:get_hp() > 0 then
			local player_pos = player:get_pos()
			local new_distance = vector_distance(player_pos, mob_pos)
			if new_distance < distance then
				distance = new_distance
				if distance < 33 then return false end
				if distance < 128 and math_random(1, 42) ~= 11 then return false end
			end
		end
	end
	return true
end

-- get entity staticdata
mobs.mob_staticdata = function(self)
	--despawn mechanism
	--don't despawned tamed or bred mobs
	if mobs.can_despawn(self) then
		self.object:remove()		
		return
	end

	self.remove_ok = true
	self.attack = nil
	self.following = nil

	if use_cmi then
		self.serialized_cmi_components = cmi and cmi.serialize_components(self._cmi_components)
	end

	local tmp = {}

	for _,stat in pairs(self) do

		local t = type(stat)

		if  t ~= "function"
		and t ~= "nil"
		and t ~= "userdata"
		and _ ~= "_cmi_components" then
			tmp[_] = self[_]
		end
	end

	return minetest.serialize(tmp)
end

mobs.armor_setup = function(self)
	if not self._armor_items then
		local armor = {}
		-- Source: https://minecraft.fandom.com/wiki/Zombie
		local materials = {
			{name = "leather", chance = 0.3706},
			{name = "gold", chance = 0.4873},
			{name = "chain", chance = 0.129},
			{name = "iron", chance = 0.0127},
			{name = "diamond", chance = 0.0004}
		}
		local types = {
			{name = "helmet", chance = 0.15},
			{name = "chestplate", chance = 0.75},
			{name = "leggings", chance = 0.75},
			{name = "boots", chance = 0.75}
		}
		
		local material
		if type(self._spawn_with_armor) == "string" then
			material = self._spawn_with_armor
		else
			local chance = 0
			for i, m in pairs(materials) do
				chance = chance + m.chance
				if math.random() <= chance then
					material = m.name
					break
				end
			end
		end
		
		for i, t in pairs(types) do
			if math.random() <= t.chance then
				armor[t.name] = material
			else
				break
			end
		end
		
		-- Save armor items in lua entity
		self._armor_items = {}
		for atype, material in pairs(armor) do
			local item = "mcl_armor:" .. atype .. "_" .. material
			self._armor_items[atype] = item
		end
		
		-- Setup armor drops
		for atype, material in pairs(armor) do
			local wear = math.random(1, 65535)
			local item = "mcl_armor:" .. atype .. "_" .. material .. " 1 " .. wear
			self.drops = table.copy(self.drops)
			table.insert(self.drops, {
				name = item,
				chance = 1/0.085, -- 8.5%
				min = 1,
				max = 1,
				looting = "rare",
				looting_factor = 0.01 / 3,
			})
		end
		
		-- Configure textures
		local t = ""
		local first_image = true
		for atype, material in pairs(armor) do
			if not first_image then
				t = t .. "^"
			end
			t = t .. "mcl_armor_" .. atype .. "_" .. material .. ".png"
			first_image = false
		end
		if t ~= "" then
			self.base_texture = table.copy(self.base_texture)
			self.base_texture[1] = t
		end
		
		-- Configure damage groups based on armor
		-- Source: https://minecraft.fandom.com/wiki/Armor#Armor_points
		local points = 2
		for atype, material in pairs(armor) do
			local item_name = "mcl_armor:" .. atype .. "_" .. material
			points = points + minetest.get_item_group(item_name, "mcl_armor_points")
		end
		local armor_strength = 100 - 4 * points
		local armor_groups = self.object:get_armor_groups()
		armor_groups.fleshy = armor_strength
		self.armor = armor_groups
		
		-- Helmet protects mob from sun damage
		if armor.helmet then
			self.ignited_by_sunlight = false
		end
	end
end


-- activate mob and reload settings
mobs.mob_activate = function(self, staticdata, def, dtime)

	-- remove monsters in peaceful mode
	if self.type == "monster" and minetest_settings:get_bool("only_peaceful_mobs", false) then
		mcl_burning.extinguish(self.object)
		self.object:remove()
		return
	end

	-- load entity variables
	local tmp = minetest.deserialize(staticdata)

	if tmp then
		for _,stat in pairs(tmp) do
			self[_] = stat
		end
	end

	--set up wandering
	if not self.wandering then
		self.wandering = true
	end

	--clear animation
	self.current_animation = nil

	-- select random texture, set model and size
	if not self.base_texture then

		-- compatiblity with old simple mobs textures
		if type(def.textures[1]) == "string" then
			def.textures = {def.textures}
		end

		self.base_texture = def.textures[math_random(1, #def.textures)]
		self.base_mesh = def.mesh
		self.base_size = self.visual_size
		self.base_colbox = self.collisionbox
		self.base_selbox = self.selectionbox
	end
	
	-- Setup armor on mobs
	if self._spawn_with_armor then
		mobs.armor_setup(self)
	end

	-- for current mobs that dont have this set
	if not self.base_selbox then
		self.base_selbox = self.selectionbox or self.base_colbox
	end

	-- set texture, model and size
	local textures = self.base_texture
	local mesh = self.base_mesh
	local vis_size = self.base_size
	local colbox = self.base_colbox
	local selbox = self.base_selbox

	-- specific texture if gotten
	if self.gotten == true
	and def.gotten_texture then
		textures = def.gotten_texture
	end

	-- specific mesh if gotten
	if self.gotten == true
	and def.gotten_mesh then
		mesh = def.gotten_mesh
	end

	-- set baby mobs to half size
	if self.baby == true then

		vis_size = {
			x = self.base_size.x * self.baby_size,
			y = self.base_size.y * self.baby_size,
		}

		if def.child_texture then
			textures = def.child_texture[1]
		end

		colbox = {
			self.base_colbox[1] * self.baby_size,
			self.base_colbox[2] * self.baby_size,
			self.base_colbox[3] * self.baby_size,
			self.base_colbox[4] * self.baby_size,
			self.base_colbox[5] * self.baby_size,
			self.base_colbox[6] * self.baby_size
		}
		selbox = {
			self.base_selbox[1] * self.baby_size,
			self.base_selbox[2] * self.baby_size,
			self.base_selbox[3] * self.baby_size,
			self.base_selbox[4] * self.baby_size,
			self.base_selbox[5] * self.baby_size,
			self.base_selbox[6] * self.baby_size
		}
	end

	--stop mobs from reviving
	if not self.dead and not self.health then
		self.health = math_random (self.hp_min, self.hp_max)
	end

	if not self.random_sound_timer then
		self.random_sound_timer = math_random(self.random_sound_timer_min,self.random_sound_timer_max)
	end

	if self.breath == nil then
		self.breath = self.breath_max
	end

	-- pathfinding init
	self.path = {}
	self.path.way = {} -- path to follow, table of positions
	self.path.lastpos = {x = 0, y = 0, z = 0}
	self.path.stuck = false
	self.path.following = false -- currently following path?
	self.path.stuck_timer = 0 -- if stuck for too long search for path

	-- Armor groups
	-- immortal=1 because we use custom health
	-- handling (using "health" property)
	local armor
	if type(self.armor) == "table" then
		armor = table.copy(self.armor)
		armor.immortal = 1
	else
		armor = {immortal=1, fleshy = self.armor}
	end
	self.object:set_armor_groups(armor)
	self.old_y = self.object:get_pos().y
	self.old_health = self.health
	self.sounds.distance = self.sounds.distance or 10
	self.textures = textures
	self.mesh = mesh
	self.collisionbox = colbox
	self.selectionbox = selbox
	self.visual_size = vis_size
	self.standing_in = "ignore"
	self.standing_on = "ignore"
	self.jump_sound_cooloff = 0 -- used to prevent jump sound from being played too often in short time
	self.opinion_sound_cooloff = 0 -- used to prevent sound spam of particular sound types

	self.texture_mods = {}

	self.v_start = false
	self.timer = 0
	self.blinktimer = 0
	self.blinkstatus = false


	--continue mob effect on server restart
	if self.dead or self.health <= 0 then
		self.object:set_texture_mod("^[colorize:red:120")
	else
		self.object:set_texture_mod("")
	end

	-- set anything changed above
	self.object:set_properties(self)

	--update_tag(self)
	--mobs.set_animation(self, "stand")

	-- run on_spawn function if found
	if self.on_spawn and not self.on_spawn_run then
		if self.on_spawn(self) then
			self.on_spawn_run = true --  if true, set flag to run once only
		end
	end

	-- run after_activate
	if def.after_activate then
		def.after_activate(self, staticdata, def, dtime)
	end

	if use_cmi then
		self._cmi_components = cmi.activate_components(self.serialized_cmi_components)
		cmi.notify_activate(self.object, dtime)
	end
end
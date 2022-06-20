--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator(minetest.get_current_modname())

local mob_name = "mobs_mc:rabbit"

local textures = {
        {"mobs_mc_rabbit_brown.png"},
        {"mobs_mc_rabbit_gold.png"},
        {"mobs_mc_rabbit_white.png"},
        {"mobs_mc_rabbit_white_splotched.png"},
        {"mobs_mc_rabbit_salt.png"},
        {"mobs_mc_rabbit_black.png"},
}

local sounds = {
	random = "mobs_mc_rabbit_random",
	damage = "mobs_mc_rabbit_hurt",
	death = "mobs_mc_rabbit_death",
	attack = "mobs_mc_rabbit_attack",
	eat = "mobs_mc_animal_eat_generic",
	distance = 16,
}

local biome_list = {
	"FlowerForest_beach",
	"Forest_beach",
	"StoneBeach",
	"ColdTaiga_beach_water",
	"Taiga_beach",
	"Savanna_beach",
	"Plains_beach",
	"ExtremeHills_beach",
	"ColdTaiga_beach",
	"Swampland_shore",
	"JungleM_shore",
	"Jungle_shore",
	"MesaPlateauFM_sandlevel",
	"MesaPlateauF_sandlevel",
	"MesaBryce_sandlevel",
	"Mesa_sandlevel",
	"Mesa",
	"FlowerForest",
	"Swampland",
	"Taiga",
	"ExtremeHills",
	"Jungle",
	"Savanna",
	"BirchForest",
	"MegaSpruceTaiga",
	"MegaTaiga",
	"ExtremeHills+",
	"Forest",
	"Plains",
	"Desert",
	"ColdTaiga",
	"IcePlainsSpikes",
	"SunflowerPlains",
	"IcePlains",
	"RoofedForest",
	"ExtremeHills+_snowtop",
	"MesaPlateauFM_grasstop",
	"JungleEdgeM",
	"ExtremeHillsM",
	"JungleM",
	"BirchForestM",
	"MesaPlateauF",
	"MesaPlateauFM",
	"MesaPlateauF_grasstop",
	"MesaBryce",
	"JungleEdge",
	"SavannaM",
}

local function spawn_rabbit(pos)
	local biome_data = minetest.get_biome_data(pos)
	local biome_name = biome_data and minetest.get_biome_name(biome_data.biome) or ""
	local mob = minetest.add_entity(pos, mob_name)
	if not mob then return end
	local self = mob:get_luaentity()
	local texture
	if biome_name:find("Desert") then
		texture = "mobs_mc_rabbit_gold.png"
	else
		local r = math.random(1, 100)
		if biome_name:find("Ice") or biome_name:find("snow") or biome_name:find("Cold") then
			-- 80% white fur
			if r <= 80 then
				texture = "mobs_mc_rabbit_white.png"
			-- 20% black and white fur
			else
				texture = "mobs_mc_rabbit_white_splotched.png"
			end
		else
			-- 50% brown fur
			if r <= 50 then
				texture = "mobs_mc_rabbit_brown.png"
			-- 40% salt fur
			elseif r <= 90 then
				texture = "mobs_mc_rabbit_salt.png"
			-- 10% black fur
			else
				texture = "mobs_mc_rabbit_black.png"
			end
		end
	end
	self.base_texture = {texture}
	self.object:set_properties({textures = {texture}})
end

local function do_custom_rabbit(self)
	-- Easter egg: Change texture if rabbit is named “Toast”
	if self.nametag == "Toast" and not self._has_toast_texture then
		self._original_rabbit_texture = self.base_texture
		self.base_texture = { "mobs_mc_rabbit_toast.png" }
		self.object:set_properties({ textures = self.base_texture })
		self._has_toast_texture = true
	elseif self.nametag ~= "Toast" and self._has_toast_texture then
		self.base_texture = self._original_rabbit_texture
		self.object:set_properties({ textures = self.base_texture })
		self._has_toast_texture = false
	end
end

local rabbit = {
	description = S("Rabbit"),
	type = "animal",
	spawn_class = "passive",
	passive = true,
	reach = 1,
	rotate = 270,
	hp_min = 3,
	hp_max = 3,
	xp_min = 1,
	xp_max = 3,
	collisionbox = {-0.2, -0.01, -0.2, 0.2, 0.49, 0.2},
	visual = "mesh",
	mesh = "mobs_mc_rabbit.b3d",
	textures = textures,
	visual_size = {x=1.5, y=1.5},
	sounds = sounds,
	makes_footstep_sound = false,
	walk_velocity = 1,
	run_velocity = 3.7,
	follow_velocity = 1.1,
	floats = 1,
	runaway = true,
	jump = true,
	drops = {
		{name = mobs_mc.items.rabbit_raw, chance = 1, min = 0, max = 1, looting = "common",},
		{name = mobs_mc.items.rabbit_hide, chance = 1, min = 0, max = 1, looting = "common",},
		{name = mobs_mc.items.rabbit_foot, chance = 10, min = 0, max = 1, looting = "rare", looting_factor = 0.03,},
	},
	fear_height = 4,
	animation = {
		speed_normal = 25, speed_run = 50,
		stand_start  =  0, stand_end =  0,
		walk_start   =  0, walk_end  = 20,
		run_start    =  0, run_end   = 20,
	},
	-- Follow (yellow) dangelions, carrots and golden carrots
	follow = mobs_mc.follow.rabbit,
	view_range = 8,
	-- Eat carrots and reduce their growth stage by 1
	replace_rate = 10,
	replace_what = mobs_mc.replace.rabbit,
	on_rightclick = function(self, clicker)
		-- Feed, tame protect or capture
		if mobs:feed_tame(self, clicker, 1, true, true) then return end
	end,
	do_custom = do_custom_rabbit,
	spawn = spawn_rabbit
}

mobs:register_mob(mob_name, rabbit)

-- The killer bunny (Only with spawn egg)
local killer_bunny = table.copy(rabbit)
killer_bunny.description = S("Killer Bunny")
killer_bunny.type = "monster"
killer_bunny.spawn_class = "hostile"
killer_bunny.attack_type = "dogfight"
killer_bunny.specific_attack = { "player", "mobs_mc:wolf", "mobs_mc:dog" }
killer_bunny.damage = 8
killer_bunny.passive = false
-- 8 armor points
killer_bunny.armor = 50
killer_bunny.textures = { "mobs_mc_rabbit_caerbannog.png" }
killer_bunny.view_range = 16
killer_bunny.replace_rate = nil
killer_bunny.replace_what = nil
killer_bunny.on_rightclick = nil
killer_bunny.run_velocity = 6
killer_bunny.do_custom = function(self)
	if not self._killer_bunny_nametag_set then
		self.nametag = S("The Killer Bunny")
		self._killer_bunny_nametag_set = true
	end
end

mobs:register_mob("mobs_mc:killer_bunny", killer_bunny)

-- Mob spawning rules.
-- Different skins depending on spawn location <- we customized spawn function

mobs:spawn_setup({
	name = mob_name,
	min_light = 9,
	chance = 1000,
	aoc = 8,
	biomes = biome_list,
	group_size_max = 1,
	baby_min = 1,
	baby_max = 2,
})

-- Spawn egg
mobs:register_egg("mobs_mc:rabbit", S("Rabbit"), "mobs_mc_spawn_icon_rabbit.png", 0)

-- Note: This spawn egg does not exist in Minecraft
mobs:register_egg("mobs_mc:killer_bunny", S("Killer Bunny"), "mobs_mc_spawn_icon_rabbit_caerbannog.png", 0) 

--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator(minetest.get_current_modname())

--###################
--################### SPIDER
--###################


-- Spider by AspireMint (fishyWET (CC-BY-SA 3.0 license for texture)

local spider = {
	description = S("Spider"),
	type = "monster",
	spawn_class = "hostile",
	passive = false,
	hostile = true,
	always_climb = true,
	docile_by_day = true,
	attack_type = "punch",
	punch_timer_cooloff = 0.5,
	rotate = 270,
	damage = 2,
	reach = 2,
	hp_min = 16,
	hp_max = 16,
	ignores_cobwebs = true,
	xp_min = 5,
	xp_max = 5,
	eye_height = 0.475,
	armor = {fleshy = 100, arthropod = 100},
	collisionbox = {-0.45, 0, -0.45, 0.45, 0.9, 0.45},
	visual = "mesh",
	mesh = "mobs_mc_spider.b3d",
	textures = {
		{"mobs_mc_spider.png^(mobs_mc_spider_eyes.png^[makealpha:0,0,0)"},
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = false,
	sounds = {
		random = "mobs_mc_spider_random",
		attack = "mobs_mc_spider_attack",
		damage = "mobs_mc_spider_hurt",
		death = "mobs_mc_spider_death",
		-- TODO: sounds: walk
		distance = 16,
	},
	walk_velocity = 1.3,
	run_velocity = 2.75, --spider can become extremely difficult if any higher
	jump = true,
	jump_height = 4,
	view_range = 16,
	floats = 1,
	drops = {
		{name = mobs_mc.items.string, chance = 1, min = 0, max = 2, looting = "common"},
		{name = mobs_mc.items.spider_eye, chance = 3, min = 1, max = 1, looting = "common", looting_chance_function = function(lvl)
			return 1 - 2 / (lvl + 3)
		end},
	},
	specific_attack = { "player", "mobs_mc:iron_golem" },
	fear_height = 4,
	animation = {
		stand_speed = 10,
		walk_speed = 25,
		run_speed = 50,
		stand_start = 20,
		stand_end = 40,
		walk_start = 0,
		walk_end = 20,
		run_start = 0,
		run_end = 20,
	},
}
mobs:register_mob("mobs_mc:spider", spider)



--Cave Spider

local cave_spider = {
	description = S("Cave Spider"),
	type = "monster",
	spawn_class = "hostile",
	passive = false,
	hostile = true,
	always_climb = true,
	docile_by_day = true,
	rotate = 270,

	--[[work-around for poison until punch augmentations are added to mob API
	works functionally but the jump while punching animation in gone--]]
	reach = 0.5, --makes it look like it's biting
	attack_type = "projectile",
	arrow = "spider_venom", --ultra short range projectile to inflict poison effect + punch damage
	projectile_cooldown_min = 1,
	projectile_cooldown_max = 1,
	shoot_arrow = function(self, pos, dir)
		local dmg = 2
		mobs.shoot_projectile_handling("mobs_mc:spider_venom", pos, dir, self.object:get_yaw(), self.object, 1, dmg,nil,nil,nil,-0.6)
	end,

	hp_min = 12, --reflect Minecraft health
	hp_max = 12,
	ignores_cobwebs = true,
	xp_min = 5,
	xp_max = 5,
	eye_height = 0.475,
	armor = {fleshy = 100, arthropod = 100},
	collisionbox = {-0.35, -0.01, -0.35, 0.35, 0.49, 0.35},
	visual = "mesh",
	mesh = "mobs_mc_spider.b3d",
	textures = {
		{"mobs_mc_cave_spider.png^(mobs_mc_spider_eyes.png^[makealpha:0,0,0)"},
	},
	visual_size = {x=1.66666, y=1.5},
	makes_footstep_sound = false,
	sounds = {
		random = "mobs_mc_spider_random",
		attack = "mobs_mc_spider_attack",
		damage = "mobs_mc_spider_hurt",
		death = "mobs_mc_spider_death",
		-- TODO: sounds: walk
		distance = 16,
	},
	base_pitch = 1.25,
	walk_velocity = 1.3,
	run_velocity = 3.5, --Compenstaing for the loss of aility to leap while attacking
	jump = true,
	jump_height = 4,
	view_range = 16,
	floats = 1,
	drops = {
		{name = mobs_mc.items.string, chance = 1, min = 0, max = 2, looting = "common"},
		{name = mobs_mc.items.spider_eye, chance = 3, min = 1, max = 1, looting = "common", looting_chance_function = function(lvl)
			return 1 - 2 / (lvl + 3)
		end},
	},
	specific_attack = { "player", "mobs_mc:iron_golem" },
	fear_height = 4,
	animation = {
		stand_speed = 10,
		walk_speed = 25,
		run_speed = 50,
		stand_start = 20,
		stand_end = 40,
		walk_start = 0,
		walk_end = 20,
		run_start = 0,
		run_end = 20,
	},
}
mobs:register_mob("mobs_mc:cave_spider", cave_spider)


-- spider_venom (projectile)
mobs:register_arrow("mobs_mc:spider_venom", {
	visual = "sprite",
	visual_size = {x = 0.1, y = 0.1},
	textures = {"hbhunger_icon_health_poison.png"},
	velocity = 1,
	collisionbox = {-.5, -.5, -.5, .5, .5, .5},
	tail = 0,

	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = self._damage},
		}, nil)

		mcl_potions.poison_func(player, 0.5, 8) --modified cuz MC rate is an unessesarily bad fraction
		local vel = player:get_velocity()
		player:add_velocity({x=(vel.x * -1.5), y=6, z=(vel.z * -1.5)}) --"chaos knockback" effect (Temporary until I understand how to implement knockback for a projectile)
	end,

	hit_mob = function(self, mob)
		if mob ~= self then --due to low power of attack, spider can shoot itself while chasing a target
			mob:punch(self.object, 1.0, {
				full_punch_interval = 1.0,
				damage_groups = {fleshy = self._damage},
			}, nil)

			if ((mob ~= "mobs_mc:cave_spider") and (mob ~= "mobs_mc:spider")) then --spider's don't have automatic immunity to poison yet so this is a stop gap solution
				mcl_potions.poison_func(mob, 0.5, 8) --modified cuz MC rate is an unessesarily bad fraction
			end
			local vel = mob:get_velocity()
			mob:add_velocity({x=(-1 * vel.z), y=6, z=(-1 * vel.x)}) --"chaos knockback" effect (Temporary until I understand how to implement knockback for a projectile)
		end
	end,
})

--[[ Cave spider (Previous code)
local cave_spider = table.copy(spider)
cave_spider.description = S("Cave Spider")
cave_spider.textures = { {"mobs_mc_cave_spider.png^(mobs_mc_spider_eyes.png^[makealpha:0,0,0)"} }
-- TODO: Poison damage
-- TODO: Revert damage to 2
cave_spider.damage = 3 -- damage increased to undo non-existing poison
cave_spider.hp_min = 1
cave_spider.hp_max = 12
cave_spider.collisionbox = {-0.35, -0.01, -0.35, 0.35, 0.49, 0.35}
cave_spider.visual_size = {x=1.66666, y=1.5}
cave_spider.walk_velocity = 1.3
cave_spider.run_velocity = 3.2
cave_spider.sounds = table.copy(spider.sounds)
cave_spider.sounds.base_pitch = 1.25
mobs:register_mob("mobs_mc:cave_spider", cave_spider)--]]


mobs:spawn_specific(
"mobs_mc:spider",
"overworld",
"ground",
{
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
"MushroomIsland",
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
"MushroomIslandShore",
"JungleM_shore",
"Jungle_shore",
"MesaPlateauFM_sandlevel",
"MesaPlateauF_sandlevel",
"MesaBryce_sandlevel",
"Mesa_sandlevel",
"RoofedForest_ocean",
"JungleEdgeM_ocean",
"BirchForestM_ocean",
"BirchForest_ocean",
"IcePlains_deep_ocean",
"Jungle_deep_ocean",
"Savanna_ocean",
"MesaPlateauF_ocean",
"ExtremeHillsM_deep_ocean",
"Savanna_deep_ocean",
"SunflowerPlains_ocean",
"Swampland_deep_ocean",
"Swampland_ocean",
"MegaSpruceTaiga_deep_ocean",
"ExtremeHillsM_ocean",
"JungleEdgeM_deep_ocean",
"SunflowerPlains_deep_ocean",
"BirchForest_deep_ocean",
"IcePlainsSpikes_ocean",
"Mesa_ocean",
"StoneBeach_ocean",
"Plains_deep_ocean",
"JungleEdge_deep_ocean",
"SavannaM_deep_ocean",
"Desert_deep_ocean",
"Mesa_deep_ocean",
"ColdTaiga_deep_ocean",
"Plains_ocean",
"MesaPlateauFM_ocean",
"Forest_deep_ocean",
"JungleM_deep_ocean",
"FlowerForest_deep_ocean",
"MushroomIsland_ocean",
"MegaTaiga_ocean",
"StoneBeach_deep_ocean",
"IcePlainsSpikes_deep_ocean",
"ColdTaiga_ocean",
"SavannaM_ocean",
"MesaPlateauF_deep_ocean",
"MesaBryce_deep_ocean",
"ExtremeHills+_deep_ocean",
"ExtremeHills_ocean",
"MushroomIsland_deep_ocean",
"Forest_ocean",
"MegaTaiga_deep_ocean",
"JungleEdge_ocean",
"MesaBryce_ocean",
"MegaSpruceTaiga_ocean",
"ExtremeHills+_ocean",
"Jungle_ocean",
"RoofedForest_deep_ocean",
"IcePlains_ocean",
"FlowerForest_ocean",
"ExtremeHills_deep_ocean",
"MesaPlateauFM_deep_ocean",
"Desert_ocean",
"Taiga_ocean",
"BirchForestM_deep_ocean",
"Taiga_deep_ocean",
"JungleM_ocean",
"FlowerForest_underground",
"JungleEdge_underground",
"StoneBeach_underground",
"MesaBryce_underground",
"Mesa_underground",
"RoofedForest_underground",
"Jungle_underground",
"Swampland_underground",
"MushroomIsland_underground",
"BirchForest_underground",
"Plains_underground",
"MesaPlateauF_underground",
"ExtremeHills_underground",
"MegaSpruceTaiga_underground",
"BirchForestM_underground",
"SavannaM_underground",
"MesaPlateauFM_underground",
"Desert_underground",
"Savanna_underground",
"Forest_underground",
"SunflowerPlains_underground",
"ColdTaiga_underground",
"IcePlains_underground",
"IcePlainsSpikes_underground",
"MegaTaiga_underground",
"Taiga_underground",
"ExtremeHills+_underground",
"JungleM_underground",
"ExtremeHillsM_underground",
"JungleEdgeM_underground",
},
0,
7,
30,
17000,
2,
mobs_mc.spawn_height.overworld_min,
mobs_mc.spawn_height.overworld_max)

-- spawn eggs
mobs:register_egg("mobs_mc:spider", S("Spider"), "mobs_mc_spawn_icon_spider.png", 0)
mobs:register_egg("mobs_mc:cave_spider", S("Cave Spider"), "mobs_mc_spawn_icon_cave_spider.png", 0)

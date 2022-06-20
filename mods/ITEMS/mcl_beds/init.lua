mcl_beds = {}
mcl_beds.player = {}
mcl_beds.pos = {}
mcl_beds.bed_pos = {}

local modpath = minetest.get_modpath("mcl_beds")
local S = minetest.get_translator(minetest.get_current_modname())

-- Load files

dofile(modpath .. "/functions.lua")
dofile(modpath .. "/api.lua")
dofile(modpath .. "/beds.lua")
dofile(modpath .. "/respawn_anchor.lua")
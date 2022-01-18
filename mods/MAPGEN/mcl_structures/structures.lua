local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

if not mcl_mapgen.singlenode then
	dofile(modpath .. "/desert_temple.lua")
	dofile(modpath .. "/desert_well.lua")
	dofile(modpath .. "/fossil.lua")
	dofile(modpath .. "/igloo.lua")
	dofile(modpath .. "/jungle_temple.lua")
	dofile(modpath .. "/nice_jungle_temple.lua")
	dofile(modpath .. "/noise_indicator.lua")
	dofile(modpath .. "/stronghold.lua")
	dofile(modpath .. "/witch_hut.lua")
end

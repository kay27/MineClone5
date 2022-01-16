local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

if not mcl_mapgen.singlenode then
	dofile(modpath .. "/desert_temple.lua")
	dofile(modpath .. "/stronghold.lua")

	dofile(modpath .. "/noise_indicator.lua")
end

dofile(minetest.get_modpath("mcl_mushrooms").."/small.lua")
dofile(minetest.get_modpath("mcl_mushrooms").."/huge.lua")
dofile(minetest.get_modpath("mcl_mushrooms").."/suspicious_stew.lua")

-- Aliases for old MCL2 versions
minetest.register_alias("mcl_farming:mushroom_red", "mcl_mushrooms:mushroom_red")
minetest.register_alias("mcl_farming:mushroom_brown", "mcl_mushrooms:mushroom_brown")

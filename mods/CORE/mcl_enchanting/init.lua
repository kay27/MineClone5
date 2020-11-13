local modpath = minetest.get_modpath("mcl_enchanting")

mcl_enchanting = {
	book_offset = vector.new(0, 0.75, 0),
	roman_numerals = dofile(modpath .. "/roman_numerals.lua"), 			-- https://exercism.io/tracks/lua/exercises/roman-numerals/solutions/73c2fb7521e347209312d115f872fa49
	enchantments = {},
	weighted_enchantments = {},
	accumulated_weight = 0,
	debug = false,
}

dofile(modpath .. "/engine.lua")
dofile(modpath .. "/enchantments.lua")
dofile(modpath .. "/command.lua")
dofile(modpath .. "/tt.lua")
dofile(modpath .. "/book.lua")
-- dofile(modpath .. "/ui.lua")
-- dofile(modpath .. "/fx.lua")
-- dofile(modpath .. "/book.lua")
-- dofile(modpath .. "/table.lua")

minetest.register_on_mods_loaded(mcl_enchanting.initialize)
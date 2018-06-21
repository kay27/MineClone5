function settlements.build_schematic(pos)
  -- list of schematics
  local schematic_table = {minetest.get_modpath("settlements").."/schems/hut.mts"}
  -- pick one of those schematics
  local schematic = schematic_table[math.random(1, #schematic_table)]
  -- get building node material for better integration to surrounding
  local balcony_material =  minetest.get_node_or_nil(pos).name
  -- pick random material
  local material = wallmaterial[math.random(1,#wallmaterial)]
  -- place schematic
  minetest.place_schematic(pos, schematic, "random", {["default:cobble"] = material,["default:dirt_with_grass"] = balcony_material}, true)
end
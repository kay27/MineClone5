function settlements.build_schematic(pos)
  -- list of schematics
  local schematic_table = {schem_path.."hut.mts"}
  -- pick one of those schematics
  local building = schematic_table[math.random(1, #schematic_table)]
  -- get building node material for better integration to surrounding
  local balcony_material =  minetest.get_node_or_nil(pos).name
  -- pick random material
  local material = wallmaterial[math.random(1,#wallmaterial)]
  -- schematic conversion to lua
  local schem_lua = minetest.serialize_schematic(building, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}).." return(schematic)"
  -- replace material
  schem_lua = schem_lua:gsub("default_cobble", material)
  -- format schematic string
  local schematic = loadstring(schem_lua)()
  -- convert to mts
  local schem_mts = minetest.serialize_schematic(schematic, "mts", {})
  -- write file
  local file, err = io.open(schem_path.."temp.mts", "wb")
	file:write(schem_mts)
	file:flush()
	file:close()
  -- place schematic
  minetest.place_schematic(pos, schem_path.."temp.mts", "random", nil, true)
end
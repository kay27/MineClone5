function settlements.build_schematic(pos)
  -- list of schematics
  local schematic_table = { schem_path.."hut.mts",
                            schem_path.."garden.mts",
                            schem_path.."lamp.mts",
                            schem_path.."tower.mts",
                            schem_path.."well.mts",}
  -- pick one of those schematics
  local building = schematic_table[math.random(1, #schematic_table)]
  -- get building node material for better integration to surrounding
  local balcony_material =  minetest.get_node_or_nil(pos).name
  -- pick random material
  local material = wallmaterial[math.random(1,#wallmaterial)]
  -- schematic conversion to lua
  local schem_lua = minetest.serialize_schematic(building, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}).." return(schematic)"
  -- replace material
  schem_lua = schem_lua:gsub("default:cobble", material):gsub("default:dirt_with_grass", balcony_material)
  -- format schematic string
  local schematic = loadstring(schem_lua)()
  -- build foundation for the building an make room above
  local width = schematic["size"]["x"]
  local depth = schematic["size"]["z"]
  local height = schematic["size"]["y"]
  settlements.foundation(pos, width, depth, height)
  -- place schematic
  minetest.place_schematic(pos, schematic, "random", nil, true)
end
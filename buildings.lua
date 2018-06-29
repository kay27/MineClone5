-- list of schematics
local schematic_table = { hut     = schem_path.."hut.mts",
                          garden  = schem_path.."garden.mts",
                          lamp    = schem_path.."lamp.mts",
                          tower   = schem_path.."tower.mts",
                          well    = schem_path.."well.mts"}
-- iterate over whole table to get all keys
local keyset = {}
for k in pairs(schematic_table) do
    table.insert(keyset, k)
end

function settlements.build_schematic(pos, building)
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
--
-- placing buildings in circles around center
--
function settlements.place_settlement_circle(minp, maxp)
  local half_map_chunk_size = 40
  -- find center of chunk
  local center = {x=maxp.x-half_map_chunk_size, y=maxp.y-half_map_chunk_size, z=maxp.z-half_map_chunk_size} 
  -- find center_surcafe of chunk
  local center_surface = settlements.find_surface(center)
  -- go build settlement around center
  if center_surface then
    minetest.chat_send_all("Dorf")
    -- pick one of those schematics
    local building = schematic_table["tower"]
    settlements.build_schematic(center_surface, building)
    -- now some buildings around in a circle
    local x, z, r = center_surface.x, center_surface.z, 15
    for i = 0, 360, 45 do
      local angle = i * math.pi / 180
      local ptx, ptz = x + r * math.cos( angle ), z + r * math.sin( angle )
      local pos1 = { x=ptx, y=center_surface.y, z=ptz}
      local pos_surcafe = settlements.find_surface(pos1)
      settlements.build_schematic(pos1, schematic_table[keyset[math.random(#keyset)]])
--      minetest.set_node(pos1, {name="default:cobble"})
    end
  end
end
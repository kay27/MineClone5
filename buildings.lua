-- list of schematics
local schematic_table = { 
  hut     = {name = "hut", mts = schem_path.."hut.mts", hsize = 10, chance = 70},
  garden  = {name = "garden", mts = schem_path.."garden.mts", hsize = 10, chance = 10},
  lamp    = {name = "lamp", mts = schem_path.."lamp.mts", hsize = 7, chance = 10},
  tower   = {name = "tower", mts = schem_path.."tower.mts", hsize = 10, chance = 10},
  well    = {name = "well", mts = schem_path.."well.mts", hsize = 10, chance = 00}
}
-- iterate over whole table to get all keys
local keyset = {}
for k in pairs(schematic_table) do
  table.insert(keyset, k)
end

local building_all_info

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
  -- find center of chunk
  local half_map_chunk_size = 40
  local center = {x=maxp.x-half_map_chunk_size, y=maxp.y-half_map_chunk_size, z=maxp.z-half_map_chunk_size} 
  -- find center_surcafe of chunk
  local center_surface = settlements.find_surface(center)
  -- go build settlement around center
  if center_surface then
    minetest.chat_send_all("Dorf")
    -- settlement_info table reset
    for k,v in pairs(settlement_info) do
      settlement_info[k] = nil
    end
    -- randomize number of buildings
    local number_of_buildings = 15
    -- build well in the center
    building_all_info = schematic_table["well"]
    settlements.build_schematic(center_surface, building_all_info["mts"])
    -- add to settlement info table
    local index = 1
    settlement_info[index] = {pos = center_surface, name = building_all_info["name"], hsize = building_all_info["hsize"]}
    --increase index for following buildings
    index = index + 1
    -- now some buildings around in a circle
    local x, z, r = center_surface.x, center_surface.z, 5
    -- draw 5 circles around center and increase radius by 5
    for j = 1,10 do
      if number_of_buildings > 0 then 
        -- set position on imaginary circle
        for j = 0, 360, 15 do
          local angle = j * math.pi / 180
          local ptx, ptz = x + r * math.cos( angle ), z + r * math.sin( angle )
          local pos1 = { x=ptx, y=center_surface.y, z=ptz}
          --
          local pos_surface = settlements.find_surface(pos1)
          if pos_surface then
            -- pick schematic based on chance
            local random_number = math.random(1,100)
            if random_number > 20 then
              building_all_info = schematic_table["hut"]   
            else
              building_all_info = schematic_table[keyset[math.random(#keyset)]]
            end
            -- before placing, check_distance to other buildings
            local distance_to_other_buildings_ok = settlements.check_distance(pos_surface, building_all_info["hsize"])
            if distance_to_other_buildings_ok then
              settlements.build_schematic(pos_surface, building_all_info["mts"])
              number_of_buildings = number_of_buildings -1
              settlement_info[index] = {pos = pos_surface, name = building_all_info["name"], hsize = building_all_info["hsize"]}
              index = index + 1
              if number_of_buildings == 0 then
                break
              end
            end
          end
        end
      else
        break
      end
      r = r + 10
    end
  end
end
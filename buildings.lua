-- list of schematics
local schematic_table = { 
  hut     = {name = "hut", mts = schem_path.."hut.mts", hsize = 10, max_num = 0.9, rplc = "y"},
  garden  = {name = "garden", mts = schem_path.."garden.mts", hsize = 10, max_num = 0.2, rplc = "n"},
  lamp    = {name = "lamp", mts = schem_path.."lamp.mts", hsize = 7, max_num = 0.2, rplc = "n"},
  tower   = {name = "tower", mts = schem_path.."tower.mts", hsize = 10, max_num = 0.2, rplc = "n"},
  well    = {name = "well", mts = schem_path.."well.mts", hsize = 10, max_num = 0, rplc = "n"},
  church  = {name = "church", mts = schem_path.."church.mts", hsize = 13, max_num = 0.1, rplc = "n"}
}
local count_buildings ={}
-- iterate over whole table to get all keys
local keyset = {}
for k in pairs(schematic_table) do
  table.insert(keyset, k)
end
--local variables for buildings
local building_all_info
local number_of_buildings 
local number_built

function settlements.build_schematic(pos, building, replace_wall, name)
  -- get building node material for better integration to surrounding
  local balcony_material =  minetest.get_node_or_nil(pos).name
  -- pick random material
  local material = wallmaterial[math.random(1,#wallmaterial)]
  -- schematic conversion to lua
  local schem_lua = minetest.serialize_schematic(building, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}).." return(schematic)"
  -- replace material
  if replace_wall == "y" then
    schem_lua = schem_lua:gsub("default:cobble", material)
  end
  schem_lua = schem_lua:gsub("default:dirt_with_grass", balcony_material)
  -- format schematic string
  local schematic = loadstring(schem_lua)()
  -- build foundation for the building an make room above
  local width = schematic["size"]["x"]
  local depth = schematic["size"]["z"]
  local height = schematic["size"]["y"]
  settlements.foundation(pos, width, depth, height)
  -- place schematic
  minetest.after(2, function()
      minetest.place_schematic(pos, schematic, "random", nil, true)
      -- fill chest
      if name == "hut" then
        minetest.after(2,settlements.fill_chest,pos)
      end
    end)
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
    -- add settlement to list
    table.insert(settlements_in_world, center_surface)
    -- save list to file
    settlements.save()
    -- initialize all settlement information
    settlements.initialize_settlement()
    -- build well in the center
    building_all_info = schematic_table["well"]
    settlements.build_schematic(center_surface, building_all_info["mts"],building_all_info["rplc"], building_all_info["name"])
    -- add to settlement info table
    local index = 1
    settlement_info[index] = {pos = center_surface, name = building_all_info["name"], hsize = building_all_info["hsize"]}
    --increase index for following buildings
    index = index + 1
    -- now some buildings around in a circle
    local x, z, r = center_surface.x, center_surface.z, 5
    -- draw 5 circles around center and increase radius by 5
    for j = 1,10 do
      if number_built < number_of_buildings  then 
        -- set position on imaginary circle
        for j = 0, 360, 15 do
          local angle = j * math.pi / 180
          local ptx, ptz = x + r * math.cos( angle ), z + r * math.sin( angle )
          local pos1 = { x=ptx, y=center_surface.y, z=ptz}
          --
          local pos_surface = settlements.find_surface(pos1)
          if pos_surface then
            if settlements.pick_next_building(pos_surface) then
              settlements.build_schematic(pos_surface, building_all_info["mts"],building_all_info["rplc"], building_all_info["name"])
              number_built = number_built + 1
              settlement_info[index] = {pos = pos_surface, name = building_all_info["name"], hsize = building_all_info["hsize"]}
              index = index + 1
              if number_of_buildings == number_built then
                break
              end
            end
          else
            break
          end
        end
        r = r + 5
      end
    end
  end
end
function settlements.initialize_settlement()
  -- settlement_info table reset
  for k,v in pairs(settlement_info) do
    settlement_info[k] = nil
  end
  -- count_buildings table reset
  for k,v in pairs(schematic_table) do
--    local name = schematic_table[v]["name"]
    count_buildings[k] = 0
  end

  -- randomize number of buildings
  number_of_buildings = math.random(7,20)
  number_built = 1
  minetest.chat_send_all("Dorf".. number_of_buildings)
end
--
-- everything necessary to pick a fitting next building
--
function settlements.pick_next_building(pos_surface)
  -- building_all_info = schematic_table[keyset[math.random(#keyset)]]
  -- pick schematic based on chance
  local random_number = math.random(1,100)
  if random_number > 85 and count_buildings["garden"] < schematic_table["garden"]["max_num"]*number_of_buildings then
    building_all_info = schematic_table["garden"]   
  elseif random_number > 75 and count_buildings["tower"] < schematic_table["tower"]["max_num"]*number_of_buildings then
    building_all_info = schematic_table["tower"]   
  elseif random_number > 65 and count_buildings["lamp"] < schematic_table["lamp"]["max_num"]*number_of_buildings then
    building_all_info = schematic_table["lamp"]   
  elseif random_number > 55 and count_buildings["church"] < schematic_table["church"]["max_num"]*number_of_buildings then
    building_all_info = schematic_table["church"]   
  else
    building_all_info = schematic_table["hut"]   
  end
  -- before placing, check_distance to other buildings
  local distance_to_other_buildings_ok = settlements.check_distance(pos_surface, building_all_info["hsize"])
  if distance_to_other_buildings_ok then
    -- count built houses
    count_buildings[building_all_info["name"]] = count_buildings[building_all_info["name"]] +1

    return building_all_info["mts"]
    --todo hier den count_up einfügen
  else
    return nil
  end
end
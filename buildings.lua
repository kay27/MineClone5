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
--
-- build schematic, replace material, rotation
--
function settlements.build_schematic(vm, data, va, pos, building, replace_wall, name)
  -- get building node material for better integration to surrounding
  local platform_material =  minetest.get_node_or_nil(pos)
  if not platform_material then
    return
  end
  platform_material = platform_material.name
  -- pick random material
  local material = wallmaterial[math.random(1,#wallmaterial)]
  -- schematic conversion to lua
  local schem_lua = minetest.serialize_schematic(building, 
    "lua", 
    {lua_use_comments = false, lua_num_indent_spaces = 0}).." return(schematic)"
  -- replace material
  if replace_wall == "y" then
    schem_lua = schem_lua:gsub("default:cobble", material)
  end
  schem_lua = schem_lua:gsub("default:dirt_with_grass", 
    platform_material)
  -- special material for spawning npcs
  schem_lua = schem_lua:gsub("default:junglewood", 
    "settlements:junglewood")
  -- format schematic string
  local schematic = loadstring(schem_lua)()
  -- build foundation for the building an make room above
  local width = schematic["size"]["x"]
  local depth = schematic["size"]["z"]
  local height = schematic["size"]["y"]
  local possible_rotations = {"0", "90", "180", "270"}
  local rotation = possible_rotations[ math.random( #possible_rotations ) ]
  settlements.foundation(
    vm,
    data, 
    va, 
    pos, 
    width, 
    depth, 
    height, 
    rotation)
  -- place schematic
  minetest.after(3, function() --increase waiting time, if "block not found" in debug.txt
      minetest.place_schematic(pos, 
        schematic, 
        rotation, 
        nil, 
        true)
      -- initialize special nodes (chests, furnace)
      minetest.after(2, settlements.initialize_nodes, pos, width, depth, height)
    end)
end
--
-- placing buildings within lvm
--
function settlements.place_settlement_lvm(vm, data, va, minp, maxp)
  -- find center of chunk
  local center = {
    x=maxp.x-half_map_chunk_size, 
    y=maxp.y, 
    z=maxp.z-half_map_chunk_size
  } 
  -- find center_surcafe of chunk
  local center_surface = settlements.find_surface_lvm(center, data, va)
  -- go build settlement around center
  if center_surface then
    -- add settlement to list
    table.insert(settlements_in_world, 
      center_surface)
    -- save list to file
    settlements.save()
    -- initialize all settlement information
    settlements.initialize_settlement()
    -- build well in the center
    building_all_info = schematic_table[1]
    settlements.build_schematic(
      vm,
      data, 
      va, 
      center_surface, 
      building_all_info["mts"],
      building_all_info["rplc"], 
      building_all_info["name"])
    -- add to settlement info table
    local index = 1
    settlement_info[index] = {pos = center_surface, 
      name = building_all_info["name"], 
      hsize = building_all_info["hsize"]}
    --increase index for following buildings
    index = index + 1
    -- now some buildings around in a circle, radius = size of town center
    local x, z, r = center_surface.x, center_surface.z, building_all_info["hsize"]
    -- draw j circles around center and increase radius by math.random(2,5)
    for j = 1,20 do
      if number_built < number_of_buildings  then 
        -- set position on imaginary circle
        for j = 0, 360, 15 do
          local angle = j * math.pi / 180
          local ptx, ptz = x + r * math.cos( angle ), z + r * math.sin( angle )
          ptx = settlements.round(ptx, 0)
          ptz = settlements.round(ptz, 0)
          local pos1 = { x=ptx, y=center_surface.y, z=ptz}
          --
          local pos_surface = settlements.find_surface_lvm(pos1, data, va)
          --local pos_surface = settlements.find_surface(pos1)
          if pos_surface 
          then
            if settlements.pick_next_building(pos_surface) 
            then
              settlements.build_schematic(
                vm,
                data, 
                va, 
                pos_surface, 
                building_all_info["mts"],
                building_all_info["rplc"], 
                building_all_info["name"]
                )
              number_built = number_built + 1
              settlement_info[index] = {
                pos = pos_surface, 
                name = building_all_info["name"], 
                hsize = building_all_info["hsize"]
                }
              index = index + 1
              if number_of_buildings == number_built 
              then
                break
              end
            end
          else
            break
          end
        end
        r = r + math.random(2,5)
      end
    end
    if settlements.debug == true
    then
      minetest.chat_send_all("really ".. number_built)
    end
    minetest.after(2, settlements.paths)
--    settlements.paths()
  end
end
--
-- placing buildings in circles around center
--
function settlements.place_settlement_circle(minp, maxp)
  -- find center of chunk
  local center = {
    x=maxp.x-half_map_chunk_size, 
    y=maxp.y-half_map_chunk_size, 
    z=maxp.z-half_map_chunk_size
  } 
  -- find center_surcafe of chunk
  local center_surface = settlements.find_surface(center)
  -- go build settlement around center
  if center_surface then
    -- add settlement to list
    table.insert(settlements_in_world, 
      center_surface)
    -- save list to file
    settlements.save()
    -- initialize all settlement information
    settlements.initialize_settlement()
    -- build well in the center
    building_all_info = schematic_table[1]
    settlements.build_schematic(
      center_surface, 
      building_all_info["mts"],
      building_all_info["rplc"], 
      building_all_info["name"])
    -- add to settlement info table
    local index = 1
    settlement_info[index] = {pos = center_surface, 
      name = building_all_info["name"], 
      hsize = building_all_info["hsize"]}
    --increase index for following buildings
    index = index + 1
    -- now some buildings around in a circle, radius = size of town center
    local x, z, r = center_surface.x, center_surface.z, building_all_info["hsize"]
    -- draw j circles around center and increase radius by math.random(2,5)
    for j = 1,20 do
      if number_built < number_of_buildings  then 
        -- set position on imaginary circle
        for j = 0, 360, 15 do
          local angle = j * math.pi / 180
          local ptx, ptz = x + r * math.cos( angle ), z + r * math.sin( angle )
          local pos1 = { x=ptx, y=center_surface.y, z=ptz}
          --
          local pos_surface = settlements.find_surface(pos1)
          if pos_surface 
          then
            if settlements.pick_next_building(pos_surface) 
            then
              settlements.build_schematic(pos_surface, 
                building_all_info["mts"],
                building_all_info["rplc"], 
                building_all_info["name"])
              number_built = number_built + 1
              settlement_info[index] = {pos = pos_surface, 
                name = building_all_info["name"], 
                hsize = building_all_info["hsize"]}
              index = index + 1
              if number_of_buildings == number_built 
              then
                break
              end
            end
          else
            break
          end
        end
        r = r + math.random(2,5)
      end
    end
    if settlements.debug == true
    then
      minetest.chat_send_all("really ".. number_built)
    end
    minetest.after(2, settlements.paths)
--    settlements.paths()
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
    count_buildings[v["name"]] = 0
  end

  -- randomize number of buildings
  number_of_buildings = math.random(10,25)
  number_built = 1
  if settlements.debug == true
  then
    minetest.chat_send_all("settlement ".. number_of_buildings)
  end
end
--
-- everything necessary to pick a fitting next building
--
function settlements.pick_next_building(pos_surface)
  local randomized_schematic_table = shuffle(schematic_table)
  -- pick schematic
  local size = #randomized_schematic_table
  for i = size, 1, -1 do
    -- already enough buildings of that type?
    if count_buildings[randomized_schematic_table[i]["name"]] < randomized_schematic_table[i]["max_num"]*number_of_buildings    then
      building_all_info = randomized_schematic_table[i]
      -- check distance to other buildings
      local distance_to_other_buildings_ok = settlements.check_distance(pos_surface, 
        building_all_info["hsize"])
      if distance_to_other_buildings_ok 
      then
        -- count built houses
        count_buildings[building_all_info["name"]] = count_buildings[building_all_info["name"]] +1
        return building_all_info["mts"]
      end
    end
  end
  return nil
end
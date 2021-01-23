-- eclipse debugging lines
--require("debugger")(idehost, ideport, idekey)

--zerobrane debugging lines
--package.cpath = package.cpath .. ";/usr/share/lua/5.2/?.so"
--package.path = package.path .. ";/usr/share/zbstudio/lualibs/mobdebug/?.lua"
--require('mobdebug').start()

settlements = {}
settlements.modpath = minetest.get_modpath("mcl_villages");

vm, data, va, emin, emax = 1

dofile(settlements.modpath.."/const.lua")
dofile(settlements.modpath.."/utils.lua")
dofile(settlements.modpath.."/foundation.lua")
dofile(settlements.modpath.."/buildings.lua")
dofile(settlements.modpath.."/paths.lua")
dofile(settlements.modpath.."/convert_lua_mts.lua")
--
-- load settlements on server
--
settlements_in_world = settlements.load()
settlements.grundstellungen()

--[[ Disable custom node spawning.
--
-- register block for npc spawn
--
minetest.register_node("settlements:junglewood", {
    description = "special junglewood floor",
    tiles = {"default_junglewood.png"},
    groups = {choppy=3, wood=2},
    sounds = default.node_sound_wood_defaults(),
  })

--]]


--[[ Enable for testing, but use MineClone2's own spawn code if/when merging.
--
-- register inhabitants
--
if minetest.get_modpath("mobs_mc") ~= nil then
  mobs:register_spawn("mobs_mc:villager", --name
    {"mcl_core:stonebrickcarved"}, --nodes
    15, --max_light
    0, --min_light
    20, --chance
    7, --active_object_count
    31000, --max_height
    nil) --day_toggle
end 
--]]

--
-- on map generation, try to build a settlement
--
minetest.register_on_generated(function(minp, maxp)
    --
    -- needed for manual and automated settlement building
    --
    local heightmap = minetest.get_mapgen_object("heightmap")
    --
    -- randomly try to build settlements
    -- 
    if math.random(1,10)<=7 then
      --
      -- time between creation of two settlements
      --
      if os.difftime(os.time(), settlements.last_settlement) < settlements.min_timer 
      then
        return
      end
--      if settlements.debug == true then
--         minetest.chat_send_all("Last opportunity ".. os.difftime(os.time(), settlements.last_settlement))
--      end
      --
      -- don't build settlement underground
      --
      if maxp.y < 0 then 
        return 
      end
      --
      -- don't build settlements too close to each other
      --
      local center_of_chunk = { 
        x=maxp.x-half_map_chunk_size, 
        y=maxp.y-half_map_chunk_size, 
        z=maxp.z-half_map_chunk_size
      } 
      local dist_ok = settlements.check_distance_other_settlements(center_of_chunk)
      if dist_ok == false 
      then
        return
      end
      --
      -- don't build settlements on (too) uneven terrain
      --
      local height_difference = settlements.evaluate_heightmap(minp, maxp)
      if height_difference > max_height_difference 
      then
        return
      end
      -- 
      -- if no hard showstoppers prevent the settlement -> try to do it (check for suitable terrain)
      --
      -- set timestamp of actual settlement
      --
      settlements.last_settlement = os.time()
      
      -- waiting necessary for chunk to load, otherwise, townhall is not in the middle, no map found behind townhall
      minetest.after(3, function()
          local suitable_place_found = false
          --
          -- fill settlement_info with buildings and their data
          --
          if settlements.lvm == true
          then
            --
            -- get LVM of current chunk
            --
            vm, data, va, emin, emax = settlements.getlvm(minp, maxp)
            suitable_place_found = settlements.create_site_plan_lvm(maxp, minp)
          else
            suitable_place_found = settlements.create_site_plan(maxp, minp)
          end
          if not suitable_place_found
          then
            return
          end
          --
          -- evaluate settlement_info and prepair terrain
          --
          if settlements.lvm == true
          then
            settlements.terraform_lvm()
          else
            settlements.terraform()
          end

          --
          -- evaluate settlement_info and build paths between buildings
          --
          if settlements.lvm == true
          then
            settlements.paths_lvm(minp)
          else
            settlements.paths()
          end
          --
          -- evaluate settlement_info and place schematics
          --
          if settlements.lvm == true
          then
            vm:set_data(data)
            settlements.place_schematics_lvm()
            vm:write_to_map(true)
          else
            settlements.place_schematics()
          end
          --
          -- evaluate settlement_info and initialize furnaces and chests
          --
          settlements.initialize_nodes()
          
        end)


    end
  end)
--
-- manually place buildings, for debugging only
--
minetest.register_craftitem("mcl_villages:tool", {
    description = "mcl_villages build tool",
    inventory_image = "default_tool_woodshovel.png",
    
	--[[ Disable on_use for now.
    -- build single house
    --
    on_use = function(itemstack, placer, pointed_thing)
      local center_surface = pointed_thing.under
      if center_surface then
        local building_all_info = {name = "blacksmith", 
          mts = schem_path.."blacksmith.mts", 
          hsize = 13, 
          max_num = 0.9, 
          rplc = "n"}
        settlements.build_schematic(center_surface, 
          building_all_info["mts"],
          building_all_info["rplc"], 
          building_all_info["name"])

--        settlements.convert_mts_to_lua()
--        settlements.mts_save()
      end
    end,
--]]
    --
    -- build ssettlement
    --
    on_place = function(itemstack, placer, pointed_thing)
      -- enable debug routines
      settlements.debug = true
      local center_surface = pointed_thing.under
      if center_surface then
        local minp = {
          x=center_surface.x-half_map_chunk_size, 
          y=center_surface.y-half_map_chunk_size, 
          z=center_surface.z-half_map_chunk_size
        }
        local maxp = {
          x=center_surface.x+half_map_chunk_size, 
          y=center_surface.y+half_map_chunk_size, 
          z=center_surface.z+half_map_chunk_size
        }
        --
        -- get LVM of current chunk
        --
        vm, data, va, emin, emax = settlements.getlvm(minp, maxp)
        --
        -- fill settlement_info with buildings and their data
        --
        local start_time = os.time()
        local suitable_place_found = false
        if settlements.lvm == true
        then
          suitable_place_found = settlements.create_site_plan_lvm(maxp, minp)
        else
          suitable_place_found = settlements.create_site_plan(maxp, minp)
        end
        if not suitable_place_found
        then
          return
        end
        --
        -- evaluate settlement_info and prepair terrain
        --
        if settlements.lvm == true
        then
          settlements.terraform_lvm()
        else
          settlements.terraform()
        end

        --
        -- evaluate settlement_info and build paths between buildings
        --
        if settlements.lvm == true
        then
          settlements.paths_lvm(minp)
        else
          settlements.paths()
        end
        --
        -- evaluate settlement_info and place schematics
        --
        if settlements.lvm == true
        then
          vm:set_data(data)
          settlements.place_schematics_lvm()
          vm:write_to_map(true)
        else
          settlements.place_schematics()
        end

        --
        -- evaluate settlement_info and initialize furnaces and chests
        --
        settlements.initialize_nodes()
        local end_time = os.time()
        minetest.chat_send_all("Time ".. end_time - start_time)
--
        --settlements.convert_mts_to_lua()
        --settlements.mts_save()

      end
    end
  })


--
-- material to replace cobblestone with
--
wallmaterial = {
  "default:junglewood", 
  "default:pine_wood", 
  "default:wood", 
  "default:aspen_wood", 
  "default:acacia_wood",   
  "default:stonebrick", 
  "default:cobble", 
  "default:desert_stonebrick", 
  "default:desert_cobble", 
  "default:sandstone"
}
--
-- path to schematics
--
schem_path = settlements.modpath.."/schematics/"
--
-- list of schematics
--
schematic_table = { 
  {name = "well", mts = schem_path.."well.mts", hsize = 11, max_num = 0, rplc = "n"},
  {name = "hut", mts = schem_path.."hut.mts", hsize = 11, max_num = 0.9, rplc = "y"},
  {name = "garden", mts = schem_path.."garden.mts", hsize = 11, max_num = 0.1, rplc = "n"},
  {name = "lamp", mts = schem_path.."lamp.mts", hsize = 10, max_num = 0.1, rplc = "n"},
  {name = "tower", mts = schem_path.."tower.mts", hsize = 11, max_num = 0.055, rplc = "n"},
  {name = "church", mts = schem_path.."church.mts", hsize = 17, max_num = 0.050, rplc = "n"},
  {name = "blacksmith", mts = schem_path.."blacksmith.mts", hsize = 11, max_num = 0.055, rplc = "n"},
}
--
-- baseplate material, to replace dirt with grass and where buildings can be built
--
surface_mat = {
  "default:dirt_with_grass",
  "default:dirt_with_snow",
  "default:dirt_with_dry_grass",
  "default:dirt_with_coniferous_litter",
  "default:sand",
--  "default:snow"
}
--
-- temporary info for currentliy built settlement (position of each building) 
--
settlement_info = {}
--
-- list of settlements, load on server start up
--
settlements_in_world = {}
--
-- min_distance between settlements
--
min_dist_settlements = 150

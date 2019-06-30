--
-- switch for debugging
--
settlements.debug = false
--
-- switch for lvm
settlements.lvm = false
--
-- timer between creation of two settlements
--
settlements.last_settlement = os.time()
settlements.min_timer = 60
--
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
  {name = "townhall", mts = schem_path.."townhall.mts", hwidth = 10, hdepth = 11, hheight = 12, hsize = 15, max_num = 0, rplc = "n"},
  {name = "well", mts = schem_path.."well.mts", hwidth = 5, hdepth = 5, hheight = 13, hsize = 11, max_num = 0.045, rplc = "n"},
  {name = "hut", mts = schem_path.."hut.mts", hwidth = 7, hdepth = 7, hheight = 13, hsize = 11, max_num = 0.9, rplc = "y"},
  {name = "garden", mts = schem_path.."garden.mts", hwidth = 7, hdepth = 7, hheight = 13, hsize = 11, max_num = 0.1, rplc = "n"},
  {name = "lamp", mts = schem_path.."lamp.mts", hwidth = 3, hdepth = 3, hheight = 13, hsize = 10, max_num = 0.1, rplc = "n"},
  {name = "tower", mts = schem_path.."tower.mts", hwidth = 7, hdepth = 7, hheight = 13, hsize = 11, max_num = 0.055, rplc = "n"},
  {name = "church", mts = schem_path.."church.mts", hwidth = 7, hdepth = 10, hheight = 13, hsize = 17, max_num = 0.050, rplc = "n"},
  {name = "blacksmith", mts = schem_path.."blacksmith.mts", hwidth = 7, hdepth = 7, hheight = 13, hsize = 11, max_num = 0.050, rplc = "n"},
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
settlements.min_dist_settlements = 500
if settlements.debug == true 
then
  min_dist_settlements = 200
end
--
-- maximum allowed difference in height for building a sttlement
--
max_height_difference = 10
--
--
--
half_map_chunk_size = 40
quarter_map_chunk_size = 20

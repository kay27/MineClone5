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

c_floor_material = "default:wood" -- not local because doors need it
last_time = os.time()

surface_mat = {
  "default:dirt_with_grass",
  "default:dirt_with_snow",
  "default:dirt_with_dry_grass",
  "default:dirt_with_coniferous_litter",
  "default:sand"
  }
above_surface_mat = {"default:air","default:dirt_with_snow"}
under_surface_mat = {"default:stone","default:dirt"}
schem_path = settlements.modpath.."/schematics/"
settlement_info = {}
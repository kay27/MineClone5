local baumaterial = {"default:junglewood", "default:pine_wood", "default:wood", "default:aspen_wood", "default:acacia_wood", 
  "default:stonebrick", "default:cobble", "default:desert_stonebrick", "default:desert_cobble", "default:sandstone"}

local baumaterial_count = 10

function settlements.build_house(pos)
  local height = math.random(4,4)
  local width = math.random(4,5)
  local depth = math.random(4,5)
  -- set random material from list
  material = baumaterial[math.random(1,baumaterial_count)]
  minetest.chat_send_all(minetest.pos_to_string(pos).." "..material)
--
  settlements.foundation(pos, height, width, depth)
  settlements.walls(pos, height, width, depth, material)
  settlements.saddle_roof(pos, height, width, depth)
  settlements.door(pos, width, depth)
end

local baumaterial = {"default:junglewood", "default:pine_wood", "default:wood", "default:aspen_wood", "default:acacia_wood", 
  "default:stonebrick", "default:cobble", "default:desert_stonebrick", "default:desert_cobble", "default:sandstone"}

local baumaterial_count = 10

local blueprint = { {{1,1,1,1,1,1,1},
    {1,0,0,0,0,0,1},
    {1,0,0,0,0,0,1},
    {1,0,0,0,0,0,1},
    {1,0,0,0,0,0,1},
    {1,0,0,0,0,0,1},
    {1,0,1,1,1,1,1}},
  {{2,2,2,2,2,2,2},
    {2,0,0,0,0,0,2},
    {2,0,0,0,0,0,2},
    {2,0,0,0,0,0,2},
    {2,0,0,0,0,0,2},
    {2,0,0,0,0,0,2},
    {2,0,2,2,2,2,2}},
}

function settlements.build_house(pos)
  local height = math.random(4,4)
  local width = math.random(4,5)
  local depth = math.random(4,5)
  -- set random material from list
  material = baumaterial[math.random(1,#baumaterial)]
  minetest.chat_send_all(minetest.pos_to_string(pos).." "..material)
--
  settlements.foundation(pos, height, width, depth)
  settlements.walls(pos, height, width, depth, material)
--  settlements.random_roof(pos, height, width, depth)
  settlements.saddle_roof(pos, height, width, depth)
  settlements.door(pos, width, depth)
end
--
--
-- blueprint section
--
--
function settlements.build_blueprint(pos)
  local blueprint_function_table = {settlements.build_blueprint_n, settlements.build_blueprint_s, settlements.build_blueprint_w, settlements.build_blueprint_o}
  local random_index = math.random(1, #blueprint_function_table) --pick random index from 1 to #f_tbl
  blueprint_function_table[random_index](pos) --execute function at the random_index we've picked
end

function settlements.build_blueprint_n(pos)
  x = 0
  y = 1
  z = 0
  for i = 1,#blueprint, 1 do   -- floor
    for j = 1, #blueprint[i], 1 do   -- row
      for k = 1, #blueprint[i][j], 1 do   -- block
        settlements.build_blueprint_block(pos, blueprint[i][j][k])       
        x = x + 1
--        minetest.chat_send_all(blocks)
      end
      x = 0
      z = z + 1   
    end
    z = 0
    y = y + 1
  end
end
--
function settlements.build_blueprint_s(pos)
  x = 0
  y = 1
  z = 0
  for i = 1,#blueprint, 1 do   -- floor
    for j = #blueprint[i], 1, -1 do   
      for k = #blueprint[i][j], 1, -1 do   
        settlements.build_blueprint_block(pos, blueprint[i][j][k])       
        x = x + 1
--        minetest.chat_send_all(blocks)
      end
      x = 0
      z = z + 1   
    end
    z = 0
    y = y + 1
  end
end
--
function settlements.build_blueprint_w(pos)
  x = 0
  y = 1
  z = 0
  for i = 1,#blueprint, 1 do   -- floor
    for j = 1, #blueprint[i], 1 do   -- row
      for k = 1, #blueprint[i][j], 1 do   -- block
        settlements.build_blueprint_block(pos, blueprint[i][j][k])       
        z = z + 1
--        minetest.chat_send_all(blocks)
      end
      z = 0
      x = x + 1   
    end
    x = 0
    y = y + 1
  end
end
--
function settlements.build_blueprint_e(pos)
  x = 0
  y = 1
  z = 0
  for i = 1,#blueprint, 1 do   -- floor
    for j = #blueprint[i], 1, -1 do   
      for k = #blueprint[i][j], 1, -1 do   
        settlements.build_blueprint_block(pos, blueprint[i][j][k])       
        z = z + 1
--        minetest.chat_send_all(blocks)
      end
      z = 0
      x = x + 1   
    end
    x = 0
    y = y + 1
  end
end

function settlements.build_blueprint_block(pos, blockid)
  if blockid == 1 then
    minetest.set_node({x=pos.x+x, y=pos.y+y, z=pos.z+z}, {name="default:wood"})
  elseif blockid == 2 then
    minetest.set_node({x=pos.x+x, y=pos.y+y, z=pos.z+z}, {name="default:cobble"})
  else
    minetest.remove_node({x=pos.x+x, y=pos.y+y, z=pos.z+z})
  end
end


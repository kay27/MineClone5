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
function settlements.build_blueprint(pos,blueprint)
  local blueprint_function_table = {settlements.build_blueprint_n, settlements.build_blueprint_s, settlements.build_blueprint_w, settlements.build_blueprint_e}
  local random_index = math.random(1, #blueprint_function_table) --pick random index from 1 to #f_tbl
  blueprint_function_table[random_index](pos,blueprint) --execute function at the random_index we've picked
end

function settlements.build_blueprint_n(pos,blueprint)
  x = 0
  y = 0
  z = 0
  for i = 1,#blueprint, 1 do   -- floor
    for j = 1, #blueprint[i], 1 do   -- row
      for k = 1, #blueprint[i][j], 1 do   -- block
        if string.find(blueprint[i][j][k],"door") then
          settlements.door({x=pos.x+x, y=pos.y+y, z=pos.z+z})
        elseif blueprint[i][j][k] ~= nil then
          minetest.set_node({x=pos.x+x, y=pos.y+y, z=pos.z+z}, {name=blueprint[i][j][k]})
        end
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
function settlements.build_blueprint_s(pos,blueprint)
  x = 0
  y = 0
  z = 0
  for i = 1,#blueprint, 1 do   -- floor
    for j = #blueprint[i], 1, -1 do   
      for k = #blueprint[i][j], 1, -1 do   
        if string.find(blueprint[i][j][k],"door") then
          settlements.door({x=pos.x+x, y=pos.y+y, z=pos.z+z})
        elseif blueprint[i][j][k] ~= nil then
          minetest.set_node({x=pos.x+x, y=pos.y+y, z=pos.z+z}, {name=blueprint[i][j][k]})
        end
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
function settlements.build_blueprint_w(pos,blueprint)
  x = 0
  y = 0
  z = 0
  for i = 1,#blueprint, 1 do   -- floor
    for j = 1, #blueprint[i], 1 do   -- row
      for k = 1, #blueprint[i][j], 1 do   -- block
        if string.find(blueprint[i][j][k],"door") then
          settlements.door({x=pos.x+x, y=pos.y+y, z=pos.z+z})
        elseif blueprint[i][j][k] ~= nil then
          minetest.set_node({x=pos.x+x, y=pos.y+y, z=pos.z+z}, {name=blueprint[i][j][k]})
        end
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
function settlements.build_blueprint_e(pos,blueprint)
  x = 0
  y = 0
  z = 0
  for i = 1,#blueprint, 1 do   -- floor
    for j = #blueprint[i], 1, -1 do   
      for k = #blueprint[i][j], 1, -1 do   
        if string.find(blueprint[i][j][k],"door") then
          settlements.door({x=pos.x+x, y=pos.y+y, z=pos.z+z})
        elseif blueprint[i][j][k] ~= nil then
          minetest.set_node({x=pos.x+x, y=pos.y+y, z=pos.z+z}, {name=blueprint[i][j][k]})
        end
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
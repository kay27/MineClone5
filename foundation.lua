local function can_replace(pos)
  local n = minetest.get_node_or_nil(pos)
  if n and n.name and minetest.registered_nodes[n.name] and not minetest.registered_nodes[n.name].walkable then
    return true
  elseif not n then
    return true
  else
    return false
  end
end
--
-- Function to fill empty space below baseplate when building on a hill
--
function settlements.ground(pos) -- Wendelsteinkircherl, Brannenburg
  local p2 = pos
  local cnt = 0
  local mat = "dirt"
  p2.y = p2.y-1
  --while can_replace(p2)==true do--minetest.get_node(p2).name == "air" do
  while true do
    cnt = cnt+1
    if cnt > 200 then break end
    if cnt>math.random(2,4) then mat = "stone"end
    minetest.set_node(p2, {name="default:"..mat})
    p2.y = p2.y-1
  end
end
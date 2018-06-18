--
-- Function to copy tables
--
function settlements.shallowCopy(original)
  local copy = {}
  for key, value in pairs(original) do
    copy[key] = value
  end
  return copy
end
--
-- Function to find surface block y coordinate
-- returns surface postion
--
function settlements.find_surface(pos)
  local p6 = settlements.shallowCopy(pos)
  local cnt = 0
  local itter -- nach oben oder nach unten zählen
  local cnt_max = 200
-- check, ob zu weit unten mit der Suche begonnen wird
  local s = minetest.get_node_or_nil(p6)
  if s and string.find(s.name,"air") then 
    --p6.y = p6.y+50
    itter = -1
  else
    itter = 1
  end
  while cnt < cnt_max do
    cnt = cnt+1
    s = minetest.get_node_or_nil(p6)
    if s == nil or s.name == "ignore" then return nil end
    for i, mats in ipairs(surface_mat) do
      if s and s.name == mats then 
        return p6 
      end
    end
    p6.y = p6.y + itter
    if p6.y < 0 then return nil end
  end
  return nil
end
--
-- Function to find random positions
-- returns array with coords where houses are built
--
function settlements.find_locations(minp, maxp)
-- Anzahl Gebäude
  local amount_of_buildings = 10 --math.random(5,10) 
  local location_list = {}
-- Mindest und maxi Abstand
  local radius = 1000
  local housemindist = 7
  local housemaxdist = 1000
  local centeroftown -- Erste location ist Mittelpunkt des Dorfes
  local tries = 500 -- 500 Versuche, ne geeignete Location zu finden
  local count = 0
--
  for i = 1,amount_of_buildings do
-- Zufallslocation finden
    ::neuerversuch:: -- Sprungpunkt, falls Abstand nicht passt
    count = count + 1
    -- nicht unendlich oft probieren, sonst endlos schleife
    if count > tries then return nil end
    local tpos = {x=math.random(minp.x,maxp.x), y=math.random(minp.y,maxp.y), z=math.random(minp.z,maxp.z)} 
    if tpos.y < 0 then goto neuerversuch end
    local mpos = settlements.find_surface(tpos)
    if not mpos or mpos == nil or mpos.y < 0 then goto neuerversuch end

-- vor dem Ablegen in die Liste, Abstand zu bisherigen locations finden, sobald mehr als eine location gefunden wurde
    if i > 1 then
-- bisherige Liste durchgehen und mit aktueller mpos vergleichen
      for j, saved_location in ipairs(location_list) do
        local distanceToCenter = math.sqrt(((centeroftown.x - mpos.x)*(centeroftown.x - mpos.x))+((centeroftown.y - mpos.y)*(centeroftown.y - mpos.y)))
        local distanceTohouses = math.sqrt(((saved_location.x - mpos.x)*(saved_location.x - mpos.x))+((saved_location.y - mpos.y)*(saved_location.y - mpos.y)))

-- nicht weiter als 
        --               if distanceToCenter > radius or distanceTohouses < housemindist or distanceTohouses > housemaxdist then
        if distanceTohouses < housemindist then
          goto neuerversuch
        end
      end
      location_list[i] = mpos
    else
      location_list[i] = mpos
      centeroftown = mpos
    end
  end
  return location_list
end

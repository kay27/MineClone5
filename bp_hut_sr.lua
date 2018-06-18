--
-- blueprint for hut with saddle roof
--
local a0 = "air"
local d1 = "doors:door_wood_b"
local f1 = c_floor_material
local f2 = "default:dirt_with_grass"
local r1 = "default:wood"
local w1 = "default:cobble"
local w2 = "default:glass"
local w3 = "default:tree"
local zz = nil
--
blueprint_hut_sr = { 
-- floor
   {
    {f2,f2,f2,f2,f2,f2,f2},
    {f2,f1,f1,f1,f1,f1,f2},
    {f2,f1,f1,f1,f1,f1,f2},
    {f2,f1,f1,f1,f1,f1,f2},
    {f2,f1,f1,f1,f1,f1,f2},
    {f2,f1,f1,f1,f1,f1,f2},
    {f2,f2,f2,f2,f2,f2,f2}
    },
-- layer 1
   {
    {a0,a0,a0,a0,a0,a0,a0},
    {a0,w3,w1,w1,w1,w3,a0},
    {a0,w1,a0,a0,a0,w1,a0},
    {a0,w1,a0,a0,a0,w1,a0},
    {a0,w1,a0,a0,a0,w1,a0},
    {a0,w3,w1,d1,w1,w3,a0},
    {a0,a0,a0,a0,a0,a0,a0},
   },
-- layer 2
   {
    {a0,a0,a0,a0,a0,a0,a0},
    {a0,w3,w1,w2,w1,w3,a0},
    {a0,w1,a0,a0,a0,w1,a0},
    {a0,w2,a0,a0,a0,w2,a0},
    {a0,w1,a0,a0,a0,w1,a0},
    {a0,w3,w1,a0,w1,w3,a0},
    {a0,a0,a0,a0,a0,a0,a0},
   },
-- layer 3
   {
    {a0,a0,a0,a0,a0,a0,a0},
    {a0,w3,w1,w1,w1,w3,a0},
    {a0,w1,a0,a0,a0,w1,a0},
    {a0,w1,a0,a0,a0,w1,a0},
    {a0,w1,a0,a0,a0,w1,a0},
    {a0,w3,w1,w1,w1,w3,a0},
    {a0,a0,a0,a0,a0,a0,a0},
   },
-- layer 4 roof
   {
    {r1,r1,r1,r1,r1,r1,r1},
    {a0,w3,w3,w3,w3,w3,a0},
    {a0,w3,a0,a0,a0,w3,a0},
    {a0,w3,a0,a0,a0,w3,a0},
    {a0,w3,a0,a0,a0,w3,a0},
    {a0,w3,w3,w3,w3,w3,a0},
    {r1,r1,r1,r1,r1,r1,r1},
   },
-- layer 5 roof
   {
    {a0,a0,a0,a0,a0,a0,a0},
    {r1,r1,r1,r1,r1,r1,r1},
    {a0,w1,a0,a0,a0,w1,a0},
    {a0,w1,a0,a0,a0,w1,a0},
    {a0,w1,a0,a0,a0,w1,a0},
    {r1,r1,r1,r1,r1,r1,r1},
    {a0,a0,a0,a0,a0,a0,a0},
   },
-- layer 6 roof
   {
    {a0,a0,a0,a0,a0,a0,a0},
    {a0,a0,a0,a0,a0,a0,a0},
    {r1,r1,r1,r1,r1,r1,r1},
    {a0,w1,a0,a0,a0,w1,a0},
    {r1,r1,r1,r1,r1,r1,r1},
    {a0,a0,a0,a0,a0,a0,a0},
    {a0,a0,a0,a0,a0,a0,a0},
   },
-- layer 7 roof
   {
    {a0,a0,a0,a0,a0,a0,a0},
    {a0,a0,a0,a0,a0,a0,a0},
    {a0,a0,a0,a0,a0,a0,a0},
    {r1,r1,r1,r1,r1,r1,r1},
    {a0,a0,a0,a0,a0,a0,a0},
    {a0,a0,a0,a0,a0,a0,a0},
    {a0,a0,a0,a0,a0,a0,a0},
   },
}

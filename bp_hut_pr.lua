--
-- blueprint for hut with pyramid roof
--
a0 = air
d1 = door
f1 = floor
f2 = surrounding
r1 = roof
w1 = wall
w2 = windows
local blueprint_hut_pr = { 
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
    {a0,w1,w1,w1,w1,w1,a0},
    {a0,w1,a0,a0,a0,w1,a0},
    {a0,w1,a0,a0,a0,w1,a0},
    {a0,w1,a0,a0,a0,w1,a0},
    {a0,w1,w1,d1,w1,w1,a0},
    {a0,a0,a0,a0,a0,a0,a0},
   },
-- layer 2
   {
    {a0,a0,a0,a0,a0,a0,a0},
    {a0,w1,w1,w2,w1,w1,a0},
    {a0,w1,a0,a0,a0,w1,a0},
    {a0,w2,a0,a0,a0,w2,a0},
    {a0,w1,a0,a0,a0,w1,a0},
    {a0,w1,w1,d1,w1,w1,a0},
    {a0,a0,a0,a0,a0,a0,a0},
   },
-- layer 3
   {
    {a0,a0,a0,a0,a0,a0,a0},
    {a0,w1,w1,w1,w1,w1,a0},
    {a0,w1,a0,a0,a0,w1,a0},
    {a0,w1,a0,a0,a0,w1,a0},
    {a0,w1,a0,a0,a0,w1,a0},
    {a0,w1,w1,w1,w1,w1,a0},
    {a0,a0,a0,a0,a0,a0,a0},
   },
-- layer 4 roof
   {
    {r1,r1,r1,r1,r1,r1,r1},
    {r1,w1,w1,w1,w1,w1,r1},
    {r1,w1,a0,a0,a0,w1,r1},
    {r1,w1,a0,a0,a0,w1,r1},
    {r1,w1,a0,a0,a0,w1,r1},
    {r1,w1,w1,w1,w1,w1,r1},
    {r1,r1,r1,r1,r1,r1,r1},
   },
-- layer 5 roof
   {
    {a0,a0,a0,a0,a0,a0,a0},
    {a0,r1,r1,r1,r1,r1,a0},
    {a0,r1,a0,a0,a0,r1,a0},
    {a0,r1,a0,a0,a0,r1,a0},
    {a0,r1,a0,a0,a0,r1,a0},
    {a0,r1,r1,r1,r1,r1,a0},
    {a0,a0,a0,a0,a0,a0,a0},
   },
-- layer 6 roof
   {
    {a0,a0,a0,a0,a0,a0,a0},
    {a0,a0,a0,a0,a0,a0,a0},
    {a0,a0,r1,r1,r1,a0,a0},
    {a0,a0,r1,a0,r1,a0,a0},
    {a0,a0,r1,r1,r1,a0,a0},
    {a0,a0,a0,a0,a0,a0,a0},
    {a0,a0,a0,a0,a0,a0,a0},
   },
-- layer 7 roof
   {
    {a0,a0,a0,a0,a0,a0,a0},
    {a0,a0,a0,a0,a0,a0,a0},
    {a0,a0,a0,a0,a0,a0,a0},
    {a0,a0,a0,r1,a0,a0,a0},
    {a0,a0,a0,a0,a0,a0,a0},
    {a0,a0,a0,a0,a0,a0,a0},
    {a0,a0,a0,a0,a0,a0,a0},
   },
}

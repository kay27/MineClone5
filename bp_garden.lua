--
-- blueprint for vegetable garden
--
a1 = air
f1 = foundation dirt
f2 = soil
v1 = vegetable wheat
w1 = wall tree
w2 = water

local blueprint_hut_sr = { 
-- foundation
   {
    {f1,f1,f1,f1,f1,f1,f1},
    {f1,f1,f1,f1,f1,f1,f1},
    {f1,f1,f1,f1,f1,f1,f1},
    {f1,f1,f1,f1,f1,f1,f1},
    {f1,f1,f1,f1,f1,f1,f1},
    {f1,f1,f1,f1,f1,f1,f1},
    {f1,f1,f1,f1,f1,f1,f1}
    },
-- layer 1
   {
    {w1,w1,w1,w1,w1,w1,w1},
    {w1,f2,f2,f2,f2,f2,w1},
    {w1,f2,f2,f2,f2,f2,w1},
    {w1,w2,w2,w2,w2,w2,w1},
    {w1,f2,f2,f2,f2,f2,w1},
    {w1,f2,f2,f2,f2,f2,w1},
    {w1,w1,w1,w1,w1,w1,w1}
    },
-- layer 2 crops
   {
    {a1,a1,a1,a1,a1,a1,a1},
    {a1,v1,v1,v1,v1,v1,a1},
    {a1,v1,v1,v1,v1,v1,a1},
    {a1,a1,a1,a1,a1,a1,a1},
    {a1,v1,v1,v1,v1,v1,a1},
    {a1,v1,v1,v1,v1,v1,a1},
    {a1,a1,a1,a1,a1,a1,a1}
    }
}

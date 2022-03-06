-- Register aliases
local doornames = {
	["door_crimson"] = "crimson_door",
	["door_warped"] = "warped_door",
}

for oldname, newname in pairs(doornames) do
	minetest.register_alias("doors:"..oldname, "mclx_doors:"..newname)
	minetest.register_alias("doors:"..oldname.."_t_1", "mclx_doors:"..newname.."_t_1")
	minetest.register_alias("doors:"..oldname.."_b_1", "mclx_doors:"..newname.."_b_1")
	minetest.register_alias("doors:"..oldname.."_t_2", "mclx_doors:"..newname.."_t_2")
	minetest.register_alias("doors:"..oldname.."_b_2", "mclx_doors:"..newname.."_b_2")
end



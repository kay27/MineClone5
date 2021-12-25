minetest.register_on_mods_loaded(function ()
	local light_min = 1
	for name, def in pairs(minetest.registered_nodes) do
		if name ~= "air" then
			local light_source = def.light_source
			if light_source == nil or light_source < light_min then
				minetest.override_item(name, { light_source = light_min })
			elseif light_source == light_min then
				minetest.override_item(name, { light_source = light_min + 1 })
			end
		end
	end
end)

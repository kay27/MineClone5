minetest.register_on_mods_loaded(function ()
	local light_min = 1
	for i, def in pairs(minetest.registered_nodes) do
		local light_source = def.light_source
		if light_source == nil or light_source < light_min then
			minetest.override_item(i, { light_source = light_min })
		end
	end
end)

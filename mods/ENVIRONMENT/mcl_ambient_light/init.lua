local light_min = tonumber(minetest.settings:get("light_min")) or 1

minetest.register_on_mods_loaded(function ()
	for i, def in pairs(minetest.registered_nodes) do
		local light_source = def.light_source
		if light_source == nil or light_source < light_min then
			minetest.override_item(i, { light_source = light_min })
		end
	end
end)

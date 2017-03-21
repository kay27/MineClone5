-- Some global variables (don't overwrite them!)
mcl_vars = {}

--- GUI / inventory menu colors
mcl_vars.gui_slots = "listcolors[#9990;#FFF7;#FFF0;#000;#FFF]"
mcl_vars.gui_bg = "bgcolor[#080808BB;true]"
mcl_vars.gui_bg_img = ""

mcl_vars.inventory_header = mcl_vars.gui_slots .. mcl_vars.gui_bg

-- Mapgen variables
local mg_name = minetest.get_mapgen_setting("mg_name")
local minecraft_height_limit = 256
if mg_name ~= "flat" then
	mcl_vars.mg_overworld_min = -62
	mcl_vars.mg_overworld_max = mcl_vars.mg_overworld_min + minecraft_height_limit

	-- 1 flat bedrock layer with 4 rough layers above
	mcl_vars.mg_bedrock_overworld_min = mcl_vars.mg_overworld_min
	mcl_vars.mg_bedrock_overworld_max = mcl_vars.mg_bedrock_overworld_min + 4
	mcl_vars.mg_bedrock_is_rough = true
else
	local ground = minetest.get_mapgen_setting("mgflat_ground_level")
	if not ground then
		ground = 8
	end
	local layer_setting = minetest.get_mapgen_setting("mcl_superflat_layers")
	local layers
	if layer_setting then
		layers = {}
		local s_version, s_layers, _, _ = string.split(layer_setting, ";", true, 4)
		if tonumber(s_version) == 3 then
			local split_layers = string.split(s_layers, ",")
			if split_layers then
				for s=1, #split_layers do
					local node, repetitions = string.match(split_layers[s], "([0-9a-zA-Z:]+)%*([0-9]+)")
					if not node then
						node = string.match(split_layers[s], "([0-9a-zA-Z:]+)")
						repetitions = 1
					end
					for r=1, repetitions do
						table.insert(layers, node)
					end
				end
			end
		end
	end
	if not layers then
		layers = {
			"mcl_core:bedrock",
			"mcl_core:dirt",
			"mcl_core:dirt",
			"mcl_core:dirt_with_grass",
		}
	end

	mcl_vars.mg_flat_layers = layers

	mcl_vars.mg_overworld_min = ground - #layers + 1
	mcl_vars.mg_overworld_max = mcl_vars.mg_overworld_min + minecraft_height_limit
end

-- Set default stack sizes
minetest.nodedef_default.stack_max = 64
minetest.craftitemdef_default.stack_max = 64

-- Set random seed for all other mods (Remember to make sure no other mod calls this function)
math.randomseed(os.time())



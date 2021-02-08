local S = minetest.get_translator("mcl_minecarts")

mcl_minecarts = {}
mcl_minecarts.modpath = minetest.get_modpath("mcl_minecarts")
mcl_minecarts.speed_max = 10

dofile(mcl_minecarts.modpath.."/functions.lua")
dofile(mcl_minecarts.modpath.."/rails.lua")

local function detach_driver(self)
	if not self._driver then
		return
	end
	if self._driver:is_player() then
		mcl_player.player_attached[self._driver:get_player_name()] = nil
		self._driver:set_detach()
		self._driver:set_eye_offset({x=0, y=0, z=0},{x=0, y=0, z=0})
		mcl_player.player_set_animation(self._driver, "stand" , 30)
	end
	self._driver = nil
	self._start_pos = nil
end

local function activate_tnt_minecart(self, timer)
	if self._boomtimer then
		return
	end
	self.object:set_armor_groups({immortal=1})
	if timer then
		self._boomtimer = timer
	else
		self._boomtimer = tnt.BOOMTIMER
	end
	self.object:set_properties({textures = {
		"mcl_tnt_blink.png",
		"mcl_tnt_blink.png",
		"mcl_tnt_blink.png",
		"mcl_tnt_blink.png",
		"mcl_tnt_blink.png",
		"mcl_tnt_blink.png",
		"mcl_minecarts_minecart.png",
	}})
	self._blinktimer = tnt.BLINKTIMER
	minetest.sound_play("tnt_ignite", {pos = self.object:get_pos(), gain = 1.0, max_hear_distance = 15}, true)
end

local activate_normal_minecart = detach_driver

-- Table for item-to-entity mapping. Keys: itemstring, Values: Corresponding entity ID
local entity_mapping = {}

local function register_entity(entity_id, mesh, textures, drop, on_rightclick, on_activate_by_rail)
	local cart = {
		physical = true,
		collide_with_objects = true,
		pointable = true,

		--collisionbox = {-0.625, -0.5, -0.625, 0.625, 0.25, 0.625},
		collisionbox = {-0.5  , -0.5, -0.5  , 0.5  , 0.25, 0.5  },
		selectionbox = {-0.5  , -0.4, -0.5  , 0.5  , 0.25, 0.5  },
		visual = "mesh",
		mesh = mesh,
		visual_size = {x=1, y=1},
		textures = textures,

		on_rightclick = on_rightclick,

		_driver = nil, -- player (or mob) who sits in and controls the minecart (only for minecart!)
		_punched = false, -- used to re-send _velocity and position
		_velocity = {x=0, y=0, z=0}, -- only used on punch
		_start_pos = nil, -- Used to calculate distance for “On A Rail” achievement
		_last_float_check = nil, -- timestamp of last time the cart was checked to be still on a rail
		_fueltime = nil, -- how many seconds worth of fuel is left. Only used by minecart with furnace
		_boomtimer = nil, -- how many seconds are left before exploding
		_blinktimer = nil, -- how many seconds are left before TNT blinking
		_blink = false, -- is TNT blink texture active?
--		_old_dir = {x=0, y=0, z=0},
--		_old_pos = nil,
--		_old_vel = {x=0, y=0, z=0},
--		_old_yaw = 0,
		_g = -9.8,
	}

	function cart:on_activate(staticdata, dtime_s)
		self.object:set_armor_groups({immortal=1})

		-- Activate cart if on activator rail
		if self.on_activate_by_rail then
			local pos = self.object:get_pos()
			local node = minetest.get_node(vector.floor(pos))
			if node.name == "mcl_minecarts:activator_rail_on" then
				self:on_activate_by_rail()
			end
		end
	end

	function cart:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
		-- Punch: Pick up minecart (unless TNT was ignited)
		if self._boomtimer then return end
		if self._driver then
			detach_driver(self)
		end
		local pos = self.object:get_pos()

		-- Disable detector rail
		local rou_pos = vector.round(pos)
		local node = minetest.get_node(rou_pos)
		if node.name == "mcl_minecarts:detector_rail_on" then
			local newnode = {name="mcl_minecarts:detector_rail", param2 = node.param2}
			minetest.swap_node(rou_pos, newnode)
			mesecon.receptor_off(rou_pos)
		end

		-- Drop items and remove cart entity
		if not minetest.is_creative_enabled(puncher:get_player_name()) then
			for d=1, #drop do
				minetest.add_item(self.object:get_pos(), drop[d])
			end
		elseif puncher and puncher:is_player() then
			local inv = puncher:get_inventory()
			for d=1, #drop do
				if not inv:contains_item("main", drop[d]) then
					inv:add_item("main", drop[d])
				end
			end
		end

		self.object:remove()
		return false
	end

	cart.on_activate_by_rail = on_activate_by_rail

	function cart:on_step(dtime, moveresult)
		local ctrl
		-- player detach
		if self._driver and self._driver:is_player() then
			ctrl = self._driver:get_player_control()
			if ctrl.sneak then
				detach_driver(self)
				return
			end
		end
		-- use collisions to accelerate carts or place mobs
		local fp = self.object:get_pos()
		local pos = vector.round(fp)
		local push = false
		for _,object in pairs(minetest.get_objects_inside_radius(fp, 1.3)) do
			if object ~= self.object then
				local mob = object:get_luaentity()
				if mob then mob = mob._cmi_is_mob == true end
				if mob and (not self._driver) and not object:get_attach() then
					self._driver = object
					object:set_attach(self.object, "", {x=0, y=-1.75, z=-2}, {x=0, y=0, z=0})
					mobs:set_animation(self.object, "sit")
					return
				end
				if object ~= self._driver then
					local op = object:get_pos()
					local vec = vector.subtract(fp, op)
					local force = 1.8 - vector.distance(fp, op)
					self.object:set_acceleration(vector.add(self.object:get_acceleration(), vector.multiply(vec, force)))
					push = true
				end
			end
		end
		-- check rails presence
		local nn = mcl_minecarts:get_node_name(pos)
		local v = self.object:get_velocity()
		local rails = (minetest.get_item_group(nn, "rail") > 0) or (nn == "air" and minetest.get_item_group(mcl_minecarts:get_node_name({x=pos.x,y=pos.y-1,z=pos.z}), "rail") > 0)
		if rails then -------- ON RAILS --------
			if ctrl then minetest.chat_send_all("rails! "..nn) end --TODO REMOVE ME
			local cd = mcl_minecarts:velocity_to_dir(v)
			local rd = mcl_minecarts:get_rail_direction(pos, cd, ctrl)
			if rd.x ~= cd.x or rd.y ~= cd.y or rd.z ~= cd.z then
				-- direction should be changed instantly:
				local vmax = math.max(math.abs(v.x), math.abs(v.z))
				if vmax > 0 then
					v = vector.multiply(rd, vmax)
					self.object:set_velocity(v)
				end
				if ctrl then minetest.chat_send_all("dir change: "..minetest.pos_to_string(rd)) end --TODO REMOVE ME
				if v.y == 0 then
					self._g = -9.8
				else
					local a = self.object:get_acceleration()
					a.y = v.y
					self.object:set_acceleration(a)
					self._g = 0
				end
			end
			-- derail prevention:
			if rd.z == 0 and rd.x ~= 0 then
				if v.z ~= 0 then
					v.z = 0
					self.object:set_velocity(v)
				end
				if fp.z ~= pos.z then
					self.object:set_pos({x=fp.x, y=fp.y, z = pos.z})
				end
			end
			if rd.x == 0 and rd.z ~= 0 then
				if v.x ~= 0 then
					v.x = 0
					self.object:set_velocity(v)
				end
				if fp.x ~= pos.x then
					self.object:set_pos({x=pos.x, y=fp.y, z = fp.z})
				end
			end
			if not push then 
				self.object:set_acceleration({x=-v.x/4,y=self._g,z=-v.z/4})
			end

			local old_yaw, new_yaw = self.object:get_yaw(), minetest.dir_to_yaw(v)
			if old_yaw < new_yaw then
				while new_yaw - old_yaw > 3.14 do
					new_yaw = new_yaw - 3.14
				end
			else
				while old_yaw - new_yaw > 3.14 do
					new_yaw = new_yaw + 3.14
				end
			end
			if old_yaw - new_yaw > 0.1 or new_yaw - old_yaw > 1.58 then
				self.object:set_yaw(old_yaw - 0.1*(math.abs(v.x)+math.abs(v.z)+0.1))
			elseif new_yaw - old_yaw > 0.1 or old_yaw - new_yaw > 1.58  then
				self.object:set_yaw(old_yaw + 0.1*(math.abs(v.x)+math.abs(v.z)+0.1))
			end
			--[[ 360 is too mach for carts, 180 needed instead
			local old_yaw, new_yaw = self.object:get_yaw(), minetest.dir_to_yaw(v)
			local dy = math.abs(old_yaw - new_yaw)
			if dy < 0.16 or dy > 6.12 then
				self.object:set_yaw(new_yaw)
			elseif ((old_yaw > new_yaw) and (dy < 3.15)) or (old_yaw < -1.57 and new_yaw > 1.57) then
				self.object:set_yaw(old_yaw - 0.1*(math.abs(v.x)+math.abs(v.z)+0.1))
			else
				self.object:set_yaw(old_yaw + 0.1*(math.abs(v.x)+math.abs(v.z)+0.1))
			end
			]]
			-- self.object:set_yaw((self.object:get_yaw()*7 + minetest.dir_to_yaw(v))/8)

			if ctrl and self._driver then
				--minetest.chat_send_all(tostring(old_yaw) .. " --- " .. tostring(new_yaw)) --TODO REMOVE ME
				if ctrl.right then
					self.object:set_acceleration(vector.add(self.object:get_acceleration(), vector.multiply(minetest.yaw_to_dir(self._driver:get_look_horizontal()-1.57), 2)))
				end
				if ctrl.left then
					self.object:set_acceleration(vector.add(self.object:get_acceleration(), vector.multiply(minetest.yaw_to_dir(self._driver:get_look_horizontal()+1.57), 2)))
				end
				if ctrl.up then
					self.object:set_acceleration(vector.add(self.object:get_acceleration(), vector.multiply(self._driver:get_look_dir(), 2)))
				end
				if ctrl.down then
					self.object:set_acceleration(vector.subtract(self.object:get_acceleration(), vector.multiply(self._driver:get_look_dir(), 2)))
				end
			end

		else
			if fp.y ~= pos.y and nn ~= "air" then
				self.object:set_pos({x=fp.x, y=pos.y, z = fp.z})
			end
			if not push then 
				self.object:set_acceleration({x=-v.x*2,y=-9.8,z=-v.z*2})
			end
		end
	end

	minetest.register_entity(entity_id, cart)
end

-- Place a minecart at pointed_thing
mcl_minecarts.place_minecart = function(itemstack, pointed_thing, placer)
	if not pointed_thing.type == "node" then
		return
	end

	local railpos, node
	if mcl_minecarts:is_rail(pointed_thing.under) then
		railpos = pointed_thing.under
		node = minetest.get_node(pointed_thing.under)
	elseif mcl_minecarts:is_rail(pointed_thing.above) then
		railpos = pointed_thing.above
		node = minetest.get_node(pointed_thing.above)
	else
		return
	end

	-- Activate detector rail
	if node.name == "mcl_minecarts:detector_rail" then
		local newnode = {name="mcl_minecarts:detector_rail_on", param2 = node.param2}
		minetest.swap_node(railpos, newnode)
		mesecon.receptor_on(railpos)
	end

	local entity_id = entity_mapping[itemstack:get_name()]
	local cart = minetest.add_entity(railpos, entity_id)
	local cart_dir = mcl_minecarts:get_rail_direction(railpos, {x=1, y=0, z=0}, nil, nil)
	cart:set_yaw(minetest.dir_to_yaw(cart_dir))

	local pname = ""
	if placer then
		pname = placer:get_player_name()
	end
	if not minetest.is_creative_enabled(pname) then
		itemstack:take_item()
	end
	return itemstack
end


local register_craftitem = function(itemstring, entity_id, description, tt_help, longdesc, usagehelp, icon, creative)
	entity_mapping[itemstring] = entity_id

	local groups = { minecart = 1, transport = 1 }
	if creative == false then
		groups.not_in_creative_inventory = 1
	end
	local def = {
		stack_max = 1,
		on_place = function(itemstack, placer, pointed_thing)
			if not pointed_thing.type == "node" then
				return
			end

			-- Call on_rightclick if the pointed node defines it
			local node = minetest.get_node(pointed_thing.under)
			if placer and not placer:get_player_control().sneak then
				if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
					return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
				end
			end

			return mcl_minecarts.place_minecart(itemstack, pointed_thing, placer)
		end,
		_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
			-- Place minecart as entity on rail. If there's no rail, just drop it.
			local placed
			if minetest.get_item_group(dropnode.name, "rail") ~= 0 then
				-- FIXME: This places minecarts even if the spot is already occupied
				local pointed_thing = { under = droppos, above = { x=droppos.x, y=droppos.y+1, z=droppos.z } }
				placed = mcl_minecarts.place_minecart(stack, pointed_thing)
			end
			if placed == nil then
				-- Drop item
				minetest.add_item(droppos, stack)
			end
		end,
		groups = groups,
	}
	def.description = description
	def._tt_help = tt_help
	def._doc_items_longdesc = longdesc
	def._doc_items_usagehelp = usagehelp
	def.inventory_image = icon
	def.wield_image = icon
	minetest.register_craftitem(itemstring, def)
end

--[[
Register a minecart
* itemstring: Itemstring of minecart item
* entity_id: ID of minecart entity
* description: Item name / description
* longdesc: Long help text
* usagehelp: Usage help text
* mesh: Minecart mesh
* textures: Minecart textures table
* icon: Item icon
* drop: Dropped items after destroying minecart
* on_rightclick: Called after rightclick
* on_activate_by_rail: Called when above activator rail
* creative: If false, don't show in Creative Inventory
]]
local function register_minecart(itemstring, entity_id, description, tt_help, longdesc, usagehelp, mesh, textures, icon, drop, on_rightclick, on_activate_by_rail, creative)
	register_entity(entity_id, mesh, textures, drop, on_rightclick, on_activate_by_rail)
	register_craftitem(itemstring, entity_id, description, tt_help, longdesc, usagehelp, icon, creative)
	if minetest.get_modpath("doc_identifier") ~= nil then
		doc.sub.identifier.register_object(entity_id, "craftitems", itemstring)
	end
end

register_minecart(	-- Minecart --
--[[itemstring]]		"mcl_minecarts:minecart",
--[[entity_id]]			"mcl_minecarts:minecart",
--[[description]]		S("Minecart"),
--[[tt_help]]			S("Vehicle for fast travel on rails"),
--[[longdesc]]			S("Minecarts can be used for a quick transportion on rails.") .. "\n" ..
				S("Minecarts only ride on rails and always follow the tracks. At a T-junction with no straight way ahead, they turn left. The speed is affected by the rail type."),
--[[usagehelp]]			S("You can place the minecart on rails. Right-click it to enter it. Punch it to get it moving.") .. "\n" ..
				S("To obtain the minecart, punch it while holding down the sneak key.") .. "\n" ..
				S("If it moves over a powered activator rail, you'll get ejected."),
--[[mesh]]			"mcl_minecarts_minecart.b3d",
--[[textures]]			{"mcl_minecarts_minecart.png"},
--[[icon]]				"mcl_minecarts_minecart_normal.png",
--[[drop]]				{"mcl_minecarts:minecart"},
--[[on_rightclick]]			function(self, clicker)
						if not clicker or not clicker:is_player() then return end
						if clicker == self._driver then
							detach_driver(self)
						else
							local name = clicker:get_player_name()
							self._driver = clicker
							self._start_pos = self.object:get_pos()
							mcl_player.player_attached[name] = true
							clicker:set_attach(self.object, "", {x=0, y=-1.75, z=-2}, {x=0, y=0, z=0})
							mcl_player.player_attached[name] = true
							minetest.after(0.2, function(name)
								local player = minetest.get_player_by_name(name)
								if player then
									mcl_player.player_set_animation(player, "sit" , 30)
									player:set_eye_offset({x=0, y=-5.5, z=0},{x=0, y=-4, z=0})
									mcl_tmp_message.message(clicker, S("Sneak to dismount"))
								end
							end, name)
							clicker:set_look_horizontal(self.object:get_yaw())
						end
					end,
--[[on_activate_by_rail]]	activate_normal_minecart,
--[[creative]]			true
)

register_minecart(	-- Minecart with Chest --
--[[itemstring]]		"mcl_minecarts:chest_minecart",	
--[[entity_id]]			"mcl_minecarts:chest_minecart",
--[[description]]		S("Minecart with Chest"),
--[[tt_help]]			S("Minecart with a chest inside it"),
--[[longdesc]]			S("A minecart with furnace is a vehicle that travels on rails. It can propel itself with fuel."),
--[[usagehelp]]			S("Place it on rails. Access chest content by pressing [Usage] on it. The boost is dependent on the load."),
--[[mesh]]			"mcl_minecarts_minecart_chest.b3d",
--[[textures]]			{ "mcl_chests_normal.png", "mcl_minecarts_minecart.png" },
--[[icon]]			"mcl_minecarts_minecart_chest.png",
--[[drop]]			{"mcl_minecarts:minecart", "mcl_chests:chest"},
--[[on_rightclick]]		nil,
--[[on_activate_by_rail]]	nil,
--[[creative]]			true
)

register_minecart(	-- Minecart with Furnace --
--[[itemstring]]		"mcl_minecarts:furnace_minecart",
--[[entity_id]]			"mcl_minecarts:furnace_minecart",
--[[description]]		S("Minecart with Furnace"),
--[[tt_help]]			S("Minecart with a furnace inside it"),
--[[longdesc]]			S("A minecart with furnace is a vehicle that travels on rails. It can propel itself with fuel."),
--[[usagehelp]]			S("Place it on rails. If you give it some coal, the furnace will start burning for a long time and the minecart will be able to move itself. Punch it to get it moving.") .. "\n" ..
				S("To obtain the minecart and furnace, punch them while holding down the sneak key."),
--[[mesh]]			"mcl_minecarts_minecart_block.b3d",
--[[textures]]			       {
					"default_furnace_top.png",
					"default_furnace_top.png",
					"default_furnace_front.png",
					"default_furnace_side.png",
					"default_furnace_side.png",
					"default_furnace_side.png",
					"mcl_minecarts_minecart.png",
				},
--[[icon]]			"mcl_minecarts_minecart_furnace.png",
--[[drop]]			{"mcl_minecarts:furnace_minecart"},
--[[on_rightclick]]		-- Feed furnace with coal
				function(self, clicker)
					if not clicker or not clicker:is_player() then
						return
					end
					if not self._fueltime then
						self._fueltime = 0
					end
					local held = clicker:get_wielded_item()
					if minetest.get_item_group(held:get_name(), "coal") == 1 then
						self._fueltime = self._fueltime + 180
						if not minetest.is_creative_enabled(clicker:get_player_name()) then
							held:take_item()
							local index = clicker:get_wield_index()
							local inv = clicker:get_inventory()
							inv:set_stack("main", index, held)
						end
						self.object:set_properties({textures =
						{
							"default_furnace_top.png",
							"default_furnace_top.png",
							"default_furnace_front_active.png",
							"default_furnace_side.png",
							"default_furnace_side.png",
							"default_furnace_side.png",
							"mcl_minecarts_minecart.png",
						}})
					end
				end,
--[[on_activate_by_rail]]	nil,
--[[creative]]			true
)

register_minecart(	-- Minecart with Command Block --
--[[itemstring]]		"mcl_minecarts:command_block_minecart",
--[[entity_id]]			"mcl_minecarts:command_block_minecart",
--[[description]]		S("Minecart with Command Block"),
--[[tt_help]]			nil,
--[[longdesc]]			nil,
--[[usagehelp]]			nil,
--[[mesh]]			"mcl_minecarts_minecart_block.b3d",
--[[textures]]			{
					"jeija_commandblock_off.png^[verticalframe:2:0",
					"jeija_commandblock_off.png^[verticalframe:2:0",
					"jeija_commandblock_off.png^[verticalframe:2:0",
					"jeija_commandblock_off.png^[verticalframe:2:0",
					"jeija_commandblock_off.png^[verticalframe:2:0",
					"jeija_commandblock_off.png^[verticalframe:2:0",
					"mcl_minecarts_minecart.png",
				},
--[[icon]]			"mcl_minecarts_minecart_command_block.png",
--[[drop]]			{"mcl_minecarts:command_block_minecart"},
--[[on_rightclick]]		nil,
--[[on_activate_by_rail]]	nil,
--[[creative]]			true
)

register_minecart(	-- Minecart with Hopper --
--[[itemstring]]		"mcl_minecarts:hopper_minecart",
--[[entity_id]]			"mcl_minecarts:hopper_minecart",
--[[description]]		S("Minecart with Hopper"),
--[[tt_help]]			nil,
--[[longdesc]]			nil,
--[[usagehelp]]			nil,
--[[mesh]]			"mcl_minecarts_minecart_hopper.b3d",
--[[textures]]			{
					"mcl_hoppers_hopper_inside.png",
					"mcl_minecarts_minecart.png",
					"mcl_hoppers_hopper_outside.png",
					"mcl_hoppers_hopper_top.png",
				},
--[[icon]]			"mcl_minecarts_minecart_hopper.png",
--[[drop]]			{"mcl_minecarts:minecart", "mcl_hoppers:hopper"},
--[[on_rightclick]]		nil,
--[[on_activate_by_rail]]	nil,
--[[creative]]			true
)

register_minecart(	-- Minecart with TNT --
--[[itemstring]]		"mcl_minecarts:tnt_minecart",
--[[entity_id]]			"mcl_minecarts:tnt_minecart",
--[[description]]		S("Minecart with TNT"),
--[[tt_help]]			S("Vehicle for fast travel on rails").."\n"..S("Can be ignited by tools or powered activator rail"),
--[[longdesc]]			S("A minecart with TNT is an explosive vehicle that travels on rail."),
--[[usagehelp]]			S("Place it on rails. Punch it to move it. The TNT is ignited with a flint and steel or when the minecart is on an powered activator rail.") .. "\n" ..
				S("To obtain the minecart and TNT, punch them while holding down the sneak key. You can't do this if the TNT was ignited."),
--[[mesh]]			"mcl_minecarts_minecart_block.b3d",
--[[textures]]			{
					"default_tnt_top.png",
					"default_tnt_bottom.png",
					"default_tnt_side.png",
					"default_tnt_side.png",
					"default_tnt_side.png",
					"default_tnt_side.png",
					"mcl_minecarts_minecart.png",
				},
--[[icon]]			"mcl_minecarts_minecart_tnt.png",
--[[drop]]			{"mcl_minecarts:minecart", "mcl_tnt:tnt"},
--[[on_rightclick]]		-- Ingite
				function(self, clicker)
					if not clicker or not clicker:is_player() or self._boomtimer then return end
					local held = clicker:get_wielded_item()
					if held:get_name() == "mcl_fire:flint_and_steel" then
						if not minetest.is_creative_enabled(clicker:get_player_name()) then
							held:add_wear(65535/65) -- 65 uses
							local index = clicker:get_wield_index()
							local inv = clicker:get_inventory()
							inv:set_stack("main", index, held)
						end
						activate_tnt_minecart(self)
					end
				end,
--[[on_activate_by_rail]]	activate_tnt_minecart,
--[[creative]]			true
)


minetest.register_craft({
	output = "mcl_minecarts:minecart",
	recipe = {
		{"mcl_core:iron_ingot", "", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot"},
	},
})

minetest.register_craft({
	output = "mcl_minecarts:tnt_minecart",
	recipe = {
		{"mcl_tnt:tnt"},
		{"mcl_minecarts:minecart"},
	},
})

-- TODO: Re-enable crafting of special minecarts when they have been implemented
if false then

minetest.register_craft({
	output = "mcl_minecarts:furnace_minecart",
	recipe = {
		{"mcl_furnaces:furnace"},
		{"mcl_minecarts:minecart"},
	},
})

minetest.register_craft({
	output = "mcl_minecarts:hopper_minecart",
	recipe = {
		{"mcl_hoppers:hopper"},
		{"mcl_minecarts:minecart"},
	},
})

minetest.register_craft({
	output = "mcl_minecarts:chest_minecart",
	recipe = {
		{"mcl_chests:chest"},
		{"mcl_minecarts:minecart"},
	},
})

end

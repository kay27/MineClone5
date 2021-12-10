mcl_bubble_column = {}

minetest.register_abm{
	label = "bubbleColumnUpStop",
	nodenames = {"group:water"},
	interval = 0.05,
	chance = 1,
	action = function(pos)
        local meta = minetest.get_meta(pos)
        if meta:get_int("bubbly") == 1 then--bubble column
        	--check down if current needs to be deleted
        	local downpos = vector.add(pos, {x = 0, y = -1, z = 0})
			local downposnode = minetest.get_node(downpos)
			local downmeta = minetest.get_meta(downpos)
			if (downmeta:get_int("bubbly") ~= 1 and downposnode.name ~= "mcl_nether:soul_sand") then
				meta:set_int("bubbly", 0)
			end
        	--check up to see if needs to go up
        	local uppos = vector.add(pos, {x = 0, y = 1, z = 0})
        	local upposnode = minetest.get_node(uppos)
        	local upmeta = minetest.get_meta(uppos)
			if (minetest.get_item_group(upposnode.name, "water") == 3 and upmeta:get_int("bubbly") ~= 1) then
        	    upmeta:set_int("bubbly", 1)
			end
		elseif meta:get_int("whirly") == 1 then--whirlpool
        	--check down if current needs to be deleted
        	local downpos = vector.add(pos, {x = 0, y = -1, z = 0})
			local downposnode = minetest.get_node(downpos)
			local downmeta = minetest.get_meta(downpos)
			if (downmeta:get_int("whirly") ~= 1 and downposnode.name ~= "mcl_nether:magma") then
				meta:set_int("whirly", 0)
			end
        	--check up to see if needs to go up
        	local uppos = vector.add(pos, {x = 0, y = 1, z = 0})
        	local upposnode = minetest.get_node(uppos)
        	local upmeta = minetest.get_meta(uppos)
			if (minetest.get_item_group(upposnode.name, "water") == 3 and upmeta:get_int("whirly") ~= 1) then
        	    upmeta:set_int("whirly", 1)
			end
		end
	end,
}

minetest.register_abm{
    label = "startBubbleColumn",
    nodenames = {"mcl_nether:soul_sand"},
    interval = 0.05,
    chance = 1,
    action = function(pos)
        local uppos = vector.add(pos, {x = 0, y = 1, z = 0})
        local upposnode = minetest.get_node(uppos)
        local upmeta = minetest.get_meta(uppos)
        if (minetest.get_item_group(upposnode.name, "water") == 3 and upmeta:get_int("bubbly") ~= 1) then
            upmeta:set_int("bubbly", 1)
        end
    end,
}

minetest.register_abm{
    label = "startWhirlpool",
    nodenames = {"mcl_nether:magma"},
    interval = 0.05,
    chance = 1,
    action = function(pos)
        local uppos = vector.add(pos, {x = 0, y = 1, z = 0})
        local upposnode = minetest.get_node(uppos)
        local upmeta = minetest.get_meta(uppos)
        if (minetest.get_item_group(upposnode.name, "water") == 3 and upmeta:get_int("whirly") ~= 1) then
            upmeta:set_int("whirly", 1)
        end
    end,
}


mcl_bubble_column.on_enter_bubble_column = function(self)
	local velocity = self:get_velocity()
	--[[if down.name == "mcl_nether:soul_sand" then
		self:add_velocity({x = 0, y = math.min(10, math.abs(velocity.y)+9.4), z = 0})
	else]]
	self:add_velocity({x = 0, y = math.min(3.6, math.abs(velocity.y)+3), z = 0})
	--end
end

mcl_bubble_column.on_enter_whirlpool = function(self)
	local velocity = self:get_velocity()
	--self:add_velocity({x = 0, y = math.max(-3, (-math.abs(velocity.y))-2), z = 0})
	self:add_velocity({x = 0, y = math.max(-0.3, (-math.abs(velocity.y))-0.03), z = 0})
end

mcl_bubble_column.on_enter_bubble_column_with_air_above = function(self)
	local velocity = self:get_velocity()
	--[[if down.name == "mcl_nether:soul_sand" then
		self:add_velocity({x = 0, y = math.min(4.3, math.abs(velocity.y)+2.8), z = 0})
	else]]
	self:add_velocity({x = 0, y = math.min(2.6, math.abs(velocity.y)+2), z = 0})
	--end
end

mcl_bubble_column.on_enter_whirlpool_with_air_above = function(self)
	local velocity = self:get_velocity()
	--self:add_velocity({x = 0, y = math.max(-3.5, (-math.abs(velocity.y))-2), z = 0})
	self:add_velocity({x = 0, y = math.max(-0.9, (-math.abs(velocity.y))-0.03), z = 0})
end

minetest.register_abm{
	label = "entGo",
	nodenames = {"group:water"},
	interval = 0.05,
	chance = 1,
	action = function(pos)
		--if not bubble column block return
		local meta = minetest.get_meta(pos)
		if meta:get_int("bubbly") == 1 then
			local up = minetest.get_node(vector.add(pos, {x = 0, y = 1, z = 0}))
			for _,entity in pairs(minetest.get_objects_inside_radius(pos, 0.75)) do
				if up.name == "air" then
					mcl_bubble_column.on_enter_bubble_column_with_air_above(entity)
				else
					mcl_bubble_column.on_enter_bubble_column(entity)
				end
			end
		elseif meta:get_int("whirly") == 1 then
			local up = minetest.get_node(vector.add(pos, {x = 0, y = 1, z = 0}))
			for _,entity in pairs(minetest.get_objects_inside_radius(pos, 0.75)) do
				if up.name == "air" then
					mcl_bubble_column.on_enter_whirlpool_with_air_above(entity)
				else
					mcl_bubble_column.on_enter_whirlpool(entity)
				end
			end
		end
	end,
}

minetest.register_globalstep(function()
    for _,player in ipairs(minetest.get_connected_players()) do
		local ppos = player:get_pos()
		local eyepos = {x = ppos.x, y = ppos.y + player:get_properties().eye_height, z = ppos.z}
		local node = minetest.get_node(ppos)
		local eyenode = minetest.get_node(eyepos)
		local meta = minetest.get_meta(ppos)
		local eyemeta = minetest.get_meta(eyepos)
		
		local eyemeta = minetest.get_meta(ppos)
		--if minetest.get_item_group(node.name, "water") == 3 and minetest.get_item_group(eyenode.name, "water") == 3 then return end
		if meta:get_int("bubbly") == 1 or eyemeta:get_int("bubbly") == 1 then
			local up = minetest.get_node(vector.add(eyepos, {x = 0, y = 1, z = 0}))
			if up.name == "air" then
				mcl_bubble_column.on_enter_bubble_column_with_air_above(player)
			else
				mcl_bubble_column.on_enter_bubble_column(player)
			end
		elseif meta:get_int("whirly") == 1 or eyemeta:get_int("whirly") == 1 then
			local up = minetest.get_node(vector.add(ppos, {x = 0, y = 1, z = 0}))
			if up.name == "air" then
				mcl_bubble_column.on_enter_whirlpool_with_air_above(player)
			else
				mcl_bubble_column.on_enter_whirlpool(player)
			end
		end
	end
end)

--abms to remove and replace old bubble columns/whirlpools
minetest.register_abm{
    label = "removeOldFlowingColumns",
    nodenames = {"mcl_bubble_column:water_flowing_up", "mcl_bubble_column:water_flowing_down"},
    interval = 1,--reduce lag
    chance = 1,
    action = function(pos)
        minetest.set_node(pos, {name = "air"})
    end,
}
minetest.register_abm{
    label = "replaceBubbleColumns",
    nodenames = {"mcl_bubble_column:water_source_up"},
    interval = 1,--reduce lag
    chance = 1,
    action = function(pos)
        minetest.set_node(pos, {name = "mcl_core:water_source"})
		local meta = minetest.get_meta(pos)
		meta:set_int("bubbly", 1)
    end,
}
minetest.register_abm{
	label = "replaceWhirlpools",
	nodenames = {"mcl_bubble_column:water_source_down"},
	interval = 1,--reduce lag
	chance = 1,
	action = function(pos)
		minetest.set_node(pos, {name = "mcl_core:water_source"})
		local meta = minetest.get_meta(pos)
		meta:set_int("whirly", 1)
	end,
}
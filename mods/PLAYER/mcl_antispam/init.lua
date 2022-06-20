local ban_spammers = true
local kick_spammers = true
local revoke_shout_for_spammers = true
local limit_messages = 10
local limit_message_length = 200
local block_special_chars = true
local enable_antispam = ban_spammers or kick_spammers or revoke_shout_for_spammers

local function update_settings()
	ban_spammers = minetest.settings:get_bool("ban_spammers", true)
	kick_spammers = minetest.settings:get_bool("kick_spammers", true)
	revoke_shout_for_spammers = minetest.settings:get_bool("revoke_shout_for_spammers", true)
	limit_messages = tonumber(minetest.settings:get("limit_messages") or 10)
	limit_message_length = tonumber(minetest.settings:get("limit_message_length") or 200)
	block_special_chars = minetest.settings:get_bool("block_special_chars", true)
	enable_antispam = ban_spammers or kick_spammers or revoke_shout_for_spammers
	minetest.after(7, update_settings)
end
update_settings()

local last_messages = {}
local exceeders = {}
local special_users = {}

local function ban(name)
	if revoke_shout_for_spammers then
		local privs = minetest.get_player_privs(name)
		if privs then
			privs.shout = nil
			minetest.set_player_privs(name, privs)
		end
	end
	if ban_spammers then
		minetest.ban_player(name)
	elseif kick_spammers then
		minetest.kick_player(name)
	end
end

local last_char = string.char(127)

local function on_chat_message(name, message)
	if not enable_antispam then return end
	local length = message:len()
	if last_messages.job then
		last_messages.job:cancel()
		last_messages.job = nil
	end
	if last_messages.name and last_messages.name == name then
		last_messages.count = last_messages.count + 1
		last_messages.summary_length = last_messages.summary_length + length
		if last_messages.count >= limit_messages then
			ban(name)
		end
	else
		last_messages.name = name
		last_messages.count = 1
		last_messages.summary_length = length
	end
	last_messages.job = minetest.after(30, function()
		last_messages.name = nil
		last_messages.job = nil
	end)
	if limit_message_length > 0 and message:len() > limit_message_length then
		if exceeders[name] then
			exceeders[name] = exceeders[name] + 1
			if exceeders[name] > limit_messages then
				ban(name)
			end
		else
			exceeders[name] = 1
		end
		message = message:sub(1, limit_message_length) .. ">8 >8 >8"
		minetest.chat_send_all("<" .. name .. "> " .. message)
		return true
	else
		if exceeders[name] then
			exceeders[name] = nil
		end
	end
	if block_special_chars then
		local sc = false
		local msg = ""
		for i = 1, #message do
			local c = message:sub(i,i)
			if c >= " " and c <= last_char then
				msg = msg .. c
			else
				sc = true
			end
		end
		if sc then
			if special_users[name] then
				special_users[name] = special_users[name] + 1
				if special_users[name] > limit_messages then
					ban(name)
				end
			else
				special_users[name] = 1
			end
			message = msg
			minetest.chat_send_all("<" .. name .. "> " .. message)
			return true
		else
			if special_users[name] then
				special_users[name] = nil
			end
		end
	end
end

minetest.register_on_chat_message(on_chat_message)

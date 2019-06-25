rpconfig = require("custom/rpchat/config")
rpdata = require("custom/rpchat/data")
local users = {}
local rpchat = {}
	
	function rpchat.loginHandler(eventStatus, pid)
		rpchat.initPlayer(pid)
	end
	
	function rpchat.disconnectHandler(eventStatus, pid)
		for index, value in pairs(users) do
			if users[index].pid == pid then
				table.remove(users, index)
				rpchat.log("PID " .. pid .. " REMOVED FROM USERS." ,"debug")
			end
		end
	end
	
	function rpchat.format(message)
		message = message:gsub("^%l", string.upper)
		local stringLength = string.len(message)
		local punctuated = string.find(message, ".", stringLength, stringLength)
		if punctuated == nil then
			message = message .. "."
		end
		return message
	end
	
	function rpchat.formatP(message)
		local punctuated = string.find(message, ".", stringLength, stringLength)
		if punctuated == nil then
			message = message .. "."
		end
		return message
	end

	function rpchat.load()
		rpchat.initData()
		rpchat.log("RP-CHAT has been loaded successfully.")
	end
	
	function rpchat.initData()
		local names = rpdata.load()
		if names == nil then
			rpchat.log("DATA JSON MISSING, REBUILDING.", "notice")
			-- explitive used as it would be caught by the filter and cannot be a player name
			-- I also may have been slightly annoyed but this is currently unverifiable
			names = {{name = "fuck", color = "null", rpname = "null"}}
			rpdata.save(names)
		end
	end
	
	function rpchat.correctName(playerName)
		playerName = playerName:gsub("^%l", string.upper)
		rpchat.log("Name " .. playerName .. " corrected.", "debug")
		return playerName
	end
	
	function rpchat.initPlayer(pid)
		local names = rpdata.load()
		local hasName = false
		local playerName = Players[pid].name
		for index, value in pairs(names)do
			if tostring(names[index].name) == playerName then
				if hasName == false then
					rpchat.log("Loading RPData for " .. playerName)
					local pData = {
						name = playerName,
						color = names[index].color,
						rpname = names[index].rpname,
						nPid = pid
					}
					table.insert(users, pData)
					rpchat.log("PID " .. pid .. " ADDED TO USERS." ,"debug")
					hasName = true
				else
					rpchat.log("Player " .. playerName .. " has multiple names registered to them in rpnames.", "warning")
				end
			end
		end
		if hasName == false then
			rpchat.log("Creating RPData for player " .. playerName)
			rpchat.addPlayer(playerName, pid)
		end
	end
	
	function rpchat.addPlayer(playerName, pid)
		local pData = {
			name = playerName,
			color = color.White,
			rpname = rpchat.correctName(playerName)
		}
		local names = rpdata.load()
		table.insert(names, pData)
		local upData = {
			name = playerName,
			color = color.White,
			rpname = rpchat.correctName(playerName),
			nPid = pid
		}
		table.insert(users, upData)
		rpchat.log("PID " .. pid .. " ADDED TO USERS." ,"debug")
		rpdata.save(names)
	end
	
	function rpchat.messageCatch(event, pid, message)
		if message:sub(1,1) ~= "/" then
			rpchat.messageHandler(pid, message)
			return customEventHooks.makeEventStatus(false, nil)
		end 
	end
	
	function rpchat.ooc(pid, cmd)
		local message = ""
		if cmd[2] ~= nil then
			for index, value in pairs(cmd) do
				if index > 1 and index <= 2 then
					message = message .. tostring(value)
				elseif index > 2 then
					message = message .. " " .. tostring(value)
				end
			end
			rpchat.messageHandler(pid, message, "ooc")
		else
			tes3mp.SendMessage(pid, "[RP-CHAT]: That's not a valid message.\n", false)
		end
	end
	
	function rpchat.looc(pid, cmd)
		local message = ""
		if cmd[2] ~= nil then
			for index, value in pairs(cmd) do
				if index > 1 and index <= 2 then
					message = message .. tostring(value)
				elseif index > 2 then
					message = message .. " " .. tostring(value)
				end
			end
			rpchat.messageHandler(pid, message, "looc")
		else
			tes3mp.SendMessage(pid, "[RP-CHAT]: That's not a valid message.\n", false)
		end
	end
	
	function rpchat.emote(pid, cmd)
		local message = ""
		if cmd[2] ~= nil then
			for index, value in pairs(cmd) do
				if index > 1 and index <= 2 then
					message = message .. tostring(value)
				elseif index > 2 then
					message = message .. " " .. tostring(value)
				end
			end
			rpchat.messageHandler(pid, message, "emote")
		else
			tes3mp.SendMessage(pid, "[RP-CHAT]: That's not a valid message.\n", false)
		end
	end
	
	function rpchat.getName(pid)
		local name = Players[pid].name
		for index, value in pairs(users) do
			if users[index].name == name then
				return users[index].rpname
			end
		end
	end
	
	function rpchat.verifyColor(colorString)
		if string.len(colorString) == 6 then
			if tonumber(colorString, 16) then
				return true
			else
				return false
			end
		else
			return false
		end
	end
	
	function rpchat.setColor(pid, newColor, originPID)
		if rpchat.verifyColor(newColor) then
			local name = Players[pid].name
			newColor = "#" .. newColor
			for index, value in pairs(users) do
				if users[index].name == name then
					users[index].color = newColor
					rpchat.log("COLOR FOR " .. name .. " CHANGED TO " .. newColor,"debug")
				end
			end
			local names = rpdata.load()
			for index, value in pairs(names) do
				if names[index].name == name then
					names[index].color = newColor
					rpdata.save(names)
					rpchat.log("COLOR FOR " .. name .. " CHANGED TO " .. newColor,"debug")
				end
			end
		else
			rpchat.systemMessage(originPID, "Invalid color, please use hex color codes.")
		end
	end
	
	function rpchat.setName(pid, newName, originPID)
		local name = Players[pid].name
		local targetUserData
		for index, value in pairs(users) do
			if users[index].name == name then
				users[index].rpname = newName
			end
		end
		local names = rpdata.load()
		for index, value in pairs(names) do
			if names[index].name == name then
				names[index].rpname = newName
				rpdata.save(names)
			end
		end
		rpchat.systemMessage(originPID, "RP name for PID " .. pid .. " changed to " .. newName)
	end
	
	function rpchat.getcolor(pid)
		local name = Players[pid].name
		for index, value in pairs(users) do
			if users[index].name == name then
				return users[index].color
			end
		end
	end
	
	function rpchat.messageHandler(pid, message, messageType)
		local name = rpchat.getName(pid)
		local pColor = rpchat.getcolor(pid)
		if pColor == nil then
			pColor = color.White
		end
		rpchat.log("PLAYER COLOR IS " .. pColor, "debug")
		if messageType == "ooc" then
			message = rpconfig.colors.ooc  .. "[OOC] " .. pColor .. Players[pid].name .. color.White .. ": " .. rpchat.format(message) .. "\n"
			tes3mp.SendMessage(pid, message, true)
		elseif messageType == "looc" then
			message = rpconfig.colors.looc .. "[LOOC] " .. pColor .. Players[pid].name .. color.White .. ": " .. rpchat.format(message) .. "\n"
			rpchat.localMessage(pid, message)
		elseif messageType == "emote" then
			message = pColor .. name .. rpconfig.colors.emote .. " " .. rpchat.formatP(message) .. "\n"
			rpchat.localMessage(pid, message)
		else
			message = pColor .. name .. color.White .. ": \"" .. rpchat.format(message) .. "\"\n"
			rpchat.localMessage(pid, message)
		end
	end
	
	function rpchat.localMessage(pid, message)
		for index, value in pairs(Players) do
			if tes3mp.GetCell(index) == tes3mp.GetCell(pid)then
				tes3mp.SendMessage(index, message, false)
			end
		end
	end
	
	function rpchat.log(message, logType)
		if logType == nil or logType == "normal" then
			message = "[RP-CHAT]: " .. message
			tes3mp.LogMessage(enumerations.log.INFO, message)
		elseif logType == "error" then
			message = "[RP-CHAT]ERR: " .. message
			tes3mp.LogMessage(enumerations.log.INFO, message)
		elseif logType == "warning" then
			message = "[RP-CHAT]WARN: " .. message
			tes3mp.LogMessage(enumerations.log.INFO, message)
		elseif logType == "notice" then
			message = "[RP-CHAT]NOTE: " .. message
			tes3mp.LogMessage(enumerations.log.INFO, message)
		elseif logType == "debug" and rpconfig.debug then
			message = "[RP-CHAT]DBG: " .. message
			tes3mp.LogMessage(enumerations.log.INFO, message)
		elseif logType == "debug" and rpconfig.debug == false then
			--do.thing("a thing")
		else
			rpchat.log("INVALID LOG CALL", "error")
			message = "[RP-CHAT](invalid): " .. message
			tes3mp.LogMessage(enumerations.log.INFO, message)
		end
	end
	function rpchat.systemMessage(pid, message)
		message = color.Cyan .. "[RP-Chat]: " .. color.White .. message .. "\n"
		tes3mp.SendMessage(pid, message, false)
	end
	function rpchat.commandHandler(pid, cmd)
		if cmd[2] ~= nil then
			if cmd[2] == "name" then
				if cmd[3] ~= nil then
					local newName = cmd[3]:gsub("^%l", string.upper)
					rpchat.setName(pid, newName, pid)
				else
					rpchat.systemMessage(pid, "Invalid name.")
				end
			elseif cmd[2] == "color" and Players[pid].data.settings.staffRank > 0 then
				if cmd[3] ~= nil and logicHandler.CheckPlayerValidity(pid, cmd[3]) then
					if cmd[4] ~= nil then
						local newColor = cmd[4]
						rpchat.setColor(tonumber(cmd[3]), newColor, pid)
					else
						rpchat.systemMessage(pid, "Invalid color.")
					end
				else
					rpchat.systemMessage(pid, "Invalid PID.")
				end
			else
				rpchat.systemMessage(pid, "Invalid command.")
			end
		else
			rpchat.systemMessage(pid, "Invalid command.")
		end
	end
	
	customEventHooks.registerHandler("OnPlayerFinishLogin", rpchat.loginHandler)
	customEventHooks.registerHandler("OnPlayerEndCharGen", rpchat.loginHandler)
	customCommandHooks.registerCommand("rpchat", rpchat.commandHandler)
	customCommandHooks.registerCommand("ooc", rpchat.ooc)
	customCommandHooks.registerCommand("/", rpchat.ooc)
	customCommandHooks.registerCommand("looc", rpchat.looc)
	customCommandHooks.registerCommand("//", rpchat.looc)
	customCommandHooks.registerCommand("me", rpchat.emote)
	customEventHooks.registerValidator("OnPlayerSendMessage", rpchat.messageCatch)
	customEventHooks.registerHandler("OnPlayerDisconnect", rpchat.disconnectHandler)
	customEventHooks.registerHandler("OnServerPostInit", rpchat.load)
return rpchat

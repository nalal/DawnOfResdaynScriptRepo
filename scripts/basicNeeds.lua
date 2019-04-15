basicNeedsLogic = function(oldPlayerName, pid, tic, val1, val2, val3, val4)
	if logicHandler.CheckPlayerValidity(pid, pid) then
		val = tonumber(Players[pid].data.playerNeeds[val1])
		playerName = Players[pid].name
		if playerName == oldPlayerName then
			newVal = val + 10
			if val < 90 then
				Players[pid].data.playerNeeds[val1] = newVal
				message = "You feel " .. val2 .. ".\n"
				if config.needsLogging == true then
					tes3mp.LogMessage(enumerations.log.INFO, "Increasing " .. val1 .. " for player " .. logicHandler.GetChatName(pid) .. ", current " .. val1 .. " is " .. newVal .. ".")
				end
				tes3mp.SendMessage(pid, message)
				basicNeeds[tic](pid)
			else
    			Players[pid].data.playerNeeds[val1] = 100
				message = "You are " .. val3 .. ".\n"
				if config.needsLogging == true then
					tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(pid) .. " is " .. val3)
				end
				tes3mp.SendMessage(pid, message)
				if config.needsEmote == true then
					basicNeedsEmote(pid, val1)
				end
				if config.needsDebuff == true then
					basicNeedsDebuff(pid, val1)
				end
				if Players[pid].data.playerNeedsDebuffs[val3] == false then
    				Players[pid].data.playerNeedsDebuffs[val3] = true
			    end
			    basicNeeds[tic](pid)
			end
		else
			basicNeedsLogDebug("Player " .. playerName .. "'s name does not match " .. oldPlayerName .. ".")
		end
	end
end

basicNeedsDebuff = function(pid, val1)
	basicNeedsLogDebug("Server tried to apply the debuff for " .. val1 .. " on PID " .. pid .. " but the debuff function isn't complete yet.")
end

basicNeedsLog = function(message)
	if config.needsLogging == true then
		tes3mp.LogMessage(enumerations.log.INFO, message)	
	end
end

basicNeedsLogDebug = function(message)
	if config.needsLogging == true and config.needsLoggingDebug == true then
		tes3mp.LogMessage(enumerations.log.INFO, message)
	end
end

basicNeedsEmote = function(pid, emoteType)
	local message = "not set"
	if emoteType == "hunger" then
	message = "Someone's stomach growls loudly\n"
	elseif emoteType == "thirst" then
	message = "Someone lets out a dry cough\n"
	elseif emoteType == "fatigue" then
	message = "Someone yawns loudly\n"
	end
	if message ~= "not set" then
		local cellDescription = Players[pid].data.location.cell
		if logicHandler.IsCellLoaded(cellDescription) == true then
			for index, visitorPid in pairs(LoadedCells[cellDescription].visitors) do
				tes3mp.SendMessage(visitorPid, message, false)
			end
		end
	end
end

local basicNeeds = {}

	function basicNeeds.startTic(pid)
		if config.needsToggle == true then
			basicNeeds.hungerTic(pid)
			basicNeeds.thirstTic(pid)
		elseif Players[pid].playerNeeds ~= nil and Players[pid].playerNeedsDebuffs ~= nil then
			basicNeedsLog("basicNeeds is disabled in the config, skiping needs tracking init.")
			Players[pid].playerNeedsDebuffs.starving = false
			Players[pid].playerNeedsDebuffs.dehydrated = false
			Players[pid].playerNeedsDebuffs.exhausted = false
			Players[pid].playerNeeds.hunger = 0
			Players[pid].playerNeeds.thirst = 0
			Players[pid].playerNeeds.fatigue = 0
			basicNeedsLog("Player " .. logicHandler.GetChatName(pid) .. " had basicNeeds data but basicNeeds is disabled.")
			basicNeedsLog("Setting data for player " .. logicHandler.GetChatName(pid) .. " to default.")
		end
	end

	function basicNeeds.hungerTic(pid)
		playerName = tostring(Players[pid].name)
		hungerTime = tes3mp.CreateTimerEx("basicNeedsLogic", 12000, "sisssss", playerName, pid, "hungerTic", "hunger", "hungry", "starving", "healthBase")
		basicNeedsLog("Running hunger timer for player " .. logicHandler.GetChatName(pid) .. ".")
		tes3mp.StartTimer(hungerTime)
	end
	
	function basicNeeds.thirstTic(pid)
		if config.needsToggle == true then
			playerName = tostring(Players[pid].name)
			thirstTime = tes3mp.CreateTimerEx("basicNeedsLogic", 12000, "sisssss", playerName, pid, "thirstTic", "thirst", "thirsty", "dehydrated", "magickaBase")
			basicNeedsLog("Running thirst timer for player " .. logicHandler.GetChatName(pid) .. ".")
			tes3mp.StartTimer(thirstTime)
		end
	end

    -- Not initialized on login, function not complete
	function basicNeeds.fatigueTic(pid)
		if config.needsToggle == true then
			playerName = tostring(Players[pid].name)
			fatigueTime = tes3mp.CreateTimerEx("basicNeedsLogic", 120000, "sisssss", playerName, pid, "fatigueTic", "fatigue", "tired", "exhausted", "fatigueBase")
			basicNeedsLog("Running fatigue timer for player " .. logicHandler.GetChatName(pid) .. ".")
			tes3mp.StartTimer(thirstTime)
		end
	end

	function basicNeeds.rest(pid, cell)
		if tableHelper.containsValue(config.restingCells, cell) then
			-- In development
		else
			basicNeedsLog("Player " .. logicHandler.GetChatName(pid) .. " tried to rest in invalid cell.")
			Players[pid]:Message("You cannot rest here.")
		end
	end

	function basicNeeds.ingest(pid, itemRefID)
		if tableHelper.containsValue(config.foodItems, itemRefID) then
			basicNeeds.ingestApply(pid, "eat", "hunger", "starving")
		elseif tableHelper.containsValue(config.drinkItems, itemRefID) then
			basicNeeds.ingestApply(pid, "drink", "thirst", "dehydrated")
		end
	end
	
	function basicNeeds.ingestApply(pid, ingestType, statType, debuffType)
		basicNeedsLog( "Applying " .. ingestType .. " function to " .. logicHandler.GetChatName(pid) .. ".")
		inVal = tonumber(Players[pid].data.playerNeeds[statType])
		consumeVal = inVal - 25
		if consumeVal >=0 then
			Players[pid].data.playerNeeds[statType] = consumeVal
			if Players[pid].data.playerNeedsDebuffs[debuffType] == true then
				Players[pid]:Message("You are no longer " .. debuffType .. ".\n")
				Players[pid].data.playerNeedsDebuffs[debuffType] = false
			end
		else
			Players[pid].data.playerNeeds[statType] = 0
		end
	end
	
return basicNeeds
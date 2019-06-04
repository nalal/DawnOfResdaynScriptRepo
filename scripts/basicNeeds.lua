basicNeedsConfig = require("basicNeedsConfig")

activeHungerTimers = { }
activeThirstTimers = { }
activeFatigueTimers = { }

basicNeedsLogic = function(oldPlayerName, pid, tic, val1, val2, val3, val4)
	if logicHandler.CheckPlayerValidity(pid, pid) then
		val = tonumber(Players[pid].data.playerNeeds[val1])
		playerName = Players[pid].name
		listName = playerName .. pid
		if listName == oldPlayerName then
			newVal = val + 10
			if val < 90 then
				Players[pid].data.playerNeeds[val1] = newVal
				message = "You feel " .. val2 .. "."
				if config.needsLogging == true then
					tes3mp.LogMessage(enumerations.log.INFO, "Increasing " .. val1 .. " for player " .. logicHandler.GetChatName(pid) .. ", current " .. val1 .. " is " .. newVal .. ".")
				end
				basicNeedsMessage(pid, message)
				basicNeedsTableConvert(listName, val1)
				basicNeeds[tic](pid)
			else
    			Players[pid].data.playerNeeds[val1] = 100
				message = "You are " .. val3 .. "."
				basicNeedsLog("Player " .. logicHandler.GetChatName(pid) .. " is " .. val3)
				basicNeedsMessage(pid, color.Red .. message)
				if config.needsEmote == true then
					basicNeedsEmote(pid, val1)
				end
				if config.needsDebuff == true then
					basicNeedsDebuff(pid, val3, playerName)
				end
				if Players[pid].data.playerNeedsDebuffs[val3] == false then
    				Players[pid].data.playerNeedsDebuffs[val3] = true
			    end
				basicNeedsTableConvert(listName, val1)
			    basicNeeds[tic](pid)
			end
		else
			basicNeedsLog("Player " .. listName .. "'s name does not match " .. oldPlayerName .. ".")
		end
	else
	basicNeedsTableConvert(oldPlayerName, val1)
	basicNeedsLog("Clearing name " .. oldPlayerName .. " from activeTimer")
	end
end

basicNeedsDebuff = function(pid, val3, playerName)
	local recordStore = RecordStores["spell"]
	basicNeedsLog("Server tried to apply the debuff " .. val3 .. " on PID " .. pid .. " but the debuff function isn't complete yet.")
	if val3 == "starving" then
		basicNeeds.spellInitHunger(pid)
		id = "needs_debuff_h_" .. playerName
		recordStore:LoadGeneratedRecords(pid, recordStore.data.generatedRecords, {id})
		table.insert(Players[pid].data.spellbook, id)
		Players[pid]:LoadSpellbook()
	end
	if val3 == "dehydrated" then
		basicNeeds.spellInitThirst(pid)
		id = "needs_debuff_t_" .. playerName
		recordStore:LoadGeneratedRecords(pid, recordStore.data.generatedRecords, {id})
		table.insert(Players[pid].data.spellbook, id)
		Players[pid]:LoadSpellbook()
	end
	if val3 == "exhausted" then
		basicNeeds.spellInitFatigue(pid)
		id = "needs_debuff_f_" .. playerName
		recordStore:LoadGeneratedRecords(pid, recordStore.data.generatedRecords, {id})
		table.insert(Players[pid].data.spellbook, id)
		Players[pid]:LoadSpellbook()
	end
end

basicNeedsRestApply = function(pid, name)
	local checkName = logicHandler.GetChatName(pid)
	if name == checkName  and Players[pid].data.playerResting == true then
		Players[pid].data.playerNeeds.fatigue = 0
		Players[pid].data.playerNeedsDebuffs.exhausted = false
		basicNeedsMessage(pid, "You are now rested.")
		basicNeedsLog(name .. " is now rested, setting fatigue to 0 and clearing fatigue debuff")
		Players[pid].data.playerResting = false
		basicNeeds.spellClean(pid, "needs_debuff_02")
	elseif Players[pid].data.playerResting == false then
		basicNeedsLog("No resting flag on player " .. name .. ", skipping rest timer.")
	else
		basicNeedsLog(checkName .. " does not match old name " .. name .. ".")
	end
end

basicNeedsLog = function(message)
	if config.needsLogging == true then
		tes3mp.LogMessage(enumerations.log.INFO, "BN: " .. message)	
	end
end

basicNeedsLogDebug = function(message)
	if config.needsLogging == true and config.needsLoggingDebug == true then
		tes3mp.LogMessage(enumerations.log.INFO, "BN-DEBUG: " .. message)
	end
end

basicNeedsEmote = function(pid, emoteType)
	local message = "not set"
	if emoteType == "hunger" then
	message = "Someone's stomach growls loudly"
	elseif emoteType == "thirst" then
	message = "Someone lets out a dry cough"
	elseif emoteType == "fatigue" then
	message = "Someone yawns loudly"
	end
	if message ~= "not set" then
		local cellDescription = Players[pid].data.location.cell
		if logicHandler.IsCellLoaded(cellDescription) == true then
			for index, visitorPid in pairs(LoadedCells[cellDescription].visitors) do
				tes3mp.SendMessage(visitorPid, color.LightSalmon ..  message .. "\n", false)
			end
		end
	end
end

basicNeedsMessage = function(pid, message, messagecolor)
	if messagecolor ~= nil then
		message = messagecolor .. message
	end
	Players[pid]:Message(color.Cyan .. "[Basic Needs]: " .. color.LightCyan .. message .. "\n")
end

basicNeedsTableConvert = function(playerName, tableType)
	if tableType == "hunger" then
		tableHelper.removeValue(activeHungerTimers, playerName)
	elseif tableType == "thirst" then
		tableHelper.removeValue(activeThirstTimers, playerName)
	elseif tableType == "fatigue" then
		tableHelper.removeValue(activeFatigueTimers, playerName)
	end
end

basicNeedsTimerPurge = function(playerName, tableType)
	basicNeedsLog("Removing " .. playerName .. " from timer list " .. tableType)
	tableHelper.removeValue(tableType, playerName)
end

local basicNeeds = {}

	function basicNeeds.logoutCatch(playerName)
		if tableHelper.containsValue(activeHungerTimers, playerName) == true then
			basicNeedsTimerPurge(playername, activeHungerTimers)
		end
		if tableHelper.containsValue(activeThirstTimers, playerName) == true then
			basicNeedsTimerPurge(playername, activeThirstTimers)
		end
		if tableHelper.containsValue(activeFatigueTimers, playerName) == true then
			basicNeedsTimerPurge(playername, activeFatigueTimers)
		end
	end
	
	function basicNeeds.spellInitHunger(pid)
		local recordStore = RecordStores["spell"]
		playerName = Players[pid].name
		dmgVal = Players[pid].stats.healthBase / 2
		local id = "needs_debuff_h_" .. playerName
		local recordTable = {
			name = "Starvation",
			subtype = 2,
			effects = {{
				id = 18,
				attribute = -1,
				skill = -1,
				rangeType = 0,
				area = 0,
				magnitudeMin = dmgVal,
				magnitudeMax = dmgVal
			}}
		}
		recordStore.data.generatedRecords[id] = recordTable
		recordStore:Save()
	end
	function basicNeeds.spellInitThirst(pid)
		local recordStore = RecordStores["spell"]
		playerName = Players[pid].name
		dmgVal = Players[pid].stats.magickaBase / 2
		local id = "needs_debuff_t_" .. playerName
		local recordTable = {
			name = "Deydration",
			subtype = 2,
			effects = {{
				id = 19,
				attribute = -1,
				skill = -1,
				rangeType = 0,
				area = 0,
				magnitudeMin = dmgVal,
				magnitudeMax = dmgVal
			}}
		}
		recordStore.data.generatedRecords[id] = recordTable
		recordStore:Save()
	end
	function basicNeeds.spellInitFatigue(pid)
		local recordStore = RecordStores["spell"]
		playerName = Players[pid].name
		dmgVal = Players[pid].stats.fatigueBase / 2
		local id = "needs_debuff_f_" .. playerName
		local recordTable = {
			name = "Exhaustion",
			subtype = 2,
			effects = {{
				id = 20,
				attribute = -1,
				skill = -1,
				rangeType = 0,
				area = 0,
				magnitudeMin = dmgVal,
				magnitudeMax = dmgVal
			}}
		}
		recordStore.data.generatedRecords[id] = recordTable
		recordStore:Save()
	end
	
	
	
	function basicNeeds.spellClean(pid, spellName)
		local recordStore = RecordStores["spell"]
		recordStore:RemoveLinkToPlayer(spellName, Players[pid])
		tableHelper.removeValue(Players[pid].data.spellbook, spellName)
		Players[pid]:RemoveLinkToRecord("spell", spellName)
		recordStore:Save()
		tes3mp.ClearSpellbookChanges(pid)
		tes3mp.SetSpellbookChangesAction(pid, enumerations.spellbook.REMOVE)
		tes3mp.AddSpell(pid, spellName)
		tes3mp.SendSpellbookChanges(pid)
	end
	
	function basicNeeds.startTic(pid)
		playerName = tostring(Players[pid].name)
		listName = playerName .. pid
		if Players[pid].data.playerNeedsDebuffs.starving == true then
			basicNeedsLogic(listName, pid, "hungerTic", "hunger", "hungry", "starving", "healthBase")
			basicNeedsLog("PlayerID " .. listName .. " logged in starving")
		end
		if Players[pid].data.playerNeedsDebuffs.dehydrated == true then
			basicNeedsLogic(listName, pid, "thirstTic", "thirst", "thirsty", "dehydrated", "magickaBase")
			basicNeedsLog("PlayerID " .. listName .. " logged in dehydrated")		
		end
		if Players[pid].data.playerNeedsDebuffs.exhausted == true then
			basicNeedsLogic(listName, pid, "fatigueTic", "fatigue", "tired", "exhausted", "fatigueBase")
			basicNeedsLog("PlayerID " .. listName .. " logged in exhausted")		
		end
		if config.needsToggle == true and Players[pid].data.debugFlags.haltTracking == false then
			basicNeeds.hungerTic(pid)
			basicNeeds.thirstTic(pid)
			basicNeeds.fatigueTic(pid)
		elseif Players[pid].data.playerNeeds ~= nil and Players[pid].data.playerNeedsDebuffs ~= nil then
			basicNeedsLog("basicNeeds is disabled in the config, skiping needs tracking init.")
			Players[pid].data.playerNeedsDebuffs.starving = false
			Players[pid].data.playerNeedsDebuffs.dehydrated = false
			Players[pid].data.playerNeedsDebuffs.exhausted = false
			Players[pid].data.playerNeeds.hunger = 0
			Players[pid].data.playerNeeds.thirst = 0
			Players[pid].data.playerNeeds.fatigue = 0
			basicNeedsLog("Player " .. logicHandler.GetChatName(pid) .. " had basicNeeds data but basicNeeds is disabled.")
			basicNeedsLog("Setting data for player " .. logicHandler.GetChatName(pid) .. " to default.")
		end
	end

	function basicNeeds.hungerTic(pid)
		if Players[pid].data.debugFlags.haltTracking == false then
			playerName = tostring(Players[pid].name)
			listName = playerName .. pid
			basicNeedsLogDebug("listName " .. listName .. " created for hungerTic.")
			if tableHelper.containsValue(activeHungerTimers, listName) ~= true then
				hungerTime = tes3mp.CreateTimerEx("basicNeedsLogic", config.needsTimer, "sisssss", listName, pid, "hungerTic", "hunger", "hungry", "starving", "healthBase")
				basicNeedsLog("Running hunger timer for player " .. logicHandler.GetChatName(pid) .. ".")
				tes3mp.StartTimer(hungerTime)
				basicNeedsLog("PlayerID " .. listName .. " added to activeHungerTimers list")
				table.insert(activeHungerTimers, listName)
			else
				basicNeedsLog("Player " .. logicHandler.GetChatName(pid) .. " already has a hunger timer running, ignoring.")
			end
		end
	end
	
	function basicNeeds.thirstTic(pid)
		if Players[pid].data.debugFlags.haltTracking == false then
			playerName = tostring(Players[pid].name)
			listName = playerName .. pid
			basicNeedsLogDebug("listName " .. listName .. " created for thirstTic.")
			if tableHelper.containsValue(activeThirstTimers, listName) ~= true then
				thirstTime = tes3mp.CreateTimerEx("basicNeedsLogic", config.needsTimer, "sisssss", listName, pid, "thirstTic", "thirst", "thirsty", "dehydrated", "magickaBase")
				basicNeedsLog("Running thirst timer for player " .. logicHandler.GetChatName(pid) .. ".")
				tes3mp.StartTimer(thirstTime)
				basicNeedsLog("PlayerID " .. listName .. " added to activeThirstTimers list")
				table.insert(activeThirstTimers, listName)
			else
				basicNeedsLog("Player " .. logicHandler.GetChatName(pid) .. " already has a thirst timer running, ignoring.")
			end
		end
	end

	function basicNeeds.fatigueTic(pid)
		if Players[pid].data.debugFlags.haltTracking == false then
			playerName = tostring(Players[pid].name)
			listName = playerName .. pid
			basicNeedsLogDebug("listName " .. listName .. " created for fatigueTic.")
			if tableHelper.containsValue(activeFatigueTimers, listName) ~= true then
				fatigueTime = tes3mp.CreateTimerEx("basicNeedsLogic", config.needsTimer, "sisssss", listName, pid, "fatigueTic", "fatigue", "tired", "exhausted", "fatigueBase")
				basicNeedsLog("Running fatigue timer for player " .. logicHandler.GetChatName(pid) .. ".")
				tes3mp.StartTimer(fatigueTime)
				basicNeedsLog("PlayerID " .. listName .. " added to activeFatigueTimers list")
				table.insert(activeFatigueTimers, listName)
			else
				basicNeedsLog("Player " .. logicHandler.GetChatName(pid) .. " already has a fatigue timer running, ignoring.")
			end
		end
	end

	function basicNeeds.rest(pid, cell)
		if tableHelper.containsValue(config.restingCells, cell) then
			basicNeedsLogDebug("Rest function called.")
			if Players[pid].data.playerNeeds.fatigue > 0 then
				basicNeedsMessage(pid, "You are now resting.\n")
				restTime = Players[pid].data.playerNeeds.fatigue --* 1000
				basicNeedsLogDebug("var 'restTime' is " .. restTime)
				playerName = logicHandler.GetChatName(pid)
				restTimer = tes3mp.CreateTimerEx("basicNeedsRestApply", restTime, "is", pid, playerName)
				tes3mp.StartTimer(restTimer)
				Players[pid].data.playerResting = true
				basicNeedsLog("Running rest timer for player " .. logicHandler.GetChatName(pid) .. ".")
			else
				basicNeedsMessage(pid, "You are not tired.\n")
			end
		elseif Players[pid].data.playerResting == true then
			basicNeedsMessage(pid, "You are already resting.")
		else
			basicNeedsLog("Player " .. logicHandler.GetChatName(pid) .. " tried to rest in invalid cell.")
			basicNeedsMessage(pid, "You cannot rest here.")
		end
	end

	function basicNeeds.ingest(pid, itemRefID)
		if tableHelper.containsValue(config.foodItems, itemRefID) then
			basicNeeds.ingestApply(pid, "eat", "hunger", "starving", "needs_debuff_00")
		elseif tableHelper.containsValue(config.drinkItems, itemRefID) then
			basicNeeds.ingestApply(pid, "drink", "thirst", "dehydrated", "needs_debuff_01")
		end
	end
	
	function basicNeeds.ingestApply(pid, ingestType, statType, debuffType, debuff)
		basicNeedsLog( "Applying " .. ingestType .. " function to " .. logicHandler.GetChatName(pid) .. ".")
		inVal = tonumber(Players[pid].data.playerNeeds[statType])
		consumeVal = inVal - 25
		if consumeVal >=0 then
			Players[pid].data.playerNeeds[statType] = consumeVal
			if Players[pid].data.playerNeedsDebuffs[debuffType] == true then
				Players[pid]:Message("You are no longer " .. debuffType .. ".\n")
				Players[pid].data.playerNeedsDebuffs[debuffType] = false
				basicNeeds.spellClean(pid, debuff)
			end
		else
			Players[pid].data.playerNeeds[statType] = 0
		end
	end
	
return basicNeeds
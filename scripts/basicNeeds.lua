basicNeedsLogic = function(oldPlayerName, pid, tic, val1, val2, val3, val4)
	if logicHandler.CheckPlayerValidity(pid, pid) then
		val = tonumber(Players[pid].data.playerNeeds[val1])
		playerName = Players[pid].name
		if playerName == oldPlayerName then
			newVal = val + 10
			if val < 90 then
				Players[pid].data.playerNeeds[val1] = newVal
				message = "You feel " .. val2 .. ".\n"
				tes3mp.LogMessage(enumerations.log.INFO, "Increasing " .. val1 .. " for player " .. logicHandler.GetChatName(pid) .. ", current " .. val1 .. " is " .. newVal .. ".")
				tes3mp.SendMessage(pid, message)
				basicNeeds[tic](pid)
			else
    			Players[pid].data.playerNeeds[val1] = 100
				message = "You are " .. val3 .. ".\n"
				tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(pid) .. " is " .. val3)
				tes3mp.SendMessage(pid, message)
				if Players[pid].data.playerNeedsDebuffs[val3] == false then
    				Players[pid].data.playerNeedsDebuffs[val3] = true
			    end
			    basicNeeds[tic](pid)
			end
		else
			tes3mp.LogMessage(enumerations.log.INFO, "Player " .. playerName .. "'s name does not match " .. oldPlayerName .. ".")
		end
	end
end


local basicNeeds = {}

	function basicNeeds.startTic(pid)
		if config.needsToggle == true then
			basicNeeds.hungerTic(pid)
			basicNeeds.thirstTic(pid)
		elseif Players[pid].playerNeeds ~= nil and Players[pid].playerNeedsDebuffs ~= nil then
			tes3mp.LogMessage(enumerations.log.INFO, "basicNeeds is disabled in the config, skiping needs tracking init.")
			Players[pid].playerNeedsDebuffs.starving = false
			Players[pid].playerNeedsDebuffs.dehydrated = false
			Players[pid].playerNeedsDebuffs.exhausted = false
			Players[pid].playerNeeds.hunger = 0
			Players[pid].playerNeeds.thirst = 0
			Players[pid].playerNeeds.fatigue = 0
			tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(pid) .. " had basicNeeds data but basicNeeds is disabled.")
			tes3mp.LogMessage(enumerations.log.INFO, "Setting data for player " .. logicHandler.GetChatName(pid) .. " to default.")
		end
	end

	function basicNeeds.hungerTic(pid)
		playerName = tostring(Players[pid].name)
		hungerTime = tes3mp.CreateTimerEx("basicNeedsLogic", 12000, "sisssss", playerName, pid, "hungerTic", "hunger", "hungry", "starving", "healthBase")
		tes3mp.LogMessage(enumerations.log.INFO, "Running hunger timer for player " .. logicHandler.GetChatName(pid) .. ".")
		tes3mp.StartTimer(hungerTime)
	end
	
	function basicNeeds.thirstTic(pid)
		if config.needsToggle == true then
			playerName = tostring(Players[pid].name)
			thirstTime = tes3mp.CreateTimerEx("basicNeedsLogic", 12000, "sisssss", playerName, pid, "thirstTic", "thirst", "thirsty", "dehydrated", "magickaBase")
			tes3mp.LogMessage(enumerations.log.INFO, "Running thirst timer for player " .. logicHandler.GetChatName(pid) .. ".")
			tes3mp.StartTimer(thirstTime)
		end
	end

    -- Not initialized on login, function not complete
	function basicNeeds.fatigueTic(pid)
		if config.needsToggle == true then
			playerName = tostring(Players[pid].name)
			fatigueTime = tes3mp.CreateTimerEx("basicNeedsLogic", 120000, "sisssss", playerName, pid, "fatigueTic", "fatigue", "tired", "exhausted", "fatigueBase")
			tes3mp.LogMessage(enumerations.log.INFO, "Running fatigue timer for player " .. logicHandler.GetChatName(pid) .. ".")
			tes3mp.StartTimer(thirstTime)
		end
	end

	function basicNeeds.rest(pid, cell)
		if tableHelper.containsValue(config.restingCells, cell) then
			-- In development
		else
			tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(pid) .. " tried to rest in invalid cell.")
			Players[pid]:Message("You cannot rest here.")
		end
	end

	function basicNeeds.ingest(pid, itemRefID)
		if tableHelper.containsValue(config.foodItems, itemRefID) then
			basicNeeds.eat(pid)
		elseif tableHelper.containsValue(config.drinkItems, itemRefID) then
			basicNeeds.drink(pid)
		end
	end

	function basicNeeds.drink(pid)
		tes3mp.LogMessage(enumerations.log.INFO, "Applying drink function to " .. logicHandler.GetChatName(pid) .. ".")
		thirstVal = tonumber(Players[pid].data.playerNeeds.thirst)
		drinkVal = thirstVal - 25
		if drinkVal >=0 then
			Players[pid].data.playerNeeds.thirst = drinkVal
			if Players[pid].data.playerNeedsDebuffs.dehydrated == true then
				Players[pid]:Message("You are no longer dehydrated.")
				Players[pid].data.playerNeedsDebuffs.dehydrated = false
			end
		else
			Players[pid].data.playerNeeds.thirst = 0
		end
	end
	
	function basicNeeds.eat(pid)
		tes3mp.LogMessage(enumerations.log.INFO, "Applying eat function to " .. logicHandler.GetChatName(pid) .. ".")
		hungerVal = tonumber(Players[pid].data.playerNeeds.hunger)
		foodVal = hungerVal - 25
		if foodVal >=0 then
			Players[pid].data.playerNeeds.hunger = foodVal
			if Players[pid].data.playerNeedsDebuffs.starving == true then
				Players[pid]:Message("You are no longer starving.")
				Players[pid].data.playerNeedsDebuffs.starving = false
			end
		else
			Players[pid].data.playerNeeds.thirst = 0
		end
	end
	
return basicNeeds
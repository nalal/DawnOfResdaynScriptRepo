craftingSkillsConfig = require("custom/basicCrafting/craftingFunctionsConfig")
craftingRecipie = require("custom/basicCrafting/craftingRecipies")
craftingItems = require("custom/basicCrafting/craftingItems")
gatheringData = require("custom/basicCrafting/gatheringData")
oreDictionary = require("custom/basicCrafting/oreDictionary")
metalDictionary = require("custom/basicCrafting/metalDictionary")
local activeTimers = {}
--Timers for skills with time delays
local craftSkills = {}
--Global functions
local craftMats = {}
--Craft function

craftSkills.craft = function(pid, items)
--Still working out the math on this one
end

craftSkills.mineMenu = function(pid)
	tes3mp.CustomMessageBox(pid, craftingSkillsConfig.menuIDs.menuMineID, "What material would you like to mine?", craftSkills.getAvailableOres(pid) .. "Close")
end

craftSkills.metalMenu = function(pid)
	if Players[pid].data.craftSkills.Mining ~= nil then
		tes3mp.CustomMessageBox(pid, craftingSkillsConfig.menuIDs.menuMetalID, "What would you like to do?", "Mine;Smelt;Close")
	else
		craftSkillsMessage("You do not have the 'Crafting' skill.", pid)
	end
end

craftSkills.smeltMenu = function(pid)
	buttons = craftSkills.getAvailableMetals(pid)
	if buttons ~= "" then
		tes3mp.CustomMessageBox(pid, craftingSkillsConfig.menuIDs.menuSmeltID, "What material would you like to smelt?", craftSkills.getAvailableMetals(pid) .. "Close")
	else
		tes3mp.CustomMessageBox(pid, craftingSkillsConfig.menuIDs.menuSmeltID, "You do not know how to smelt any metals, try mining for a bit to see if you can learn anything.", "Close")
	end
end

craftSkills.getAvailableOresCount = function(pid)
	oreCount = 0
	for index, ID in pairs(gatheringData) do
		local skillVal = 0
		if Players[pid].data.craftSkills.Mining <= 1 then
			skillVal = 1
		else
			skillVal = Players[pid].data.craftSkills.Mining
		end
		if gatheringData[index] <= skillVal then
			oreCount = oreCount + 1
		end
		craftSkillsLog("getAvailableOresCount RETURNED INT " .. oreCount ,"debug")
	end
	return oreCount
end

craftSkills.getAvailableMetalsCount = function(pid)
	oreCount = 0
	for index, ID in pairs(metalDictionary) do
		local skillVal = 0
		if Players[pid].data.craftSkills.Mining <= 1 then
			skillVal = 1
		else
			skillVal = Players[pid].data.craftSkills.Mining
		end
		if metalDictionary[index].skill <= skillVal then
			oreCount = oreCount + 1
		end
		craftSkillsLog("getAvailableOresCount RETURNED INT " .. oreCount ,"debug")
	end
	return oreCount
end

craftSkills.getAvailableOres = function(pid)
	buttons = ""
	for index, ID in pairs(gatheringData) do
		local skillVal = 0
		if Players[pid].data.craftSkills.Mining <= 1 then
			skillVal = 1
		else
			skillVal = Players[pid].data.craftSkills.Mining
		end
		if gatheringData[index] <= skillVal then
			buttons = buttons .. index .. ";"
		end
		craftSkillsLog("getAvailableOres RETURNED BUTTON LIST " .. buttons ,"debug")
	end
	return buttons
end

craftSkills.getAvailableMetals = function(pid)
	buttons = ""
	for index, ID in pairs(metalDictionary) do
		craftSkillsLog("INDEX IS " .. index  ,"debug")
		local skillVal = 0
		if Players[pid].data.craftSkills.Mining <= 1 then
			skillVal = 1
		else
			skillVal = tonumber(Players[pid].data.craftSkills.Mining)
		end
		local skillnum = metalDictionary[index].skill
		craftSkillsLog("skillVal IS " .. skillVal ,"debug")
		if skillnum <= skillVal then
			buttons = buttons .. index .. ";"
		end
	end
	craftSkillsLog("getAvailableOres RETURNED BUTTON LIST " .. buttons ,"debug")
	return buttons
end

craftSkills.mine = function(pid, material)
	local message = "You do not have the mining skill, you cannot mine."
	if Players[pid].data.craftSkills.Mining ~= nil then
		if tableHelper.containsValue(craftingSkillsConfig.mineCells, tes3mp.GetCell(pid)) and tableHelper.containsValue(activeTimers, pid .. Players[pid].name .. "mining") ~= true then
			message = "You begin mining..."
			miningTime = tes3mp.CreateTimerEx("execMine", craftingSkillsConfig.mineTime, "sis", tes3mp.GetCell(pid), pid, material)
			craftSkillsLog("Starting mining timer for " .. Players[pid].name)
			table.insert(activeTimers, pid .. Players[pid].name .. "mining")
			tes3mp.StartTimer(miningTime)
			craftSkillsLog("TIMER ID IS " .. miningTime,"debug")
		elseif tableHelper.containsValue(activeTimers, pid .. Players[pid].name .. "mining") then
			craftSkillsLog("Player " .. Players[pid].name .. " tried to mine but already has a timer.")
			local message = "You are already mining."
		else
			message = "You are not in a mine, you cannot mine here."
		end
	end
	craftSkillsMessage(message, pid)
end

craftSkills.getQuality = function(id)
	local qual = ""
	local message = "qual RETURNED VALUE "
	if id ~= nil then
		qual = string.match(id, "qual.")
		qual = string.sub(string.reverse(id), 1, 1)
		qual = tonumber(qual)
	else
		message = "qual REQUESTED WITH NIL ID VALUE "
	end
	craftSkillsLog(message .. qual,"debug")
	return qual
end

craftSkills.smelt = function(pid, mat)
	craftSkillsLog("SMELT CALLED WITH MAT " .. mat ,"debug")
	local recordStore = RecordStores["miscellaneous"]
	local qualval = Players[pid].data.craftSkills.Mining / gatheringData[mat]
	if qualval < 1 then
		qualval = 1
	end
	local id = "ingred_" .. mat .. "_qual" .. qualval .. "_1"
	id = string.lower(id)
	if recordStore.data.generatedRecords[id] == nil then
		local recordTable = {
			name = "Grade " .. qualval .. " " .. mat,
			value = qualval / 2,
			weight = 1,
			icon = "m/Tx_repair_A_01.tga",
			model = "m/misc_hammer10.nif"
		}
		recordStore.data.generatedRecords[id] = recordTable
		permID = "ingred_" .. mat .. "_1"
		recordStore:Save()
		craftSkills.sendRecord(id)
	end
	recordStore:Save()
	recordStore:LoadGeneratedRecords(pid, recordStore.data.generatedRecords, {id})
	--recordStore:Load()
	inventoryHelper.addItem(Players[pid].data.inventory, id, 1, -1, -1, "")
	craftSkills.getQuality(id)
	Players[pid]:SaveEquipment()
	Players[pid]:LoadInventory()
	Players[pid]:LoadEquipment()
	local message = "You have smelted " .. mat
	craftSkillsMessage(message, pid)
end

craftSkills.sendRecord = function(id)
	recordStore = RecordStores["miscellaneous"]
	for index, pid in pairs(Players) do
		craftSkillsLog("SENT RECORD " .. id .. " FOR PLAYERID " .. index, "debug")
		recordStore:LoadGeneratedRecords(index, recordStore.data.generatedRecords, {id})
	end
end

craftSkills.catchLogout = function(eventStatus, pid, name, data)
	if tableHelper.containsValue(activeTimers, pid .. name .. "mining") then
		craftSkillsLog("Player " .. name .. " quit with a running timer, cleaning timer from array.")
		tableHelper.removeValue(activeTimers, pid .. name .. "mining")
	end
end

craftSkills.returnMine = function(pid, material)
	local quantity = 0
	if logicHandler.CheckPlayerValidity(pid, pid) then
		if Players[pid].data.craftSkills.mining == 0 then
			quantity = 1
		else
			quantity = Players[pid].data.craftSkills.Mining - gatheringData[material]
			if quantity <= 0 then
				quantity = 1
			end
		end
		if quantity == 1 then
			message = "You gathered " .. quantity .. " chunk of " .. material .. "."
		else
			message = "You gathered " .. quantity .. " chunks of " .. material .. "."
		end
		craftSkillsMessage(message, pid)
		inventoryHelper.addItem(Players[pid].data.inventory, oreDictionary[material], quantity)
		Players[pid]:LoadInventory()
		Players[pid]:LoadEquipment()
		diff = gatheringData[material] * quantity
		craftSkills.increaseSkill(pid, diff, "mining")
		craftSkills.gemRoll(pid)
	end
	craftSkillsLog("TOTAL ITEMS RETURNED FROM MINING IS " .. quantity,"debug")
end

craftSkills.getGem = function()
	local val = math.random(1,3)
	local gem = ""
	if val == 1 then
		gem = "Ingred_Ruby_01"
	elseif val == 2 then
		gem = "Ingred_Emerald_01"
	elseif val == 3 then
		gem = "Ingred_Pearl_01"
	end
	return gemName
end

craftSkills.gemRoll = function(pid)
	local skill = 0
	if Players[pid].data.craftSkills.Mining ~= 0 then
	skill = Players[pid].data.craftSkills.Mining
	else
	skill = 1
	end
	rollCap = 10000 / skill
	rollCap = rollCap - (10000 % skill)
	roll = math.random(1, rollCap)
	craftSkillsLog (Players[pid].name .. " ROLLED " .. roll .. " FOR gemRoll","debug")
	if roll == 1 then
		local message = "You found a very rare gem while mining!"
		craftSkillsMessage(message, pid)
		inventoryHelper.addItem(Players[pid].data.inventory, "Ingred_Diamond_01", 1)
	end
	if roll <= 5 and roll > 1 then
		local quantity = math.random(1,10)
		local message = ""
		if quantity == 1 then
			message = "You found a gem while mining!"
		else
			message = "You found several gems while mining!"
		end
		local i = 0
		craftSkillsMessage(message, pid)
		while(i < quantity) do
			local gotGem = craftSkills.getGem
			inventoryHelper.addItem(Players[pid].data.inventory, gotGem, quantity)
			i = i + 1
		end
		Players[pid]:LoadInventory()
		Players[pid]:LoadEquipment()
	end
end

execMine = function(cell, pid, material)
	if logicHandler.CheckPlayerValidity(pid, pid) and tableHelper.containsValue(activeTimers, pid .. Players[pid].name .. "mining") then
		craftSkillsLog("Completing mining timer for " .. Players[pid].name)
		local message = "You finished mining.\n"
		craftSkillsMessage(message, pid)
		craftSkills.returnMine(pid, material)
	else
		craftSkillsLog("Mining timer for PID " .. pid .. " called but either no player with PID exists or timer no matching timer in array.")
	end
	tableHelper.removeValue(activeTimers, pid .. Players[pid].name .. "mining")
end

craftSkills.menuCraftType = function(pid, skill)
	items = craftSkills.getCraftItems(pid, skill)
	return tes3mp.ListBox(pid, craftingSkillsConfig.menuIDs.craftSelect, "Item's you can craft with your current " .. skill .. " skill.", items)
end

--Init menu
craftSkills.menu = function(pid)
	craftSkillsLog("Player " .. tes3mp.GetName(pid) .. " called for crafting menu.")
	tes3mp.CustomMessageBox(pid, craftingSkillsConfig.menuIDs.main, "What would you like to do?", "Manage craft skills;Craft;Close")
end

craftSkills.menuSkills = function(pid)
	skills = craftSkills.getLearnedSkillsNames(pid)
	tes3mp.CustomMessageBox(pid, craftingSkillsConfig.menuIDs.skill, "What would you like to do?\nYou may only know 2 crafting skills at once.\nYour current crafting skills are:\n" .. skills, "Learn skill;Unlearn skill;Close")
end

craftSkills.menuLearnSkill = function(pid)
	tes3mp.CustomMessageBox(pid, craftingSkillsConfig.menuIDs.skillSelect, "Please select a skill to learn.", "Mining;Skinning;Tailoring;Blacksmithing;Leatherworking;Cooking;Close")
end

craftSkills.menuUnlearnSkill = function(pid)
	skills = craftSkills.getLearnedSkills(pid)
	if skills ~= "" then
		tes3mp.CustomMessageBox(pid, craftingSkillsConfig.menuIDs.skillUnselect, "Please select a skill to Unlearn.\nBe aware, this is a permanent change, you will lose all your knowledge in this skill.", skills .. "Close")
	else
		tes3mp.CustomMessageBox(pid, craftingSkillsConfig.menuIDs.skillUnselect, "You have no skills to unlearn.", "Close")
	end
end

craftSkills.menuMaxSkills = function(pid)
	tes3mp.CustomMessageBox(pid, craftingSkillsConfig.menuIDs.maxSkills, "You cannot learn any more skills.", "Close")
end

craftSkills.menuCraft = function(pid)
	types = craftSkills.getCraftableSkillsButton(pid)
	tes3mp.CustomMessageBox(pid, craftingSkillsConfig.menuIDs.craft, "What kind of crafting would you like to do?", types .. "Close")
end

craftSkills.menuMainCraft = function(pid, name)
	tes3mp.CustomMessageBox(pid, craftingSkillsConfig.menuIDs.menuMainCraftID, "Please select the materials you would like to craft the " .. name .. " with.\n Required materials:\n".. craftSkills.getCraftMatNames("smithing", "iron_longsword") .. " SYSTEM IS CURRENTLY INCOMPLETE, ANY INPUT WILL CLOSE THIS MENU", "Close")
end

craftSkills.getCraftMatNames = function(skill, item)
	local message = ""
	craftSkillsLog("get CALL RETURNS " .. tostring(craftingRecipie[skill][item].name), "debug" ) 
	for i, ID in pairs(craftingRecipie[skill][item].ingreds) do
		craftSkillsLog("INGRED NAME IS " .. tostring(i))
		message = message .. craftingItems[tostring(i)].name .. ": " .. ID .. "\n"
	end
	return message
end

craftSkills.getCraftItemsArray = function(pid, skill)
	local items = {}
	if skill == "Blacksmithing" then
		for index, ID in pairs(craftingRecipie.smithing) do
			if craftingRecipie.smithing[index].diff <= Players[pid].data.craftSkills[skill] then
				table.insert(items, tostring(craftingRecipie.smithing[index].name))
			end
			craftSkillsLog("ITEM NAME IS " .. tostring(craftingRecipie.smithing[index].name), "debug")
			craftSkillsLog("PLAYER SKILL IS " .. tostring(Players[pid].data.craftSkills[skill]), "debug")
		end
	elseif skill == "Leatherworking" then
		for index, ID in pairs(craftingRecipie.leather) do
			if craftingRecipie.smithing[index].diff <= Players[pid].data.craftSkills[skill] then
				table.insert(items, tostring(craftingRecipie.smithing[index].name))
			end
			craftSkillsLog("ITEM NAME IS " .. tostring(craftingRecipie.smithing[index].name), "debug")
			craftSkillsLog("PLAYER SKILL IS " .. tostring(Players[pid].data.craftSkills[skill]), "debug")
		end
	elseif skill == "Tailoring" then
		for index, ID in pairs(craftingRecipie.tailor) do
			if craftingRecipie.smithing[index].diff <= Players[pid].data.craftSkills[skill] then
				table.insert(items, tostring(craftingRecipie.smithing[index].name))
			end
			craftSkillsLog("ITEM NAME IS " .. tostring(craftingRecipie.smithing[index].name), "debug")
			craftSkillsLog("PLAYER SKILL IS " .. tostring(Players[pid].data.craftSkills[skill]), "debug")
		end
	elseif skill == "Cooking" then
		for index, ID in pairs(craftingRecipie.cook) do
			if craftingRecipie.smithing[index].diff <= Players[pid].data.craftSkills[skill] then
				table.insert(items, tostring(craftingRecipie.smithing[index].name))
			end
			craftSkillsLog("ITEM NAME IS " .. tostring(craftingRecipie.smithing[index].name), "debug")
			craftSkillsLog("PLAYER SKILL IS " .. tostring(Players[pid].data.craftSkills[skill]), "debug")
		end
	end 
	return items
end

craftSkills.getCraftItems = function(pid, skill)
	local items = ""
	if skill == "Blacksmithing" then
		for index, ID in pairs(craftingRecipie.smithing) do
			if craftingRecipie.smithing[index].diff <= Players[pid].data.craftSkills[skill] then
				items = items .. tostring(craftingRecipie.smithing[index].name) .. "\n"
			end
			craftSkillsLog("ITEM NAME IS " .. tostring(craftingRecipie.smithing[index].name), "debug")
			craftSkillsLog("PLAYER SKILL IS " .. tostring(Players[pid].data.craftSkills[skill]), "debug")
		end
	elseif skill == "Leatherworking" then
		for index, ID in pairs(craftingRecipie.leather) do
			if craftingRecipie.smithing[index].diff <= Players[pid].data.craftSkills[skill] then
				items = items .. tostring(craftingRecipie.smithing[index].name) .. "\n"
			end
			craftSkillsLog("ITEM NAME IS " .. tostring(craftingRecipie.smithing[index].name), "debug")
			craftSkillsLog("PLAYER SKILL IS " .. tostring(Players[pid].data.craftSkills[skill]), "debug")
		end
	elseif skill == "Tailoring" then
		for index, ID in pairs(craftingRecipie.tailor) do
			if craftingRecipie.smithing[index].diff <= Players[pid].data.craftSkills[skill] then
				items = items .. tostring(craftingRecipie.smithing[index].name) .. "\n"
			end
			craftSkillsLog("ITEM NAME IS " .. tostring(craftingRecipie.smithing[index].name), "debug")
			craftSkillsLog("PLAYER SKILL IS " .. tostring(Players[pid].data.craftSkills[skill]), "debug")
		end
	elseif skill == "Cooking" then
		for index, ID in pairs(craftingRecipie.cook) do
			if craftingRecipie.smithing[index].diff <= Players[pid].data.craftSkills[skill] then
				items = items .. tostring(craftingRecipie.smithing[index].name) .. "\n"
			end
			craftSkillsLog("ITEM NAME IS " .. tostring(craftingRecipie.smithing[index].name), "debug")
			craftSkillsLog("PLAYER SKILL IS " .. tostring(Players[pid].data.craftSkills[skill]), "debug")
		end
	end 
	return items
end

craftSkills.getCraftableSkillsArray = function(pid)
	local message = {}
	for index in pairs(Players[pid].data.craftSkills) do
		if tableHelper.containsValue(craftingSkillsConfig.craftableSkills, index) then
			table.insert(message, index)
		end
	end
	return message
end

craftSkills.getCraftableSkillsButton = function(pid)
	local message = ""
	for index in pairs(Players[pid].data.craftSkills) do
		if tableHelper.containsValue(craftingSkillsConfig.craftableSkills, index) then
			message = message .. index .. ";"
		end
	end
	return message
end

craftSkills.getLearnedSkills = function(pid)
	local message = ""
	for index in pairs(Players[pid].data.craftSkills) do
		message = message .. index .. ";"
	end
	return message
end

craftSkills.getLearnedSkillsNames = function(pid)
	local message = ""
	for index in pairs(Players[pid].data.craftSkills) do
		message = message .. index .. " : " .. Players[pid].data.craftSkills[index] .. "\n"
	end
	return message
end

--Ugly system for getting skill name because for SOME reason I can't call to the index of array skillNames without getting a nil return
craftSkills.getSkillName = function(i)
	if i == 0 then
		iname = "mining"
	elseif i == 1 then
		iname = "skinning"
	elseif i == 2 then
		iname = "tailoring"
	elseif i == 3 then
		iname = "smithing"
	elseif i == 4 then
		iname = "leatherworking"
	elseif i == 5 then
		iname = "cooking"
	end
	return iname
end

--Skill management
craftSkills.learnSkill = function(pid, inputData)
	if inputData ~= nil then
		skillCall = craftSkills.getSkillName(inputData)
		skill = craftingSkillsConfig.skillNames[skillCall]
	else
		craftSkillsLog("Got learnSkill call with null inputData, aborting learnSkill", "error")
	end
	if skill ~= nil then
		Players[pid].data.craftSkills[skill] = 0
		Players[pid].data.craftSkillsProgress[skill] = 0
		craftSkillsLog("Added skill " .. skill .. " to player " .. tes3mp.GetName(pid))
	else
		craftSkillsLog("Got learnSkill call and inputData was not nil, but skill was, aborting learnSkill", "error")
	end
end

craftSkills.unlearnSkill = function(pid, inputID)
	skillUnlearn = craftSkills.getSkillUnlearn(pid, inputID)
	craftSkillsLog("skillUnlearn IS CURRENTLY " .. skillUnlearn, "debug")
	Players[pid].data.craftSkills[skillUnlearn] = nil
	Players[pid].data.craftSkillsProgress[skillUnlearn] = nil
end

craftSkills.getSkillUnlearn = function(pid, i)
	local message = "noSkillFound"
	local count = 0
	for index in pairs(Players[pid].data.craftSkills) do
		if count == tonumber(i) then
			craftSkillsLog("GOT STRING " .. tostring(index) .. " FOR RETURN", "debug")
			message = tostring(index)
		end
		count = count + 1
	end
	return message
end

craftSkills.getSkillTarget = function(array, target)
	local message = "noSkillFound"
	local count = 1
	for index, ID in pairs(array) do
		if count == tonumber(target) then
			craftSkillsLog("GOT STRING " .. tostring(ID) .. " FOR RETURN", "debug")
			message = tostring(ID)
		end
		count = count + 1
	end
	return message
end

--logger function
craftSkillsLog = function(message, debugFlag)
	if debugFlag == "debug" then
		message = "[CS-DEBUG]: " .. message
	elseif debugFlag == nil or debugFlag == "normal" then
		message = "[CS]: " .. message
	elseif debugFlag == "error" then
		message = "[CS-ERROR]: " .. message
	else
		message1 = "[CS-DEBUG]: Improperly flagged log = " .. message
		message = "[CS-ERROR]: Log was called but was given invalid debug flag, take a break and get some coffee, Nac"
	end
	
	tes3mp.LogMessage(enumerations.log.INFO, message)
	
	if message1 ~= nil then
		tes3mp.LogMessage(enumerations.log.INFO, message1)
	end
end


--Increase player skill
craftSkills.increaseSkill = function(pid, diffValue, skill)
	local skillName = craftingSkillsConfig.skillNames[skill]
	local pName = Players[pid].name
	craftSkillsLog ("skillName IS SET TO " .. skillName, "debug")
	craftSkillsLog ("pName IS SET TO " .. pName, "debug")
	if skillName ~= nil then
		if diffValue - Players[pid].data.craftSkillsProgress[skillName] <= 0 then
			xpValue = 1
		else
			xpValue = diffValue - Players[pid].data.craftSkillsProgress[skillName]
		end
		if Players[pid].data.craftSkillsProgress[skillName] < craftingSkillsConfig.maxSkillProgress * Players[pid].data.craftSkills[skillName] then
			Players[pid].data.craftSkillsProgress[skillName] = Players[pid].data.craftSkillsProgress[skillName] + xpValue
			logMessage = "Increasing skillProgress " .. skill .. " for " .. pName
			craftSkillsLog(logMessage)
			if Players[pid].data.craftSkillsProgress[skillName] >=  craftingSkillsConfig.maxSkillProgress * Players[pid].data.craftSkills[skillName] then
				logMessage = "Increasing skill " .. skill .. " for " .. pName
				craftSkillsLog(logMessage)
				message = "You have become more proficient in " .. skillName .. ".\n" 
				craftSkillsMessage(message, pid)
				Players[pid].data.craftSkills[skillName] = Players[pid].data.craftSkills[skillName] + 1 --(Players[pid].data.craftSkillsProgress[skill] / 3)
				Players[pid].data.craftSkillsProgress[skillName] = 0
			end
		else
			if Players[pid].data.craftSkills[skill] == craftingSkillsConfig.maxSkill then
				message = "Player " .. pName .. " has reached maxSkill in " .. skill
				craftSkillsLog(message)
				Players[pid].data.craftSkills[skillName] = craftingSkillsConfig.maxSkill
			else
				if skillName ~= nil then
					logMessage = "Increasing skill " .. skill .. " for " .. pName
					craftSkillsLog(logMessage)
					message = "You have become more proficient in " .. skillName .. ".\n" 
					craftSkillsMessage(message, pid)
				else
					craftSkillsLog("Skill name for " .. skill .. " is a nil, remember to set this in 'skillName'", "error")
				end
				Players[pid].data.craftSkills[skillName] = Players[pid].data.craftSkills[skillName] + 1 --(Players[pid].data.craftSkillsProgress[skill] / 3)
				Players[pid].data.craftSkillsProgress[skillName] = 0
			end
		end
	else
		message0 = "Skill provided for function 'increaseSkill' was invalid/nil."
		message1 = "Skill provided is nil"
		if skill ~= nil then
			message1 = "Skill provided = " .. skill
		end
		craftSkillsLog(message0, "error")
		craftSkillsLog(message1, "debug")
	end
end

--Count function
tablelength = function(T)
  local count = 0
  for index in pairs(T) do count = count + 1 end
  return count
end

--Chat PM function
craftSkillsMessage = function(message, pid)
	message = color.Cyan .. "[Crafting]: " .. color.LightCyan .. message .. "\n"
	tes3mp.SendMessage(pid, message, false)
end

--Call functions

	--Pass ingredients for item
	function craftSkills.checkIngreds(item)
		if craftingRecipie[item] ~= nil then
			--Still working on this part
			craftSkillsLog("Called checkIngred but function is not complete so nothing happened", "debug")
		else
			if item ~= nil then
				message0 = "Item is not in recipies."
			else
				message1 = "checkIngreds called with nil item"
				item = "N/A"
			end
			craftSkillsLog(message0, "error")
			craftSkillsLog("Item called: " .. item, "debug")
		end
	end
	
	function craftSkills.OnGUIAction(eventStatus, pid, idGui, data)
		if idGui == craftingSkillsConfig.menuIDs.main then
			if tonumber(data) == 0 then
				craftSkills.menuSkills(pid)
			elseif tonumber(data) == 1 then
				craftSkills.menuCraft(pid)
			end
		elseif idGui == craftingSkillsConfig.menuIDs.skill then
			if tonumber(data) == 0 and Players[pid].data.craftSkills ~= nil then
				if tablelength(Players[pid].data.craftSkills) < 2 then
					craftSkills.menuLearnSkill(pid)
				else
					craftSkills.menuMaxSkills(pid)
				end
			elseif tonumber(data) == 1 then
				craftSkills.menuUnlearnSkill(pid)
			end
		elseif idGui == craftingSkillsConfig.menuIDs.skillSelect then
			craftSkills.learnSkill(pid, tonumber(data))
		elseif idGui == craftingSkillsConfig.menuIDs.skillUnselect then
			craftSkills.unlearnSkill(pid, tonumber(data))
		elseif idGui == craftingSkillsConfig.menuIDs.craft then
			skillList = craftSkills.getCraftableSkillsArray(pid)
			craftingSkills = tablelength(skillList)
			if tonumber(data) ~= tonumber(craftingSkills) then
				target = tonumber(data) + 1
				craftSkillName = craftSkills.getSkillTarget(skillList, target)
				skillName = craftSkillName
				craftSkills.menuCraftType(pid, craftSkillName)
			end
		elseif idGui == craftingSkillsConfig.menuIDs.craftSelect then
			if data ~= nil then
				local craftItem = ""
				local target = tonumber(data) + 1
				skillList = craftSkills.getCraftableSkillsArray(pid)
				craftItemNames = craftSkills.getCraftItemsArray(pid, skillName)
				for index, ID in pairs(craftItemNames) do
				targetIndex = 1
				craftSkillsLog("INDEX " .. index, "debug")
				craftSkillsLog("ID " .. ID, "debug")
					if targetIndex == target then
						craftItem = tostring(ID)
					else
						targetIndex = targetIndex + 1
					end
				end
				craftSkillsLog("DATA OUTPUT FOR craftSelect RETURNED RAW DATA " .. craftItem, "debug")
				craftSkills.menuMainCraft(pid, craftItem)
			end
		elseif idGui == craftingSkillsConfig.menuIDs.menuMetalID then
			if tonumber(data) == 0 then
				craftSkills.mineMenu(pid)
			elseif tonumber(data) == 1 then
				craftSkills.smeltMenu(pid)
			end
		elseif idGui == craftingSkillsConfig.menuIDs.menuMineID then
			local mat = ""
				oreTotal = craftSkills.getAvailableOresCount(pid)
			if tonumber(data) == 0 and oreTotal ~= tonumber(data) then
				mat = "Copper"
			elseif tonumber(data) == 1 and oreTotal ~= tonumber(data) then
				mat = "Tin"
			elseif tonumber(data) == 2 and oreTotal ~= tonumber(data) then
				mat = "Iron"
			else
			end
			if mat ~= "" then
				craftSkills.mine(pid, mat) 
			end
		elseif idGui == craftingSkillsConfig.menuIDs.menuSmeltID then
			local metalTotal = craftSkills.getAvailableMetalsCount(pid)
			local mat = ""
			if tonumber(data) == 0 and oreTotal ~= tonumber(data) then
				mat = "Copper"
			elseif tonumber(data) == 1 and oreTotal ~= tonumber(data) then
				mat = "Tin"
			elseif tonumber(data) == 2 and oreTotal ~= tonumber(data) then
				mat = "Bronze"
			elseif tonumber(data) == 3 and oreTotal ~= tonumber(data) then
				mat = "Iron"
			elseif tonumber(data) == 4 and oreTotal ~= tonumber(data) then
				mat = "Steel"
			end
			if mat ~= "" then
				craftSkills.smelt(pid, mat)
			end
		end
	end
	
	function craftSkills.loadRecords(pid)
		recordStore = RecordStores["miscellaneous"]
		for index, id in pairs(recordStore.data.generatedRecords) do
			craftSkillsLog("LOADED RECORD " .. tostring(index) .. " FOR PLAYERID " .. pid, "debug")
			recordStore:LoadGeneratedRecords(pid, recordStore.data.generatedRecords, {index})
		end
		Players[pid]:LoadInventory()
		Players[pid]:LoadEquipment()
	end
	
	function craftSkills.loginHandler(eventStatus, pid)
		craftSkills.loadRecords(pid)
	end
	
	customEventHooks.registerHandler("OnPlayerFinishLogin", craftSkills.loginHandler)
	customEventHooks.registerHandler("OnPlayerDisconnect", craftSkills.catchLogout)
	customEventHooks.registerHandler("OnGUIAction", craftSkills.OnGUIAction)
	customCommandHooks.registerCommand("craft", craftSkills.menu)
	customCommandHooks.registerCommand("mine", craftSkills.metalMenu)
return craftSkills

craftingSkillsConfig = require("custom/basicCrafting/craftingFunctionsConfig")
craftingRecipie = require("custom/basicCrafting/craftingRecipies")

local craftSkills = {}
--Global functions

--Craft function
craftSkills.craft = function(pid, items)
--Still working out the math on this one
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
		message = message .. index .. "\n"
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

craftSkills.unlearnSkill = function(pid, skill)

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
	if Players[pid].data.craftSkillsProgress[skill] ~= nil then
		pName = Players[pid].name
		if diffValue - Players[pid].data.craftSkillsProgress[skill] <= 0 then
			xpValue = 1
		else
			xpValue = diffValue - Players[pid].data.craftSkillsProgress[skill]
		end
		if Players[pid].data.craftSkillsProgress[skill] < craftingSkillsConfig.maxSkillProgress then
			Players[pid].data.craftSkillsProgress[skill] = Players[pid].data.craftSkillsProgress[skill] + xpValue
		else
			if Players[pid].data.craftSkills[skill] == raftingSkillsConfig.maxSkill then
				message = "Player " .. pName .. " has reached maxSkill in " .. skill
				craftSkillsLog(message)
				Players[pid].data.craftSkills[skill] = raftingSkillsConfig.maxSkill
			else
				skillName = craftingSkillsConfig.skillNames[skill]
				if skillName ~= nil then
					logMessage = "Increasing skill " .. skill .. " for " .. pname
					craftSkillsLog(logMessage)
					message = "You have become more proficient in " .. skillName .. ".\n" 
					craftSkillsMessage(message, pid)
				else
					craftSkillsLog("Skill name for " .. skill .. " is a nil, remember to set this in 'skillName'", "error")
				end
				Players[pid].data.craftSkills[skill] = Players[pid].data.craftSkills[skill] + (Players[pid].data.craftSkillsProgress[skill] / 3)
				Players[pid].data.craftSkillsProgress[skill] = 0
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
				--crafting menu goes here
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
		end
	end
	
	customEventHooks.registerHandler("OnGUIAction", craftSkills.OnGUIAction)
	customCommandHooks.registerCommand("craft", craftSkills.menu)
return craftSkills

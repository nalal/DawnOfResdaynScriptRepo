craftingSkillsConfig = require("craftingFunctionsConfig")
craftingRecipie = require("craftingRecipies")

local craftSkills = {}
--Global functions
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
	
return craftSkills
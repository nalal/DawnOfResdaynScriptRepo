craftingSkillsConfig = require("craftingFunctionsConfig")


--Variables/arrays
skillNames = {
	armorSmithing = "Armor Smithing"
	weaponSmithing = "Weapon Smithing"
}


--Global functions
craftSkillsLog = function(message, debugFlag)
	if debugFlag == "debug" then
		message = "[CS-DEBUG]: " .. message
	elseif debugFlag == nil or debugFlag == "normal" then
		message = "[CS]: " .. message
	elseif debugFlag == "error" then
		message = "[CS-ERROR]: " .. message
	else
		message = "[CS-ERROR]: Log was called but was given invalid debug flag, take a break and get some coffee, Nac"
	end
	tes3mp.LogMessage(enumerations.log.INFO, message)
end

craftSkillsMessage = function(message, pid)
	tes3mp.SendMessage(pid
end


--Call functions
local craftSkills = {}

	function craftSkills.increaseSkill(diffValue, skill, pid)
		if Players[pid].data.craftSkillsProgress[skill] ~= nil then
			if diffValue - Players[pid].data.craftSkillsProgress[skill] < 1 then
				xpValue = 1
			else
				xpValue = diffValue - Players[pid].data.craftSkillsProgress[skill]
			end
			if Players[pid].data.craftSkillsProgress[skill] < craftingSkillsConfig.maxSkillProgress then
				Players[pid].data.customSkillsProgress[skill] = Players[pid].data.craftSkillsProgress[skill] + xpValue
			else
				if Players[pid].data.craftSkills[skill] == 10 then
					Players[pid].data.customSkills[skill] = 10
				else
					skillName = skillNames[skill]
					message = "You have become more proficient in " .. skillName .. ".\n" 
					tes3mp.SendMessage(pid, message, false)
					Players[pid].data.craftSkills[skill] = Players[pid].data.craftSkills[skill] + (Players[pid].data.craftSkillsProgress[skill] / 3)
					Players[pid].data.craftSkillsProgress[skill] = 0
				end
			end
		else
			message0 = "Skill provided for function 'increaseSkill' was invalid/nil."
			if skill ~= nil then
				message1 = "Skill provided = " .. skill
			end
			craftSkillsLog(message0, "error")
			if message1 ~= nil then
				craftSkillsLog(message1, "debug")
			end
		end
	end
	
return craftSkills
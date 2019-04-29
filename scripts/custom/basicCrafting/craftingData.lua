local craftModData = {}

craftModData.OnPlayerFinishLogin = function(eventStatus, pid)
	if Players[pid].data.craftSkills == nil then
		Players[pid]:Message(color.Aqua .. "[SYSTEM]: You were missing save data for 'craftSkills', this has been fixed.\n")
		tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(Players[pid].pid) .. " was missing key player data from 'craftSkills', repairing now. ")
		Players[pid].data.craftSkills = {}
		tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(Players[pid].pid) .. "'s playerdata was repaired. ")
	end
	if Players[pid].data.craftSkillsProgress == nil then
		tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(Players[pid].pid) .. " was missing key player data from 'craftSkills', repairing now. ")
		Players[pid].data.craftSkillsProgress = {}
		tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(Players[pid].pid) .. "'s playerdata was repaired. ")
	end
end

customEventHooks.registerHandler("OnPlayerFinishLogin", craftModData.OnPlayerFinishLogin)

return craftModData

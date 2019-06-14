basicNeedsConfig = require("custom/basicNeeds/basicNeedsConfig")

local basicNeedsData = {}

basicNeedsData.OnPlayerFinishLogin = function(eventStatus, pid)
	if Players[pid].data.playerNeeds == nil then
		Players[pid]:Message(color.Aqua .. "[SYSTEM]: You were missing save data for 'playerNeeds', this has been fixed.\n")
		tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(Players[pid].pid) .. " was missing key player data from 'playerNeeds', repairing now. ")
		Players[pid].data.playerNeeds = {
			hunger = 0,
			thirst = 0,
			fatigue = 0
		}
		tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(Players[pid].pid) .. "'s playerdata was repaired. ")
	end
	if Players[pid].data.playerNeedsDebuffs == nil then
		Players[pid]:Message(color.Aqua .. "[SYSTEM]: You were missing save data for 'playerNeedsDebuffs', this has been fixed.\n")
		tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(Players[pid].pid) .. " was missing key player data from 'playerNeedsDebuffs', repairing now. ")
		Players[pid].data.playerNeedsDebuffs = {
			dehydrated = false,
			starving = false,
			exhausted = false,
		}
		tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(Players[pid].pid) .. "'s playerdata was repaired. ")
	end
	if Players[pid].data.playerResting == nil then
		tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(Players[pid].pid) .. " was missing key player data from 'playerResting', repairing now. ")
		Players[pid].data.playerResting = false
		tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(Players[pid].pid) .. "'s playerdata was repaired. ")
	end
	--
	if Players[pid].data.playerRoles == nil then
		Players[pid]:Message(color.Aqua .. "[SYSTEM]: You were missing save data for 'playerRoles', this has been fixed.\n")
		tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(Players[pid].pid) .. " was missing key player data from 'playerRoles', repairing now. ")
		Players[pid].data.playerRoles = { }
		tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(Players[pid].pid) .. "'s playerdata was repaired. ")
	end
end

customEventHooks.registerHandler("OnPlayerFinishLogin", basicNeedsData.OnPlayerFinishLogin)

return basicNeedsData

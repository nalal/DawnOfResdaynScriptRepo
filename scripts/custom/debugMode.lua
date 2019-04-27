debugConfig = require("custom/debugConfig")
local debugMode = {}

debugMode.OnPlayerFinishLogin = function(eventStatus, pid)
	if Players[pid].data.debugMode == nil then
		tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(Players[pid].pid) .. " was missing key player data from 'debugMode', repairing now. ")
		Players[pid].data.debugMode = false
		tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(Players[pid].pid) .. "'s playerdata was repaired. ")
	end
	if Players[pid].data.debugFlags == nil then
		tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(Players[pid].pid) .. " was missing key player data from 'debugFlags', repairing now. ")
		Players[pid].data.debugFlags = {}
		tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(Players[pid].pid) .. "'s playerdata was repaired. ")
	end

end

debugMode.Toggle = function(pid, args)
	if debugConfig.debugMode == true or admin then
		if args[2] ~= nil then
			if args[2] == "enable" then
				Players[pid].data.debugMode = true
				debugMode.messageCompiler(pid, "DEBUG MODE ENABLED.\n")
			elseif args[2] == "disable" then
				Players[pid].data.debugMode = false
				debugMode.messageCompiler(pid, "DEBUG MODE DISABLED..\n")
			end
		else
			debugMode.messageCompiler(pid, "INVALID DEBUG COMMAND/FLAG.\n")
		end
	else
		debugMode.messageCompiler(pid, "DEBUGMODE IS DISABLED.\n")
	end
end

function debugMode.messageCompiler(pid, message, colorOverride)
	if colorOverride == nil then
		Players[pid]:Message(color.Cyan .. "[SYSTEM]: " .. color.White .. message)
	else
		Players[pid]:Message(color.Cyan .. "[SYSTEM]: " .. color[colorOverride] .. message)
	end
end

customCommandHooks.registerCommand("debug", debugMode.Toggle)
customEventHooks.registerHandler("OnPlayerFinishLogin", debugMode.OnPlayerFinishLogin)

return debugMode

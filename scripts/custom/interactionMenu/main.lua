interactionConfig = require("custom/interactionMenu/main")

local interactionMenu = {}

	function interactionMenu.OnObjectActivate(eventStatus, pid, cellDescription, objects, players)
		interactionMenu.logHandler(tostring(type(eventStatus)), "debug")
		interactionMenu.logHandler(tostring(type(pid)), "debug")
		interactionMenu.logHandler(tostring(type(cellDescription)), "debug")
		interactionMenu.logHandler(tostring(type(objects)), "debug")
		interactionMenu.logHandler(tostring(type(players)), "debug")
	end

	function interactionMenu.logHandler(message, logType)
		if logType == "normal" or nil then
			message = "[I.-MENU]: " .. message
		elseif logType == "debug" then
			message = "[I.-MENU]DBG: " .. message
		elseif logType == "error" then
			message = "[I.-MENU]ERR: " .. message
		else
			interactionMenu.logHandler("Invalid log type.", "error")
			message = "[I.-MENU](invalid): " .. message
		end
	tes3mp.LogMessage(enumerations.log.INFO, message)
	end
	customEventHooks.registerHandler("OnObjectActivate", interactionMenu.OnObjectActivate)

return interactionMenu

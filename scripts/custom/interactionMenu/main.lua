interactionConfig = require("custom/interactionMenu/config")

local interactionMenu = {}

	function interactionMenu.OnObjectActivate(eventStatus, pid, cellDescription, objects, players)
		if players[1] ~= nil then
			local buffer = 1
			local pressee = players[1].pid
			local presser = players[1].activatingPid
			if pressee ~= nil and presser ~= nil then
				interactionMenu.logHandler("PRESSEE IS " .. pressee, "debug")
				interactionMenu.logHandler("PRESSER IS " .. presser, "debug")
			end
			if pressee ~= nil and presser ~= nil then
				local data = {
					presseePid = pressee,
					presserPid = presser
				}
				return data
			end
		end
	end

	function interactionMenu.logHandler(message, logType)
		if logType == "normal" or nil then
			message = "[I.-MENU]: " .. message
		elseif logType == "debug" and interactionConfig.debug == true then
			message = "[I.-MENU]DBG: " .. message
		elseif logType == "debug" and interactionConfig.debug == false then
			--do.thing("a thing")
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

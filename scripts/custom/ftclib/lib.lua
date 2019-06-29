local ftc = {}

	function ftc.msg(pid, message, scriptName)
		if scriptName == nil then
			scriptName = "UNKNOWN"
		end
		if message == nil then
			ftc.cli("Blank message given by scriptName: " .. scriptName, "FTCLIB", "error" )
			return false
		end
		if Players[pid] == nil then
			ftc.cli("invalid PID given by scriptName: " .. scriptName, "FTCLIB", "error" )
			return false
		else
			Players[pid]:Message(color.Cyan .. "[" .. scriptName .. "]: " .. color.White .. message)
		end
	end

	function ftc.cli(message, scriptName, mType)
		if scriptName == nil then
			scriptName = "UNKNOWN"
		end
		if message ~= nil then
			if mType == "normal" or mType == nil then
				message = "[" .. scriptName .. "]: " .. message
			elseif mType == "debug" then 
				message = "[" .. scriptName .. "-DBG]: " .. message
			elseif mType == "error" then
				message = "[" .. scriptName .. "-!ERR!]: " .. message
			else
				message = "[" .. scriptName .. "-(Invalid CLI Flag!)]: " .. message
			end 
			tes3mp.LogMessage(enumerations.log.INFO, message)
		else
			ftc.cli( "Invalid message from scriptName: " .. scriptName, "FTCLIB","error")
		end
	end

return ftc

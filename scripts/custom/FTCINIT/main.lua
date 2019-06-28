local FTCINIT = {}
	function FTCINIT.INIT()
		tes3mp.LogMessage(enumerations.log.INFO, "\n\n==[INITIALIZATION INFO]==\n" ..
			"DATE-TIME: " .. os.date("%c") .. "\n" ..
			"LOCATION: FTC-NorthAmerica\n" ..
			"SERVER: Dawn of Resdayn [Official Server]")
		end
	customEventHooks.registerHandler("OnServerPostInit", FTCINIT.INIT)
return FTCINIT

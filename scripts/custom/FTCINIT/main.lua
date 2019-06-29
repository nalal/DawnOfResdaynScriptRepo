local FTCINIT = {}
	function FTCINIT.INIT()
		tes3mp.LogMessage(enumerations.log.INFO, "\n\n==[INITIALIZATION INFO]==\n" ..
			"DATE-TIME: " .. os.date("%c") .. "\n" ..
			"LOCATION: FTC-NorthAmerica\n" ..
			"SERVER: Dawn of Resdayn [INTERNAL_TESTING]\n" .. 
			"==[*THIS SERVER IS INTENDED FOR TESTING AND SHOULD NOT BE CONFIGURED FOR PUBLIC ACCESS*]==\n")
		end
	customEventHooks.registerHandler("OnServerPostInit", FTCINIT.INIT)
return FTCINIT

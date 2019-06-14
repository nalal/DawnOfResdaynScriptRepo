fileHelper = require("fileHelper")
tableHelper = require("tableHelper")
betterBansConfig = require("custom/betterBans/config")

local betterBansJson = {}

	function bankBuddyJson.save(data)
		jsonInterface.save("banRegistrar.json", data)
		message = "Successfully saved ban registrar."
		message = "[BetterBansJSON]: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	end

	function bankBuddyJson.load(initData, dateNums)
		local registrar = jsonInterface.load("banRegistrar.json")
		tes3mp.LogMessage(enumerations.log.INFO, message)
		return registrar
	end

return betterBansJson

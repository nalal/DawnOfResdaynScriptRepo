fileHelper = require("fileHelper")
tableHelper = require("tableHelper")
bankBuddyConfig = require("custom/bankBuddy/config")

local bankBuddyJson = {}

	function bankBuddyJson.CreateAccount(accountName, accountData)
		accountData.accountHolder = accountName
		hasAccount = jsonInterface.save("BankBuddy/accounts/" .. accountName .. ".json", accountData)

		if hasAccount then
			message = "Successfully created JSON bank file for player " .. accountName
			message = "[BankBuddyJSON]: " .. message
			tes3mp.LogMessage(enumerations.log.INFO, message)
		else
			local message = "Failed to create JSON file for " .. accountName
			tes3mp.LogMessage(enumerations.log.INFO, message)
			tes3mp.SendMessage(self.pid, message, true)
			--tes3mp.Kick(self.pid)
		end
	end

	function bankBuddyJson.loadPlayerAccount()
		accountData = jsonInterface.load("BankBuddy/accounts/" .. accountFile .. ".json")

		-- JSON doesn't allow numerical keys, but we use them, so convert
		-- all string number keys into numerical keys
		tableHelper.fixNumericalKeys(accountData)
		return accountData
	end

	function bankBuddyJson.loadAccounts()
		accountData = jsonInterface.load("BankBuddy/" .. bankBuddyConfig.accountTableFileName .. ".json")
		return accountData
	end
	
	function bankBuddyJson.saveAccounts(accounts)
		jsonInterface.save("BankBuddy/" .. bankBuddyConfig.accountTableFileName .. ".json", accounts)
	end

return bankBuddyJson

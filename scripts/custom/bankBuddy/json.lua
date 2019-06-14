fileHelper = require("fileHelper")
tableHelper = require("tableHelper")
bankBuddyConfig = require("custom/bankBuddy/config")

local bankBuddyJson = {}

	--Create bank account
	function bankBuddyJson.CreateAccount(accountName, accountData, dateNums)
		accountData.accountHolder = accountName
		accountData.lastUse = dateNums
		hasAccount = jsonInterface.save("BankBuddy/accounts/" .. accountName .. ".json", accountData)

		if hasAccount then
			message = "Successfully created JSON bank file for player " .. accountName
			message = "[BankBuddyJSON]: " .. message
			tes3mp.LogMessage(enumerations.log.INFO, message)
		else
			local message = "Failed to create JSON file for " .. accountName
			tes3mp.LogMessage(enumerations.log.INFO, message)
			tes3mp.SendMessage(self.pid, message, true)
		end
	end

	--Update lastUse date
	function bankBuddyJson.dateUpdate(pid, dateSet)
		account = bankBuddyJson.loadPlayerAccount(pid)
		account.lastUse = nil
		account.lastUse = dateSet
		bankBuddyJson.savePlayerAccount(Players[pid].name, account)
	end

	function bankBuddyJson.savePlayerAccount(accountName, accountData)
		jsonInterface.save("BankBuddy/accounts/" .. accountName .. ".json", accountData)
	end

	function bankBuddyJson.loadPlayerAccount(pid)
		accountFile = Players[pid].name
		accountData = jsonInterface.load("BankBuddy/accounts/" .. accountFile .. ".json")
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

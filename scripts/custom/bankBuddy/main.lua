bankBuddyJson = require("custom/bankBuddy/json")
bankBuddyConfig = require("custom/bankBuddy/config")

bankAccount = {
	accountHolder = "",
	gold = 0,
	items = {}
}

accounts = {
	accountList = {}
}

logHandler = function(message, handleType)
	if(handleType == "normal" or handleType == nil) then
		message = "[BankBuddy]: " .. message
	elseif(handleType == "debug") then
		message = "[BankBuddy-DEBUG]: " .. message
	elseif(handleType == "error") then
		message = "[BankBuddy-ERROR]: " .. message
	else
		tes3mp.LogMessage(enumerations.log.INFO, "INVALID LOG TYPE IN SCRIPT [BankBuddy]")
		message = "[BankBuddy-(INVALID LOG TYPE)]: " .. message
	end
	
	tes3mp.LogMessage(enumerations.log.INFO, message)
end

local bankBuddy = {}

	function bankBuddy.withdrawlGold(pid)
		logHandler("withdrawlGold called by " .. Players[pid].name .. " but is not implemented.", "debug")
	end

	function bankBuddy.depositGold(pid)
		logHandler("depositGold called by " .. Players[pid].name .. " but is not implemented.", "debug")
	end

	function bankBuddy.addItem(pid)
		logHandler("addItem called by " .. Players[pid].name .. " but is not implemented.", "debug")
	end

	function bankBuddy.withdrawlItem(pid)
		logHandler("withdrawlItem called by " .. Players[pid].name .. " but is not implemented.", "debug")
	end

	function bankBuddy.loadBank(pid)
		accountName = Players[pid].name
		if(tableHelper.containsValue(accounts.accountList, accountName)) then
			logHandler("Creating bank account for " .. accountName)
			bankBuddyJson.loadAccount(accountName)
		else
			bankBuddyJson.CreateAccount(accountName, bankAccount)
			table.insert(accounts.accountList, accountName)
			bankBuddyJson.saveAccounts(accounts)
		end
		--logHandler("loadBank called by " .. Players[pid].name .. " but is not implemented.", "debug")
	end

	function bankBuddy.loginHandler(eventStatus, pid)
		logHandler("Loading bank info for " .. Players[pid].name .. ".", "debug")
		bankBuddy.loadBank(pid)
	end

	function bankBuddy.bankMenu(pid)
		logHandler("bankMenu called by " .. Players[pid].name .. " but is not implemented.", "debug")
	end

	function bankBuddy.loadBankData()
		accounts = bankBuddyJson.loadAccounts()
	end

	customEventHooks.registerHandler("OnServerPostInit", bankBuddy.loadBankData)
	customEventHooks.registerHandler("OnPlayerFinishLogin", bankBuddy.loginHandler)
	customCommandHooks.registerCommand("bank", bankBuddy.menu)
return bankBuddy

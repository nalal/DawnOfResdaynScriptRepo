--[[
[SCRIPT INFO]
Scrip Name:
	BankBuddy
	
Script Author:
	Nac(FTC)

Init Date:(DMY)
	4-6-2019
	
Script Description:
	Script is intended to act as a banking system for servers, settings can be found in the config.lua file in this scripts folder
]]--
bankBuddyJson = require("custom/bankBuddy/json")
bankBuddyConfig = require("custom/bankBuddy/config")

bankAccount = {
	accountHolder = "",
	gold = 0,
	items = {},
	lastUse = {
	}
}

accounts = {
	accountList = {}
}

logHandler = function(message, handleType)
	if(handleType == "normal" or handleType == nil) then
		message = "[BankBuddy]: " .. message
	elseif(handleType == "debug" and bankBuddyConfig.debugMode == true) then
		message = "[BankBuddy-DEBUG]: " .. message
	elseif(handleType == "error") then
		message = "[BankBuddy-ERROR]: " .. message
	elseif(bankBuddyConfig.debugMode == false and handleType == "debug") then
		--Do literally nothing, probably a right way to do it but w/e
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

	function bankBuddy.getDate()
		dateVal = {
			day = tonumber(os.date("%d")),
			month = tonumber(os.date("%m")),
			year = tonumber(os.date("%y"))
		}
		return dateVal
		--logHandler("DAY IS " .. day, "debug")
	end

	function bankBuddy.loadBank(pid)
		accountName = Players[pid].name
		if(tableHelper.containsValue(accounts.accountList, accountName)) then
			logHandler("User " .. accountName .. " has an existing bank account.")
		else
			dateNums = bankBuddy.getDate()
			logHandler("Creating bank account for " .. accountName)
			bankBuddyJson.CreateAccount(accountName, bankAccount, dateNums)
			table.insert(accounts.accountList, accountName)
			bankBuddyJson.saveAccounts(accounts)
		end
		--logHandler("loadBank called by " .. Players[pid].name .. " but is not implemented.", "debug")
	end

	function bankBuddy.loginHandler(eventStatus, pid)
		logHandler("Loading bank info for " .. Players[pid].name .. ".", "debug")
		bankBuddy.loadBank(pid)
	end

	function bankBuddy.logoutHandler(eventStatus, pid)
		--Not sure if I actually need this, lol
	end

	function bankBuddy.checkDate(pid)
		currentDate = bankBuddy.getDate()
		local account = bankBuddyJson.loadPlayerAccount(pid)
		local lastUsed = account.lastUse
		if(lastUsed.month < currentDate.month or lastUsed.year < currentDate.year) then
			return true
		else
			return false
		end
	end

	function bankBuddy.getIntrestVal(accountDate, currentDate)
		local total = 0
		if(accountDate.year < currentDate.year)then
			total = (currentDate.year - accountDate.year) * 12
			total = total + (currentDate.month - accountDate.month)
		elseif(accountDate.year >= currentDate.year and currentDate.month < accountDate.month)then
			total = currentDate.month - accountDate.month
		end
		if(total <= 0)then
			total = 1
		end
		return total
	end

	function bankBuddy.transferGold(pidFrom, pidTo, total)
		fromAccount = bankBuddyJson.loadPlayerAccount(pidFrom)
		toAccount = bankBuddyJson.loadPlayerAccount(pidTo)
		fromAccount.gold = fromAccount.gold - total
		toAccount.gold = toAccount.gold + total
		bankBuddyJson.savePlayerAccount(Players[pidFrom].name, fromAccount)
		bankBuddyJson.savePlayerAccount(Players[pidTo].name, toAccount)
	end

	function bankBuddy.checkIntrest(pid)
		logHandler("Checking intrest for " .. Players[pid].name)
		local account = bankBuddyJson.loadPlayerAccount(pid)
		local canGetIntrest = bankBuddy.checkDate(pid)
		if(canGetIntrest) then
			local dateVal = bankBuddy.getDate()
			logHandler("USER CAN GET INTREST","debug")
			bankBuddyJson.dateUpdate(pid, dateVal)
			money = account.gold
			if(money == 0) then
				logHandler("USER HAS NO MONEY","debug")
				return 0
			else
				money = money + (((money / 100) * 5) * (bankBuddy.getIntrestVal(account.lastUse, dateVal)))
				logHandler("USER MONEY IS NOW " .. money,"debug")
			end
			account.gold = money
			bankBuddyJson.savePlayerAccount(Players[pid].name, account)
		else
			logHandler("USER CAN'T GET INTREST","debug")
		end
		return 0
	end
	
	function bankBuddy.bankMenu(pid)
		bankBuddy.checkIntrest(pid)
		tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.mainMenu, "Welcome to the Bank, what would you like to do?\nTHESE BUTTONS DO FUCKING NOTHING!", "Check Account;Transfer Gold;Withdraw;Deposit")
		logHandler("bankMenu called by " .. Players[pid].name .. " but is not implemented.", "debug")
	end

	function bankBuddy.loadBankData()
		accounts = bankBuddyJson.loadAccounts()
	end

	customEventHooks.registerHandler("OnServerPostInit", bankBuddy.loadBankData)
	customEventHooks.registerHandler("OnPlayerFinishLogin", bankBuddy.loginHandler)
	customEventHooks.registerHandler("OnPlayerDisconnect", bankBuddy.logoutHandler)
	customCommandHooks.registerCommand("bank", bankBuddy.bankMenu)
return bankBuddy

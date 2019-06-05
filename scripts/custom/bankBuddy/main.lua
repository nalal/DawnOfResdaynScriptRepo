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
	elseif(handleType == "alert")then
		message = "[BankBuddy-!ALERT!]: " .. message
	elseif(bankBuddyConfig.debugMode == false and handleType == "debug") then
		--Do literally nothing, probably a right way to do it but w/e
	else
		tes3mp.LogMessage(enumerations.log.INFO, "INVALID LOG TYPE IN SCRIPT [BankBuddy]")
		message = "[BankBuddy-(INVALID LOG TYPE)]: " .. message
	end
	
	tes3mp.LogMessage(enumerations.log.INFO, message)
end

local bankBuddy = {}

	function bankBuddy.getGoldInventory(pid)
		local gold = 0
		for Index, Value in pairs( Players[pid].data.inventory ) do
			if(Value.refid == "gold_001")then
				logHandler("FOUND GOLD IN INVENTORY.", "debug")
				gold = tonumber(Value.count)
				logHandler("GOLD VALUE IS " .. gold, "debug")
			end
		end
		return gold
	end
	
	function bankBuddy.setGoldInventory(pid, val)
		local gold = 0
		for Index, Value in pairs( Players[pid].data.inventory ) do
			if(Value.refid == "gold_001")then
				logHandler("FOUND GOLD IN INVENTORY.", "debug")
				gold = tonumber(Value.count)
				logHandler("GOLD VALUE IS " .. gold, "debug")
			end
		end
		return gold
	end
	
	function bankBuddy.hasGold(pid, total)
		local isTrue = false
		local goldInInventory = bankBuddy.getGoldInventory(pid)
		if(goldInInventory > total)then
			isTrue = true
		end
		return isTrue
	end

	function bankBuddy.withdrawlGold(pid, total)
		logHandler("withdrawlGold called by " .. Players[pid].name .. " but is not implemented.", "debug")
	end

	function bankBuddy.depositGold(pid, total)
		if(bankBuddy.hasGold(pid, total))then
			
		else
			logHandler("Player " .. Players[pid].name .. " tried to deposit more gold than they have.", "debug")
		end
	end

	function bankBuddy.addItem(pid, total, item)
		logHandler("addItem called by " .. Players[pid].name .. " but is not implemented.", "debug")
	end

	function bankBuddy.withdrawlItem(pid, total, item)
		logHandler("withdrawlItem called by " .. Players[pid].name .. " but is not implemented.", "debug")
	end

	function bankBuddy.getDate()
		dateVal = {
			day = tonumber(os.date("%d")),
			month = tonumber(os.date("%m")),
			year = tonumber(os.date("%y")),
			POSIX = tonumber(os.time())
		}
		return dateVal
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

	function bankBuddy.getPOSIXDate()
		total = tonumber(os.time())
		return total
	end

	function bankBuddy.getIntrestVal(accountDate, currentDate)
		local total = 0
		UTCNow = bankBuddy.getPOSIXDate()
		UTCAccount = accountDate.POSIX
		total = UTCNow - UTCAccount
		total = ((total / 60) /60) /24
		logHandler("TOTAL IS " .. total, "debug")
		logHandler("UTCNow IS " .. UTCNow, "debug")
		logHandler("UTCAccount IS " .. UTCAccount, "debug")
		if(total <= 0)then
			total = 1
		end
		return total
	end

	function bankBuddy.getTotalItems(pid)
		local Count = 0
		index = bankBuddyJson.loadPlayerAccount(pid)
		for Index, Value in pairs( index.items ) do
			Count = Count + 1
		end
		return Count
	end

	function bankBuddy.getTotalInventoryItems(pid)
		local Count = 0
		index = Players[pid].data.inventory
		for Index, Value in pairs( index ) do
			Count = Count + 1
		end
		return Count
	end
	
	function bankBuddy.getTotalArray(array)
		local Count = 0
		local dex = array
		if(tostring(type(dex)) == "table" or tostring(type(dex)) == "function")then
			for Index, Value in pairs( dex ) do
				Count = Count + 1
			end
		else
			logHandler("ARRAY IS NOT TABLE, VALUE IS " .. dex,"debug")
		end
		return Count
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
		local canGetIntrest = bankBuddy.checkDate(pid)
		if(canGetIntrest and bankBuddyConfig.intrestRateToggle) then
			local account = bankBuddyJson.loadPlayerAccount(pid)
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
	
	function bankBuddy.getGoldCount(pid)
		local account = bankBuddyJson.loadPlayerAccount(pid)
		local dosh = account.gold
		return dosh
	end
	
	function bankBuddy.getItemsStored(pid)
		local itemList = ""
		if(bankBuddy.getTotalItems(pid) > 0)then
			local targetAccount = bankBuddyJson.loadPlayerAccount(pid)
			for Index, Value in pairs( targetAccount.items ) do
				itemList = itemList .. "-" .. Index .. ":" .. Value .. "\n"
			end
		else
			itemList = "*none*"
		end
		return itemList
	end

	function bankBuddy.getItemList(pid)
		local itemList = {
			itemsShow = "",
			itemsList = {}
		}
		if(bankBuddy.getTotalInventoryItems(pid) > 0)then
			local targetInventory = Players[pid].data.inventory
			for index, Value in pairs( targetInventory ) do
				if(targetInventory[index].refId ~= "gold_001")then
					logHandler("ITEM IS " .. targetInventory[index].refId,"debug")
					itemList.itemsShow = itemList.itemsShow .. targetInventory[index].refId .. "\n"
					itemAdd = targetInventory[index].refId
					table.insert(itemList.itemsList, itemAdd)
				end
			end
		else
			itemList = "*none*"
		end
		return itemList
	end	

	function bankBuddy.accountInfoMenu(pid)
		tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.accountInfoMenu, "Here is your current account balance and items in safety deposit.\nGold: \n" .. bankBuddy.getGoldCount(pid) .. "\nItems: \n" .. bankBuddy.getItemsStored(pid), "Back;Close")
	end

	function bankBuddy.withdrawMenu(pid)
		tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.withdrawMenu, "Would you like to withdraw gold or items?", "Gold;Items;Close")
	end
	
	function bankBuddy.withdrawItemMenu(pid)
	end
	
	function bankBuddy.withdrawGoldMenu(pid)
		tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.withdrawGoldMenu, "How much would you like to withdraw?", "All;Specific Ammount;Close")
	end

	function bankBuddy.depositMenu(pid)
		tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.depositMenu, "Would you like to deposit gold or items?", "Gold;Items;Close")
	end

	function bankBuddy.depositItemsMenu(pid)
		logHandler("GETTING INVENTORY LIST", "debug")
		items = bankBuddy.getItemList(pid)
		tes3mp.ListBox(pid, bankBuddyConfig.menuIDArray.depositItemsMenu, "What item would you like to deposit?", items.itemsShow)
	end

	function bankBuddy.depositGoldMenu(pid)
		tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.depositGoldMenu, "How much would you like to deposit?", "All;Specific Ammount;Close")
	end

	function bankBuddy.transferMenu(pid)
		tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.withdrawMenu, "How much would you like to transfer?", "Confirm;Back;Close")
	end

	function bankBuddy.getButtons()
		local buttons = "Withdraw;Deposit;Check Account"
		if(bankBuddyConfig.allowTransfers)then
			buttons = buttons .. ";Transfer Gold"
		end
		return buttons
	end

	function bankBuddy.checkCell(pid)
		if(tableHelper.containsValue(bankBuddyConfig.cellList, Players[pid].data.location.cell))then
			return false
		else
			return true
		end
	end
	
	function bankBuddy.adminMenu(pid)
		tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.withdrawMenu, "Nothin here but us frogs.", "Close")
	end
	
	function bankBuddy.bankMenu(pid)
		if(bankBuddyConfig.limitToCell and tableHelper.containsValue(bankBuddyConfig.cellList, Players[pid].data.location.cell))then
			bankBuddy.checkIntrest(pid)
			logHandler("bankMenu called by " .. Players[pid].name .. " from valid cell.", "debug")
			tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.mainMenu, "Welcome to the Bank, what would you like to do?", bankBuddy.getButtons())
		elseif(bankBuddyConfig.limitToCell and bankBuddy.checkCell(pid))then
			logHandler("bankMenu called by " .. Players[pid].name .. " but is prohibited from current cell.", "debug")
			tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.invalidMenu, "You cannot check your bank from here.","Close")
		else
			bankBuddy.checkIntrest(pid)
			logHandler("bankMenu called by " .. Players[pid].name .. ".", "debug")
			tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.mainMenu, "Welcome to the Bank, what would you like to do?", bankBuddy.getButtons())
		end
	end

	function bankBuddy.loadBankData()
		accounts = bankBuddyJson.loadAccounts()
	end

	function bankBuddy.messageCompiler(pid, message, colorOverride)
		if colorOverride == nil then
			Players[pid]:Message(color.Cyan .. "[" .. bankBuddyConfig.chatName .. "]: " .. color.White .. message)
		else
			Players[pid]:Message(color.Cyan .. "[" .. bankBuddyConfig.chatName .. "]: " .. color[colorOverride] .. message)
		end
	end

	function bankBuddy.commandHandler(pid,cmds)
		if(cmds[2] ~= nil)then
			if(cmds[2] == "account")then
				if(cmds[3] == "info")then
					message = "Gold: \n" .. bankBuddy.getGoldCount(pid) .. "\nItems: \n" .. bankBuddy.getItemsStored(pid) .. "\n"
					bankBuddy.messageCompiler(pid, message)
				else
					message = "Invalid bank account command"
					bankBuddy.messageCompiler(pid, message)
				end
			elseif(cmds[2] == "admin")then
				if(Players[pid].data.settings.staffRank > 2)then
					bankBuddy.adminMenu(pid)
				else
				logHandler("!UNAUTHORIZED USER ATTEMPTED TO USE ADMIN MENU FOR BANK!", "alert")
					message = "You do not have the permission required for this menus, this has been logged."
					local accountsFile = bankBuddyJson.loadAccounts()
					local reportPacket = {
						name = Players[pid].name,
						dateOf = bankBuddy.getDate()
					}
					table.insert(accountsFile.unauthorizedAdminAccessRequests, reportPacket)
					bankBuddy.messageCompiler(pid, message)
					bankBuddyJson.saveAccounts(accountsFile)
				end
			else
				message = "Invalid bank command"
				bankBuddy.messageCompiler(pid, message, color.Red)
			end
		else
			bankBuddy.bankMenu(pid)
		end
	end

	function bankBuddy.OnGUIAction(eventStatus, pid, idGui, data)
		if(idGui == bankBuddyConfig.menuIDArray.mainMenu)then
			if(tonumber(data) == 0)then
				bankBuddy.accountInfoMenu(pid)
			elseif(tonumber(data) == 1)then
				bankBuddy.depositMenu(pid)
			elseif(tonumber(data) == 2)then
				bankBuddy.withdrawMenu(pid)
			elseif(tonumber(data) == 3)then
				bankBuddy.transferMenu(pid)
			else
				logHandler("INVALID DATA INDEX VALUE " .. tonumber(data) .. "  FOR MENU ID " .. idGui,"error")
			end
		elseif(idGui == bankBuddyConfig.menuIDArray.withdrawMenu)then
			if(tonumber(data) == 0)then
				withdrawGoldMenu(pid)
			elseif(tonumber(data) == 1)then
				withdrawItemMenu(pid)
			else
				logHandler("INVALID DATA INDEX VALUE " .. tonumber(data) .. "  FOR MENU ID " .. idGui,"error")
			end
		elseif(idGui == bankBuddyConfig.menuIDArray.depositMenu)then
			if(tonumber(data) == 0)then
				bankBuddy.depositGoldMenu(pid)
			elseif(tonumber(data) == 1)then
				bankBuddy.depositItemsMenu(pid)
			else
				logHandler("INVALID DATA INDEX VALUE " .. tonumber(data) .. "  FOR MENU ID " .. idGui,"error")
			end
		elseif(idGui == bankBuddyConfig.menuIDArray.withdrawGoldMenu)then
			if(tonumber(data) == 0)then
			end
		elseif(idGui == bankBuddyConfig.menuIDArray.depositGoldMenu)then
			if(tonumber(data) == 0)then
				bankBuddy.depositGold(pid, "all")
			elseif(tonumber(data) == 1)then
				bankBuddy.totalInputGoldMenu(pid)
			end
		else
			logHandler("INVALID idGui INDEX VALUE " .. idGui,"error")
		end
	end
	
	customEventHooks.registerHandler("OnGUIAction", bankBuddy.OnGUIAction)
	customEventHooks.registerHandler("OnServerPostInit", bankBuddy.loadBankData)
	customEventHooks.registerHandler("OnPlayerFinishLogin", bankBuddy.loginHandler)
	customEventHooks.registerHandler("OnPlayerDisconnect", bankBuddy.logoutHandler)
	customCommandHooks.registerCommand("bank", bankBuddy.commandHandler)
return bankBuddy

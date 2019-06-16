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
	
Notes:
	Holy shit Nac, need to add more comments, I can't tell what most shit here does and I wrote it
]]--
bankBuddyJson = require("custom/bankBuddy/json")
bankBuddyMySQL = require("custom/bankBuddy/mysql")
bankBuddyConfig = require("custom/bankBuddy/config")

local bankBuddy = {}

function bankBuddy.getDate()
	dateVal = {
		day = tonumber(os.date("%d")),
		month = tonumber(os.date("%m")),
		year = tonumber(os.date("%y")),
		POSIX = tonumber(os.time())
	}
	return dateVal
end

function bankBuddy.getDateString()
	local dateBuffer = bankBuddy.getDate()
	local currentDate = dateBuffer.day .. "/" .. dateBuffer.month .. "/" .. dateBuffer.year .. "-(POSIX):" .. dateBuffer.POSIX
	return currentDate
end

bankAccount = {
	accountHolder = "",
	gold = 0,
	items = {},
	lastUse = {},
	transactionHistory = {{
		tType = "Initialization date",
		tItem = "N/A",
		tTotal = "N/A",
		tDate = bankBuddy.getDateString(),
		tID = 0
	}}
}

depositID = 0

activeDeposits = {}

activeWithdraws = {}

onUsers = {}

accounts = {
	accountList = {},
	unauthorizedAdminAccessRequests = {},
	transactionHistory = {{
		tType = "Initialization date",
		tItem = "N/A",
		tTotal = "N/A",
		tDate = bankBuddy.getDateString(),
		tPlayer = "N/A",
		tID = 0
	}}
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
	elseif(handleType == "warn")then
		message = "[BankBuddy-WARNING]: " .. message
	elseif(bankBuddyConfig.debugMode == false and handleType == "debug") then
		--Do literally nothing, probably a right way to do it but w/e
	else
		tes3mp.LogMessage(enumerations.log.INFO, "INVALID LOG TYPE IN SCRIPT [BankBuddy]")
		message = "[BankBuddy-(INVALID LOG TYPE)]: " .. message
	end
	
	tes3mp.LogMessage(enumerations.log.INFO, message)
end

	function bankBuddy.getGoldInventory(pid)
		local gold = 0
		for Index, Value in pairs( Players[pid].data.inventory ) do
			if(Value.refid == "gold_001")then
				logHandler("FOUND GOLD IN INVENTORY.", "debug")
				gold = Value.count
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
		local goldInInventory = bankBuddy.getTotalGold(pid)
		if(goldInInventory >= total)then
			isTrue = true
			logHandler("Player " .. Players[pid].name ..  " has exactly or more than " .. total, "debug")
		else
			logHandler("Player " .. Players[pid].name .. " does not have " .. total, "debug")
		end
		return isTrue
	end

	function bankBuddy.withdrawlGold(pid, total)
		logHandler("withdrawlGold called by " .. Players[pid].name .. " but is not implemented.", "debug")
	end

	function bankBuddy.getID(pid)
		local ID = 0
		local account = bankBuddyJson.loadPlayerAccount(pid)
		for Index, Value in pairs(account.transactionHistory) do
			ID = Value.tID + 1
		end
		return ID
	end

	function bankBuddy.getIDMain()
		local ID = 0
		local account = bankBuddyJson.loadAccounts()
		for Index, Value in pairs(account.transactionHistory) do
			ID = Value.tID + 1
		end
		return ID
	end

	function bankBuddy.depositGold(pid, total)
		logHandler("DEPOSITING " .. total .. " GOLD FOR " .. Players[pid].name, "debug")
		if(bankBuddy.hasGold(pid, total) == true)then
		local account = bankBuddyJson.loadPlayerAccount(pid)
			if(total ~= "all" and total >0)then
				account.gold = account.gold + total
				inventoryHelper.removeItem(Players[pid].data.inventory, "gold_001", total)
				
				local currentDate = bankBuddy.getDateString()
				logHandler("Adding transaction log on date " .. currentDate)
				local transactionData = {
					tType = "Deposit",
					tItem = "Gold",
					tTotal = total,
					tDate = currentDate,
					tID = bankBuddy.getID(pid)
				}
				table.insert(account.transactionHistory, transactionData)
				bankBuddyJson.savePlayerAccount(Players[pid].name, account)
				bankBuddy.genericInfoBox(pid, "You have deposited " .. total .. " gold.")
			elseif(total ~= "all" and total <= 0)then
				logHandler("Player " .. Players[pid].name .. " tried to deposit " .. total .. " gold but this value is less than 0.")
				bankBuddy.genericInfoBox(pid, "You cannot deposit a negative number.")
			else
				total = bankBuddy.getTotalGold(pid)
				bankBuddy.depositGold(pid, total)
			end
		else
			logHandler("Player " .. Players[pid].name .. " tried to deposit more gold than they have.", "debug")
			bankBuddy.genericInfoBox(pid, "You do not have enough gold for that size of deposit.")
		end
	end

	function bankBuddy.withdrawlItem(pid, total, item)
		logHandler("withdrawlItem called by " .. Players[pid].name .. " but is not implemented.", "debug")
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
		local hasAcc = bankBuddyMySQL.checkAccount(Players[pid].name)
		if hasAcc == 0 then
			bankBuddyMySQL.createAccount(Players[pid].name)
		elseif hasAcc == 1 then
			logHandler("Player " .. Players[pid].name .. " logged in with existing account")
		else
			logHandler ("PID " .. pid .. " is either tied to a null player name or something has gone really wrong...", "error")
		end
		logHandler("Loading bank info for " .. Players[pid].name .. ".", "debug")
		bankBuddy.loadBank(pid)
		local onUser = {
			PID = pid,
			User = Players[pid].name
		}
		if(onUsers ~= nil)then
			for Index, Value in pairs(onUsers) do
				if(Value.PID == pid or Value.User == Players[pid].name)then
					logHandler("Player " .. Players[pid].name .. " joined but was already registered in list.")
					table.remove(onUsers, Index)
				end
			end
		end
		logHandler("Player " .. Players[pid].name .. " added to onUsers list.", "debug")
		table.insert(onUsers, onUser)
	end

	function bankBuddy.logoutHandler(eventStatus, pid)
		logHandler("PID " .. pid .. " logged out, performing cleanup...")
		bankBuddy.cleanDeposit(pid)
		bankBuddy.cleanOnUsers(pid)
	end

	function bankBuddy.checkDate(pid)
		currentDate = bankBuddy.getDate()
		local account = bankBuddyJson.loadPlayerAccount(pid)
		local lastUsed = account.lastUse
		if(math.floor(((lastUsed.POSIX / 60)/60)/24) < math.floor(((currentDate.POSIX / 60)/60)/24)) then
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
		if(total < 0)then
			total = 0
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

	function bankBuddy.transferGold(pidFrom, playerTo, total)
		fromAccount = bankBuddyJson.loadPlayerAccount(pidFrom)
		if(fromAccount.gold >= total)then
			toAccount = bankBuddyJson.loadPlayerAccount(nil,playerTo)
			fromAccount.gold = fromAccount.gold - total
			toAccount.gold = toAccount.gold + total
			bankBuddyJson.savePlayerAccount(Players[pidFrom].name, fromAccount)
			bankBuddyJson.savePlayerAccount(playerTo, toAccount)
		else
			logHandler("Player " .. Players[pid].name .. " attempted to transfer more gold than they have in their account.", "debug")
		end
	end

	function bankBuddy.checkIntrest(pid)
		logHandler("Checking intrest for " .. Players[pid].name)
		local canGetIntrest = bankBuddy.checkDate(pid)
		if(canGetIntrest and bankBuddyConfig.intrestRateToggle) then
			local account = bankBuddyJson.loadPlayerAccount(pid)
			local dateVal = bankBuddy.getDate()
			logHandler("USER CAN GET INTREST","debug")
			money = account.gold
			if(money == 0) then
				logHandler("USER HAS NO MONEY","debug")
				return 0
			else
				bankBuddyJson.dateUpdate(pid, dateVal)
				money = money + (((money / 100) * 5) * (bankBuddy.getIntrestVal(account.lastUse, dateVal)))
				money = math.floor(money)
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
				itemList = itemList .. "-" .. Value.iName .. ":" .. Value.iTotal .. "\n"
			end
		else
			itemList = "*none*"
		end
		return itemList
	end

	function bankBuddy.getAccountItemList(pid)
		local items = {
			itemsArray = {},
			itemsString = ""
		}
		local account = bankBuddyJson.loadPlayerAccount(pid)
		for Index, Value in pairs(account.items) do
			table.insert(items.itemsArray, Value.iName)
			items.itemsString = items.itemsString .. Value.iName .. "\n"
		end
		return items
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
	
	function bankBuddy.getTotalGold(pid)
		local Count = -1
		index = Players[pid].data.inventory
		for Index, Value in pairs( index ) do
			if(Value.refId == "gold_001")then
				Count = Value.count
			end
		end
		if(Count == -1)then
			logHandler("Could not find gold in player inventory for " .. Players[pid].name .. ".", "error")
		else
			logHandler("FOUND " .. Count .. " GOLD ON PLAYER " .. Players[pid].name)
		end
		return Count
	end

	function bankBuddy.genericInfoBox(pid, info)
		tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.genericInfoBoxID, info, "Close")
	end	

	function bankBuddy.accountInfoMenu(pid)
		tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.accountInfoMenu, "Here is your current account balance and items in safety deposit.\n\nGold: " .. bankBuddy.getGoldCount(pid) .. "\nItems: \n" .. bankBuddy.getItemsStored(pid), "Transaction History;Back;Close")
	end

	function bankBuddy.withdrawMenu(pid)
		tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.withdrawMenu, "Would you like to withdraw gold or items?", "Gold;Items;Close")
	end
	
	function bankBuddy.withdrawItemMenu(pid)
		items = bankBuddy.getAccountItemList(pid)
		tes3mp.ListBox(pid, bankBuddyConfig.menuIDArray.withdrawItemsMenuID, "Which item would you like to withdraw?", items.itemsString)
	end
	
	function bankBuddy.withdrawItemCountTypeMenu(pid)
		tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.withdrawItemCountTypeMenuID, "How many items would you like to withdraw?", "All;Specific Ammount;Close")
	end
	
	function bankBuddy.withdrawSpecificItemMenu(pid)
		tes3mp.InputDialog(pid, bankBuddyConfig.menuIDArray.withdrawSpecificItemMenu, "Please specify a total.", "Total number of items you can withdraw for this item: " .. tostring(bankBuddy.getMaxItemsW(pid)))
	end
	
	function bankBuddy.withdrawGoldMenu(pid)
		tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.withdrawGoldMenu, "How much would you like to withdraw?", "All;Specific Ammount;Close")
	end

	function bankBuddy.depositMenu(pid)
		tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.depositMenu, "Would you like to deposit gold or items?", "Gold;Items;Close")
	end

	function bankBuddy.depositItemsMenu(pid)
		logHandler("GETTING INVENTORY LIST FOR " .. Players[pid].name, "debug")
		items = bankBuddy.getItemList(pid)
		tes3mp.ListBox(pid, bankBuddyConfig.menuIDArray.depositItemsMenu, "What item would you like to deposit?", items.itemsShow)
	end

	function bankBuddy.depositItemsTotalMenu(pid)
		tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.depositItemsTotalMenuID, "How many would you like to deposit?", "All;Specific Ammount;Close")
	end

	function bankBuddy.depositGoldMenu(pid)
		local total = bankBuddy.getTotalGold(pid)
		if(total > 0)then
			tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.depositGoldMenu, "How much would you like to deposit?", "All;Specific Ammount;Close")
		else
			bankBuddy.genericInfoBox(pid, "You have no gold in your account.")
		end
	end
	
	function bankBuddy.totalInputGoldMenu(pid)
		logHandler("GETTING TOTAL GOLD FOR " .. Players[pid].name, "debug")
		tes3mp.InputDialog(pid, bankBuddyConfig.menuIDArray.depositGoldSpecificID, "Please specify a total.", "Total gold you can deposit: " .. tostring(bankBuddy.getTotalGold(pid)))
	end

	function bankBuddy.transferMenu(pid)
		tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.withdrawMenu, "How much would you like to transfer?", "Confirm;Back;Close")
	end
	
	function bankBuddy.depositItemSpecific(pid)
		tes3mp.InputDialog(pid, bankBuddyConfig.menuIDArray.depositItemSpecificID, "Please specify a total.", "Total number of items you can deposit for this item: " .. tostring(bankBuddy.getMaxItems(pid)))
	end

	function bankBuddy.depositItemErrorMenu(pid)
		tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.depositItemErrorMenuID, "You must use a number here.", "Back")
	end

	function bankBuddy.fixBrokenRemoveArtifacts(pid)
		logHandler("Fixing retarded nulls in the inventory table for SOME REASON.")
		for Index, Value in pairs(Players[pid].data.inventory)do
			if(tostring(Value) == "null")then
				table.remove(Players[pid].data.inventory, Index)
			end
		end
		Players[pid]:SaveEquipment()
		Players[pid]:SaveInventory()
		Players[pid]:LoadInventory()
		Players[pid]:LoadEquipment()
	end

	function bankBuddy.depositItems(pid, total)
		local ItemID = bankBuddy.getItemRefId(pid)
		if(total == "all")then
			bankBuddy.depositItems(pid, bankBuddy.getMaxItems(pid))
		else
			if(ItemID ~= nil)then
				logHandler("ItemID IS " .. ItemID,"debug")
				local ind = bankBuddy.getIndex(pid, ItemID)
				if(bankBuddy.isEquipped(pid, ItemID) ~= true or bankBuddy.stackTotal(pid, refId) > 1)then
					if(bankBuddy.getMaxItems(pid) < total)then
						logHandler("Total given to deposit for " .. Players[pid].name .. " is more than total items.","Error")
					else
						local account = bankBuddyJson.loadPlayerAccount(pid, ItemID)
						if(bankBuddy.itemInAccount(pid, ItemID) ~= true)then
							if(Players[pid].data.inventory[ind].count == total)then
								local item = {
									iTotal = total,
									iName = ItemID
								}
								table.insert(account.items, item)
								inventoryHelper.removeItem(Players[pid].data.inventory, ItemID, total)
							else
								local item = {
									iTotal = total,
									iName = ItemID
								}
								table.insert(account.items, item)
								inventoryHelper.removeItem(Players[pid].data.inventory, ItemID, total)
							end
						else
							for Index, Value in pairs( account.items ) do
								if(Value.refId == ItemID)then
									acount.items[index].count = acount.items[index].count + total
									inventoryHelper.removeItem(Players[pid].data.inventory, ItemID, total)
								end
							end
						end
						bankBuddy.fixBrokenRemoveArtifacts(pid)
						bankBuddyJson.savePlayerAccount(Players[pid].name, account)
						logHandler("Player " .. Players[pid].name .. " deposited " .. total .. " " .. ItemID .. "'s.")
						bankBuddy.addTransactionHistory(pid, ItemID, total, "deposit")
					end
				else
					bankBuddy.genericInfoBox(pid, "You cannot deposit an item that is equipped.")
					logHandler("Player " .. Players[pid].name .. " attempted to deposit an equipped item.","Error")
				end
			else
				logHandler("ItemID for deposit is nil, terminating execution.","Error")
			end
		end
		bankBuddy.cleanDeposit(pid)
	end

	function bankBuddy.addTransactionHistory(pid, item, total, tAType)
		local account = bankBuddyJson.loadPlayerAccount(pid)
		local transactionData = {
			tType = tAType,
			tTotal = total,
			tID = bankBuddy.getID(pid),
			tItem = item,
			tDate = bankBuddy.getDateString()
		}
		local transactionLogData = {
			tType = tAType,
			tTotal = total,
			tID = bankBuddy.getIDMain(),
			tItem = item,
			tDate = bankBuddy.getDateString(),
			tPlayer = Players[pid].name
		}
		table.insert(account.transactionHistory, transactionData)
		bankBuddyJson.savePlayerAccount(Players[pid].name, account)
		local mainAccount =  bankBuddyJson.loadAccounts()
		table.insert(mainAccount.transactionHistory, transactionLogData)
		bankBuddyJson.saveAccounts(mainAccount)
	end

	function bankBuddy.withdrawItem(pid, data)
		if(data ~= "all")then
			if(data <= bankBuddy.getMaxItemsW(pid))then
				local account = bankBuddyJson.loadPlayerAccount(pid)
				local targID
				local UID = pid .. Players[pid].name
				for Index, Value in pairs(activeWithdraws)do
					if(Value.UID == UID)then
						logHandler("targID IS " .. Value.IID, "debug")
						targID = Value.IID
					end
				end
				local item = account.items[targID].iName
				if(account.items[targID].iTotal == data)then
					table.remove(account.items[targID])
				elseif(account.items[targID].iTotal > data)then
					account.items[targID].iTotal = account.items[targID].iTotal - data
				end
				inventoryhelper.addItem(Players[pid].data.inventory, ItemID, data)
				bankBuddy.addTransactionHistory(pid, item, data, "withdraw")
			else
				bankBuddy.genericInfoBox(pid, "You cannot withdraw more items than you have in the bank.")
			end
		elseif(data == "all")then
			bankBuddy.withdrawItem(pid, bankBuddy.getMaxItemsW(pid))
		end
	end

	function bankBuddy.getNameFromOnUsers(pid)
		local rVal = ""
		for Index, Value in pairs(onUsers)do
			if(Value.PID == pid)then
				rVal = Value.User
			end
		end
		return rVal
	end

	function bankBuddy.cleanOnUsers(pid)
		for Index, Value in pairs(onUsers)do
			if(Value.PID == pid)then
				logHandler("Player " .. Value.PID .. " removed from list onUsers at index " .. Index .. ".")
				table.remove(onUsers, Index)
			end
		end
	end

	function bankBuddy.cleanWithdraw(pid)
		local targIndex = 0
		local name = bankBuddy.getNameFromOnUsers(pid)
		for Index, Value in pairs(activeDeposits)do
			if(Value.UID == pid .. name)then
				table.remove(activeWithdraws, Index)
				logHandler("Removed active withdraw for " .. name .. ".")
			end
		end
	end

	function bankBuddy.cleanDeposit(pid)
		local targIndex = 0
		local name = bankBuddy.getNameFromOnUsers(pid)
		for Index, Value in pairs(activeDeposits)do
			if(Value.UID == pid .. name)then
				table.remove(activeDeposits, Index)
				logHandler("Removed active deposit for " .. name .. ".")
			end
		end
	end

	function bankBuddy.stackTotal(pid, refId)
		count = 0
		for Index, Value in pairs( Players[pid].data.inventory ) do
			if(Value.refId == refId)then
				count = count + 1
			end
		end
		return count
	end

	function bankBuddy.isEquipped(pid, ItemID)
		local isBool = false
		for Index, Value in pairs( Players[pid].data.equipment ) do
			if(Players[pid].data.equipment[Index] ~= nil)then
				if(Value.refId == ItemID)then
					isBool = true
				end
			end
		end
		return isBool
	end

	function bankBuddy.getIndex(pid, ItemID)
		logHandler("CHECKING FOR " .. ItemID .. "'s INDEX IN INVENTORY.","debug")
		for Index, Value in pairs(Players[pid].data.inventory)do
			if(Value.refId == ItemID)then
				logHandler("ITEM " .. ItemID .. " IS IN INVENTORY.","debug")
				logHandler("INDEX IS " .. Index .. " IN INVENTORY.","debug")
				return Index
			end
		end
	end

	function bankBuddy.itemInAccount(pid, item)
		local account = bankBuddyJson.loadPlayerAccount(pid)
		local isBool = false
		for Index, Value in pairs(account.items)do
			if(Value.iName == ItemID)then
				isBool = true
			end
		end
		return isBool
	end

	function bankBuddy.getActiveDepositIndex(pid)
		local UID = pid .. Players[pid].name
		local ind = 1
		for Index, Value in pairs( activeDeposits ) do
			if(Value.UID == UID)then
				return ind
			else
				ind = ind + 1
			end
		end
	end

	function bankBuddy.getMaxItemsW(pid)
		local maxItems = 0
		local UID = pid .. Players[pid].name
		local IID
		for Index, Value in pairs( activeWithdraws ) do
			if(Value.UID == UID)then
				IID = Value.IID
			end
		end
		local count = 0
		local account = bankBuddyJson.loadPlayerAccount(pid)
		for Index, Value in pairs( account.items ) do
			if(count == IID)then
				maxItems = maxItems + Value.count
				logHandler("maxItems IS " .. maxItems,"debug")
			end
			count = count + 1
		end
		return maxItems
	end

	function bankBuddy.getMaxItems(pid)
		local maxItems = 0
		local UID = pid .. Players[pid].name
		local IID
		for Index, Value in pairs( activeDeposits ) do
			if(Value.UID == UID)then
				IID = Value.IID
			end
		end
		local count = 0
		for Index, Value in pairs( Players[pid].data.inventory ) do
			if(count == IID)then
				maxItems = maxItems + Value.count
				count = count + 1
				logHandler("maxItems IS " .. maxItems,"debug")
			else
				count = count + 1
			end
		end
		return maxItems
	end

	function bankBuddy.getItemRefId(pid)
		local ItemID
		local UID = pid .. Players[pid].name
		local IID
		for Index, Value in pairs( activeDeposits ) do
			if(Value.UID == UID)then
				IID = Value.IID
			end
		end
		local count = 0
		for Index, Value in pairs( Players[pid].data.inventory ) do
			if(count == IID and Value.refId ~= "gold_001")then
				ItemID = Value.refId
				logHandler("ItemID IS " .. ItemID,"debug")
				return ItemID
			elseif(Value.refId ~= "gold_001")then
				count = count + 1
			end
		end
		return "GET ITEM REFID ERROR"
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
	
	function bankBuddy.depositAll(pid)
		local item = bankBuddy.getItemRefId(pid)
		local total = bankBuddy.getMaxItems(pid)
		bankBuddy.depositItems(pid, total)
	end
	
	function bankBuddy.getTransactions(pid)
		local account = bankBuddyJson.loadPlayerAccount(pid)
		local transactionString = ""
		for Index, Value in pairs(account.transactionHistory)do
			transactionString = transactionString .. Value.tType .. " on " .. Value.tDate .. "\n"
		end
		return transactionString
	end

	function bankBuddy.transactionLogMenu(pid)
		tes3mp.ListBox(pid, bankBuddyConfig.menuIDArray.transactionLogMenuID, "Here is a list of your transactions", bankBuddy.getTransactions(pid))
	end
	
	function bankBuddy.transactionInfoMenu(pid, index)
		local id = index + 1
		local account = bankBuddyJson.loadPlayerAccount(pid)
		local tLog = account.transactionHistory[id]
		tes3mp.CustomMessageBox(pid, bankBuddyConfig.menuIDArray.transactionLogShowMenuID, "Transaction info:\n\n" .. "Transaction Type: " .. tLog.tType .. "\nItem: " .. tLog.tItem .. "\nTotal: " .. tLog.tTotal .. "\nID: " .. tLog.tID .. "\nDate: " .. tLog.tDate, "Close")
	end
	
	function bankBuddy.bankMenu(pid)
		bankBuddy.cleanDeposit(pid)
		bankBuddy.cleanWithdraw(pid)
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
		bankBuddyMySQL.initDB()
		--local accounts = bankBuddyJson.loadAccounts()
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
		logHandler("GOT GUI CALL WITH IDGUI " .. idGui .. " AND DATA " .. tostring(data),"debug")
		if(idGui == bankBuddyConfig.menuIDArray.mainMenu)then
			if(tonumber(data) == 0)then
				bankBuddy.withdrawMenu(pid)
			elseif(tonumber(data) == 1)then
				bankBuddy.depositMenu(pid)
			elseif(tonumber(data) == 2)then
				bankBuddy.accountInfoMenu(pid)
			elseif(tonumber(data) == 3 and bankBuddyConfig.allowTransfers)then
				bankBuddy.transferMenu(pid)
			else
				logHandler("INVALID DATA INDEX VALUE " .. tonumber(data) .. "  FOR MENU ID " .. idGui,"error")
			end
		elseif(idGui == bankBuddyConfig.menuIDArray.withdrawMenu)then
			if(tonumber(data) == 0)then
				bankBuddy.withdrawGoldMenu(pid)
			elseif(tonumber(data) == 1)then
				bankBuddy.withdrawItemMenu(pid)
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
		elseif(idGui == bankBuddyConfig.menuIDArray.depositItemsMenu)then
			bankBuddy.depositItemsTotalMenu(pid)
			local transferData = {
				UID = pid .. Players[pid].name,
				IID = tonumber(data)
			}
			table.insert(activeDeposits, transferData)
		elseif(idGui == bankBuddyConfig.menuIDArray.depositItemsTotalMenuID)then
			if(tonumber(data) == 0)then
				bankBuddy.depositAll(pid)
			elseif(tonumber(data) == 1)then
				bankBuddy.depositItemSpecific(pid)
			end
		elseif(idGui == bankBuddyConfig.menuIDArray.depositItemSpecificID)then
			if tonumber(data) ~= nil then
				bankBuddy.depositItems(pid, tonumber(data))
				bankBuddy.genericInfoBox(pid, "Total of " .. tonumber(data) .. " Items deposited.")
			else
				bankBuddy.depositItemErrorMenu(pid)
				logHandler("User " .. Players[pid].name .. " attemted to use non numerical for deposit amount.","error")
			end
		elseif(idGui == bankBuddyConfig.menuIDArray.depositItemErrorMenuID)then
			bankBuddy.depositItemSpecific(pid)
		elseif(idGui == bankBuddyConfig.menuIDArray.withdrawGoldMenu)then
			if(tonumber(data) == 0)then
				bankBuddy.withdrawAllGold(pid)
			elseif(tonumber(data))then
				bankBuddy.withdrawSpecificGoldMenu(pid)
			end
		elseif(idGui == bankBuddyConfig.menuIDArray.depositGoldMenu)then
			if(tonumber(data) == 0)then
				bankBuddy.depositGold(pid, "all")
			elseif(tonumber(data) == 1)then
				bankBuddy.totalInputGoldMenu(pid)
			end
		elseif(idGui == bankBuddyConfig.menuIDArray.depositGoldSpecificID)then
			if(tonumber(data))then
				bankBuddy.depositGold(pid, tonumber(data))
			else
				bankBuddy.genericInfoBox(pid, "You must provide a valid number that is equal to or less than your total gold")
			end
		elseif(idGui == bankBuddyConfig.menuIDArray.withdrawItemsMenuID)then
			--bankBuddy.withdrawlGold(pid, total)
			withdrawData = {
				UID = pid .. Players[pid].name,
				IID = tonumber(data)
			}
			table.insert(activeWithdraws, withdrawData)
		elseif(idGui == bankBuddyConfig.menuIDArray.withdrawItemCountTypeMenuID)then
			if(tonumber(data) == 0)then
				bankBuddy.withdrawItem(pid, "all")
			elseif(tonumber(data))then
				bankBuddy.withdrawSpecificItemMenu(pid)
			end
		elseif(idGui == bankBuddyConfig.menuIDArray.withdrawSpecificItemMenu)then
			if(tonumber(data))then
				bankBuddy.withdrawItem(pid, tonumber(data))
			else
				bankBuddy.genericInfoBox(pid, "Please use a number.")
			end
		elseif(idGui == bankBuddyConfig.menuIDArray.accountInfoMenu)then
			if(tonumber(data) == 0)then
				bankBuddy.transactionLogMenu(pid)
			elseif(tonumber(data) == 1)then
				bankBuddy.bankMenu(pid)
			end
		elseif(idGui == bankBuddyConfig.menuIDArray.transactionLogMenuID)then
			if(tonumber(data) and tonumber(data) ~= 18446744073709551615)then
				logHandler("LOADING HISTORY FOR " .. Players[pid].name, "debug")
				bankBuddy.transactionInfoMenu(pid, tonumber(data))
			end
		elseif(idGui ~= bankBuddyConfig.menuIDArray.genericInfoBoxID)then
			logHandler("INVALID idGui INDEX VALUE " .. idGui,"error")
		end
	end
	
	customEventHooks.registerHandler("OnGUIAction", bankBuddy.OnGUIAction)
	customEventHooks.registerHandler("OnServerPostInit", bankBuddy.loadBankData)
	customEventHooks.registerHandler("OnPlayerFinishLogin", bankBuddy.loginHandler)
	customEventHooks.registerHandler("OnPlayerDisconnect", bankBuddy.logoutHandler)
	customCommandHooks.registerCommand("bank", bankBuddy.commandHandler)
return bankBuddy

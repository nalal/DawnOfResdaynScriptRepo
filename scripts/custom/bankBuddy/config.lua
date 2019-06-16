local bankBuddyConfig = {}

	--Name of the JSON file used to store account list
	bankBuddyConfig.accountTableFileName = "accountsDB"
	--Menu IDs for the in game menus, likely wont need to mess with them but can if you have conflicts with other scripts
	bankBuddyConfig.menuIDArray = {
		mainMenu = 9900,
		accountInfoMenu = 9901,
		invalidMenu = 9902,
		withdrawMenu = 9903,
		depositMenu = 9904,
		depositGoldMenu = 9905,
		withdrawGoldMenu = 9906,
		depositItemsMenu = 9907,
		depositItemsTotalMenuID = 9908,
		depositItemSpecificID = 9909,
		depositItemErrorMenuID = 9910,
		genericInfoBoxID = 9911,
		depositGoldSpecificID = 9912,
		withdrawItemsMenuID = 9913,
		withdrawItemCountTypeMenuID = 9914,
		transactionLogMenuID = 9915,
		transactionLogShowMenuID = 9916,
		withdrawSpecificItemMenu = 9917
	}
	bankBuddyConfig.SQLData = {
		SQLAcc = "tes3mpusr",
		SQLPass = "1105",
		SQLDB = "tes3mp",
		SQLIP = "localhost",
		SQLPort = nil
	}
	bankBuddyConfig.databaseNames = {
		main = "bank_roster"
	}
	--Database type, will try to work on a MySQL implementation for this one
	bankBuddyConfig.dataBase = "json"
	--Debug mode, shows verbose messages on script opperations
	bankBuddyConfig.debugMode = true
	--Maximum gold storable, if nil will not have a max (not sure if that's dangerous yet)
	bankBuddyConfig.maxGold = nil
	--Maximum items storable, if nil will not have a max (not sure if that's dangerous yet)
	bankBuddyConfig.maxItems = nil
	--Use intrest rate?
	bankBuddyConfig.intrestRateToggle = true
	--Intrest rate for gold deposited in percent
	bankBuddyConfig.intrestRate = 5
	--Allow transfers from account to account
	bankBuddyConfig.allowTransfers = true
	--Name that appears in chat when message is sent from script
	bankBuddyConfig.chatName = "BankBuddy"
	--Should players be in a specific cell to use the bank?
	bankBuddyConfig.limitToCell = false
	--List of whitelisted cells for banking
	bankBuddyConfig.cellList = {
		
	}
return bankBuddyConfig

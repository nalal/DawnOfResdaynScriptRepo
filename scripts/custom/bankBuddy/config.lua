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
		withdrawGoldMenu = 9906
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
	--Should players be in a specific cell to use the bank?
	bankBuddyConfig.limitToCell = false
	--List of whitelisted cells for banking
	bankBuddyConfig.cellList = {
		
	}
return bankBuddyConfig

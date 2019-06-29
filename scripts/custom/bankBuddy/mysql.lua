local bankBuddyMySQL = {}

	function bankBuddyMySQL.initDB()
		local tableRosterCreateSQL = "CREATE TABLE IF NOT EXISTS " .. bankBuddyConfig.databaseNames.main .. " (" ..
			"id INT UNSIGNED AUTO_INCREMENT NOT NULL," ..
			"playername VARCHAR(30) NOT NULL," .. 
			"PRIMARY KEY (id)" ..
		") ENGINE=INNODB;"
		mysqlHandler.testDB("tes3mpusr", "1105", "tes3mp", "localhost")
		mysqlHandler.manualQuery(tableRosterCreateSQL, bankBuddyConfig.SQLData.SQLAcc, bankBuddyConfig.SQLData.SQLPass, bankBuddyConfig.SQLData.SQLDB, bankBuddyConfig.SQLData.SQLIP)
	end
	
	function bankBuddyMySQL.createAccount(name)
		local accountQuery = "INSERT INTO " .. bankBuddyConfig.databaseNames.main .. "(playername) VALUE('" .. name .. "');"
		mysqlHandler.manualQuery(accountQuery, bankBuddyConfig.SQLData.SQLAcc, bankBuddyConfig.SQLData.SQLPass, bankBuddyConfig.SQLData.SQLDB, bankBuddyConfig.SQLData.SQLIP)
	end
	
	function bankBuddyMySQL.checkAccount(name)
		if name ~= nil then
			local retNum = 0
			local total = mysqlHandler.checkVal("playername", tostring(name), bankBuddyConfig.databaseNames.main, bankBuddyConfig.SQLData.SQLAcc, bankBuddyConfig.SQLData.SQLPass, bankBuddyConfig.SQLData.SQLDB, bankBuddyConfig.SQLData.SQLIP)
			if total > 0 then
				retNum = 1
			end
			return retNum
		else
			return -1
		end
	end

return bankBuddyMySQL

--[[
	To whom it may concern, please note that this script was developed with the 
	intended usecase being FTC's internal scripting, there is no official 
	support for this script and it is recomended that you know basic database
	administration prior to attempting to use this script. If you wish to use
	any of the scripting related to this system, feel free to do so, just note
	that you will also need the file located at `./server/lib/luasql/mysql.so` 
	to actually use this script.
]]--
local driver = require "luasql.mysql"

local mysqlHandler = {}

env = assert (driver.mysql())

	function mysqlHandler.init()
		local message = "MySQL handler loaded."
		mysqlHandler.logger(message)
		--mysqlHandler.testDB("tes3mpusr", "1105", "tes3mp", "localhost")
	end

	function mysqlHandler.testDB(usr, pass, DB, IP, port)
		if DB ~= nil then
			mysqlHandler.logger("Testing connection to DB " .. DB)
			if IP == nil then
				IP = "localhost"
			end
			if port == nil then
				port = "3306"
			end
			con = env:connect(DB, usr, pass, IP, port)
			con:close()
			--env:close()
			if con ~= nil then
				mysqlHandler.logger("Test successful for DB " .. DB)
				return true
			else

			end
		else
			mysqlHandler.logger("testDB called with nil DB, aborting.")
		end
	end

	function mysqlHandler.initDB(usr, pass, DB, IP, port)
		mysqlHandler.logger("Running init for database '" .. DB .. "'")
	end

	--Note, none of this is escaped so be real careful what you execute
	--Like, REALLY GOD DAMN CAREFUL
	--I will not be held accountable for any 'DROP TABLES *;' shenanigans
	--Only manditory inputs are "query, usr, pass, DB", rest are auto assigned to local and 3306 if not given
	function mysqlHandler.manualQuery(query, usr, pass, DB, IP, port, pid)
		executee = ""
		if pid ~= nil then
			executee = Players[pid].name
		else
			executee = "SYSTEM"
		end
		if usr ~= nil and pass ~= nil and query ~= nil and DB ~= nil then
			if IP == nil then
				IP = "localhost"
			end
			if port == nil then
				port = "3306"
			end
			con = assert(env:connect( DB, usr, pass, IP, port))
			con:execute(string.format(query))
			con:close()
			--env:close()
			--mysqlHandler.messageRelay("executing query (".. query ..").\n")
			tes3mp.LogMessage(enumerations.log.INFO, "TB Test executed by " .. executee)
			mysqlHandler.queryLog(query)
		else
			--tes3mp.SendMessage(pid, "No/Incomplete DB login provided, execution terminated.\n", false)
			tes3mp.LogMessage(enumerations.log.INFO, "TB Test executed by " ..executee .. " but no/incomplete login info given.")
			if usr == nil then
				usr = "NILL"
			end
			if pass == nil then
				pass = "NILL"
			end
			if DB == nil then
				DB = "NILL"
			end
			msg = "testDB failed to connect to database " .. DB .. "."
			trace = "testDB call data: \nUSR: " .. usr .. "\nPASS: " .. pass .. "\nDB: " .. DB
			mysqlHandler.logger(msg)
			mysqlHandler.logger(trace)
			return false
		end
	end
	
	function mysqlHandler.checkVal(column, val, tableName, usr, pass, DB, IP, port)
		local SQLInput = "SELECT id FROM " .. tableName .. " WHERE " .. column .. " = '" .. val .. "'"
		con = assert(env:connect( DB, usr, pass, IP, port))
		res = con:execute(string.format(SQLInput))
		resf = res:numrows()
		mysqlHandler.queryLog(SQLInput)
		con:close()
		return resf
	end

	function mysqlHandler.messageRelay(pid, message)
		tes3mp.SendMessage(pid, color.Cyan .. "[MySQL]: " .. color.LightCyan .. message, false)
	end

	function mysqlHandler.logger(message)
		tes3mp.LogMessage(enumerations.log.INFO, "[MySQL]: " .. message)
	end

	function mysqlHandler.queryLog(message)
		tes3mp.LogMessage(enumerations.log.INFO, "[MySQL]: SYSTEM executed query (" .. message .. ")")
	end

	function mysqlHandler.commandHandler(pid, cmds)
		if cmds[2] ~= nil then
			if cmds[2] == "test" then
				mysqlHandler.messageRelay("Testing DB..")
				mysqlHandler.logger("testDB called by " .. Players[pid].name)
			else
				mysqlHandler.messageRelay("Invalid MySQL command.")
			end
		else
			local messageL = "MySQL script info called by " .. Players[pid].name
			local messageC = "MySQL script is currently loaded.\nScript by: Nac\nIntended for use by FTC internal scripting."
			mysqlHandler.logger(messageL)
			mysqlHandler.messageRelay(pid, messageC)
		end
	end

	customCommandHooks.registerCommand("mysql", mysqlHandler.commandHandler)
	customEventHooks.registerHandler("OnServerPostInit", mysqlHandler.init)
return mysqlHandler

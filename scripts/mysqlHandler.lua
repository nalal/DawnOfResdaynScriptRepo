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
	end

	function mysqlHandler.initDB(usr, pass, DB, IP, port)
		mysqlHandler.logger("Running init for database '" .. DB .. "'")
	end

	--Note, none of this is escaped so be real careful what you execute
	--Only manditory inputs are "query, usr, pass, DB", rest are auto assigned to local and 3306 if not given
	function mysqlHandler.manualQuery(query, usr, pass, DB, IP, port)
		if usr ~= nil and pass ~= nil and queary ~= nil and DB ~= nil then
			if IP == nil then
				IP = "localhost"
			end
			if port == nil then
				port = "3306"
			end
			con = assert (env:connect( DB, usr, pass, IP, port))
			con:execute(string.format(query))
			con:close()
			env:close()
			mysqlHandler.messageRelay("executing query (".. query ..").\n")
			tes3mp.LogMessage(enumerations.log.INFO, "TB Test executed by " .. logicHandler.GetChatName(pid))
			mysqlHandler.queryLog(query)
		else
			tes3mp.SendMessage(pid, "No/Incomplete DB login provided, execution terminated.\n", false)
			tes3mp.LogMessage(enumerations.log.INFO, "TB Test executed by " .. logicHandler.GetChatName(pid) .. " but no/incomplete login info given.")
		end
	end

	function mysqlHandler.messageRelay(message)
		tes3mp.SendMessage(pid, color.Cyan .. "[MySQL]: " .. color.LightCyan .. message, false)
	end

	function mysqlHandler.logger(message)
		tes3mp.LogMessage(enumerations.log.INFO, "[MySQL]: " .. message)
	end

	function mysqlHandler.queryLog(message)
		tes3mp.LogMessage(enumerations.log.INFO, "[MySQL]: System executed query (" .. message .. ")")
	end

	customEventHooks.registerHandler("OnServerPostInit", mysqlHandler.init)
return mysqlHandler

local driver = require "luasql.mysql"

local mysqlHandler = {}

env = assert (driver.mysql())

--Note, none of this is escaped so be real careful what you execute
function testDB.manualQuery(query)
	if config.DBUSER ~= nil and config.DBPASS ~= nil then
		con = assert (env:connect( "testDB", config.DBUSER, config.DBPASS, "localhost", "3306"))
		con:execute(string.format(query))
		con:close()
		env:close()
		mysqlHandler.messageRelay("executing query (".. query ..").\n")
		tes3mp.LogMessage(enumerations.log.INFO, "TB Test executed by " .. logicHandler.GetChatName(pid))
		mysqlHandler.queryLog(query)
	else
		tes3mp.SendMessage(pid, "No/Incomplete DB login provided, execution terminated.\n", false)
		tes3mp.LogMessage(enumerations.log.INFO, "TB Test executed by " .. logicHandler.GetChatName(pid) .. " but no/incomplete login info in config.")
	end
end

function mysqlHandler.messageRelay(message)
	tes3mp.SendMessage(pid, color.Cyan .. "[MYSQL]: " .. color.LightCyan .. message, false)
end

function mysqlHandler.queryLog(message)
	tes3mp.LogMessage(enumerations.log.INFO, "System executed query (" .. message .. ")")
end
	
return testDB

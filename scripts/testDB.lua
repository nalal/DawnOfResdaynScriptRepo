local driver = require "luasql.mysql"

local testDB = {}

env = assert (driver.mysql())

function testDB.testQuerry()
	if config.DBUSER ~= nil and config.DBPASS ~= nil then
		con = assert (env:connect( "testDB", config.DBUSER, config.DBPASS, "localhost", "3306"))
		con:execute(string.format([[INSERT INTO `testDB`.`testTB` (`testInt`) VALUES ('1');]]))
		con:close()
		env:close()
		tes3mp.SendMessage(pid, "executing DB test.\n", false)
		tes3mp.LogMessage(enumerations.log.INFO, "TB Test executed by " .. logicHandler.GetChatName(pid))
	else
		tes3mp.SendMessage(pid, "No/Incomplete DB login provided, execution terminated.\n", false)
		tes3mp.LogMessage(enumerations.log.INFO, "TB Test executed by " .. logicHandler.GetChatName(pid) .. " but no/incomplete login info in config.")
	end
end

return testDB
test = function(pid, args)
	local list = "test\n" .. "test1\n"
	return tes3mp.ListBox(pid, 9009, "This is a test", list)
end


customCommandHooks.registerCommand("menutest", test)

local menuTest = {}

function menuTest.OnGUIAction(eventStatus, pid, idGui, data)
	if idGui == 9009 then
		tes3mp.SendMessage(pid, "[DEBUG]: PIPEIN = " .. data .. ".\n")
	end
end
customEventHooks.registerHandler("OnGUIAction", menuTest.OnGUIAction)
return menuTest



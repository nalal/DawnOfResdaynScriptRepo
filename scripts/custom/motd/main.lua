local motd = {}
	
	local infotxt = "This server is running 24/7.\n" .. 
		color.Red .. "\nAbout Dawn of Resdayn:\n" .. color.White ..
		"Dawn of Resdayne is a serious RolePlay server with a good bit of history.\n" ..
		"It is a good idea to have a decent grasp on the lore of Morrowind prior to playing.\n" ..
		color.Cyan .. "\nDiscord:\n" .. color.White .. "It is recomended that you check the discord for our rules prior to playing.\n" ..
		color.Blue .. "https://discord.gg/nvN46d6\n" ..
		color.Green .. "\nStaff:\n" ..
		color.DarkRed .. "Dystopia: " .. color.White .. "DM Team (Manager)\n" ..
		color.DarkRed .. "Gryphoth: " .. color.White .. "DM Team (Manager)\n" ..
		color.DarkRed .. "Spartan: " .. color.White .. "DM Team\n" ..
		color.DarkRed .. "West: " .. color.White .. "DM Team\n" ..
		color.DarkGreen .. "Nac: " .. color.White .. "Host, Head of development\n" ..
		color.DarkGreen .. "Hotaru: " .. color.White .. "System Administrator, Development Team (Manager)\n" ..
		color.DarkGreen .. "Dave: " .. color.White .. "Development Team (Senior)\n" ..
		color.DarkGreen .. "Malic: " .. color.White .. "Development Team, JRP Host/Owner\n" ..
		color.Orange .. "David C.: " .. color.White .. "TES3MP Development Staff (Manager), Scripting Consultant\n" ..
		color.Orange .. "Urm: " .. color.White .. "TES3MP Development Staff (Scripting), Scripting Consultant\n" ..
		"\nFor information on commands, see " .. color.Cyan .. " /help" .. color.White .. "."
		
	
	function motd.new(eventStatus, pid)
		tes3mp.CustomMessageBox(pid, 999999, "Welcome to " .. color.Red  .. "Dawn of Resdayn!\n" .. color.White .. infotxt,"Close")
	end

	function motd.returning(eventStatus, pid)
		tes3mp.CustomMessageBox(pid, 999999, "Welcome back to " .. color.Red  .. "Dawn of Resdayn!\n" .. color.White .. infotxt,"Close")
	end

	function motd.cmd(pid)
		tes3mp.CustomMessageBox(pid, 999999, "Welcome back to " .. color.Red  .. "Dawn of Resdayn!\n" .. color.White .. infotxt,"Close")
	end

	function motd.init()
		ftc.cli("MOTD loaded", "MOTD")
	end

	customCommandHooks.registerCommand("motd", motd.cmd)
	customEventHooks.registerHandler("OnPlayerEndCharGen", motd.new)
	customEventHooks.registerHandler("OnPlayerFinishLogin", motd.returning)
	customEventHooks.registerHandler("OnServerPostInit", motd.init)

return motd

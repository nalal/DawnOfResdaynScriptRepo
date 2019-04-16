local function ShowMOTDGui(pid)
  tes3mp.CustomMessageBox(pid, -1, ""..color.Red.."Welcome to Dawn of Resdayn's public test realm!"..color.Default.."\n\nThis server is intended for testing new systems prior to full release.".."\n\nOur Forum is located at:\n"..color.Cyan.."http://resdayn.boards.net/\n\n"..color.Default.."Join our Admin Help discord:\n"..color.Wheat.."https://discord.gg/aWSgHtR\n\n"..color.Default.."Server Host:\n"..color.Yellow.."Nac\n\n"..color.Default.."Community Founder:\n"..color.Red.."2cwldys\n\n"..color.Default.."Founded:\n"..color.Yellow.."6/29/2018"..color.Default.."\n\n"..color.Wheat.."Extra Commands:\n/showmotd, /staff\n//(spacebar) <words> - Global Out of Character\n///(spacebar) <words> - Local Out of Character\n/me(spacebar) <action> - complete an action", "Ok")
  Players[pid]:Message(color.Yellow.."Welcome to Dawn of Resdayn!\n"..color.Default)
  Players[pid]:Message(color.Green.."We enforce Serious Roleplay, and a Safe Roleplaying Environment!\n"..color.Default)
  Players[pid]:Message(color.Blue.."Join our forums!\n(http://resdayn.boards.net/)\n"..color.Default)
  Players[pid]:Message(color.Cyan.."This server utilizes Custom Lore!\n"..color.Default)
end

local SCRIPT = scriptLoader.DefineScript()
SCRIPT.ID = "motd"
SCRIPT.Name = "MOTD"
SCRIPT.Author = "Wishbone"
SCRIPT.Desc = "MOTD for players"

SCRIPT:AddHook("ProcessCommand", "MOTDCommand", function(pid, cmd, message, isOwner, isAdmin, isMod)
  if(cmd[1] == "showmotd") then
    ShowMOTDGui(pid)
  end
end)

SCRIPT:AddHook("OnPlayerLoginFinish", "ShowMOTD", function(pid)
  ShowMOTDGui(pid)
end)

SCRIPT:AddHook("OnPlayerEndCharGen", "ShowMOTDOnCreate", function(pid)
  ShowMOTDGui(pid)
end)

SCRIPT:Register()

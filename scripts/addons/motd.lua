local function ShowMOTDGui(pid)
  tes3mp.CustomMessageBox(pid, -1, ""..color.Red.."Welcome to Dawn of Resdayn!"..color.Default.."\n\nThis is a "..color.Yellow.."SERIOUS"..color.Default.." roleplaying community!"..color.Error.." [18+]"..color.Default.."\n\nUptime:\nThis server is up "..color.Yellow.."24/7"..color.Default.."\n\nThese are the rules for our community:\n\nAbsolutely "..color.Red.."NO"..color.Default.." hacking, scripting, cheating, or abusing privileges!\n\nNo "..color.Yellow.."Powergaming!"..color.Default.." (forcing your actions onto others without response)\n\nNo "..color.Yellow.."Metagaming!"..color.Default.." (taking out of character information into in-character)\n\n"..color.Default..""..color.Cyan.."Read the rest of the rules on our Forums!"..color.Default.."\n\nOur Forum is located at:\n"..color.Cyan.."http://resdayn.boards.net/\n\n"..color.Default.."Join our Admin Help discord:\n"..color.Wheat.."https://discord.gg/aWSgHtR\n\n"..color.Default.."Server Host:\n"..color.Yellow.."Nac\n\n"..color.Default.."Community Founder:\n"..color.Red.."2cwldys\n\n"..color.Default.."Founded:\n"..color.Yellow.."6/29/2018"..color.Default.."\n\n"..color.Wheat.."Extra Commands:\n/showmotd, /staff\n//(spacebar) <words> - Global Out of Character\n///(spacebar) <words> - Local Out of Character\n/me(spacebar) <action> - complete an action", "Ok")
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

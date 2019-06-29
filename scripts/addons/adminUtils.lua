local function implode(table)
  local i;
  local result = table[2]

  for i=3, #table, 1 do
    result = result .. table[i]
  end

  return result
end

local function resetCell(cell)
  local fullPath = tes3mp.GetModDir().."/cell/"..cell..".json"
  local partPath = tes3mp.GetModDir().."/cell/"..cell
  local ret,err = os.rename(fullPath, partPath..".old")
  if(ret == nil) then
    return err
  else
    return true
  end
end

local SCRIPT = scriptLoader.DefineScript()
SCRIPT.ID = "adminutils"
SCRIPT.Name = "Admin Utilities"
SCRIPT.Author = "Wishbone"
SCRIPT.Desc = "Admin utility commands."

SCRIPT:AddHook("ProcessCommand", "AUCommands", function(pid, cmd, message, isOwner, isAdmin, isMod)
  if(cmd[1] == "loadscript") then
    if(isAdmin == true) then
      if(cmd[2] ~= nil) then
        local res,err = pcall(require, cmd[2])

        if(res) then
          tes3mp.SendMessage(pid, color.White.."Successfully loaded script!", false)
        else
          tes3mp.SendMessage(pid, color.Red.."Lua Error: "..tostring(err), false)
        end
      end
    end

  elseif(cmd[1] == "killscript") then
    if(isAdmin == true) then
      if(cmd[2] ~= nil) then
        scriptLoader.Kill(cmd[2])
      end
    end

  elseif(cmd[1] == "annouce") then
    if(isMod == true) then
      if(cmd[2] ~= nil) then
        local i
        local msg = "SERVER: "
        for i=2, #cmd, 1 do
          msg = msg .. cmd[i]
        end

        local realMsg = color.Orange .. msg .. "\n"
        tes3mp.SendMessage(pid, realMsg, true)
      end
    end

  elseif(cmd[1] == "resetcell") then
    if(isAdmin == true) then
      if(cmd[2] ~= nil) then
        local arg = implode(cmd)
        local cell = resetCell(arg)
        if(cell ~= true) then
          tes3mp.SendMessage(pid, color.Red.."Error: "..tostring(cell), false)
        end
      else
        Players[pid]:Message("You didn't supply an parameter of what cell to reset.\n")
      end
    end
  end

end)

SCRIPT:Register();
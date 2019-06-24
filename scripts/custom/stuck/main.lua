local config = {}
config.delay = 180

--[[
	Script "stuck"
	Ported to scriptHook by Nac
]]--

--[[local SCRIPT = scriptLoader.DefineScript()
SCRIPT.ID = "stuck"
SCRIPT.Name = "Stuck"
SCRIPT.Author = "Texafornian"
SCRIPT.Desc = "When you get stuck."
]]--Creditation preserved due to 3rd party scripting

local function TimeParse(pid, timeStored) -- Used to report days, hours, minutes since some timestamp
	-- https://forum.rainmeter.net/viewtopic.php?t=23486
	local diff = config.delay - (os.time() - timeStored)
	local diffDays = math.floor(diff / 86400)
	local remainder = diff % 86400
	local diffHours = math.floor(remainder / 3600)
	local remainder = remainder % 3600
	local diffMinutes = math.floor(remainder / 60)
	local diffSeconds = remainder % 60

	tes3mp.SendMessage(pid, color.Red .. "You will be able to /stuck again in " .. diffMinutes .. " minutes, " .. diffSeconds .. " seconds." .. color.Default .. "\n", false)
end

local function Unstick(pid)
	Players[pid]:LoadCell()
	Players[pid].data.stuck = os.time()
	Players[pid]:Save()
	tes3mp.SendMessage(pid, color.Orange .. "Attempting to fix player position..." .. color.Default .. "\n", false)
end



function stuckCMD(pid, cmd)
	local delay = config.delay

  if(cmd[1] == "stuck") then
    local playerName = Players[pid].data.login.name

  	-- Check whether the player has the "Stuck" entry in their playerfile
  	if Players[pid].data.stuck then
  	else
  		Players[pid].data.stuck = 0
  	end

  	tes3mp.LogMessage(2, "++++ /stuck: Player " .. playerName .. "attempted to use /stuck ++++")

  	-- Ensure that enough time has passed since last /stuck attempt
  	local timeStored = Players[pid].data.stuck

  	if timeStored == 0 or type(timeStored) == "number" then -- This should happen
  		local diff = (os.time() - timeStored)

  		tes3mp.LogMessage(2, "++++ diff == " .. diff .. " ++++")
  		if (diff / delay) >= 1 then
  			Unstick(pid)
  		else
  			TimeParse(pid, timeStored)
  		end

  	elseif type(timeStored) == "string" then -- This shouldn't happen, takes care of "" strings
  		Unstick(pid)
  	end
	end
end

function loadScript()
	tes3mp.LogMessage(enumerations.log.INFO, "[STUCK]: Stuck loaded (through scriptHook)")
end

customEventHooks.registerHandler("OnServerPostInit", loadScript)
customCommandHooks.registerCommand("stuck", stuckCMD)

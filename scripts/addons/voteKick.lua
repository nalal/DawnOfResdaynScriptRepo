local TimerStart = TimerCtrl.create(VoteKickTimerEnd, 300)
local isVoteKickRunning = false
local pidToKick = nil
local TimerCtrl = require("TimerCtrl")

local votes = {}

local function VoteKickTimerEnd()
  if(pidToKick == nil) then
    TimerCtrl.kill(TimerStart)
    TimerStart = nil
  end

  isVoteKickRunning = false
  local yes, no = 1, 1

  for pid,vote in pairs(votes) do
    if pid ~= pidToKick then
      if vote then
        yes = yes + 1
      else
        no = no + 1
      end
    end
  end

  if(Players[pidToKick]:IsLoggedIn() == true) then
    if yes/no > 0.5 and yes/no ~= 1 then
      Players[pidToKick]:Kick()
      tes3mp.SendMessage(0, color.Red.."[SERVER] You have all voted "..color.White..Players[pidToKick].name..color.Red.." off the server.\n"..color.White, true)
    else
      tes3mp.SendMessage(0, color.Red.."[SERVER] Not enough of you want "..color.White..Players[pidToKick].name..color.Red.." off the server.\n"..color.White, true)
    end
  end

  --Destroy the timer since it's no longer needed.
  TimerCtrl.kill(TimerStart)
  TimerStart = nil
end

local SCRIPT = scriptLoader.DefineScript()
SCRIPT.ID = "votekick"
SCRIPT.Name = "Vote Kick"
SCRIPT.Author = "David-AW, fixes from Wishbone"
SCRIPT.Desc = "Vote kick all of the DMs"

SCRIPT:AddHook("ProcessCommand", "VK_Commands", function(pid, cmd)
  if cmd[1] == "votekick" and cmd[2] then
    if tonumber(cmd[2]) and Players[tonumber(cmd[2])] and Players[tonumber(cmd[2])]:IsLoggedIn() then
      if not isVoteKickRunning then
        pidToKick = tonumber(cmd[2])
        isVoteKickRunning = true
        TimerStart = TimerCtrl.create(VoteKickTimerEnd, 30000)
        tes3mp.SendMessage(pid, color.Red.."[SERVER] A 30 second vote to kick "..color.White..Players[pidToKick].name..color.Red.." has begun.\n[SERVER] Use /voteyes and /voteno\n"..color.White, true)
      else
        tes3mp.SendMessage(pid, "A votekick is already running.\n", false)
      end
    else
      tes3mp.SendMessage(pid, "Invalid pid.\n", false)
    end

  elseif cmd[1] == "voteyes" then
    if isVoteKickRunning then
      if not votes[pid] then
        votes[pid] = true
        tes3mp.SendMessage(pid, "You voted to kick "..Players[pidToKick].name..".\n", false)
      else
        tes3mp.SendMessage(pid, "You cannot vote twice.\n", false)
      end
    else
      tes3mp.SendMessage(pid, "A vote to kick is not running.\n", false)
    end

  elseif cmd[1] == "voteno" then
    if isVoteKickRunning then
      if not votes[pid] then
        votes[pid] = false
        tes3mp.SendMessage(pid, "You voted NOT to kick "..Players[pidToKick].name..".\n", false)
      else
        tes3mp.SendMessage(pid, "You cannot vote twice.\n", false)
      end
    else
      tes3mp.SendMessage(pid, "A vote to kick is not running.\n", false)
    end
  end
end)

SCRIPT:AddHook("OnPlayerDisconnect", "VK_PlayerLeave", function(pid)
  if(pidToKick == pid) then
    pidToKick = nil
    isVoteKickRunning = false
    TimerCtrl.kill(TimerStart)
    TimerStart = nil --Destroy the timer.
  end
end)

SCRIPT:Register()

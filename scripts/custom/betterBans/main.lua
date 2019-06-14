--[[
[SCRIPT INFO]
Scrip Name:
	BetterBans
	
Script Author:
	Nac(FTC)

Init Date:(DMY)
	5-6-2019
	
Script Description:
	Script is intended to allow timed bans as to reduce workload for administrative staff
]]--
betterBansJson = require("custom/betterBans/json")

local betterBans = {}

	function betterBans.getDate()
		dateVal = POSIX = tonumber(os.time())
		return dateVal
	end

	function submitBan(pid)
	
	end

	function betterBans.setBan(pid, timeFrame, reason)
		local banEntry = {
			userName = Players[pid].name,
			IP = Players[pid].name,
			banDate = betterBans.getDate(),
			banEndDate = betterBans.getDate() + timeFrame
			banReason = 
		}
		local banRegistrarBuffer = betterBansJson.load()
		table.insert(banRegistrarBuffer.bans, banEntry)
	end

	function betterBans.banPlayer(pid, timeType, timeFrame)
		if(timeType == "hours")then
			timeFrame = timeFrame * 3600
		elseif(timeType == "days")then
			timeFrame = timeFrame * 86400
		elseif(timeType == "month")
			timeFrame = timeFrame * 2629743
		end
		timeFrame = betterBans.getDate() + timeFrame
		betterBans.setBan(pid, timeFrame)
	end

return betterBans

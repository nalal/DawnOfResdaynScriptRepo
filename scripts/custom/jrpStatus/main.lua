-- jrpStatus v0.1.01 for tes3mp 0.7-prerelease. created by malic for JRP Roleplay
-- player menu to see peoples appearances, traits, biography, injuries, etc.
-- under GPLv3

--[[
Add the following to customScripts.lua
	require("custom.jrpStatus")
--]]

local jrpStatus = {}
local jrpStatusList = {"age","appearance","biography","gender","height","sexuality"}
local guiID = {}
guiID.playeractivate = 31340

-- player activate menu
function jrpStatus.showPlayerActivateGUI(eventStatus,pid,targetName,targetPid)

	local message = color.Yellow .. targetName .. "\n\n" .. 
	color.Orange .. "Age: " .. color.Default ..  Players[targetPid].data.customVariables.jrpStatus.age .. "\n" ..
	color.Orange .. "Height: " .. color.Default .. Players[targetPid].data.customVariables.jrpStatus.height .. "\n" .. 
	color.Orange .. "Gender: " .. color.Default .. Players[targetPid].data.customVariables.jrpStatus.gender .. "\n" ..
	color.Orange .. "Sexuality: " .. color.Default .. Players[targetPid].data.customVariables.jrpStatus.sexuality ..  "\n\n" .. 
	color.Orange .. "Appearance: " .. color.Default .. Players[targetPid].data.customVariables.jrpStatus.appearance .. "\n\n" ..
	color.Orange .. "Biography: " .. color.Default .. Players[targetPid].data.customVariables.jrpStatus.biography

	tes3mp.CustomMessageBox(pid, guiID.playeractivate, message, "Cancel")
end



function jrpStatus.setPlayerStatus(eventStatus,pid,cmd)
	if cmd[2] == "height" and cmd[3] ~= nil then
		Players[pid].data.customVariables.jrpStatus.height = table.concat(cmd, " ", 3)
	elseif cmd[2] == "age" and cmd[3] ~= nil then
		Players[pid].data.customVariables.jrpStatus.age = table.concat(cmd, " ", 3)
	elseif cmd[2] == "appearance" and cmd[3] ~= nil then
		Players[pid].data.customVariables.jrpStatus.appearance = table.concat(cmd, " ", 3)
	elseif cmd[2] == "biography" and cmd[3] ~= nil then
		Players[pid].data.customVariables.jrpStatus.biography = table.concat(cmd, " ", 3)
	elseif cmd[2] == "gender" and cmd[3] ~= nil then
		Players[pid].data.customVariables.jrpStatus.gender = table.concat(cmd, " ", 3)
	elseif cmd[2] == "sexuality" and cmd[3] ~= nil then
		Players[pid].data.customVariables.jrpStatus.sexuality = table.concat(cmd, " ", 3)
	end
	Players[pid]:Save()
end

function jrpStatus.OnObjectActivateValidator(eventStatus, pid, cellDescription, objects, players)
	for index = 0, tes3mp.GetObjectListSize() - 1 do
		local object={}
		local isObjectPlayer = tes3mp.IsObjectPlayer(index)
	
		if isObjectPlayer then
			targetPid = tes3mp.GetObjectPid(index)
			targetName =  logicHandler.GetChatName(targetPid)
			jrpStatus.showPlayerActivateGUI(eventStatus,pid,targetName,targetPid)
			tes3mp.LogMessage(enumerations.log.INFO, "[jrpStatus] " .. Players[pid].name .. "activated " .. targetName)
		end
	end
end

function jrpStatus.OnPlayerAuthentified(eventStatus,pid)
	if Players[pid].data.customVariables == nil then
			Players[pid].data.customVariables = {}
	end

	if Players[pid].data.customVariables.jrpStatus == nil then
			Players[pid].data.customVariables.jrpStatus = {}
	end
	
		-- create player status entry if it doesnt exist already. make this a for loop at some point
	if Players[pid].data.customVariables.jrpStatus.age == nil then Players[pid].data.customVariables.jrpStatus.age = "Unknown" end
	if Players[pid].data.customVariables.jrpStatus.appearance == nil then Players[pid].data.customVariables.jrpStatus.appearance = "Unknown" end
	if Players[pid].data.customVariables.jrpStatus.biography == nil then Players[pid].data.customVariables.jrpStatus.biography = "Unknown" end
	if Players[pid].data.customVariables.jrpStatus.gender == nil then Players[pid].data.customVariables.jrpStatus.gender = "Unknown" end
	if Players[pid].data.customVariables.jrpStatus.height == nil then Players[pid].data.customVariables.jrpStatus.height = "Unknown" end
	if Players[pid].data.customVariables.jrpStatus.sexuality == nil then Players[pid].data.customVariables.jrpStatus.sexuality = "Unknown" end
end

function jrpStatus.ChatListener(pid, cmd)
	if cmd[1] == "status" then
		if cmd[2] == nil then
			targetName = Players[pid].accountName
			targetPid = Players[pid].pid
			jrpStatus.showPlayerActivateGUI(eventStatus,pid,targetName,pid)
		elseif cmd[2] ~= nil then
			jrpStatus.setPlayerStatus(eventStatus,pid,cmd)
		end
	end
end

customCommandHooks.registerCommand("status", jrpStatus.ChatListener)
customEventHooks.registerValidator("OnObjectActivate", jrpStatus.OnObjectActivateValidator)
customEventHooks.registerHandler("OnPlayerAuthentified", jrpStatus.OnPlayerAuthentified)

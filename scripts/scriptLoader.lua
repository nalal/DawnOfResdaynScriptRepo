scripts = {} --The global table for scripts.
local scriptLoader = {} --Functions
local scriptMeta = {} --Our object
local Hooks = {} --Hooks
local Methods = {}
local Config = {}
Config["disableDefaultChat"] = true
Config["disableObjectActivate"] = false

local function requireScript(file)
  local res,err = pcall(require, file)

  if(res) then
    print("Loaded script \""..file.."\".")
    return true
  else
    print("Could not load script with the name of \""..file.."\".")
    tes3mp.LogMessage(enumerations.log.ERROR, err)
    return false
  end
end

function scriptLoader.LoadScripts()
  info = jsonInterface.load("scripts.json")

  if(info == nil) then
    info = {}
  end

  for _,v in pairs(info) do
    requireScript("addons/"..v)
  end
end

--[[
    Methods to allow script functions to be accessed from other scripts.
--]]
function scriptLoader.CallMethod(scriptID, func, ...)
  local MethodTable = Method[scriptID][func]
  if(not MethodTable) then return end

	local a, b, c, d, e, f

	for k,v in pairs(MethodTable) do
		if(type(k) == "string") then
			a, b, c, d, e, f = v( ... )
		else
			MethodTable[k] = nil --The key should always be a string.
		end
	end
end

function scriptLoader.AddMethod(scriptID, name, func)
  if(type(func) ~= "function") then return end
  if(type(name) ~= "string") then return end

  if(Methods[scriptID] == nil) then
			Methods[scriptID] = {}
	end

  Methods[scriptID][name] = func
end

function scriptLoader.RemoveMethod(scriptID, name)
  if(type(name) ~= "string") then return end
  if(not Methods[scriptID]) then return end

  Methods[scriptID][name] = nil
end

--[[
    Our own hook system so scripts don't have to mess with core files.
--]]
function scriptLoader.AddHook(event, key, func)
  if(type(event) ~= "string") then return end
  if(type(func) ~= "function") then return end

	if(Hooks[event] == nil) then
			Hooks[event] = {}
	end

  Hooks[event][key] = func
end

function scriptLoader.RemoveHook(event, key)
  if(type(event) ~= "string") then return end
	if(not Hooks[event]) then return end

  Hooks[event][key] = nil
end

function scriptLoader.CallHook(name, ...)
  local HookTable = Hooks[name]

	if(HookTable ~= nil) then
		local a, b, c, d, e, f

		for k,v in pairs(HookTable) do
			if(type(k) == "string") then
				a, b, c, d, e, f = v( ... )
			else
				HookTable[k] = nil --The key should always be a string.
			end
		end
	end
end

--[[
  Overwrite functions
]]
function scriptLoader.GetConfig(opt)
  if(Config[opt]) then
    return Config[opt]
  else
    return false
  end
end

function scriptLoader.ProcessCommand(pid, cmd, message)
  --Some preliminary stuff taken from the built in ProcessCommand function
  --Feel free to change stuff if you know what you're doing.
  if cmd[1] == nil then
      local message = "Please use a command after the / symbol.\n"
      tes3mp.SendMessage(pid, color.Error .. message .. color.Default, false)
      return false
  else
      -- The command itself should always be lowercase
      cmd[1] = string.lower(cmd[1])
  end

  local serverOwner = false
  local admin = false
  local moderator = false

  if Players[pid]:IsServerOwner() then
      serverOwner = true
      admin = true
      moderator = true
  elseif Players[pid]:IsAdmin() then
      admin = true
      moderator = true
  elseif Players[pid]:IsModerator() then
      moderator = true
  end

  scriptLoader.CallHook("ProcessCommand", pid, cmd, message, serverOwner, admin, moderator)
end

--[[
    Some utility functions
--]]
function scriptLoader.GetActiveScripts()
  local scripts = scripts --for the speed
  local pluginList = {}

	for k,v in pairs(scripts) do
		pluginList[k] = v.Name
	end

  return pluginList
end

--This completely kills the script. The script will have to be re-included.
function scriptLoader.Kill(id)
  local scripts = scripts --for the speed

	if(scripts[id]) then
		scripts[id] = nil
  end
end

--Unregister a script.
function scriptLoader.Unregister(id)
  local scripts = scripts --for the speed

  if(scripts[id]) then
    scripts[id].Unregister()
  end
end

--Force register a script that's already loaded.
function scriptLoader.Register(id)
  local scripts = scripts --for the speed

  if(scripts[id]) then
    scripts[id].Register()
  end
end

--Reload a script, this will reload just hooks and that's it.
function scriptLoader.Reload(id)
  local scripts = scripts --for the speed

  if(scripts[id]) then
    scripts[id].Reload()
  end
end

--[[
    Our object for scripts.
--]]
function scriptLoader.DefineScript()
	local object = {}

	setmetatable(object, scriptMeta)

	object.Hooks = {}
  object.Methods = {}

	object.ID = nil
	object.Name = "Name"
	object.Author = "Author"
	object.Desc = "Description"

	return object
end

function scriptMeta:AddMethod(id, callback)
  self.Methods[id] = {
    func = callback
  }
end

function scriptMeta:AddHook(name, id, callback)
  self.Hooks[id] = {
    name = name,
    func = callback
  }
end

function scriptMeta:Inject()
  scriptLoader.CallHook("ScriptInit")

  for k,v in pairs(self.Methods) do
    scriptLoader.AddMethod(self.ID, k, v.func)
  end

	for k,v in pairs(self.Hooks) do
		scriptLoader.AddHook(v.name, k, v.func)
  end
end

function scriptMeta:Eject()
  for k,_ in pairs(self.Methods) do
    scriptLoader.RemoveMethod(self.ID, k)
  end

	for k,v in pairs(self.Hooks) do
		scriptLoader.RemoveHook(v.name, k)
	end
end

function scriptMeta:Register()
  local scripts = scripts --for the speed.
	local id = self.ID

	if(id == nil) then
		tes3mp.LogMessage(enumerations.log.ERROR, "scriptLoader: ID returned nil.")
		return
	end

	table.remove(self, 1)

  scripts[id] = self
	self:Inject() --We load all scripts.
end

function scriptMeta:Unregister()
  local scripts = scripts --for the speed
	local id = self.ID

	if scripts[id] then
		self:Eject()
	end
end

function scriptMeta:Reload()
  self:Unregister()
	self:Register()
end

scriptMeta.__index = scriptMeta
return scriptLoader

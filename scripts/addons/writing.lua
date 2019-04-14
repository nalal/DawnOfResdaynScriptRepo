local noteGuiID = 41300
local bookGuiID = 41301
local scrollGuiID = 41302
local _name = nil
--scroll name = t_sc_blank
--book name =

local function showNoteGUI(pid)
  local msg = "Enter what you would like your note to say: "
  tes3mp.InputDialog(pid, noteGuiID, msg, "")
end

local function showBookGUI(pid)
  local msg = "Enter what you would like your book to say: "
  tes3mp.InputDialog(pid, bookGuiID, msg, "")
end

local function showScrollGUI(pid)
  local msg = "Enter what you would like your scroll to say: "
  tes3mp.InputDialog(pid, scrollGuiID, msg, "")
end

local function checkForInk(pid)
  if inventoryHelper.containsItem(Players[pid].data.inventory, "misc_quill") and inventoryHelper.containsItem(Players[pid].data.inventory, "misc_inkwell") then
    return true
  end
  return false
end

local function _genItemName()
  local newName = _name[2];
  local i

  if(#_name > 2) then
    for i=3, #_name, 1 do
      newName = newName.." ".._name[i]
    end
  end

  return newName;
end

local function CreateNote(pid, txt)
  inventoryHelper.removeItem(Players[pid].data.inventory, "sc_paper plain", 1) --remove the paper.

  local idIterator = WorldInstance.data.customVariables.noteCounter
	local noteId
	local noteName = _genItemName()
	local noteModel = "m\\Text_Note_02.nif"
	local noteIcon = "m\\Tx_note_02.tga"
	local noteWeight = 0.20
	local noteValue = 1
	local noteText = txt
	local i = 3

  noteText = "<DIV ALIGN=\"CENTER\">" .. noteText .. "<p>"

  if WorldInstance.data.customVariables.noteCounter == nil then
		idIterator = 0
	else
		idIterator = idIterator + 1
	end
	WorldInstance.data.customVariables.noteCounter = idIterator

	noteId = "plynote_" .. idIterator

  --Storing and creating custom records
	--I'll make proper functions at some point I swear
  local recordTable = CreateRecordTable(noteWeight, noteIcon, "-1", noteModel, noteText, noteValue, true, noteName)

	nuCreateBookRecord(pid, noteId, recordTable)

	local structuredItem = { refId = noteId, count = 1, charge = -1}
	Players[pid]:Save()
	WorldInstance:Save()

	return structuredItem
end

local function CreateBook(pid, txt)
  inventoryHelper.removeItem(Players[pid].data.inventory, "tr_m1_bk_plain", 1) --remove the paper.

  local idIterator = WorldInstance.data.customVariables.bookCounter
	local noteId
	local noteName = _genItemName()
	local noteModel = "m\\Text_Octavo_04.nif"
	local noteIcon = "m\\Tx_Octavo_04.tga"
	local noteWeight = 0.20
	local noteValue = 1
	local noteText = txt
	local i = 3

  noteText = "<DIV ALIGN=\"CENTER\">" .. noteText .. "<p>"

  if WorldInstance.data.customVariables.bookCounter == nil then
		idIterator = 0
	else
		idIterator = idIterator + 1
	end
	WorldInstance.data.customVariables.bookCounter = idIterator

	noteId = "plybook_" .. idIterator

  --Storing and creating custom records
	--I'll make proper functions at some point I swear
  local recordTable = CreateRecordTable(noteWeight, noteIcon, "-1", noteModel, noteText, noteValue, true, noteName)

	nuCreateBookRecord(pid, noteId, recordTable)

	local structuredItem = { refId = noteId, count = 1, charge = -1}
	Players[pid]:Save()
	WorldInstance:Save()

	return structuredItem
end

local function CreateScroll(pid, txt)
  inventoryHelper.removeItem(Players[pid].data.inventory, "t_sc_blank", 1) --remove the paper.

  local idIterator = WorldInstance.data.customVariables.scrollCounter
	local noteId
	local noteName = _genItemName()
	local noteModel = "m\\Text_Scroll_01.nif"
	local noteIcon = "m\\Tx_Scroll_01.tga"
	local noteWeight = 0.20
	local noteValue = 1
	local noteText = txt
	local i = 3

  noteText = "<DIV ALIGN=\"CENTER\">" .. noteText .. "<p>"

  if WorldInstance.data.customVariables.scrollCounter == nil then
		idIterator = 0
	else
		idIterator = idIterator + 1
	end
	WorldInstance.data.customVariables.scrollCounter = idIterator

	noteId = "plyscroll_" .. idIterator

  --Storing and creating custom records
	--I'll make proper functions at some point I swear
  local recordTable = CreateRecordTable(noteWeight, noteIcon, "-1", noteModel, noteText, noteValue, true, noteName)

	nuCreateBookRecord(pid, noteId, recordTable)

	local structuredItem = {refId = noteId, count = 1, charge = -1}
	Players[pid]:Save()
	WorldInstance:Save()

	return structuredItem
end

function CopyItem(pid, item)
  inventoryHelper.removeItem(Players[pid].data.inventory, "ingred_dreugh_wax_01", 1)

  local structuredItem = {refId = item, count = 1, charge = -1}
  table.insert(Players[pid].data.inventory, structuredItem)
end

function CreateRecordTable(weight, icon, skillID, model, text, value, scrollState, name)
  local recordTable = {}
  recordTable["weight"] = weight
	recordTable["icon"] = icon
	recordTable["skillId"] = skillID
	recordTable["model"] = model
	recordTable["text"] = text
	recordTable["value"] = value
	recordTable["scrollState"] = scrollState
	recordTable["name"] = name

  return recordTable;
end

--Based on Create and store record functions from commandhandler in https://github.com/TES3MP/CoreScripts
function nuCreateBookRecord(pid, noteId, recordTable)
	local id = noteId
	local recordStore = RecordStores["book"]
	local savedTable = recordTable

	recordStore.data.permanentRecords[id] = savedTable
	recordStore:Save()
  tes3mp.ClearRecords()
  tes3mp.SetRecordType(enumerations.recordType[string.upper("book")])
	packetBuilder.AddBookRecord(id, savedTable)
	tes3mp.SendRecordDynamic(pid, true, false)
end

local SCRIPT = scriptLoader.DefineScript()
SCRIPT.ID = "writing"
SCRIPT.Name = "Writing"
SCRIPT.Author = "Boyos999, modded by Wishbone"
SCRIPT.Desc = "Write stuff"

SCRIPT:AddHook("ProcessCommand", "WritingCommands", function(pid, cmd, message, isOwner, isAdmin, isMod)
  if(cmd[1] == "writenote") then
    if(cmd[2] ~= nil) then
      if inventoryHelper.containsItem(Players[pid].data.inventory, "sc_paper plain") and checkForInk(pid) then
        _name = cmd
    		showNoteGUI(pid)
    	else
    		Players[pid]:Message("You lack the materials to make a note\n")
    	end
    else
      Players[pid]:Message("You need to name your book! /writenote name here\n")
    end

  elseif(cmd[1] == "writebook") then
    if(cmd[2] ~= nil) then
      if inventoryHelper.containsItem(Players[pid].data.inventory, "tr_m1_bk_plain") and checkForInk(pid) then
        _name = cmd
    		showBookGUI(pid)
    	else
    		Players[pid]:Message("You lack the materials to make a book\n")
    	end
    else
      Players[pid]:Message("You need to name your book! /writebook name here\n")
    end

  elseif(cmd[1] == "writescroll") then
    if(cmd[2] ~= nil) then
      if inventoryHelper.containsItem(Players[pid].data.inventory, "t_sc_blank") and checkForInk(pid) then
        _name = cmd
    		showScrollGUI(pid)
    	else
    		Players[pid]:Message("You lack the materials to make a scroll\n")
    	end
    else
      Players[pid]:Message("You need to name your book! /writescroll name here\n")
    end

  elseif(cmd[1] == "makecopy") then
    if(isMod ~= true) then return end
    if(cmd[2] ~= nil) then
      if(inventoryHelper.containsItem(Players[pid].data.inventory, cmd[2])) then
        if inventoryHelper.containsItem(Players[pid].data.inventory, "ingred_dreugh_wax_01") then
          CopyItem(pid, cmd[2])
      	else
      		Players[pid]:Message("You lack the materials to make a copy!\n")
      	end
      else
        Players[pid]:Message("You can't copy that item or that item doesn't exist!\n")
      end
    else
      Players[pid]:Message("You didn't say what you wanted to copy!\n")
    end
  end
end)

SCRIPT:AddHook("OnGUIAction", "WritingGUI", function(pid, idGui, data)
  if(idGui == noteGuiID) then
    if(data ~= nil) then
      local playerNote = CreateNote(pid, data)
      if(playerNote ~= nil) then
  			table.insert(Players[pid].data.inventory, playerNote)
  			Players[pid]:LoadInventory()
  			Players[pid]:LoadEquipment()
  			Players[pid]:Save()
  		end
    end

  elseif(idGui == bookGuiID) then
    if(data ~= nil) then
      local playerBook = CreateBook(pid, data)
      if(playerBook ~= nil) then
  			table.insert(Players[pid].data.inventory, playerBook)
  			Players[pid]:LoadInventory()
  			Players[pid]:LoadEquipment()
  			Players[pid]:Save()
  		end
    end

  elseif(idGui == scrollGuiID) then
    if(data ~= nil) then
      local playerScroll = CreateScroll(pid, data)
      if(playerScroll ~= nil) then
  			table.insert(Players[pid].data.inventory, playerScroll)
  			Players[pid]:LoadInventory()
  			Players[pid]:LoadEquipment()
  			Players[pid]:Save()
  		end
    end

  end
end)

SCRIPT:Register()

local items = { {"gold_001", 350, -1}, {"p_restore_magicka_c", 1, -1} }

local SCRIPT = scriptLoader.DefineScript()
SCRIPT.ID = "startitems"
SCRIPT.Name = "Starter Items"
SCRIPT.Author = "David-AW"
SCRIPT.Desc = "Gives you some starter items."

SCRIPT:AddHook("OnPlayerEndCharGen", "StarterItems", function(pid)
  for i,item in pairs(items) do
      local structuredItem = { refId = item[1], count = item[2], charge = item[3] }
      table.insert(Players[pid].data.inventory, structuredItem)
  end

  Players[pid]:LoadInventory()
  Players[pid]:LoadEquipment()
end)

SCRIPT:Register()

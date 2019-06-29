math.randomseed( os.time() )
math.random(); math.random() -- Try to improve RNG
local spawnTable = {
  {"-3, 6", -16523, 54362, 1973, 2.73}, -- Ald'Ruhn
  {"-11, 15", -89353, 128479, 110, 1.86}, -- Ald Velothi
  {"-3, -3", -20986, -17794, 865, -0.87}, -- Balmora
  {"-2, 2", -12238, 20554, 1514, -2.77}, -- Caldera
  {"7, 22", 62629, 185197, 131, -2.83}, -- Dagon Fel
  {"2, -13", 20769, -103041, 107, -0.87}, -- Ebonheart
  {"-8, 3", -58009, 26377, 52, -1.49}, -- Gnaar Mok
  {"-11, 11", -86910, 90044, 1021, 0.44}, -- Gnisis
  {"-6, -5", -49093, -40154, 78, 0.94}, -- Hla Oad
  {"-9, 17", -69502, 142754, 50, 2.89}, -- Khuul
  {"-3, 12", -22622, 101142, 1725, 0.28}, -- Maar Gan
  {"12, -8", 103871, -58060, 1423, 2.2}, -- Molag Mar
  {"0, -7", 2341, -56259, 1477, 2.13}, -- Pelagiad
  {"17, 4", 141415, 39670, 213, 2.47}, -- Sadrith Mora
  {"6, -6", 52855, -48216, 897, 2.36}, -- Suran
  {"14, 4", 122576, 40955, 59, 1.16}, -- Tel Aruhn
  {"14, -13", 119124, -101518, 51, 3.08}, -- Tel Branora
  {"13, 14", 106608, 115787, 53, -0.39}, -- Tel Mora
  {"3, -10", 36412, -74454, 59, -1.66}, -- Vivec
  {"11, 14", 101402, 114893, 158, -2.03}, -- Vos
}

local function SpawnItems(pid)
  local rand
  local clothes
  local giveItems = {}
  local wearItems = {}
  local _item = {}
  giveItems[1] = {"gold_001", 350, -1}
  giveItems[2] = {"p_restore_magicka_c", 1, -1}
  giveItems[3] = {"iron dagger", 1, 400}
  --giveItems[4] = {"text_paper_roll_01", 50, -1}
  --giveItems[5] = {"TR_m1_bk_Plain", 50, -1}
  --giveItems[6] = {"sc_paper plain", 50, -1}
  wearItems[1] = "common_shirt_0"
  wearItems[2] = "common_pants_0"--men
  wearItems[3] = "common_skirt_0" --women
  wearItems[4] = "common_shoes_0" --no kats or lizards

  Players[pid].data.inventory = {}
  Players[pid].data.equipment = {}

  tes3mp.LogMessage(2, "++++ Randomizing new player's clothes ++++")

  rand = tostring(math.random(1,5))
  clothes = wearItems[1]..rand
  _item = { refId = clothes, count = 1, charge = -1 }
  Players[pid].data.equipment[8] = _item

  if Players[pid].data.character.gender == 0 then
    rand = tostring(math.random(1,5))
    clothes = wearItems[3]..rand
		_item = { refId = clothes, count = 1, charge = -1 }
		Players[pid].data.equipment[10] = _item
  else
    rand = tostring(math.random(1,5))
    clothes = wearItems[2]..rand
		_item = { refId = clothes, count = 1, charge = -1 }
		Players[pid].data.equipment[9] = _item
  end

  if race ~= "argonian" and race ~= "khajiit" then
    rand = tostring(math.random(1,5))
    clothes = wearItems[4]..rand
		_item = { refId = clothes, count = 1, charge = -1 }
		Players[pid].data.equipment[7] = _item
  end

  tes3mp.LogMessage(2, "++++ Giving new player's starter items ++++")

  for k,v in pairs(giveItems) do
    _item = { refId = v[1], count = v[2], charge = v[3] }
    table.insert(Players[pid].data.inventory, _item)
  end

  Players[pid]:LoadInventory()
  Players[pid]:LoadEquipment()
end

local function SpawnPosition(pid) -- Randomized spawn position based on spawnTable in this script
	local tempRef = math.random(1,#spawnTable) -- Pick a random value from the spawn table

	tes3mp.LogMessage(2, "++++ Spawning new player in cell ... ++++")
	tes3mp.LogMessage(2, "++++ (" .. spawnTable[tempRef][1] .. ") ++++")
	tes3mp.SetCell(pid, spawnTable[tempRef][1])
	tes3mp.SendCell(pid)
	tes3mp.SetPos(pid, spawnTable[tempRef][2], spawnTable[tempRef][3], spawnTable[tempRef][4])
	tes3mp.SetRot(pid, 0, spawnTable[tempRef][5])
	tes3mp.SendPos(pid)
end

local SCRIPT = scriptLoader.DefineScript()
SCRIPT.ID = "randomspawn"
SCRIPT.Name = "Spawn Randomizer"
SCRIPT.Author = "Texafornian, modified by Wishbone"
SCRIPT.Desc = "Randomized player spawns."

SCRIPT:AddHook("OnPlayerEndCharGen", "RandomSpawn", function(pid)
  SpawnItems(pid)
  SpawnPosition(pid)
end)

SCRIPT:Register()

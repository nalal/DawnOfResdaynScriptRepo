local SCRIPT = scriptLoader.DefineScript()
SCRIPT.ID = "dynamicdiff"
SCRIPT.Name = "Dynamic Difficulty"
SCRIPT.Author = "David-AW"
SCRIPT.Desc = "Change the difficulty to match your level."

SCRIPT:AddHook("OnPlayerCellChange", "DynamicDif", function(pid)
  local difficulty
  local difficultyMin = config.difficulty
  local difficultyCap = 150

  local endgameLevel = 77
  local currentLevel = tes3mp.GetLevel(pid)

  difficulty = difficultyMin + (currentLevel * (difficultyCap - difficultyMin) / endgameLevel)
  difficulty = math.floor(difficulty)

  if difficulty < difficultyMin then difficulty = difficultyMin end
  if difficulty > difficultyCap then difficulty = difficultyCap end

  tes3mp.SetDifficulty(pid, difficulty)
  tes3mp.SendSettings(pid)
end)

SCRIPT:Register()

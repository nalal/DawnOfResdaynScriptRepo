
local craftingSkillsConfig = {}
	
	craftingSkillsConfig.craftableSkills = {
		"Blacksmithing",
		"Leatherworking",
		"Tailoring",
		"Cooking"
	}
	--How much progress is required for increasing crafting skill
	craftingSkillsConfig.maxSkillProgress = 10
	--The level caps for skills
	craftingSkillsConfig.maxSkill = 100
	
	craftingSkillsConfig.mineTime = 10000
	
	--The total craft skills you can learn
	craftingSkillsConfig.maxLearnedSkills = 2
	
	--IDNumbers for menus
	craftingSkillsConfig.menuIDs = {
		main = 10000,
		skill = 10001,
		skillSelect = 10002,
		skillUnselect = 10003,
		maxSkills = 10004,
		craft = 10005,
		craftSelect = 10006,
		menuMainCraftID = 10007,
		menuMineID = 10008,
		menuMetalID = 10009,
		menuSmeltID = 10010
	}
	
	craftingSkillsConfig.mineCells = {
		"Caldera Mine"
	}
	
	--Skill names and their corresponding data value
	craftingSkillsConfig.skillNames = {
		mining = "Mining",
		skinning = "Skinning",
		tailoring = "Tailoring",
		smithing = "Blacksmithing",
		leatherworking = "Leatherworking",
		cooking = "Cooking"
	}

return craftingSkillsConfig

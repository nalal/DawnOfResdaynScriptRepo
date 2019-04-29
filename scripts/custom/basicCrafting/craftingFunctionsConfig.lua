
local craftingSkillsConfig = {}

	--How much progress is required for increasing crafting skill
	craftingSkillsConfig.maxSkillProgress = 10
	
	--The level caps for skills
	craftingSkillsConfig.maxSkill = 10
	
	--The total craft skills you can learn
	craftingSkillsConfig.maxLearnedSkills = 2
	
	--IDNumbers for menus
	craftingSkillsConfig.menuIDs = {
		main = 10000,
		skill = 10001,
		skillSelect = 10002,
		skillUnselect = 10003,
		maxSkills = 10004
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

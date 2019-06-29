gatheringData = require("custom/basicCrafting/gatheringData")
oreDictionary = require("custom/basicCrafting/oreDictionary")
local metalDictionary = {}
	metalDictionary.Copper = {
		name = "Copper",
		skill = gatheringData.Copper,
		items = {
			oreDictionary.Copper
		}
	}
	metalDictionary.Tin = {
		name = "Tin",
		skill = gatheringData.Tin,
		items = {
			oreDictionary.Tin
		}
	}
	metalDictionary.Bronze = {
		name = "Bronze",
		skill = gatheringData.Tin + gatheringData.Copper,
		items = {
			oreDictionary.Copper,
			oreDictionary.Tin
		}
	} 
	metalDictionary.Iron = {
		name = "Iron",
		skill = gatheringData.Iron,
		items = {
			oreDictionary.Iron
		}
	}
	metalDictionary.Steel = {
		name = "Steel",
		skill = gatheringData.Iron + gatheringData.Coal,
		items = {
			oreDictionary.Iron,
			oreDictionary.Coal
		}
	}

return metalDictionary

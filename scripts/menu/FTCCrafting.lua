Menus["default crafting start"] = {
	text = color.Orange .. "Crafting Menu\n" ..
		"What would you like to do?",
	    buttons = {
			{caption = "Craft",
				destinations = {
                menuHelper.destinations.setDefault("default crafting select")
			}},
			{caption = "See crafting skills",
				destinations = {
                menuHelper.destinations.setDefault("crafting skills menu")
			}},
			{caption = "Exit", destinations = nil}
		}
}

Menus["default crafting select"] = {
	text = color.Orange .. "Crafting Menu\n" ..
		"What would you like to do?",
	    buttons = {
			{caption = "Smithing",
				destinations = {
                menuHelper.destinations.setDefault("default crafting smithing")
			}},
			{caption = "Tailoring",
				destinations = {
                menuHelper.destinations.setDefault("default crafting tailoring")
			}},
			{caption = "Cooking",
				destinations = {
                menuHelper.destinations.setDefault("default crafting cooking")
			}},
			{caption = "Back", destinations = { menuHelper.destinations.setDefault("default crafting start") } },
			{caption = "Exit", destinations = nil}
		}
}

Menus["default crafting cooking"] = {
    text = color.Orange .. "What would you like to craft?\n" ..
			"There are currently no items in cooking.",
            --color.Yellow .. "Iron Sword" .. color.White .. " - 1 per 3 Iron and 1 Ragged Leather",
    buttons = {--[[
        { caption = "Iron Sword",
            destinations = {
                menuHelper.destinations.setDefault("lack of materials"),
                menuHelper.destinations.setConditional("crafting iron sword",
                {
                    menuHelper.conditions.requireItem("ingred_iron_1", 3),
					menuHelper.conditions.requireItem("ingred_leather_1", 1)
					--menuHelper.conditions.requireCustomSkill("weaponSmithing", 0)
                })
            }
        },]]--
		{ caption = "Back", destinations = { menuHelper.destinations.setDefault("default crafting start") } },
        { caption = "Exit", destinations = nil }
    }
}

Menus["default crafting tailoring"] = {
    text = color.Orange .. "What would you like to craft?\n" ..
			"There are currently no items in tailoring.",
            --color.Yellow .. "Iron Sword" .. color.White .. " - 1 per 3 Iron and 1 Ragged Leather",
    buttons = {
        --[[{ caption = "Iron Sword",
            destinations = {
                menuHelper.destinations.setDefault("lack of materials"),
                menuHelper.destinations.setConditional("crafting iron sword",
                {
                    menuHelper.conditions.requireItem("ingred_iron_1", 3),
					menuHelper.conditions.requireItem("ingred_leather_1", 1)
					--menuHelper.conditions.requireCustomSkill("weaponSmithing", 0)
                })
            }
        },]]--
		{ caption = "Back", destinations = { menuHelper.destinations.setDefault("default crafting start") } },
        { caption = "Exit", destinations = nil }
    }
}

Menus["default crafting smithing"] = {
    text = color.Orange .. "What would you like to craft?\n" ..
            color.Yellow .. "Iron Sword" .. color.White .. " - 1 per 3 Iron and 1 Ragged Leather",
    buttons = {
        { caption = "Iron Sword",
            destinations = {
                menuHelper.destinations.setDefault("lack of materials"),
                menuHelper.destinations.setConditional("crafting iron sword",
                {
                    menuHelper.conditions.requireItem("ingred_iron_1", 3),
					menuHelper.conditions.requireItem("ingred_leather_1", 1)
					--menuHelper.conditions.requireCustomSkill("weaponSmithing", 0)
                })
            }
        },
		{ caption = "Back", destinations = { menuHelper.destinations.setDefault("default crafting start") } },
        { caption = "Exit", destinations = nil }
    }
}

Menus["crafting iron sword"] = {
    text = "Are you sure you want to craft an Iron Sword?",
    buttons = {
        { caption = "yes",
            destinations = {
                menuHelper.destinations.setDefault("lack of materials"),
				menuHelper.destinations.setConditional("reward generic singular",	
				{
				menuHelper.conditions.requireItem("ingred_iron_1", 3),
				menuHelper.conditions.requireItem("ingred_leather_1", 1)},
				{		
				menuHelper.effects.removeItem("ingred_iron_1", 3),
				menuHelper.effects.removeItem("ingred_leather_1", 1),
                menuHelper.effects.giveItem("iron longsword", 1),
				menuHelper.effects.runGlobalFunction("craftSkills", "increaseSkill",  { menuHelper.variables.currentPid(), 1, "weaponSmithing"})})
            }
        },
        { caption = "No",
            destinations = {menuHelper.destinations.setDefault("default crafting origin")}
        },
        { caption = "Back", destinations = { menuHelper.destinations.setDefault("default crafting origin") } },
        { caption = "Exit", destinations = nil }
    }
}

Menus["lack of materials"] = {
    text = "You lack the materials/skill to craft that.",
    buttons = {
        { caption = "Back", destinations = { menuHelper.destinations.setFromCustomVariable("previousCustomMenu") } },
        { caption = "Ok", destinations = nil }
    }
}

Menus["reward generic singular"] = {
    text = "Congratulations! The item is now yours",
    buttons = {
        { caption = "Craft more", destinations = { menuHelper.destinations.setFromCustomVariable("previousCustomMenu") } },
        { caption = "Exit", destinations = nil }
    }
}

Menus["reward generic plural"] = {
    text = "Congratulations! The items are now yours",
    buttons = {
        { caption = "Craft more", destinations = { menuHelper.destinations.setFromCustomVariable("previousCustomMenu") } },
        { caption = "Exit", destinations = nil }
    }
}

Menus["crafting skills menu"] = {
	text =  color.Red .. "FUNCTIONALITY NOT YET IMPLEMENTED\n" .. color.Orange .. "Please use /craftskill\n",
	buttons = {
		{caption = "Back", destinations = menuHelper.destinations.setDefault("previousCustomMenu")},
		{caption = "Exit", destinations = nil}
	}
}
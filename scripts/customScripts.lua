-- Load up your custom scripts here! Ideally, your custom scripts will be placed in the scripts/custom folder and then get loaded like this:
--
-- require("custom/yourScript")
--
-- Refer to the Tutorial.md file for information on how to use various event and command hooks in your scripts.
--Internally developed scripts
basicCraftingSkills = require("custom/basicCrafting/craftingData")
basicCrafting = require("custom/basicCrafting/main")
debugMode = require("custom/debugMode/main")
basicNeeds = require("custom/basicNeeds/main")
basicNeeds = require("custom/bankBuddy/main")

--[This script was for educational purposes, no need to re-enable it] menuTest = require("custom/menuTest/main")
--3rd party scripting, thanks to those who are responsible
FossMail = require("custom/FossMail/main")

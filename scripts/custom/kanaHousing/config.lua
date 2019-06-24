local config = {}

config.defaultPrice = 5000 --The price a house defaults to when it's created
config.requiredAdminRank = 1 --The admin rank required to use the admin GUI
config.allowWarp = true --Whether or not players can use the option to warp to their home
config.logging = true --If the script reports its own information to the server log
config.chatColor = "#00FF7F" --The color used for the script's chat messages

config.AdminMainGUI = 31371
config.AdminHouseCreateGUI = 31372
config.AdminHouseSelectGUI = 31373
config.CellEditGUI = 31374
config.HouseEditGUI = 31375
config.HouseEditPriceGUI = 31376
config.HouseEditOwnerGUI = 31377
config.HouseInfoGUI = 31378
config.PlayerMainGUI = 31379
config.PlayerAllHouseSelectGUI = 31380
config.PlayerSettingGUI = 31381
config.PlayerOwnedHouseSelect = 31382
config.PlayerAddCoOwnerGUI = 31383
config.PlayerRemoveCoOwnerGUI = 31384
config.PlayerSellConfirmGUI = 31385

return kanaHousingConfig

local enableLocalChat = true
local enableNickNames = true
local enableLanguages = true

local lastMessage = ""
local lastMessageSenderPID = 0

local localChatCellRadius = 1 -- 0 means only the players in the same cell can hear eachother
local WhisperDistance = 250
local TalkingDistance = 750
local ShoutingDistance = 2000

local WhisperText = color.Red .. ": *whispers*" .. color.Default
local ShoutText = color.Red .. ": *shouts*" .. color.Default

local globalChatHeader = "[OOC] "
local globalChatHeaderColor = color.LightSalmon
local disableOOCForNonAdmins = false -- Use /toggleooc to change this value ingame if you are an admin

local localOOCChatHeader = "[LOOC] "
local localOOCChatHeaderColor = color.Wheat
local prefixesAllowedInOOC = {}
local prefixesAllowedInRP = {}

local actionMsgSymbol = "[ACTION] "
local actionMsgColor = color.Red
-- color.RedAction is not a default TES3MP color, it is custom assigned in scripts/colors.lua !!
-- color.RedAction = "#DF2424"
local nickNames = {}
local nickNameColor = color.SlateGray
local nickNameMinCharLength = 3
local nickNameMaxCharLength = 15

local acceptableEnds = {["."] = true, ["?"] = true, ["!"] = true}

local languageColors = {}
languageColors["high elf"] = color.GoldenRod
languageColors["argonian"] = color.HoneyDew
languageColors["Dark Elf"] = color.DarkSlateBlue
languageColors["wood elf"] = color.Linen
languageColors["breton"] = color.PeachPuff
languageColors["khajiit"] = color.Tan
languageColors["nord"] = color.CadetBlue
languageColors["orc"] = color.Chartreuse
languageColors["redguard"] = color.OrangeRed

local langColorKey = {}
langColorKey["d"] = "Dark Elf"
langColorKey["a"] = "argonian"
langColorKey["h"] = "high elf"
langColorKey["w"] = "wood elf"
langColorKey["b"] = "breton"
langColorKey["k"] = "khajiit"
langColorKey["n"] = "nord"
langColorKey["o"] = "orc"
langColorKey["r"] = "redguard"

langNames = {}
langNames["high elf"] = "Altmer"
langNames["argonian"] = "Argonian"
langNames["wood elf"] = "Bosmer"
langNames["breton"] = "Breton"
langNames["Dark Elf"] = "Dunmer"
langNames["khajiit"] = "Khajiit"
langNames["nord"] = "Nordic"
langNames["orc"] = "Orsimer"
langNames["redguard"] = "Redguardian"

local rpChat = {}

local styles = {}
local playerStyles = {}
local learnedLang

function rpChat.loadPlayerStyle(pid)
    -- Replace characters not allowed in filenames
    local acc = string.upper(Players[pid].accountName)
    acc = string.gsub(acc, patterns.invalidFileCharacters, "_")
    acc = acc .. ".json"
    
    local style = {}
    style.nameColor = color.Moccasin -- add this to bottom of color.lua, color.Default2 = color.Moccasin for this to work!
    style.prefix = {}
    
    local home = tes3mp.GetModDir() .. "/style/players/"
    local file = io.open(home .. acc, "r")
    if file ~= nil then
        io.close()
        style = jsonInterface.load("style/players/" .. acc)
    else
        style.nameColor = color.Moccasin -- add this to bottom of color.lua, color.Default2 = color.Moccasin for this to work!
        style.prefix = {}
        jsonInterface.save("style/players/" .. acc, style)
    end
    
    return style
end

function rpChat.savePlayerStyle(pid)
    -- Replace characters not allowed in filenames
    local acc = string.upper(Players[pid].accountName)
    acc = string.gsub(acc, patterns.invalidFileCharacters, "_")
    acc = acc .. ".json"
    
    jsonInterface.save("style/players/" .. acc, playerStyles[pid])
end

function rpChat.saveWhitelistSettings(description, rp, ooc)
    prefixesAllowedInRP[description] = rp
    jsonInterface.save("style/RPWhitelist.json", prefixesAllowedInRP)
    
    prefixesAllowedInOOC[description] = ooc
    jsonInterface.save("style/OOCWhitelist.json", prefixesAllowedInOOC)
end

function rpChat.saveToLearnedLanguages(pid, lang)
    local n = string.upper(Players[pid].accountName)
    
    if learnedLang[n] then
        for i, l in pairs(learnedLang[n]) do
            if l == langColorKey[lang] then
                return
            end
        end
    else
        learnedLang[n] = {}
        learnedLang[n][1] = langColorKey[lang]
    end
    
    learnedLang[n][#learnedLang[n] + 1] = langColorKey[lang]
    jsonInterface.save("style/LearnedLanguages.json", learnedLang)
    
    tes3mp.SendMessage(pid, color.Green .. "You learned to speak in " .. languageColors[langColorKey[lang]] .. langNames[langColorKey[lang]] .. color.Green .. "!\n" .. color.Default)
end

function rpChat.removeLearnedLanguage(pid, lang)
    local n = string.upper(Players[pid].accountName)
    
    if learnedLang[n] then
        for i, l in pairs(learnedLang[n]) do
            if l == langColorKey[lang] then
                learnedLang[n][i] = nil
                break
            end
        end
    end
    
    jsonInterface.save("style/LearnedLanguages.json", learnedLang)
    tes3mp.SendMessage(pid, color.Red .. "You forgot how to speak in " .. languageColors[langColorKey[lang]] .. langNames[langColorKey[lang]] .. color.Red .. ".\n" .. color.Default)
end

function rpChat.firstToUpper(str)
    -- allows uppercasing the beginning of sentences.
    return (str:gsub("^%l", string.upper))
end

function rpChat.periodAtEnd(str)
    local lastChar = string.sub(str, string.len(str))
    if not acceptableEnds[lastChar] then
        return str .. "."
    else
        return str
    end
end

function rpChat.translate(pid1, pid2, lang, message)
    local temp = ""
    local speakerRace = Players[pid1].data.character.race
    local listenerRace = Players[pid2].data.character.race
    local speakerLanguages = learnedLang[string.upper(Players[pid1].name)]
    local listenerLanguages = learnedLang[string.upper(Players[pid2].name)]
    local speakerSpeaksLang = false
    local listenerSpeaksLang = false
    
    if lang and lang ~= "" and langColorKey[lang] then
        
        if speakerLanguages then
            for i, l in pairs(speakerLanguages) do
                if l == langColorKey[lang] then
                    speakerSpeaksLang = true
                    break
                end
            end
        elseif langColorKey[lang] == speakerRace then
            speakerSpeaksLang = true
        end
        
        if speakerSpeaksLang then
            if listenerLanguages then
                for i, l in pairs(listenerLanguages) do
                    if l == langColorKey[lang] then
                        listenerSpeaksLang = true
                        break
                    end
                end
            else
                listenerSpeaksLang = false
            end
            if not listenerSpeaksLang and listenerRace ~= langColorKey[lang] then
                temp = temp .. languageColors[langColorKey[lang]] .. "(" .. langNames[langColorKey[lang]] .. ") "
                for i = 1, string.len(message) do
                    if string.byte(message, i) ~= 32 then
                        temp = temp .. "?"
                    else
                        temp = temp .. " "
                    end
                end
            else
                temp = languageColors[langColorKey[lang]] .. "(" .. langNames[langColorKey[lang]] .. ") " .. message --TODO make a translator module script
            end
        else
            return message
        end
    
    elseif (not lang or lang == "") and langNames[speakerRace] then
        
        if not lang or lang == "" then
            lang = string.lower(string.sub(speakerRace, 1, 1))
        end
        
        if listenerLanguages then
            for i, l in pairs(listenerLanguages) do
                if l == speakerRace then
                    listenerSpeaksLang = true
                    break
                end
            end
        else
            listenerSpeaksLang = false
        end
        
        if not listenerSpeaksLang and listenerRace ~= speakerRace then
            temp = temp .. languageColors[speakerRace] .. "(" .. langNames[speakerRace] .. ") "
            for i = 1, string.len(message) do
                if string.byte(message, i) ~= 32 then
                    temp = temp .. "?"
                else
                    temp = temp .. " "
                end
            end
        else
            temp = languageColors[speakerRace] .. "(" .. langNames[speakerRace] .. ") " .. message --TODO make a translator module script
        end
    else
        return message
    end
    return temp
end

function rpChat.HandleLanguageConversion(pid1, pid2, message)
    local temp = ""
    local lang = ""
    local totalMessage = {}
    local t = 1
    local skipto = 0
    
    if enableLanguages then
        
        for i = 1, string.len(message) do
            if i > skipto then
                if string.byte(message, i) == 123 then
                    totalMessage[t] = {false, temp}
                    skipto = i + 1
                    t = t + 1
                    temp = ""
                    if string.find(message, "}", i + 1) then
                        if string.find(message, "~", i + 1) and string.find(message, "~", i + 1) - i < 3 and string.find(message, "~", i + 1) < string.find(message, "}", i + 1) then
                            lang = string.char(string.byte(message, i + 1))
                            skipto = i + 3
                            if string.byte(message, skipto) == 32 then
                                skipto = skipto + 1
                            end
                        end
                        totalMessage[t] = {true, string.sub(message, skipto, string.find(message, "}", i + 1) - 1), lang}
                        skipto = string.find(message, "}", i + 1)
                        lang = ""
                        t = t + 1
                    else
                        totalMessage[t] = {true, string.sub(message, i + 1), lang}
                        break
                    end
                else
                    temp = temp .. string.char(string.byte(message, i))
                end
            end
        end
        
        t = t + 1
        totalMessage[t] = {false, temp, lang}
        
        -- for i,v in pairs(totalMessage) do
        -- print(v[1])
        -- print(v[3])
        -- print(i..": "..v[2])
        -- end
        temp = ""
        
        for index, msg in pairs(totalMessage) do
            if msg[1] then
                temp = temp .. rpChat.translate(pid1, pid2, msg[3], msg[2])
                temp = temp .. color.Default
            else
                temp = temp .. msg[2]
            end
        end
        return temp
    end
    
    return message
end

-------------------------------------------
--				Start of RP functions				   --
-------------------------------------------
function rpChat.GetFullName(pid, enforceRealName)
    local playerName = Players[pid].accountName
    
    if enforceRealName == true then
        local temp = ""
        
        for pre, bool in pairs(prefixesAllowedInOOC) do
            for i, tag in pairs(playerStyles[pid].prefix) do
                if bool and tag == pre and styles[tag] then
                    temp = temp .. styles[tag] .. " "
                end
            end
        end
        return temp .. playerName
    else
        
        local temp = ""
        for pre, bool in pairs(prefixesAllowedInRP) do
            for i, tag in pairs(playerStyles[pid].prefix) do
                if bool and tag == pre and styles[tag] then
                    temp = temp .. styles[pre] .. " "
                end
            end
        end
        
        if nickNames[pid] ~= nil and enableNickNames == true then
            return nickNameColor .. nickNames[pid] .. color.Default
        else
            return temp .. playerStyles[pid].nameColor .. playerName .. color.Default
        end
    end
end

function rpChat.HandleLanguageTeaching(pid, teach, lang)
    if teach == "teach" then
        rpChat.saveToLearnedLanguages(tonumber(pid), lang)
    elseif teach == "unteach" then
        rpChat.removeLearnedLanguage(tonumber(pid), lang)
    end
end

function rpChat.SetNickNames(pid, name)
    if enableNickNames == true then
        if name ~= nil then
            name = string.sub(name, 7)
            if name:len() >= nickNameMinCharLength and name:len() <= nickNameMaxCharLength then
                nickNames[pid] = name
                tes3mp.SendMessage(pid, "Your nickname has been set to: " .. name .. "\n", false)
            else
                nickNames[pid] = nil
                tes3mp.SendMessage(pid, "Your nickname has been reset.\n(Nicknames must be " .. nickNameMinCharLength .. "-" .. nickNameMaxCharLength .. " characters long)\n", false)
            end
        end
    else
        tes3mp.SendMessage(pid, "Nicknames are not enabled on this server.\n", false)
    end
end

function rpChat.AddPrefix(pid, desc)
    if styles[desc] ~= nil then
        for i, d in pairs(playerStyles[pid].prefix) do
            if d == desc then
                return "That player already has the prefix \"" .. desc .. "\".\n"
            end
        end
        
        table.insert(playerStyles[pid].prefix, desc)
        
        rpChat.savePlayerStyle(pid)
        
        return "Prefix \"" .. desc .. "\" added to " .. rpChat.GetFullName(pid, true) .. ".\n"
    else
        
        return "The prefix \"" .. desc .. "\" does not exist.\n"
    end
end

function rpChat.CreatePrefix(desc, tag, col, allowedInOOC, allowedInRP)
    if not styles[desc] then
        
        styles[desc] = "#" .. col .. "[" .. tag .. "]" .. color.Default
        jsonInterface.save("style/prefix.json", styles)
        
        local rp, ooc = false, false
        
        if string.upper(allowedInRP) == "TRUE" then
            rp = true
        end
        
        if string.upper(allowedInOOC) == "TRUE" then
            ooc = true
        end
        
        rpChat.saveWhitelistSettings(desc, rp, ooc)
        
        return "Prefix \"" .. desc .. "\" created.\n"
    else
        
        return "The prefix \"" .. desc .. "\" already exists.\n"
    end
end

function rpChat.ChangePrefixPerms(desc, allowedInOOC, allowedInRP)
    if styles[desc] then
        
        local rp, ooc = false, false
        
        if string.upper(allowedInRP) == "TRUE" then
            rp = true
        end
        
        if string.upper(allowedInOOC) == "TRUE" then
            ooc = true
        end
        
        rpChat.saveWhitelistSettings(desc, rp, ooc)
        
        return "Prefix \"" .. desc .. "\" permissions changed.\n"
    
    else
        return "The prefix \"" .. desc .. "\" doesnt exist.\n"
    end
end

function rpChat.RemovePrefix(pid, desc)
    if styles[desc] ~= nil then
        
        local index = 0
        
        for i, d in pairs(playerStyles[pid].prefix) do
            if d == desc then
                index = i
            end
        end
        
        if index > 0 then
            table.remove(playerStyles[pid].prefix, index)
        end
        
        rpChat.savePlayerStyle(pid)
        
        return "Removed prefix \"" .. desc .. "\" from player " .. rpChat.GetFullName(pid, true) .. ".\n"
    
    else
        return "The prefix \"" .. desc .. "\" does not exist.\n"
    end
end

function rpChat.SetNameColor(pid, color)
    if string.len(color) == 7 then
        if string.byte(string.sub(color, 1, 1)) == 35 then
            for i = 2, 7, 1 do
                local b = string.byte(string.sub(color, i, i))
                if (b < 48 or b > 57) and (b < 65 or b > 70) then
                    return "Incorrect color code format 0-9 / A-F (ie: FFFFFF).\n"
                end
            end
            
            if playerStyles[pid] ~= nil then
                playerStyles[pid].nameColor = color
                rpChat.savePlayerStyle(pid)
                return "Player " .. rpChat.GetFullName(pid, true) .. "'s name color has been set.\n"
            else
                return "Player " .. pid .. " does not exist.\n"
            end
        end
        return "Incorrect color code format 0-9 / A-F (ie: FFFFFF).\n"
    
    else
        return "Color codes have to be 7 characters long (ie: FFFFFF).\n"
    end
end

function rpChat.ToggleOOC(pid)
    if disableOOCForNonAdmins == true then
        disableOOCForNonAdmins = false
        tes3mp.SendMessage(pid, color.Green .. "OOC has been enabled for all players.\n", true)
    else
        disableOOCForNonAdmins = true
        tes3mp.SendMessage(pid, color.Error .. "OOC has been disabled for all players except admins.\n", true)
    end
end

function rpChat.ToggleLanguage(pid)
    if not enableLanguages then
        enableLanguages = true
        tes3mp.SendMessage(pid, color.Green .. "Languages have been enabled.\n", true)
    else
        enableLanguages = false
        tes3mp.SendMessage(pid, color.Error .. "Languages have been disabled.\n", true)
    end
end

function rpChat.SendGlobalMessage(pid, message, useName)
    if useName == true then
        tes3mp.SendMessage(pid, rpChat.GetFullName(pid, false) .. ": " .. rpChat.firstToUpper(rpChat.periodAtEnd(message)) .. "\n", true)
    else
        tes3mp.SendMessage(pid, rpChat.firstToUpper(rpChat.periodAtEnd(message)) .. "\n", true)
    end
end

function rpChat.SendLocalMessage(pid, message, useName, whisper, yell)
    local playerName = Players[pid].accountName
    
    local myCellDescription = Players[pid].data.location.cell
    
    local pX = tes3mp.GetPosX(pid)
    local pZ = tes3mp.GetPosY(pid)
    
    --Because of modded clients.
    if myCellDescription ~= nil and myCellDescription ~= '' then
        if tes3mp.IsInExterior(pid) == true then
            local cellX = tonumber(string.sub(myCellDescription, 1, string.find(myCellDescription, ",") - 1))
            local cellY = tonumber(string.sub(myCellDescription, string.find(myCellDescription, ",") + 2))
            
            local firstCellX = cellX - localChatCellRadius
            local firstCellY = cellY + localChatCellRadius
            
            local length = localChatCellRadius * 2
            
            for x = 0, length, 1 do
                for y = 0, length, 1 do
                    -- loop through all y inside of x
                    local tempCell = (x + firstCellX) .. ", " .. (firstCellY - y)
                    -- send message to each player in cell
                    if LoadedCells[tempCell] ~= nil then
                        if useName == true then
                            rpChat.SendMessageToAllInCellWithLanguage(pid, pX, pZ, tempCell, message, whisper, yell)
                        else
                            rpChat.SendMessageToAllInCell(pX, pZ, tempCell, "" .. rpChat.firstToUpper(rpChat.periodAtEnd(message)) .. "\n")
                        end
                    end
                end
            end
        else
            
            if useName == true then
                rpChat.SendMessageToAllInCellWithLanguage(pid, pX, pZ, myCellDescription, message, whisper, yell)
            else
                rpChat.SendMessageToAllInCell(pX, pZ, myCellDescription, "" .. rpChat.firstToUpper(rpChat.periodAtEnd(message)) .. "\n")
            end
        end
    end
end

function rpChat.SendMessageToAllInCellWithLanguage(pid1, pX, pZ, cellDescription, message, whisper, yell)
    local temp = ""
    
    for index, pid2 in pairs(LoadedCells[cellDescription].visitors) do
        if Players[pid2].data.location.cell == cellDescription then
            local pX2 = tes3mp.GetPosX(pid2)
            local pZ2 = tes3mp.GetPosY(pid2)
            
            local dist = math.sqrt(math.pow(pX2 - pX, 2) + math.pow(pZ2 - pZ, 2))
            
            if whisper and dist <= WhisperDistance then
                if enableLanguages then
                    tes3mp.SendMessage(pid2, rpChat.GetFullName(pid1, false) .. WhisperText .. " \"" .. rpChat.firstToUpper(rpChat.periodAtEnd(rpChat.HandleLanguageConversion(pid1, pid2, message))) .. "\"\n", false)
                else
                    tes3mp.SendMessage(pid2, rpChat.GetFullName(pid1, false) .. WhisperText .. " \"" .. rpChat.firstToUpper(rpChat.periodAtEnd(message)) .. "\"\n", false)
                end
                
                if pid2 ~= pid1 then
                    if nickNames[Players[pid2].name] ~= nil and enableNickNames == true then
                        if temp ~= "" then
                            temp = temp .. ", " .. nickNames[Players[pid2].name]
                        else
                            temp = temp .. nickNames[Players[pid2].name]
                        end
                    else
                        if temp ~= "" then
                            temp = temp .. ", " .. Players[pid2].name
                        else
                            temp = temp .. Players[pid2].name
                        end
                    end
                end
            
            elseif yell and dist <= ShoutingDistance then
                if enableLanguages then
                    tes3mp.SendMessage(pid2, rpChat.GetFullName(pid1, false) .. ShoutText .. " \"" .. rpChat.firstToUpper(rpChat.periodAtEnd(rpChat.HandleLanguageConversion(pid1, pid2, message))) .. "\"\n", false)
                else
                    tes3mp.SendMessage(pid2, rpChat.GetFullName(pid1, false) .. ShoutText .. " \"" .. rpChat.firstToUpper(rpChat.periodAtEnd(message)) .. "\"\n", false)
                end
            
            elseif not whisper and not yell and dist <= TalkingDistance then
                if enableLanguages then
                    tes3mp.SendMessage(pid2, rpChat.GetFullName(pid1, false) .. ": \"" .. rpChat.firstToUpper(rpChat.periodAtEnd(rpChat.HandleLanguageConversion(pid1, pid2, message))) .. "\"\n", false)
                else
                    tes3mp.SendMessage(pid2, rpChat.GetFullName(pid1, false) .. ": \"" .. rpChat.firstToUpper(rpChat.periodAtEnd(message)) .. "\"\n", false)
                end
            
            elseif (yell and dist <= ShoutingDistance + 500 and dist > ShoutingDistance) or (not whisper and not yell and dist <= TalkingDistance + 250 and dist > TalkingDistance) then
                if nickNames[Players[pid2].name] ~= nil and enableNickNames == true then
                    if temp ~= "" then
                        temp = temp .. ", " .. nickNames[Players[pid2].name]
                    else
                        temp = temp .. nickNames[Players[pid2].name]
                    end
                else
                    if temp ~= "" then
                        temp = temp .. ", " .. Players[pid2].name
                    else
                        temp = temp .. Players[pid2].name
                    end
                end
            end
        end
    end
    
    if temp:len() > 2 then
        if not whisper then
            tes3mp.SendMessage(pid1, color.Yellow .. temp .. color.DarkGray .. " cannot hear what you had to say.\n" .. color.Default, false)
        else
            tes3mp.SendMessage(pid1, color.Yellow .. temp .. color.DarkGray .. " heard you.\n" .. color.Default, false)
        end
    end
end

function rpChat.SendMessageToAllInCell(pX, pZ, cellDescription, message)
    for index, pid2 in pairs(LoadedCells[cellDescription].visitors) do
        if Players[pid2].data.location.cell == cellDescription then
            tes3mp.SendMessage(pid2, message, false)
        end
    end
end

function rpChat.SendLocalOOCMessage(pid, message)
    if enableLocalChat == true then
        local msg = localOOCChatHeaderColor .. localOOCChatHeader .. color.Default .. rpChat.GetFullName(pid, true) .. " (" .. pid .. "):" .. rpChat.firstToUpper(rpChat.periodAtEnd(message))
        rpChat.SendLocalMessage(pid, msg, false, false, false)
    else
        tes3mp.SendMessage(pid, "You cannot send a local OOC with local chat disabled.\n")
    end
end

function rpChat.SendGlobalOOCMessage(pid, message)
    if message:len() > 1 then
        local msg = globalChatHeaderColor .. globalChatHeader .. color.Default .. rpChat.GetFullName(pid, true) .. " (" .. pid .. "):" .. rpChat.firstToUpper(rpChat.periodAtEnd(message))
        rpChat.SendGlobalMessage(pid, msg, false)
    else
        tes3mp.SendMessage(pid, "Your message cannot be empty.\n", false)
    end
end

function rpChat.SendActionMsg(pid, message)
    local msg
    
    if message:len() > 1 then
        if nickNames[Players[pid].accountName] ~= nil and enableNickNames == true then
            msg = actionMsgColor .. actionMsgSymbol .. "" .. color.Default .. nickNames[Players[pid].accountName] .. string.sub(message, 4)
        else
            msg = actionMsgColor .. actionMsgSymbol .. "" .. color.Default .. Players[pid].accountName .. string.sub(message, 4)
        end
        
        if enableLocalChat == true then
            rpChat.SendLocalMessage(pid, msg, false, false, false)
        else
            rpChat.SendGlobalMessage(pid, msg, false)
        end
    else
        tes3mp.SendMessage(pid, "Your message cannot be empty.\n", false)
    end
end

function IsLocalChatEnabled()
    return enableLocalChat
end

function rpChat.init()
    local home = tes3mp.GetModDir() .. "/style/"
    local file = io.open(home .. "prefix.json", "r")
    
    if file ~= nil then
        io.close()
        styles = jsonInterface.load("style/prefix.json")
    else
        styles.owner = color.Purple .. "[Owner]" .. color.Default
        styles.admin = color.Red .. "[Admin]" .. color.Default
        styles.moderator = color.BlueViolet .. "[Mod]" .. color.Default
        
        jsonInterface.save("style/prefix.json", styles)
    end
    io.close()
    
    file = io.open(home .. "OOCWhitelist.json", "r")
    if file ~= nil then
        io.close()
        prefixesAllowedInOOC = jsonInterface.load("style/OOCWhitelist.json")
    else
        prefixesAllowedInOOC = {admin = true}
        jsonInterface.save("style/OOCWhitelist.json", prefixesAllowedInOOC)
    end
    io.close()
    
    file = io.open(home .. "RPWhitelist.json", "r")
    if file ~= nil then
        io.close()
        prefixesAllowedInRP = jsonInterface.load("style/RPWhitelist.json")
    else
        prefixesAllowedInRP = {admin = true}
        jsonInterface.save("style/RPWhitelist.json", prefixesAllowedInRP)
    end
    io.close()
    
    file = io.open(home .. "LearnedLanguages.json", "r")
    if file ~= nil then
        io.close()
        learnedLang = jsonInterface.load("style/LearnedLanguages.json")
    else
        learnedLang = {t3st1234567890 = {"Dark Elf"}}
        jsonInterface.save("style/LearnedLanguages.json", learnedLang)
    end
    io.close()
end

function rpChat.CommandtHook(pid, cmd)
    
    if cmd[1] == "me" then
        rpChat.SendActionMsg(pid, message)
    
    elseif cmd[1] == "nick" then
        rpChat.SetNickNames(pid, message)
    
    elseif cmd[1] == "toggleooc" then
        if isAdmin then
            rpChat.ToggleOOC(pid)
        end
    
    elseif cmd[1] == "togglelang" then
        if isAdmin then
            rpChat.ToggleLanguage(pid)
        end
    
    elseif cmd[1] == "lang" then
        if isAdmin then
            if cmd[2] and cmd[3] and cmd[4] and logicHandler.CheckPlayerValidity(pid, cmd[4]) then
                rpChat.HandleLanguageTeaching(cmd[4], cmd[2], cmd[3])
            else
                tes3mp.SendMessage(pid, color.Red .. "Usage /lang teach/unteach d/a/h/w/b/k/n/o/r pid\n")
            end
        end
    
    elseif cmd[1] == "/" then
        if disableOOCForNonAdmins == false or isAdmin == true then
            message = color.DimGray .. string.sub(message, 3)
            rpChat.SendGlobalOOCMessage(pid, message)
        end
    
    elseif cmd[1] == "//" then
        message = color.DimGray .. string.sub(message, 4)
        rpChat.SendLocalOOCMessage(pid, message)
    
    elseif cmd[1] == "w" then
        rpChat.SendLocalMessage(pid, string.sub(message, 4), true, true, false)
    
    elseif cmd[1] == "s" then
        rpChat.SendLocalMessage(pid, string.sub(message, 4), true, false, true)
    
    elseif cmd[1] == "ncolor" then
        if (isMod == true) then
            if cmd[2] ~= nil and cmd[3] ~= nil then
                if logicHandler.CheckPlayerValidity(pid, cmd[2]) then
                    tes3mp.SendMessage(pid, rpChat.SetNameColor(tonumber(cmd[2]), "#" .. cmd[3]), false)
                end
            else
                tes3mp.SendMessage(pid, "Invalid arguments expected /ncolor PID ColorCode\n", false)
            end
        end
    
    elseif cmd[1] == "prefix" then
        if (isMod == true) then
            if cmd[2] ~= nil and cmd[3] ~= nil and cmd[4] ~= nil then
                if cmd[2] == "add" then
                    if styles[cmd[3]] ~= nil and logicHandler.CheckPlayerValidity(pid, tonumber(cmd[4])) then
                        tes3mp.SendMessage(pid, rpChat.AddPrefix(tonumber(cmd[4]), cmd[3]), false)
                    end
                
                elseif cmd[2] == "remove" then
                    if styles[cmd[3]] ~= nil and logicHandler.CheckPlayerValidity(pid, tonumber(cmd[4])) then
                        tes3mp.SendMessage(pid, rpChat.RemovePrefix(tonumber(cmd[4]), cmd[3]), false)
                    end
                
                elseif cmd[2] == "create" then
                    if cmd[5] ~= nil and cmd[6] ~= nil and cmd[7] then
                        tes3mp.SendMessage(pid, rpChat.CreatePrefix(cmd[3], cmd[4], cmd[5], cmd[6], cmd[7]), false)
                    else
                        tes3mp.SendMessage(pid, "Expected color code in argument #5 and true or false in argument #6 and #7.\n", false)
                    end
                
                elseif cmd[2] == "perm" then
                    if cmd[5] ~= nil then
                        tes3mp.SendMessage(pid, rpChat.ChangePrefixPerms(cmd[3], cmd[4], cmd[5]), false)
                    else
                        tes3mp.SendMessage(pid, "Expected true or false in argument #5.\n", false)
                    end
                
                else
                    tes3mp.SendMessage(pid, "Expected add/remove/create in argument #2.\n", false)
                end
            else
                tes3mp.SendMessage(pid, "Use [/prefix add/remove description PID] or\n[/prefix create description tagcontent colorcode useInRP useInOOC] or\n[/prefix perm description useInRP useInOOC]\n", false)
            end
        end
    end
end

customEventHooks.registerHandler('OnServerPostInit', rpChat.init)

customEventHooks.registerHandler("OnPlayerAuthentified", function(pid)
    playerStyles[pid] = rpChat.loadPlayerStyle(pid)
end)

customEventHooks.registerHandler("OnPlayerDisconnect", function(pid)
    playerStyles[pid] = nil
    nickNames[pid] = nil
end)

customEventHooks.registerValidator("OnPlayerSendMessage",  function(pid, message) 
	if message ~= lastMessage then
		lastMessage = message
		
		if enableLocalChat == true then
			rpChat.SendLocalMessage(pid, message, true, false, false)
		else
			rpChat.SendGlobalMessage(pid, message, true)
		end
	end
end)

-- Register commands
customCommandHooks.registerCommand("me", rpChat.ChatHook)
customCommandHooks.registerCommand("nick", rpChat.ChatHook)
customCommandHooks.registerCommand("toggleooc", rpChat.ChatHook)
customCommandHooks.registerCommand("togglelang", rpChat.ChatHook)
customCommandHooks.registerCommand("lang", rpChat.ChatHook)
customCommandHooks.registerCommand("/", rpChat.ChatHook)
customCommandHooks.registerCommand("//", rpChat.ChatHook)
customCommandHooks.registerCommand("w", rpChat.ChatHook)
customCommandHooks.registerCommand("s", rpChat.ChatHook)
customCommandHooks.registerCommand("ncolor", rpChat.ChatHook)
customCommandHooks.registerCommand("prefix", rpChat.ChatHook)

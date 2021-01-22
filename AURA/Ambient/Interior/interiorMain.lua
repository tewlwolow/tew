local data = require("tew\\AURA\\Ambient\\Interior\\interiorData")
local config = require("tew\\AURA\\config")
local debugLogOn = config.debugLogOn
local modversion = require("tew\\AURA\\version")
local version = modversion.version
--local common = require("tew\\AURA\\common")
--local getCellType = common.getCellType
local tewLib = require("tew\\tewLib\\tewLib")
local findWholeWords = tewLib.findWholeWords

local interiorDir = "tew\\AURA\\Interior\\"
local path, playedFlag, musicPath, lastMusicPath

local function debugLog(string)
    if debugLogOn then
       mwse.log("[AURA "..version.."] RA: "..string.format("%s", string))
    end
end

local arrays = {
    ["Alchemist"] = {},
    ["Caves"] = {},
    ["Clothier"] = {},
    ["Daedric"] = {},
    ["Dwemer"] = {},
    ["Ice Caves"] = {},
    ["Mages"] = {},
    ["Fighters"] = {},
    ["Temple"] = {},
    ["Library"] = {},
    ["Trader"] = {},
    ["Tavern"] = {
        ["Imperial"] = {},
        ["Dark Elf"] = {},
        ["Nord"] = {},
    }
}

local musicArrays = {
    ["Imperial"] = {},
    ["Dark Elf"] = {},
    ["Nord"] = {},
}

local function playInterior()
    timer.start{duration=0.82, type=timer.real, callback=function()
        playedFlag = 1
        debugLog("Playing interior track: "..path)
        tes3.playSound{
        soundPath = path,
        reference = tes3.player,
        volume = 1.0,
        loop=true
        }
    end}
end

local function playMusic()
        playedFlag = 1
        lastMusicPath=musicPath
        --debugLog("Playing music track: "..musicPath)
        tes3.streamMusic{
            path = musicPath,
            crossfade = 0,
        }
end

for interiorType, _ in pairs(arrays) do
    for soundfile in lfs.dir("Data Files\\Sound\\"..interiorDir.."\\"..interiorType) do
        if soundfile and soundfile ~= ".." and soundfile ~= "." and string.endswith(soundfile, ".wav") then
            table.insert(arrays[interiorType], soundfile)
            debugLog("Adding interior file: "..soundfile)
        end
    end
end

for folder in lfs.dir("Data Files\\Sound\\"..interiorDir.."\\Tavern") do
    for soundfile in lfs.dir("Data Files\\Sound\\"..interiorDir.."\\Tavern\\"..folder) do
        if soundfile and soundfile ~= ".." and soundfile ~= "." and string.endswith(soundfile, ".wav") then
            table.insert(arrays["Tavern"][folder], soundfile)
            debugLog("Adding tavern file: "..soundfile)
        end
    end
end

for folder in lfs.dir("Data Files\\Music\\tew\\AURA") do
    if folder ~= "Special" then
        for soundfile in lfs.dir("Data Files\\Music\\tew\\AURA\\"..folder) do
            if soundfile and soundfile ~= ".." and soundfile ~= "." and string.endswith(soundfile, ".mp3") then
                table.insert(musicArrays[folder], soundfile)
                debugLog("Adding music file: "..soundfile)
            end
        end
    end
end

local function cellCheck()
    local cell = tes3.getPlayerCell()

    if playedFlag == 1 then
        timer.start{duration=0.82, type=timer.real, callback=function()
            debugLog("Removing sounds.")
            tes3.removeSound{reference = tes3.player}
            playedFlag = 0
        end}

        debugLog("Removing music.")
        --musicTimer:pause()
        --musicTimer:cancel()
        --musicTimer = nil
        timer.start{duration=0.01, type=timer.real, iterations=5, callback=function()
            tes3.streamMusic{
                path = "tew\\AURA\\Special\\silence.mp3",
            }
        end}

        playedFlag = 0
    end

    if not (cell) or not (cell.isInterior) or not (cell.name) then
        debugLog("Player in exterior or no cell found. Returning.")
        return
    end

    for cellType, nameTable in pairs(data.names) do
        for _, pattern in pairs(nameTable) do
            if findWholeWords(cell.name, pattern) then
                debugLog("Found appropriate cell. Playing interior ambient sound.")
                path = interiorDir..cellType.."\\"..arrays[cellType][math.random(1, #arrays[cellType])]
                playInterior()
                return
            end
        end
    end

    local function getTypeCell(maxCount)
        local count = 0
        local typeCell
        for stat in cell:iterateReferences(tes3.objectType.static) do
            for cellType, typeArray in pairs(data.statics) do
                for _, statName in ipairs(typeArray) do
                    if string.startswith(stat.object.id:lower(), statName) then
                        count = count + 1
                        typeCell = cellType
                        if count >= maxCount then return typeCell end
                    end
                end
            end
        end
        if count == 0 then return nil end
    end

    local function getPopulatedCell(maxCount)
        local count = 0
        for npc in cell:iterateReferences(tes3.objectType.NPC) do
            if (npc.object.mobile) and (not npc.object.mobile.isDead) then
                count = count + 1
            end
            if count >= maxCount then return true end
        end
        if count < maxCount then return false end
    end

    if getPopulatedCell(3) == false then debugLog ("Too few people in a cell. Returning.") return end

    local typeCell = getTypeCell(5)
    if typeCell ~= nil then
        debugLog("Found appropriate cell. Playing interior ambient sound.")
        path = interiorDir..typeCell.."\\"..arrays[typeCell][math.random(1, #arrays[typeCell])]
        playInterior()
        return
    end

    for race, _ in pairs(data.tavernNames) do
        for _, pattern in ipairs(data.tavernNames[race]) do
            if string.find(cell.name, pattern) then
                path = interiorDir.."Tavern\\"..race.."\\"..arrays["Tavern"][race][math.random(1, #arrays["Tavern"][race])]

                debugLog("Found appropriate tavern. Playing interior ambient sound.")
                playInterior()

                playedFlag = 1
                return
            end
        end
    end

    for npc in cell:iterateReferences(tes3.objectType.npc) do
        if (npc.object.class.id == "Publican"
        or npc.object.class.id == "T_Sky_Publican"
        or npc.object.class.id == "T_Cyr_Publican")
        and (npc.object.mobile and not npc.object.mobile.isDead) then
            debugLog("Found appropriate tavern. Playing interior ambient sound.")

            local race = npc.object.race.id
            if race ~= "Imperial"
            and race ~= "Nord"
            and race ~= "Dark Elf" then
                race = "Dark Elf"
            end

            path = interiorDir.."Tavern\\"..race.."\\"..arrays["Tavern"][race][math.random(1, #arrays["Tavern"][race])]
            playInterior()

            playedFlag = 1
            return
        end
    end

    debugLog("No appropriate cell detected.")
    playedFlag = 0

end

local function onMusicSelection()
    local cell = tes3.getPlayerCell()

    if not (cell) or not (cell.isInterior) or not (cell.name) then return end

    for race, _ in pairs(data.tavernNames) do
        for _, pattern in ipairs(data.tavernNames[race]) do
            if string.find(cell.name, pattern) then
                while musicPath == lastMusicPath do
                    musicPath = "tew\\AURA\\"..race.."\\"..table.choice(musicArrays[race])
                end

                playMusic()

                playedFlag = 1
                return
            end
        end
    end

    for npc in cell:iterateReferences(tes3.objectType.npc) do
        if (npc.object.class.id == "Publican"
        or npc.object.class.id == "T_Sky_Publican"
        or npc.object.class.id == "T_Cyr_Publican")
        and (npc.object.mobile and not npc.object.mobile.isDead) then

            local race = npc.object.race.id
            if race ~= "Imperial"
            and race ~= "Nord"
            and race ~= "Dark Elf" then
                race = "Dark Elf"
            end

            while musicPath == lastMusicPath do
                musicPath = "tew\\AURA\\"..race.."\\"..table.choice(musicArrays[race])
            end

            timer.start{duration=3, type=timer.real, callback=function()
                playMusic()
            end}

            playedFlag = 1
            return
        end
    end

end

local function deathCheck(e)
    if e.reference
    and (e.reference.object.class.id == "Publican"
    or  e.reference.object.class.id == "T_Sky_Publican"
    or  e.reference.object.class.id == "T_Cyr_Publican") then
        cellCheck()
        onMusicSelection()
    end
end


event.register("cellChanged", cellCheck, { priority = -200 })
event.register("musicSelectTrack", onMusicSelection)

event.register("death", deathCheck)
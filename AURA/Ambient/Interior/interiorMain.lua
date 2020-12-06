local data = require("tew\\AURA\\Ambient\\Interior\\interiorData")
local config = require("tew\\AURA\\config")
local debugLogOn = config.debugLogOn
local modversion = require("tew\\AURA\\version")
local version = modversion.version
local common = require("tew\\AURA\\common")
local getCellType = common.getCellType
local tewLib = require("tew\\tewLib\\tewLib")
local findWholeWords = tewLib.findWholeWords

local interiorDir = "tew\\AURA\\Interior\\"
local path, playedFlag

local function debugLog(string)
    if debugLogOn then
       mwse.log("[AURA "..version.."] RA: "..string.format("%s", string))
    end
end

local arrays = {
    ["Caves"] = {},
    ["Daedric"] = {},
    ["Dwemer"] = {},
    ["Ice Caves"] = {},
    ["Mages"] = {},
    ["Fighters"] = {},
    ["Temple"] = {},
}

for interiorType, _ in pairs(arrays) do
    for soundfile in lfs.dir("Data Files\\Sound\\"..interiorDir.."\\"..interiorType) do
        if soundfile and soundfile ~= ".." and soundfile ~= "." and string.endswith(soundfile, ".wav") then
            table.insert(arrays[interiorType], soundfile)
            debugLog("Adding file: "..soundfile)
        end
    end
end

local function cellCheck(e)
    local cell = e.cell

    if playedFlag == 1 then
        tes3.removeSound{reference = tes3.player}
        playedFlag = 0
    end

    for cellType, nameTable in pairs(data.names) do
        for _, pattern in pairs(nameTable) do
            if findWholeWords(cell.name, pattern) then
                debugLog("Found appropriate cell. Playing interior ambient sound.")
                path = interiorDir..cellType.."\\"..arrays[cellType][math.random(1, #arrays[cellType])]
                timer.start{duration=0.82, type=timer.real, callback=function()
                    tes3.playSound{
                    soundPath = path,
                    reference = tes3.player,
                    volume = 0.8,
                    loop=true
                    }
                end}
                playedFlag = 1
                return
            end
        end
    end

    for cellType, typeArray in pairs(data.statics) do
        if getCellType(cell, typeArray) == true then
            debugLog("Found appropriate cell. Playing interior ambient sound.")
            path = interiorDir..cellType.."\\"..arrays[cellType][math.random(1, #arrays[cellType])]
            timer.start{duration=0.82, type=timer.real, callback=function()
                tes3.playSound{
                soundPath = path,
                reference = tes3.player,
                volume = 0.8,
                loop=true
                }
            end}
            playedFlag = 1
            return
        else
            debugLog("No appropriate cell detected.")
            playedFlag = 0
        end
    end
end


event.register("cellChanged", cellCheck, { priority = -180 })
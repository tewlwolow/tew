local data = require("tew\\AURA\\Ambient\\Ruins\\ruinsData")
local config = require("tew\\AURA\\config")
local debugLogOn = config.debugLogOn
local modversion = require("tew\\AURA\\version")
local version = modversion.version
local common = require("tew\\AURA\\common")
local getCellType = common.getCellType
local ruinsDir = "tew\\AURA\\Ruins\\"
local path, caveFlag

local function debugLog(string)
    if debugLogOn then
       mwse.log("[AURA "..version.."] RA: "..string.format("%s", string))
    end
end

local arrays = {
    ["Dwemer"] = {},
    ["Daedric"] = {},
    ["Ice Caves"] = {},
}

for ruinType, _ in pairs(arrays) do
    for soundfile in lfs.dir("Data Files\\Sound\\"..ruinsDir.."\\"..ruinType) do
        if soundfile and soundfile ~= ".." and soundfile ~= "." and string.endswith(soundfile, ".wav") then
            table.insert(arrays[ruinType], soundfile)
            debugLog("Adding file: "..soundfile)
        end
    end
end

local function cellCheck(e)
    local cell = e.cell

    if caveFlag == 1 then
        tes3.removeSound{reference = tes3.player}
        caveFlag = 0
    end

    for cellType, typeArray in pairs(data) do
        if getCellType(cell, typeArray) == true then
            debugLog("Found appropriate cell. Playing ruins ambient sound.")
            path = ruinsDir..cellType.."\\"..arrays[cellType][math.random(1, #arrays[cellType])]
            timer.start{duration=0.82, type=timer.real, callback=function()
                tes3.playSound{
                soundPath = path,
                reference = tes3.player,
                volume = 0.8,
                loop=true
                }
            end}
            caveFlag = 1
            break
        else
            debugLog("No appropriate cell detected.")
            caveFlag = 0
        end
    end
end


event.register("cellChanged", cellCheck, { priority = -180 })
local data = require("tew\\AURA\\Ambient\\Populated\\populatedData")
local config = require("tew\\AURA\\config")
local debugLogOn = config.debugLogOn
local modversion = require("tew\\AURA\\version")
local version = modversion.version
local popVol = config.popVol/200
local popDir = "tew\\AURA\\Populated\\"
local path, playedFlag

local function debugLog(string)
    if debugLogOn then
       mwse.log("[AURA "..version.."] PA: "..string.format("%s", string))
    end
end

local arrays = {
    ["Ashlander"] = {},
    ["Daedric"] = {},
    ["Dark Elf"] = {},
    ["Dwemer"] = {},
    ["Imperial"] = {},
    ["Nord"] = {},
    ["Night"] = {}
}

local function getTypeCell(maxCount, cell)
    local count = 0
    local typeCell
    for stat in cell:iterateReferences(tes3.objectType.static) do
        for cellType, typeArray in pairs(data.statics) do
            for _, statName in ipairs(typeArray) do
                if string.startswith(stat.object.id:lower(), statName) then
                    count = count + 1
                    typeCell = cellType
                    if count >= maxCount then debugLog("Enough statics. Cell type: "..typeCell) return typeCell end
                end
            end
        end
    end
    if count == 0 then debugLog("Too few statics. Count: "..count) return nil end
end

local function playPopulated()
    timer.start{duration=0.86, type=timer.real, callback=function()
        playedFlag = 1
        debugLog("Playing populated track: "..path)
        tes3.playSound{
        soundPath = path,
        reference = tes3.player,
        volume = 1.0*popVol,
        loop=true
        }
    end}
end

for populatedType, _ in pairs(arrays) do
    for soundfile in lfs.dir("Data Files\\Sound\\"..popDir.."\\"..populatedType) do
        if soundfile and soundfile ~= ".." and soundfile ~= "." and string.endswith(soundfile, ".wav") then
            table.insert(arrays[populatedType], soundfile)
            debugLog("Adding populated file: "..soundfile)
        end
    end
end

local function cellCheck()
    local cell = tes3.getPlayerCell()

    if (not cell) or (not cell.name) or (cell.isInterior and not cell.behavesAsExterior and not string.find(cell.name, "Plaza")) then
        debugLog("Player in interior cell or in the wilderness. Returning.")
        if playedFlag == 1 then
            timer.start{duration=0.82, type=timer.real, callback=function()
                debugLog("Removing sounds.")
                tes3.removeSound{reference = tes3.player}
                playedFlag = 0
            end}
        end
        playedFlag = 0
        return
    end


    local typeCell = getTypeCell(5, cell)
    if typeCell ~= nil then
        local gameHour=tes3.worldController.hour.value
        if gameHour < 5 or gameHour > 21 then
            debugLog("Found appropriate cell at night. Playing populated night ambient sound.")
            path = popDir.."\\Night\\"..arrays["Night"][math.random(1, #arrays["Night"])]
            playPopulated()
            return
        end
        debugLog("Found appropriate cell at day. Playing populated ambient day sound.")
        path = popDir..typeCell.."\\"..arrays[typeCell][math.random(1, #arrays[typeCell])]
        playPopulated()
        playedFlag = 1
        return
    end

    playedFlag = 0
    debugLog("No appropriate cell detected.")
end


event.register("cellChanged", cellCheck, { priority = -190 })


local modversion = require("tew\\AURA\\version")
local version = modversion.version
local config=require("tew\\AURA\\config")
local common=require("tew\\AURA\\common")
local debugLogOn=config.debugLogOn

local overhang, weather

local function debugLog(string)
    if debugLogOn then
       mwse.log("[AURA "..version.."] Misc (Others): "..string)
    end
end

local function playOverhang()
    if not overhang then return end
    if weather==4 then
        tes3.playSound{soundPath="tew\\AURA\\Interior Weather\\Tent\\Rain.wav", reference=overhang, loop=true, volume=0.6, pitch=0.8}
        debugLog("Playing overhang sound for rainy weather.")
    end
    if weather==5 then
        tes3.playSound{soundPath="tew\\AURA\\Interior Weather\\Tent\\rain heavy.wav", reference=overhang, loop=true, volume=0.6, pitch=0.8}
        debugLog("Playing overhang sound for stormy weather.")
    end
end

local function getOverhangs(e)
    local cell=e.cell
    weather=tes3.getWorldController().weatherController.currentWeather.index

    if not (cell.isInterior) and (weather==4 or weather==5) then
        debugLog("Finding overhangs in cell.")
        for stat in cell:iterateReferences(tes3.objectType.static) do
            for _, pattern in pairs(common.overhangs) do
                if string.find(stat.object.id, pattern) then
                    overhang=stat
                    playOverhang()
                end
            end
        end
    end
end


print("[AURA "..version.."] Overhang sound initialised.")
event.register("cellChanged", getOverhangs)
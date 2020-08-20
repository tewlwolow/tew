local modversion = require("tew\\AURA\\version")
local version = modversion.version
local config=require("tew\\AURA\\config")
local common=require("tew\\AURA\\common")
local debugLogOn=config.debugLogOn

local banners={}

local function debugLog(string)
    if debugLogOn then
       mwse.log("[AURA "..version.."] Misc (Others): "..string)
    end
end

local function playBanner()
    for _, banner in ipairs(banners) do
        if banner~=nil then
        tes3.playSound{sound="Flag", reference=banner, volume=0.6, pitch=0.8}
        debugLog("Playing banner flap.") end
    end
end

local function getBanners(e)
    local cell=e.cell
    if cell.isInterior then return end
    debugLog("Finding banners in cell.")
    for act in cell:iterateReferences(tes3.objectType.activator) do
        for _, pattern in pairs(common.banners) do
            if string.find(act.object.id, pattern) then
                table.insert(banners, act.object)
            end
        end
    end
    timer.start{duration=2, callback=playBanner, iterations=-1}
end


print("[AURA "..version.."] Banner flap sound initialised.")
event.register("cellChanged", getBanners)
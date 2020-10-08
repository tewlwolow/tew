local modversion = require("tew\\AURA\\version")
local version = modversion.version
local config = require("tew\\AURA\\config")
local debugLogOn=config.debugLogOn

local path = ""
local containersData = require("tew\\AURA\\Containers\\containersData")

local function debugLog(string)
    if debugLogOn then
       mwse.log("[AURA "..version.."] C: "..string)
    end
end

local function getPitch(containerType)
    if not containerType then return 1.0 end
    local pitch
    for k, v in pairs(containersData["pitch"]) do
        if string.find(containerType:lower(), k) then
            pitch=v
        end
    end
    return pitch or 1.0
end

local function playOpenSound(e)
    if e.target.object.objectType == tes3.objectType.container
    and not tes3.getLocked({reference=e.target}) then

        local containerType

        for type, filepath in pairs(containersData["open"]) do
            if string.find(e.target.object.id:lower(), type) then
                path=filepath
                containerType=type
                break
            end
        end
        if path ~= "" then
            tes3.playSound{soundPath=path, reference=e.target, volume=0.8, pitch=getPitch(containerType)}
            debugLog("Playing container opening sound.")
        end
        path=""

    end
end

local function playCloseSound(e)

    local containerType
    for type, filepath in pairs(containersData["close"]) do
        if string.find(e.reference.object.id:lower(), type) then
            path=filepath
            containerType=type
            break
        end
    end
    if path ~= "" then
        tes3.playSound{soundPath=path, reference=e.target, volume=0.8, pitch=getPitch(containerType)-0.2}
        debugLog("Playing container closing sound.")
    end
    path=""

end


debugLog("Containers module initialised.")

event.register("activate", playOpenSound)
event.register("containerClosed", playCloseSound)

--[[ TODO:
    * add more types to containersData.lua
    * maybe skip .id, just use .object? General name then shown?
--]]
local modversion = require("tew\\AURA\\version")
local version = modversion.version
local config = require("tew\\AURA\\config")
local debugLogOn=config.debugLogOn
local Cvol=config.Cvol/200

local path = ""
local flag = 0
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
            if string.find(e.target.object.name:lower(), type) then
                path=filepath
                containerType=type
                break
            end
        end
        if path ~= "" then
            tes3.playSound{soundPath=path, reference=e.target, volume=0.8*Cvol, pitch=getPitch(containerType)}
            debugLog("Playing container opening sound.")
        end
        path=""

    end
end

local function playCloseSound(e)
    --if not e.reference.object.baseObject == tes3.objectType.container then return end
    if flag == 1 then return end
    local containerType
    for type, filepath in pairs(containersData["close"]) do
        if string.find(e.reference.object.name:lower(), type) then
            path=filepath
            containerType=type
            break
        end
    end
    if path ~= "" then
        tes3.playSound{soundPath=path, reference=e.reference, volume=0.8*Cvol, pitch=getPitch(containerType)-0.1}
        debugLog("Playing container closing sound.")
        flag=1
    end
    path=""
    timer.start{type=timer.real, duration=1.5, callback=function()
        flag=0
    end}
end


debugLog("Containers module initialised.")

event.register("activate", playOpenSound)
event.register("containerClosed", playCloseSound)
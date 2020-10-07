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

local function playContainerSound(e)
    if e.target.object.objectType == tes3.objectType.container then
        tes3.messageBox(e.target.object.id)
        for type, filepath in pairs(containersData["open"]) do
            if string.find(e.target.object.id:lower(), type) then
                path=filepath
                break
            end
        end
        if path ~= "" then
            tes3.playSound{soundPath=path, reference=e.target, volume=0.8, pitch=0.9}
        end
    end
end

debugLog("Containers module initialised.")
event.register("activate", playContainerSound)

--[[ TODO:
    * clear path after usage
    * block locked containers
    * add separate function for closing (uiActivated?)
    * add more types to containersData.lua
    * maybe skip .id, just use .object? General name then shown?
--]]
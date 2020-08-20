local modversion = require("tew\\AURA\\version")
local version = modversion.version
local config=require("tew\\AURA\\config")
local debugLogOn=config.debugLogOn

local yurtDoors={
    "in_ashl_door_01",
    "in_ashl_door_02",
    "in_ashl_door_02_sha",
    "ex_ashl_door_01",
    "ex_ashl_door_02"
}

local function debugLog(string)
    if debugLogOn then
       mwse.log("[AURA "..version.."] Misc (Others): "..string)
    end
end

local function yurtFlap(e)
    for _, door in pairs(yurtDoors) do
        if e.target.object.id==door then
            tes3.playSound({soundPath="tew\\AURA\\Misc\\yurtflap.wav", volume=0.9, pitch=0.8, reference=tes3.player})
            debugLog("Playing yurt flap sound.")
            return
        end
    end
end

print("[AURA "..version.."] Yurt flap sound initialised.")
event.register("activate", yurtFlap)
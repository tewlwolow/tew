local modversion = require("tew\\AURA\\version")
local version = modversion.version
local config=require("tew\\AURA\\config")

local function init()
    local pcVitalSigns = config.pcVitalSigns

    if pcVitalSigns then
        print("[AURA "..version.."] Loading file: vitalSigns.lua")
        dofile("Data Files\\MWSE\\mods\\tew\\AURA\\PC\\vitalSigns.lua")
    end

end


print("[AURA "..version.."] Player character module initialised.")
init()
local modversion = require("tew.AURA.version")
local version = modversion.version

local function init()

    print("[AURA] Version "..version.." initialised.")

    local config=require("tew.AURA.config")
    local moduleAmbientOutdoor = config.moduleAmbientOutdoor
    local moduleInteriorWeather = config.moduleInteriorWeather
    local moduleServiceVoices = config.moduleServiceVoices
    local moduleMisc = config.moduleMisc

    if moduleAmbientOutdoor then
        print("[AURA "..version.."] Loading file: outdoorMain.lua.")
        dofile("Data Files\\MWSE\\mods\\tew\\AURA\\Ambient\\Outdoor\\outdoorMain.lua")
    end

    if moduleInteriorWeather then
        print("[AURA "..version.."] Loading file: interiorWeatherMain.lua.")
        dofile("Data Files\\MWSE\\mods\\tew\\AURA\\Interior Weather\\interiorWeatherMain.lua")
    end

    if moduleServiceVoices then
        print("[AURA "..version.."] Loading file: serviceVoicesMain.lua.")
        dofile("Data Files\\MWSE\\mods\\tew\\AURA\\Service Voices\\serviceVoicesMain.lua")
    end

    if moduleMisc then
        print("[AURA "..version.."] Loading file: miscMain.lua.")
        dofile("Data Files\\MWSE\\mods\\tew\\AURA\\Misc\\miscMain.lua")
    end
end

-- Registers MCM menu --
event.register("modConfigReady", function()
    dofile("Data Files\\MWSE\\mods\\tew\\AURA\\mcm.lua")
 end)

event.register("initialized", init)
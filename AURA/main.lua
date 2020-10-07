local modversion = require("tew.AURA.version")
local version = modversion.version

local function volumeAdjust()

    tes3.game.soundQuality=2
    tes3.game.volumeMaster=244
    tes3.game.volumeEffect=244
    timer.delayOneFrame{
    callback=function()
    tes3.game.volumeMaster=250
    tes3.game.volumeEffect=250
    end}
    tes3.game.volumeMaster=250
    tes3.game.volumeEffect=250

end

local function warning()
    tes3.messageBox("[AURA]: Do NOT adjust MASTER or EFFECTS slider! Do NOT change the 3D audio setting!")
end

local function init()

    event.register("uiActivated", warning, {filter="MenuAudio"})
    event.register("cellChanged", volumeAdjust, {priority=-160})

    mwse.log("[AURA] Version "..version.." initialised.")

    local config=require("tew.AURA.config")
    local moduleAmbientOutdoor = config.moduleAmbientOutdoor
    local moduleInteriorWeather = config.moduleInteriorWeather
    local moduleServiceVoices = config.moduleServiceVoices
    local moduleContainers = config.moduleContainers
    local moduleUI = config.moduleUI
    local moduleMisc = config.moduleMisc

    if moduleAmbientOutdoor then
        mwse.log("[AURA "..version.."] Loading file: outdoorMain.lua.")
        dofile("Data Files\\MWSE\\mods\\tew\\AURA\\Ambient\\Outdoor\\outdoorMain.lua")
    end

    if moduleInteriorWeather then
        mwse.log("[AURA "..version.."] Loading file: interiorWeatherMain.lua.")
        dofile("Data Files\\MWSE\\mods\\tew\\AURA\\Interior Weather\\interiorWeatherMain.lua")
    end

    if moduleServiceVoices then
        mwse.log("[AURA "..version.."] Loading file: serviceVoicesMain.lua.")
        dofile("Data Files\\MWSE\\mods\\tew\\AURA\\Service Voices\\serviceVoicesMain.lua")
    end

    if moduleMisc then
        mwse.log("[AURA "..version.."] Loading file: miscMain.lua.")
        dofile("Data Files\\MWSE\\mods\\tew\\AURA\\Misc\\miscMain.lua")
    end

    if moduleUI then
        mwse.log("[AURA "..version.."] Loading file: UIMain.lua.")
        dofile("Data Files\\MWSE\\mods\\tew\\AURA\\UI\\UIMain.lua")
    end

    if moduleContainers then
        mwse.log("[AURA "..version.."] Loading file: containersMain.lua.")
        dofile("Data Files\\MWSE\\mods\\tew\\AURA\\Containers\\containersMain.lua")
    end

    -- Old version deleter --
    if lfs.dir("Data Files/MWSE/mods/AURA/") then
        lfs.rmdir("Data Files/MWSE/mods/AURA/", true)
        mwse.log("[AURA "..version.."]: Old version found and deleted.")
    end
end

-- Registers MCM menu --
event.register("modConfigReady", function()
    dofile("Data Files\\MWSE\\mods\\tew\\AURA\\mcm.lua")
end)

event.register("initialized", init)
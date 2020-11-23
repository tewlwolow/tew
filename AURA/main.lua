local modversion = require("tew.AURA.version")
local version = modversion.version

local function volumeAdjust()
    tes3.game.volumeMaster=245
    tes3.game.volumeEffect=245
    tes3.game.volumeMaster=250
    tes3.game.volumeEffect=250
end

local function warning(e)
    if not e.newlyCreated then
        return
    end
    tes3.messageBox("[AURA]: Do NOT adjust MASTER or EFFECTS slider!")
end

local function init()

    mwse.log("[AURA] Version "..version.." initialised.")

    local config=require("tew.AURA.config")
    local moduleAmbientOutdoor = config.moduleAmbientOutdoor
    local moduleInteriorWeather = config.moduleInteriorWeather
    local moduleServiceVoices = config.moduleServiceVoices
    local moduleContainers = config.moduleContainers
    local moduleUI = config.moduleUI
    local moduleMisc = config.moduleMisc
    local modulePC = config.modulePC
    local volumeFix = config.volumeFix

    if volumeFix then
        volumeAdjust()
        event.register("uiActivated", warning, {filter="MenuAudio"})
        event.register("cellChanged", volumeAdjust, {priority=-160})
    end

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

    if modulePC then
        mwse.log("[AURA "..version.."] Loading file: PCMain.lua")
        dofile("Data Files\\MWSE\\mods\\tew\\AURA\\PC\\PCMain.lua")
    end

    -- Old version deleter --
    if lfs.dir("Data Files\\MWSE\\mods\\AURA") then
        lfs.rmdir("Data Files\\MWSE\\mods\\AURA", true)
        mwse.log("[AURA "..version.."]: Old mod folder found and deleted.")
    end
    if lfs.dir("Data Files\\MWSE\\mods\\tew\\AURA\\Misc\\travelFee.lua") then
        os.remove("Data Files\\MWSE\\mods\\tew\\AURA\\Misc\\travelFee.lua")
        mwse.log("[AURA "..version.."]: Old 'travelFee.lua' file found and deleted.")
    end
end

-- Registers MCM menu --
event.register("modConfigReady", function()
    dofile("Data Files\\MWSE\\mods\\tew\\AURA\\mcm.lua")
end)


event.register("initialized", init)
local modversion = require("tew\\AURA\\version")
local config = require("tew\\AURA\\config")
local common=require("tew\\AURA\\common")

local IWAURAdir="tew\\AURA\\Interior Weather\\"
local version = modversion.version
local debugLogOn=config.debugLogOn
local vol = config.IWvol/200

local IWLoop, thunRef, windoors, interiorType, thunder, interiorTimer, thunderTimerBig, thunderTimerSmall

local WtC=tes3.getWorldController().weatherController

local thunArray=common.thunArray

local function debugLog(string)
    if debugLogOn then
       mwse.log("[AURA "..version.."] IW: "..string)
    end
end

local function playThunder()
    thunder=thunArray[math.random(1, #thunArray)]
    debugLog("Playing thunder: "..thunder)
    tes3.playSound{sound=thunder, volume=0.4, pitch=0.6, reference=thunRef}
end

local function updateThunderBig()
    debugLog("Updating interior doors for thunders.")
    local playerPos=tes3.player.position
    for _, windoor in ipairs(windoors) do
        if common.getDistance(playerPos, windoor.position) < 2048
        and windoor~=nil then
            thunRef=windoor
            playThunder()
        end
    end
end

local function playInteriorSmall(cell)
    local IWPath=IWAURAdir..interiorType.."\\"..IWLoop..".wav"
    if IWLoop=="rain heavy" then
        tes3.playSound{soundPath=IWPath, volume=0.9*vol, loop=true, reference=cell}
        thunRef=cell
        debugLog("Playing small interior storm and thunder loops.")
    elseif IWLoop=="Rain" then
        tes3.playSound{soundPath=IWPath, volume=0.8*vol, loop=true, reference=cell}
        debugLog("Playing small interior rain loops.")
    elseif IWLoop=="Blight" or IWLoop=="ashstorm" or IWLoop=="BM Blizzard" then
        tes3.playSound{sound=IWLoop, volume=0.5*vol, pitch=0.5, loop=true, reference=cell}
        tes3.playSound{soundPath=IWAURAdir.."Common\\wind gust.wav", volume=0.4, loop=true, reference=cell}
    else
        tes3.playSound{sound=IWLoop, volume=0.5*vol, pitch=0.4, loop=true, reference=cell}
    end
end

local function playInteriorBig(windoor)
    if windoor==nil then debugLog("Dodging an empty ref.") return end
    if IWLoop=="Rain" then
        tes3.playSound{sound="Sound Test", volume=0.8*vol, pitch=0.8, loop=true, reference=windoor}
        debugLog("Playing big interior rain loop.")
    elseif IWLoop=="rain heavy" then
        tes3.playSound{sound="Sound Test", volume=0.9*vol, pitch=1.2, loop=true, reference=windoor}
        debugLog("Playing big interior storm loop.")
        thunderTimerBig:resume()
    else
        debugLog("Playing big interior loop: "..IWLoop)
        tes3.playSound{sound=IWLoop, volume=0.4*vol, pitch=0.5, loop=true, reference=windoor}
    end
end

local function updateInteriorBig()
    debugLog("Updating interior doors and windows.")
    local playerPos=tes3.player.position
    for _, windoor in ipairs(windoors) do
        if common.getDistance(playerPos, windoor.position) > 2048 then
            playInteriorBig(windoor)
        end
    end
end

local function cellCheck()

    local cell=tes3.getPlayerCell()
    if not cell then return end
    if not cell.isInterior
    or (cell.isInterior and cell.behavesAsExterior) then
        debugLog("Found exterior cell. Returning.")
        return
    end

    if not interiorTimer then
        interiorTimer = timer.start({duration=3, iterations=-1, callback=updateInteriorBig})
        interiorTimer:pause()
    else
        interiorTimer:pause()
    end
    if not thunderTimerBig then
        thunderTimerBig = timer.start({duration=15, iterations=-1, callback=updateThunderBig})
        thunderTimerBig:pause()
    else
        thunderTimerBig:pause()
    end
    if not thunderTimerSmall then
        thunderTimerSmall = timer.start({duration=15, iterations=-1, callback=playThunder})
        thunderTimerSmall:pause()
    else
        thunderTimerSmall:pause()
    end


    tes3.removeSound{reference=cell}


    local IWweather=WtC.currentWeather.index
    IWLoop=nil
    if not (IWweather >=4 and IWweather <= 7) and not IWweather==9 then
        debugLog("Uneligible weather detected. Returning.")
        return
    elseif IWweather==4 then
        IWLoop="Rain"
    elseif IWweather==5 then
        IWLoop="rain heavy"
    elseif IWweather==6 then
        IWLoop="ashstorm"
    elseif IWweather==7 then
        IWLoop="Blight"
    elseif IWweather==9 then
        IWLoop="BM Blizzard"
    end
    debugLog("Weather: "..IWweather)

    if IWLoop==nil then
        debugLog("Clearing windoors.")
        if windoors~={} and windoors~=nil then
            for _, windoor in ipairs(windoors) do
                tes3.removeSound{reference=windoor}
            end
            return
        else
            return
        end
    end

    windoors={}
    windoors=common.getWindoors(cell)

    debugLog("Found interior cell.")
    if common.getCellType(cell, common.cellTypesSmall)==true then
        interiorType="Small"
        playInteriorSmall(cell, interiorType)
        debugLog("Playing small interior sounds.")
        if IWLoop=="rain heavy" then
            thunRef=cell
            thunderTimerSmall:resume()
        end
    elseif common.getCellType(cell, common.cellTypesTent)==true then
        interiorType="Tent"
        playInteriorSmall(cell, interiorType)
        debugLog("Playing tent interior sounds.")
        if IWLoop=="rain heavy" then
            thunRef=cell
            thunderTimerSmall:resume()
        end
    else
        for _, windoor in ipairs(windoors) do
            tes3.removeSound{reference=windoor}
            playInteriorBig(windoor)
        end
        interiorTimer:resume()
        debugLog("Playing big interior sound.")
        if IWLoop=="rain heavy" then
            updateThunderBig()
            thunderTimerBig:resume()
        end
    end
end


debugLog("Interior Weather module initialised.")

event.register("cellChanged", cellCheck, { priority = -165 })
event.register("weatherTransitionStarted", cellCheck, { priority = -165 })
event.register("weatherChangedImmediate", cellCheck, { priority = -165 })
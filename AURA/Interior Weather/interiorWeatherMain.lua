local modversion = require("tew\\AURA\\version")
local config = require("tew\\AURA\\config")
local common=require("tew\\AURA\\common")

local IWAURAdir="tew\\AURA\\Interior Weather\\"
local version = modversion.version
local debugLogOn=config.debugLogOn
local vol = config.intVol/200

local moduleAmbientOutdoor=config.moduleAmbientOutdoor

local IWLoop, transState, thunRef, windoors, interiorType, thunder, interiorTimer, thunderTimerBig, thunderTimerSmall

local wTC=tes3.getWorldController().weatherController

local thunArray=common.thunArray

local function debugLog(string)
    if debugLogOn then
       mwse.log("[AURA "..version.."] IW: "..string)
    end
end

local function playThunder()
    thunder=thunArray[math.random(1, #thunArray)]
    debugLog("Playing thunder: "..thunder)
    tes3.playSound{sound=thunder, volume=0.2, pitch=0.5, reference=thunRef}
end

local function updateThunderBig()
    if transState==false
    or transState==true and wTC.transitionScalar>=0.5 then
        debugLog("Updating interior doors for thunders.")
        local playerPos=tes3.player.position
        for _, windoor in ipairs(windoors) do
            if common.getDistance(playerPos, windoor.position) < 2000
            and windoor~=nil then
                thunRef=windoor
                playThunder()
            end
        end
    end
end

local function playInteriorSmall(cell)
    local IWPath=IWAURAdir..interiorType.."\\"..IWLoop..".wav"
    if IWLoop=="rain heavy" then
        tes3.playSound{soundPath=IWPath, volume=0.8*vol, loop=true, reference=cell}
        thunRef=cell
        debugLog("Playing small interior storm and thunder loops.")
    elseif IWLoop=="Rain" then
        tes3.playSound{soundPath=IWPath, volume=1.0*vol, loop=true, reference=cell}
        debugLog("Playing small interior rain loops.")
    elseif IWLoop=="Blight" or IWLoop=="ashstorm" or IWLoop=="BM Blizzard" then
        tes3.playSound{sound=IWLoop, volume=0.5*vol, pitch=0.5, loop=true, reference=cell}
        tes3.playSound{soundPath=IWAURAdir.."Common\\wind gust.wav", volume=0.2, loop=true, reference=cell}
    else
        tes3.playSound{sound=IWLoop, volume=0.5*vol, pitch=0.4, loop=true, reference=cell}
    end
end

local function playInteriorBig(windoor)
    if IWLoop=="Rain" then
        tes3.playSound{sound="Sound Test", volume=0.7*vol, pitch=0.8, loop=true, reference=windoor}
        debugLog("Playing big interior rain loop.")
    elseif IWLoop=="rain heavy" then
        tes3.playSound{sound="Sound Test", volume=0.8*vol, pitch=0.8, loop=true, reference=windoor}
        debugLog("Playing big interior storm loop.")
        thunderTimerBig:resume()
    else
        tes3.playSound{sound=IWLoop, volume=0.3*vol, pitch=0.5, loop=true, reference=windoor}
    end
end

local function updateInteriorBig()
    if transState==false
    or transState==true and wTC.transitionScalar>=0.4 then
        local playerPos=tes3.player.position
        for _, windoor in ipairs(windoors) do
            if common.getDistance(playerPos, windoor.position) > 2000 then
                playInteriorBig(windoor)
            end
        end
    end
end

local function cellCheck()

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

    local cell=tes3.getPlayerCell()

    if not moduleAmbientOutdoor then
        tes3.removeSound{reference=cell}
    end

    local IWweather=wTC.currentWeather.index
    IWLoop=nil
    if not wTC.nextWeather then
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
        transState=false
    end

    if wTC.nextWeather then
        local IWweatherNext=wTC.nextWeather.index
        if not (IWweatherNext >=4 and IWweatherNext <= 7) and not IWweatherNext==9 then
            debugLog("Uneligible weather detected. Returning.")
            return
        elseif IWweatherNext==4 then
            IWLoop="Rain"
        elseif IWweatherNext==5 then
            IWLoop="rain heavy"
        elseif IWweatherNext==6 then
            IWLoop="ashstorm"
        elseif IWweatherNext==7 then
            IWLoop="Blight"
        elseif IWweatherNext==9 then
            IWLoop="BM Blizzard"
        end
        debugLog("Next weather: "..IWweatherNext)
        transState=true
    end

    if not cell.isInterior
    or (cell.isInterior and cell.behavesAsExterior) then
        debugLog("Found exterior cell. Returning.")
        return
    elseif IWLoop~=nil then
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
            thunRef=nil
            windoors={}
            windoors=common.getWindoors(cell)
            for _, windoor in ipairs(windoors) do
                playInteriorBig(windoor)
            end
            interiorTimer:resume()
            debugLog("Playing big interior sound.")
        end
    end
end

debugLog("Interior Weather module initialised.")


event.register("cellChanged", cellCheck, { priority = -150 })
event.register("weatherTransitionStarted", cellCheck,  { priority = -150 })
event.register("weatherChangedImmediate", cellCheck,  { priority = -150 })
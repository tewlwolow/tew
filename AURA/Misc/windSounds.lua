local modversion = require("tew.AURA.version")
local version = modversion.version
local sounds=require("tew.AURA.sounds")
local common=require("tew.AURA.common")
local moduleName = "wind"
local windPlaying = false
local config = require("tew.AURA.config")
local windVol = (config.windVol/200)
local windTypeLast

local debugLog = common.debugLog

local WtC

local blockedWeathers = {
    [7] = true,
    [8] = true,
    [10] = true
}


local function getWindType(cSpeed)
    local cloudSpeed = cSpeed * 100
    if cloudSpeed < 180 then
        return nil
    elseif cloudSpeed < 350 then
        return "warm"
    elseif cloudSpeed <= 1800 then
        return "cold"
    else
        return nil
    end
end

local function playWind(e)
    local cell = tes3.getPlayerCell()
    if not cell or not cell.isOrBehavesAsExterior then
        debugLog("Not in an exterior cell. Returning.")
        sounds.remove{module = moduleName, volume = windVol}
        windPlaying = false
        return
    end
    local weather
    if e and e.to then
        weather = e.to
    else
        weather = WtC.currentWeather
    end

    if blockedWeathers[weather.index] then
        debugLog("Weather is blocked. Returning.")
        sounds.remove{module = moduleName, volume = windVol}
        windPlaying = false
        return
    end

    local cloudsSpeed = weather.cloudsSpeed
    debugLog("Current clouds speed: "..tostring(cloudsSpeed))
    local windType = getWindType(cloudsSpeed)

    if not windType then
        debugLog("Wind type is nil. Returning.")
        sounds.remove{module = moduleName, volume = windVol}
        windPlaying = false
        return
    end

    if not windPlaying or (windTypeLast ~= windType)then
        debugLog("Wind type: "..windType)
        sounds.play{module = moduleName, type = windType, volume = windVol}
        windPlaying = true
        windTypeLast = windType
    end
end

local function onLoad()
    windPlaying = false
end

local function waitCheck(e)
	local element=e.element
	element:register("destroy", function()
        timer.start{
            type=timer.game,
            duration = 0.02,
            callback = playWind
        }
    end)
end


print("[AURA "..version.."] Wind sounds initialised.")
WtC=tes3.worldController.weatherController
event.register("weatherChangedImmediate", playWind, {priority=-100})
event.register("weatherTransitionImmediate", playWind, {priority=-100})
event.register("weatherTransitionStarted", playWind, {priority=-100})
event.register("weatherTransitionFinished", playWind, {priority=-100})
event.register("load", onLoad)
event.register("uiActivated", waitCheck, {filter="MenuTimePass", priority = 10})
event.register("cellChanged", playWind, {priority=-100})

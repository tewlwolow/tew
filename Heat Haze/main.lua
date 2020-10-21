local modversion = require("tew\\Heat Haze\\version")
local version = modversion.version
local config = require("tew.Heat Haze.config")

local hazeStartHour = config.hazeStartHour
local hazeEndHour = config.hazeEndHour

local heatRegions = config.heatRegions


local function debugLog(string)
    if config.debugLogOn then
        mwse.log("[Heat Haze "..version.."] "..string.format("%s", string))
    end
end

local function isHeatRegion(regionID)
    if heatRegions[regionID] then
        return true
    end
end

local function startHaze()

    local cell = tes3.getPlayerCell()

    if not (cell) or (cell and cell.isInterior) then
        debugLog("Detected interior cell. Removing shader.")
        mge.disableShader({shader="heathaze"})
        timer.start{
            type=timer.real,
            duration=0.1,
            iterations=10,
            callback = function()
                mge.disableShader({shader="heathaze"})
            end}
        return
    end

    local regionID = cell.region.id
    if not isHeatRegion(regionID) then
        debugLog("Detected ineligible region. Removing shader.")
        mge.disableShader({shader="heathaze"})
        timer.start{
            type=timer.real,
            duration=0.1,
            iterations=10,
            callback = function()
                mge.disableShader({shader="heathaze"})
            end}
        return
    end

    local WtC=tes3.getWorldController().weatherController
    local currentWeather = WtC.currentWeather
    if currentWeather.index > 3 or currentWeather.index == 2 then
        debugLog("Detected ineligible weather. Removing shader.")
        mge.disableShader({shader="heathaze"})
        timer.start{
            type=timer.real,
            duration=0.1,
            iterations=10,
            callback = function()
                mge.disableShader({shader="heathaze"})
            end}
        return
    end

    local gameHour=tes3.worldController.hour.value
    if gameHour < hazeStartHour or gameHour >= hazeEndHour  then
        debugLog("Detected ineligible game hour. Removing shader.")
        mge.disableShader({shader="heathaze"})
        timer.start{
            type=timer.real,
            duration=0.1,
            iterations=10,
            callback = function()
                mge.disableShader({shader="heathaze"})
            end}
        return
    end

    if (cell.isInterior==false)
    and isHeatRegion(regionID)
    and (currentWeather.index <= 3 and currentWeather.index ~= 2)
    and (gameHour >= hazeStartHour and gameHour < hazeEndHour) then
        debugLog("Check ok. Enabling shader.")
        mge.enableShader({shader="heathaze"})
    end
end

local function hazeTimers()
    timer.start{
       duration=0.3,
        callback=startHaze,
        iterations=-1,
        type=timer.game
    }
end

local function init()
    event.register("cellChanged", startHaze, {priority=-179})
    event.register("weatherTransitionFinished", startHaze, {priority=-179})
    event.register("weatherChangedImmediate", startHaze, {priority=-179})
    event.register("loaded", hazeTimers, {priority=-179})
end

event.register("initialized", init)
event.register("modConfigReady", function()
    dofile("Data Files\\MWSE\\mods\\tew\\Heat Haze\\mcm.lua")
end)
local modversion = require("tew\\Heat Haze\\version")
local version = modversion.version
local config = require("tew.Heat Haze.config")

local hazeStartHour = config.hazeStartHour
local hazeEndHour = config.hazeEndHour
local heatRegions = config.heatRegions

local tewLib = require("tew\\tewLib\\tewLib")
local getObjects = tewLib.getObjects
local getDistance = tewLib.getDistance

local distanceTimer
local heatWeathers = {}
local heatEmitters = {}

local heatEmittersClassifiers={
    ["activators"]={
        "in_lava",
    },
    ["statics"]={
        "volcano",
        "terrain_lava"
    }
}

local defaultFloats = {
    ["warpint"] = 0.003,
    ["wspeed"] = -0.06
}

local strongFloats = {
    ["warpint"] = 0.01,
    ["wspeed"] = -0.75
}

local farInts = {
    ["dmaskint1"] = 5005,
    ["dmaskint2"] = 9000
}

local closeInts = {
    ["dmaskint1"] = 500,
    ["dmaskint2"] = 506
}

local function getHeatEmitters(cell, objects, array)
    local heatObjects = getObjects(cell, objects, array)
    for _, emitter in ipairs(heatObjects) do
        table.insert(heatEmitters, emitter)
    end
end

local function debugLog(string)
    if config.debugLogOn then
        mwse.log("[Heat Haze "..version.."] "..string.format("%s", string))
    end
end

local function isHeatRegion(regionID)
    if heatRegions[regionID] and regionID ~= nil then
        return true
    end
end

local function isHeatWeather(weather)
    for _, w in pairs(heatWeathers) do
        if w == weather and w ~= nil then
            return true
        end
    end
end

local function removeHeatShader()
    mge.disableShader({shader="heathaze"})
    timer.start{
        type=timer.real,
        duration=0.1,
        iterations=10,
        callback = function()
            mge.disableShader({shader="heathaze"})
    end}
end

local function startHaze()

    local cell = tes3.getPlayerCell()
    if not cell then return end

    heatEmitters={}

    for float, val in pairs(defaultFloats) do
        mge.setShaderFloat{
            shader="heathaze",
            variable=float,
            value=val
        }
    end

    for float, val in pairs(farInts) do
        mge.setShaderLong{
            shader="heathaze",
            variable=float,
            value=val
        }
    end

    if cell.isInterior then
        debugLog("Detected interior cell. Removing shader.")
        distanceTimer:pause()
        removeHeatShader()
        return
    end

    local regionID = cell.region.id
    if not isHeatRegion(regionID) then
        debugLog("Detected ineligible region. Removing shader.")
        distanceTimer:pause()
        removeHeatShader()
        return
    end

    local WtC=tes3.getWorldController().weatherController
    local currentWeather = WtC.currentWeather
    local weatherNow

    heatWeathers = {}
    for weather, _ in pairs(config.heatWeathers) do
        if not heatWeathers[weather:lower()] then
            table.insert(heatWeathers, weather:lower())
        end
    end

    for name, weather in pairs(tes3.weather) do
        if currentWeather.index == weather then
            weatherNow=name:lower()
        end
    end

    if not isHeatWeather(weatherNow) then
        debugLog("Detected ineligible weather. Removing shader.")
        distanceTimer:pause()
        removeHeatShader()
        return
    end

    local gameHour=tes3.worldController.hour.value
    if gameHour < hazeStartHour or gameHour >= hazeEndHour  then
        getHeatEmitters(cell, tes3.objectType.activator, heatEmittersClassifiers["activators"])
        getHeatEmitters(cell, tes3.objectType.static, heatEmittersClassifiers["statics"])
        if heatEmitters[1]~=nil then
            debugLog("Near lava at night. Enabling shader.")
            mge.enableShader({shader="heathaze"})
            distanceTimer:resume()
        else
            debugLog("Detected ineligible game hour. Removing shader.")
            distanceTimer:pause()
            removeHeatShader()
            return
        end
    end

    debugLog("Check ok. Enabling shader.")
    mge.enableShader({shader="heathaze"})

    if (regionID == "Red Mountain Region"
    or regionID == "Ashlands Region"
    or regionID == "Armun Ashlands Region"
    or regionID == "Molag Mar Region") then
        debugLog("Found region with lava. Running lava distance checks.")
        getHeatEmitters(cell, tes3.objectType.activator, heatEmittersClassifiers["activators"])
        getHeatEmitters(cell, tes3.objectType.static, heatEmittersClassifiers["statics"])
        if heatEmitters[1]~=nil then
            distanceTimer:resume()
        end
    end

end

local function updateHaze()
    if not heatEmitters then return end
    local playerPos=tes3.player.position
    for _, emitter in ipairs(heatEmitters) do
        if getDistance(playerPos, emitter.position) <= 1500 then
            for float, val in pairs(strongFloats) do
                mge.setShaderFloat{
                    shader="heathaze",
                    variable=float,
                    value=val
                }
            end
            for float, val in pairs(closeInts) do
                mge.setShaderLong{
                    shader="heathaze",
                    variable=float,
                    value=val
                }
            end
            break
        else
            for float, val in pairs(defaultFloats) do
                mge.setShaderFloat{
                    shader="heathaze",
                    variable=float,
                    value=val
                }
            end
            for float, val in pairs(farInts) do
                mge.setShaderLong{
                    shader="heathaze",
                    variable=float,
                    value=val
                }
            end
        end
    end
end

local function hazeTimers()
    timer.start{
       duration=0.3,
        callback=startHaze,
        iterations=-1,
        type=timer.game
    }

    distanceTimer=
    timer.start{
        duration=0.4,
        callback=updateHaze,
        iterations=-1,
    }
    distanceTimer:pause()
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


--[[
local distConst = 2000
if getDistance(playerPos, emitter.position) <= distConst then
    local dist = getDistance(playerPos, emitter.position)

    local const1 = 5005
    local const2 = 9000

    local val1 = const1 / 2 * distConst
    local val2 = const2 / 4 * distConst

    mge.setShaderLong{
        shader="heathaze",
        variable="dmaskint1",
        value=dist*val1
    }
    mge.setShaderLong{
        shader="heathaze",
        variable="dmaskint2",
        value=dist*val2
    }
end
--]]

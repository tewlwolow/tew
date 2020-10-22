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
local heatEmitters={}

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
    ["wspeed"] = -0.5
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
    if heatRegions[regionID] then
        return true
    end
end

local function startHaze()

    local cell = tes3.getPlayerCell()
    if not cell then return end

    tes3.messageBox("Cell changed!")

    heatEmitters={}

    for float, val in pairs(defaultFloats) do
        mge.setShaderFloat{
            shader="heathaze",
            variable=float,
            value=val
        }
    end

    if cell.isInterior then
        debugLog("Detected interior cell. Removing shader.")
        mge.disableShader({shader="heathaze"})
        distanceTimer:pause()
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
        distanceTimer:pause()
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

        getHeatEmitters(cell, tes3.objectType.activator, heatEmittersClassifiers["activators"])
        getHeatEmitters(cell, tes3.objectType.static, heatEmittersClassifiers["statics"])

        if heatEmitters[1]~=nil and currentWeather.index == 2 then
            debugLog("Near lava in foggy weather. Enabling shader.")
            mge.enableShader({shader="heathaze"})
            distanceTimer:resume()
        else
            debugLog("Detected ineligible weather. Removing shader.")
            mge.disableShader({shader="heathaze"})
            distanceTimer:pause()
            timer.start{
                type=timer.real,
                duration=0.1,
                iterations=10,
                callback = function()
                    mge.disableShader({shader="heathaze"})
                end}
            return
        end
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
            mge.disableShader({shader="heathaze"})
            distanceTimer:pause()
            timer.start{
                type=timer.real,
                duration=0.1,
                iterations=10,
                callback = function()
                    mge.disableShader({shader="heathaze"})
                end}
            return
        end
    end

    if cell.isInterior==false
    and isHeatRegion(regionID)
    and (currentWeather.index <= 3 and currentWeather.index ~= 2)
    and (gameHour >= hazeStartHour and gameHour < hazeEndHour) then
        debugLog("Check ok. Enabling shader.")
        mge.enableShader({shader="heathaze"})
    end
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
        if getDistance(playerPos, emitter.position) <= 1700 then
            tes3.messageBox("Very close to lava.")
            for float, val in pairs(strongFloats) do
                mge.setShaderFloat{
                    shader="heathaze",
                    variable=float,
                    value=val
                }
            end
            break
        else
            tes3.messageBox("Far from lava.")
            for float, val in pairs(defaultFloats) do
                mge.setShaderFloat{
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
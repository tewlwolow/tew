local weathers=require("tew\\Watch the Skies\\weathers")
local config=require("tew\\Watch the Skies\\config")
local debugLogOn=config.debugLogOn
local WtSdir="Data Files\\Textures\\tew\\Watch the Skies\\"
local vanChance=config.vanChance/100
local alterChanges=config.alterChanges
local interiorTransitions=config.interiorTransitions
local randomiseParticles=config.randomiseParticles
local randomiseCloudsSpeed=config.randomiseCloudsSpeed
local modversion = require("tew\\Watch the Skies\\version")
local version = modversion.version
local WtC, intWeatherTimer


local interiorWeathers={0,1,2,3,4,5}

local function debugLog(string)
    if debugLogOn then
       mwse.log("[Watch the Skies "..version.."] "..string.format("%s", string))
    end
end

local function changeMaxParticles()
    WtC.weathers[5].maxParticles=math.random(200,1200)
    WtC.weathers[6].maxParticles=math.random(600,1500)
    WtC.weathers[9].maxParticles=math.random(150,1200)
end

local function changeCloudsSpeed()
    WtC.weathers[1].cloudsSpeed=math.random(100,200)/100
    WtC.weathers[2].cloudsSpeed=math.random(100,300)/100
    WtC.weathers[3].cloudsSpeed=math.random(50,150)/100
    WtC.weathers[4].cloudsSpeed=math.random(100,300)/100
    WtC.weathers[5].cloudsSpeed=math.random(150,350)/100
    WtC.weathers[6].cloudsSpeed=math.random(200,450)/100
    WtC.weathers[7].cloudsSpeed=math.random(600,1000)/100
    WtC.weathers[8].cloudsSpeed=math.random(800,1500)/100
    WtC.weathers[9].cloudsSpeed=math.random(100,200)/100
    WtC.weathers[10].cloudsSpeed=math.random(600,1200)/100
end

local function skyChoice(e)
    if not e then return end
    debugLog("Starting cloud texture randomisation.")
    if vanChance<math.random() then
        local sArray=weathers[e.to.index]
        local texPath
        for weather, index in pairs(tes3.weather) do
            if e.to.index==index then
                texPath=weather
            end
        end
        if texPath~=nil and sArray[1]~=nil then
            e.to.cloudTexture=WtSdir..texPath.."\\"..sArray[math.random(1, #sArray)]
            debugLog("Cloud texture path set to: "..e.to.cloudTexture)
        end
    else
        debugLog("Using vanilla texture.")
    end

    if alterChanges then
        WtC.hoursBetweenWeatherChanges=math.random(3,12)
        debugLog("Current time between weather changes: "..WtC.hoursBetweenWeatherChanges)
    end

    if randomiseParticles then
        changeMaxParticles()
    end

    if randomiseCloudsSpeed then
        changeCloudsSpeed()
    end
end

local function changeInteriorWeather()
    local currentWeather=WtC.currentWeather.index
    debugLog("Weather before randomisation: "..currentWeather)
    local newWeather=interiorWeathers[math.random(1, #interiorWeathers)]

    while newWeather==currentWeather do
        newWeather=interiorWeathers[math.random(1, #interiorWeathers)]
    end

    WtC:switchTransition(newWeather)

    debugLog("Weather randomised. New weather: "..WtC.nextWeather.index)
end

local function onCellChanged(e)
    local cell=e.cell

    if not (cell.isInterior) or (cell.isInterior and cell.behavesAsExterior) then
        if intWeatherTimer then
        intWeatherTimer:pause()
        debugLog("Player in exterior. Pausing interior timer.") end
    elseif (cell.isInterior) and not (cell.behavesAsExterior) then
        if intWeatherTimer then
        intWeatherTimer:cancel()
        intWeatherTimer=nil end
        intWeatherTimer=timer.start{duration=WtC.hoursBetweenWeatherChanges, callback=changeInteriorWeather, iterations=-1, type=timer.game}
        debugLog("Player in interior. Resuming interior timer. Time to weather change: "..WtC.hoursBetweenWeatherChanges)
    end
end

local function init()
    WtC=tes3.getWorldController().weatherController
    print("Watch the Skies version "..version.." initialised.")
    for weather, index in pairs(tes3.weather) do
        debugLog("Weather: "..weather)
        for sky in lfs.dir(WtSdir..weather) do
            if sky ~= ".." and sky ~= "." then
                debugLog("Found file: "..sky)
                if string.endswith(sky, ".dds") or string.endswith(sky, ".tga") then
                    table.insert(weathers[index], sky)
                    debugLog("Adding file: "..sky)
                end
            end
        end
    end
    for _, weather in pairs(WtC.weathers) do
        for index, _ in pairs(weathers) do
            if weather.index==index then
                local texPath
                for w, i in pairs(tes3.weather) do
                    if index==i then
                        texPath=w
                        break
                    end
                end
                if texPath~=nil and weathers[index][1]~=nil then
                    weather.cloudTexture=WtSdir..texPath.."\\"..weathers[index][math.random(1, #weathers[index])]
                end
            end
        end
    end

    if alterChanges then
        WtC.hoursBetweenWeatherChanges=math.random(3,12)
    end

    event.register("weatherChangedImmediate", skyChoice, {priority=-149})
    event.register("weatherTransitionFinished", skyChoice, {priority=-149})

    if interiorTransitions then
        event.register("cellChanged", onCellChanged, {priority=-149})
    end

    if randomiseParticles then
        changeMaxParticles()
    end

    if randomiseCloudsSpeed then
        changeCloudsSpeed()
    end
end

event.register("initialized", init)

-- Registers MCM menu --
event.register("modConfigReady", function()
    dofile("Data Files\\MWSE\\mods\\tew\\Watch the Skies\\mcm.lua")
end)
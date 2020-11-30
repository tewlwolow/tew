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
local tewLib = require("tew\\tewLib\\tewLib")
local isOpenPlaza=tewLib.isOpenPlaza

local function debugLog(string)
    if debugLogOn then
       mwse.log("[Watch the Skies "..version.."] "..string.format("%s", string))
    end
end

local function changeMaxParticles()
    WtC.weathers[5].maxParticles=math.random(100,1200)
    WtC.weathers[6].maxParticles=math.random(400,1500)
    WtC.weathers[9].maxParticles=math.random(100,1200)
    debugLog("Particles amount randomised.")
    debugLog("Rain particles: "..WtC.weathers[5].maxParticles)
    debugLog("Thunderstorm particles: "..WtC.weathers[6].maxParticles)
    debugLog("Snow particles: "..WtC.weathers[9].maxParticles)
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
    debugLog("Clouds speed randomised.")
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
        WtC.hoursBetweenWeatherChanges=math.random(3,10)
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
    local newWeather
    debugLog("Weather before randomisation: "..currentWeather)

    local region = tes3.getRegion()
    local regionChances={
    [0] = region.weatherChanceClear,
    [1] = region.weatherChanceCloudy,
    [2] = region.weatherChanceFoggy,
    [3] = region.weatherChanceOvercast,
    [4] = region.weatherChanceRain,
    [5] = region.weatherChanceThunder,
    [6] = region.weatherChanceAsh,
    [7] = region.weatherChanceBlight,
    [8] = region.weatherChanceSnow,
    [9] = region.weatherChanceBlizzard
    }

    while newWeather == nil do
        for weather, chance in pairs(regionChances) do
            if chance/100 > math.random() then
                newWeather = weather
                break
            end
        end
    end

    WtC:switchTransition(newWeather)

    debugLog("Weather randomised. New weather: "..WtC.nextWeather.index)
end

local function onCellChanged(e)
    debugLog("Cell changed.")
    local cell=e.cell or tes3.getPlayerCell()
    if not cell then return end

    if isOpenPlaza(cell)==true then
        WtC.weathers[5].maxParticles=1500
        WtC.weathers[6].maxParticles=3000
        WtC.weathers[5].particleRadius=1200
        WtC.weathers[6].particleRadius=1200
    end

    if not (cell.isInterior) or (cell.isInterior and cell.behavesAsExterior) then
        if intWeatherTimer then
        intWeatherTimer:pause()
        debugLog("Player in exterior. Pausing interior timer.") end
    elseif (cell.isInterior) and not (cell.behavesAsExterior) then
        if intWeatherTimer then
            intWeatherTimer:pause()
            intWeatherTimer:cancel()
            intWeatherTimer=nil
        end
        intWeatherTimer=timer.start{
            duration=WtC.hoursBetweenWeatherChanges,
            callback=changeInteriorWeather,
            type=timer.game,
            iterations=-1
        }
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
        WtC.hoursBetweenWeatherChanges=math.random(3,10)
    end

    event.register("weatherChangedImmediate", skyChoice, {priority=-150})
    event.register("weatherTransitionFinished", skyChoice, {priority=-150})

    if interiorTransitions then
        event.register("cellChanged", onCellChanged, {priority=-150})
    end

    if randomiseParticles then
        changeMaxParticles()
    end

    if randomiseCloudsSpeed then
        changeCloudsSpeed()
    end
end

event.register("initialized", init, {priority=-150})

-- Registers MCM menu --
event.register("modConfigReady", function()
    dofile("Data Files\\MWSE\\mods\\tew\\Watch the Skies\\mcm.lua")
end)
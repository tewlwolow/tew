local weathers=require("tew\\Watch the Skies\\weathers")
local config=require("tew\\Watch the Skies\\config")
local seasonalChances=require("tew\\Watch the Skies\\seasonalChances")
local daytimeData=require("tew\\Watch the Skies\\daytime")
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

local particleAmount = {
    ["rain"] = {
        50,
        80,
        100,
        150,
        250,
        400,
        500,
        1000,
        1200,
        1500,
    },
    ["thunder"] = {
        275,
        400,
        500,
        600,
        900,
        1400,
        1700,
        2000,
    },
    ["snow"] = {
        60,
        100,
        300,
        460,
        600,
        1000,
        1200,
        1500,
    }
}

local function debugLog(string)
    if debugLogOn then
       mwse.log("[Watch the Skies "..version.."] "..string.format("%s", string))
    end
end

local function changeMaxParticles()
    WtC.weathers[5].maxParticles=particleAmount["rain"][math.random(1, #particleAmount["rain"])]
    WtC.weathers[6].maxParticles=particleAmount["thunder"][math.random(1, #particleAmount["thunder"])]
    WtC.weathers[9].maxParticles=particleAmount["snow"][math.random(1, #particleAmount["snow"])]
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

    local region = tes3.getRegion({useDoors=true})
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

local function changeSeasonal()
    -- TODO: check for journal entries --
    -- all blight values to clear --
    -- red mountain custom something --
    -- mournhold machine --
    local month = tes3.worldController.month.value + 1

    for region in tes3.iterate(tes3.dataHandler.nonDynamicData.regions) do
        region.weatherChanceClear = seasonalChances[region.name][month][1]
        region.weatherChanceCloudy = seasonalChances[region.name][month][2]
        region.weatherChanceFoggy = seasonalChances[region.name][month][3]
        region.weatherChanceOvercast = seasonalChances[region.name][month][4]
        region.weatherChanceRain = seasonalChances[region.name][month][5]
        region.weatherChanceThunder = seasonalChances[region.name][month][6]
        region.weatherChanceAsh = seasonalChances[region.name][month][7]
        region.weatherChanceBlight = seasonalChances[region.name][month][8]
        region.weatherChanceSnow = seasonalChances[region.name][month][9]
        region.weatherChanceBlizzard = seasonalChances[region.name][month][10]
    end

end

local function changeDaytime()
    local region = tes3.getRegion({useDoors=true}).name
    local month = tes3.worldController.month.value + 1
    print(WtC.sunriseHour)
    print(WtC.sunsetHour)
    for _, regionName in pairs(daytimeData["cold regions"]) do
        if region == regionName then
            WtC.sunriseHour = daytimeData["northern"]["sunrise"][month]
            WtC.sunsetHour = daytimeData["northern"]["sunset"][month]
            break
        else
            WtC.sunriseHour = daytimeData["regular"]["sunrise"][month]
            WtC.sunsetHour = daytimeData["regular"]["sunset"][month]
        end
    end
    print(WtC.sunriseHour)
    print(WtC.sunsetHour)
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

    if config.seasonalWeather then
        changeSeasonal()
    end

    if config.daytime then
        changeDaytime()
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

local function seasonalTimer()
    changeSeasonal()
    timer.start({duration=1, callback=changeSeasonal, iterations=-1, type=timer.game})
end

local function daytimeTimer()
    changeDaytime()
    timer.start({duration=1, callback=changeDaytime, iterations=-1, type=timer.game})
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
                    debugLog("Cloud texture path set to: "..weather.cloudTexture)
                end
            end
        end
    end

    if alterChanges then
        WtC.hoursBetweenWeatherChanges=math.random(3,10)
    end

    if randomiseParticles then
        changeMaxParticles()
    end

    if randomiseCloudsSpeed then
        changeCloudsSpeed()
    end

    if config.seasonalWeather then
        event.register("loaded", seasonalTimer)
    end

    if config.daytime then
        event.register("loaded", daytimeTimer)
    end

    event.register("weatherChangedImmediate", skyChoice, {priority=-150})
    event.register("weatherTransitionFinished", skyChoice, {priority=-150})

    if interiorTransitions then
        event.register("cellChanged", onCellChanged, {priority=-150})
    end



    ----------------------------------------------------
    -- Beneath you can find some useful functions to automatically generate varied weather --
--[[
    -- Prints a lua-friendly table with weather chances per month (vanilla) --    
    local months = {1,2,3,4,5,6,7,8,9,10,11,12}
    for region in tes3.iterate(tes3.dataHandler.nonDynamicData.regions) do
        print("[\""..region.name.."\"] = {")
        for _, month in ipairs(months) do
            print("["..month.."] = {"..region.weatherChanceClear..", "..region.weatherChanceCloudy..", "..region.weatherChanceFoggy..", "..region.weatherChanceOvercast..", "..region.weatherChanceRain..", "..region.weatherChanceThunder..", "..region.weatherChanceAsh..", "..region.weatherChanceBlight..", "..region.weatherChanceSnow..", "..region.weatherChanceBlizzard.."},")
        end
        print("},\n")
    end

    -- Adjusts value per month --
    for region in tes3.iterate(tes3.dataHandler.nonDynamicData.regions) do
        for month, chanceArray in ipairs(seasonalChances[region.name]) do
            if month ==  1 then
                chanceArray[1] = math.ceil(chanceArray[1] + chanceArray[1]*15/100)
                chanceArray[2] = math.ceil(chanceArray[2] - chanceArray[2]*20/100)
                chanceArray[3] = math.ceil(chanceArray[3] + chanceArray[3]*50/100)
                chanceArray[4] = math.ceil(chanceArray[4] + chanceArray[4]*20/100)
                chanceArray[5] = math.ceil(chanceArray[5] + chanceArray[5]*15/100)
                if chanceArray[7]~=0 then
                    chanceArray[7] = math.ceil(chanceArray[7] - chanceArray[7]*12/100)
                end
                if chanceArray[9]~=0 then
                    chanceArray[5] = 0
                    chanceArray[6] = 0
                    chanceArray[9] = math.ceil(chanceArray[9] + chanceArray[9]*10/100)
                    chanceArray[10] = math.ceil(chanceArray[10] + chanceArray[10]*10/100)
                end
            elseif month == 2 then
                chanceArray[1] = math.ceil(chanceArray[1] + chanceArray[1]*20/100)
                chanceArray[2] = math.ceil(chanceArray[2] - chanceArray[2]*30/100)
                chanceArray[3] = math.ceil(chanceArray[3] + chanceArray[3]*60/100)
                chanceArray[4] = math.ceil(chanceArray[4] + chanceArray[4]*15/100)
                chanceArray[5] = math.ceil(chanceArray[5] + chanceArray[5]*20/100)
                if chanceArray[7]~=0 then
                    chanceArray[7] = math.ceil(chanceArray[7] - chanceArray[7]*10/100)
                end
                if chanceArray[9]~=0 then
                    chanceArray[5] = 0
                    chanceArray[6] = 0
                    chanceArray[9] = math.ceil(chanceArray[9] + chanceArray[9]*16/100)
                    chanceArray[10] = math.ceil(chanceArray[10] + chanceArray[10]*4/100)
                end
            elseif month == 3 then
                chanceArray[1] = math.ceil(chanceArray[1] + chanceArray[1]*25/100)
                chanceArray[2] = math.ceil(chanceArray[2] - chanceArray[2]*5/100)
                chanceArray[3] = math.ceil(chanceArray[3] + chanceArray[3]*20/100)
                chanceArray[4] = math.ceil(chanceArray[4] + chanceArray[4]*25/100)
                chanceArray[5] = math.ceil(chanceArray[5] + chanceArray[5]*50/100)
                chanceArray[6] = math.ceil(chanceArray[6] + chanceArray[6]*120/100)
                if chanceArray[7]~=0 then
                    chanceArray[7] = math.ceil(chanceArray[7] - chanceArray[7]*4/100)
                end
                if chanceArray[9]~=0 then
                    chanceArray[5] = 0
                    chanceArray[6] = 0
                    chanceArray[9] = math.ceil(chanceArray[9] + chanceArray[9]*28/100)
                    chanceArray[10] = math.ceil(chanceArray[10] + chanceArray[10]*12/100)
                end
            elseif month == 4 then
                chanceArray[1] = math.ceil(chanceArray[1] + chanceArray[1]*40/100)
                chanceArray[2] = math.ceil(chanceArray[2] - chanceArray[2]*12/100)
                chanceArray[3] = math.ceil(chanceArray[3] + chanceArray[3]*40/100)
                chanceArray[4] = math.ceil(chanceArray[4] + chanceArray[4]*20/100)
                chanceArray[5] = math.ceil(chanceArray[5] + chanceArray[5]*170/100)
                chanceArray[6] = math.ceil(chanceArray[6] + chanceArray[6]*70/100)
                if chanceArray[7]~=0 then
                    chanceArray[7] = math.ceil(chanceArray[7] - chanceArray[7]*25/100)
                end
                if chanceArray[9]~=0 then
                    chanceArray[5] = 10
                    chanceArray[6] = 5
                    chanceArray[9] = math.ceil(chanceArray[9] + chanceArray[9]*12/100)
                    chanceArray[10] = math.ceil(chanceArray[10] + chanceArray[10]*18/100)
                end
            elseif month == 5 then
                chanceArray[1] = math.ceil(chanceArray[1] + chanceArray[1]*80/100)
                chanceArray[2] = math.ceil(chanceArray[2] + chanceArray[2]*30/100)
                chanceArray[3] = math.ceil(chanceArray[3] + chanceArray[3]*20/100)
                chanceArray[4] = math.ceil(chanceArray[4] - chanceArray[4]*30/100)
                chanceArray[5] = math.ceil(chanceArray[5] + chanceArray[5]*75/100)
                chanceArray[6] = math.ceil(chanceArray[6] + chanceArray[6]*30/100)
                if chanceArray[7]~=0 then
                    chanceArray[7] = math.ceil(chanceArray[7] + chanceArray[7]*25/100)
                end
                if chanceArray[9]~=0 then
                    chanceArray[9] = 0
                    chanceArray[10] = 0
                end
            elseif month == 6 then
                chanceArray[1] = math.ceil(chanceArray[1] + chanceArray[1]*150/100)
                chanceArray[2] = math.ceil(chanceArray[2] + chanceArray[2]*80/100)
                chanceArray[3] = math.ceil(chanceArray[3] + chanceArray[3]*40/100)
                chanceArray[4] = math.ceil(chanceArray[4] - chanceArray[4]*25/100)
                chanceArray[5] = math.ceil(chanceArray[5] + chanceArray[5]*25/100)
                chanceArray[6] = math.ceil(chanceArray[6] + chanceArray[6]*30/100)
                if chanceArray[7]~=0 then
                    chanceArray[7] = math.ceil(chanceArray[7] + chanceArray[7]*35/100)
                end
                if chanceArray[9]~=0 then
                    chanceArray[9] = 0
                    chanceArray[10] = 0
                end
            elseif month == 7 then
                chanceArray[1] = math.ceil(chanceArray[1] + chanceArray[1]*120/100)
                chanceArray[2] = math.ceil(chanceArray[2] + chanceArray[2]*70/100)
                chanceArray[3] = math.ceil(chanceArray[3] + chanceArray[3]*50/100)
                chanceArray[4] = math.ceil(chanceArray[4] - chanceArray[4]*15/100)
                chanceArray[5] = math.ceil(chanceArray[5] - chanceArray[5]*16/100)
                chanceArray[6] = math.ceil(chanceArray[6] - chanceArray[6]*12/100)
                if chanceArray[7]~=0 then
                    chanceArray[7] = math.ceil(chanceArray[7] + chanceArray[7]*30/100)
                end
                if chanceArray[9]~=0 then
                    chanceArray[9] = 0
                    chanceArray[10] = 0
                end
            elseif month == 8 then
                chanceArray[1] = math.ceil(chanceArray[1] + chanceArray[1]*90/100)
                chanceArray[2] = math.ceil(chanceArray[2] + chanceArray[2]*150/100)
                chanceArray[3] = math.ceil(chanceArray[3] - chanceArray[3]*35/100)
                chanceArray[4] = math.ceil(chanceArray[4] - chanceArray[4]*15/100)
                chanceArray[5] = math.ceil(chanceArray[5] - chanceArray[5]*16/100)
                chanceArray[6] = math.ceil(chanceArray[6] - chanceArray[6]*28/100)
                if chanceArray[7]~=0 then
                    chanceArray[7] = math.ceil(chanceArray[7] + chanceArray[7]*20/100)
                end
                if chanceArray[9]~=0 then
                    chanceArray[9] = 0
                    chanceArray[10] = 0
                end
            elseif month == 9 then
                chanceArray[1] = math.ceil(chanceArray[1] + chanceArray[1]*70/100)
                chanceArray[2] = math.ceil(chanceArray[2] + chanceArray[2]*100/100)
                chanceArray[3] = math.ceil(chanceArray[3] + chanceArray[3]*50/100)
                chanceArray[4] = math.ceil(chanceArray[4] + chanceArray[4]*30/100)
                chanceArray[5] = math.ceil(chanceArray[5] + chanceArray[5]*25/100)
                chanceArray[6] = math.ceil(chanceArray[6] + chanceArray[6]*10/100)
                if chanceArray[7]~=0 then
                    chanceArray[7] = math.ceil(chanceArray[7] + chanceArray[7]*16/100)
                end
                if chanceArray[9]~=0 then
                    chanceArray[5] = 10
                    chanceArray[6] = 0
                    chanceArray[9] = math.ceil(chanceArray[9] + chanceArray[9]*10/100)
                    chanceArray[10] = math.ceil(chanceArray[10] + chanceArray[10]*10/100)
                end
            elseif month == 10 then
                chanceArray[1] = math.ceil(chanceArray[1] + chanceArray[1]*40/100)
                chanceArray[2] = math.ceil(chanceArray[2] + chanceArray[2]*80/100)
                chanceArray[3] = math.ceil(chanceArray[3] + chanceArray[3]*70/100)
                chanceArray[4] = math.ceil(chanceArray[4] + chanceArray[4]*60/100)
                chanceArray[5] = math.ceil(chanceArray[5] + chanceArray[5]*15/100)
                chanceArray[6] = math.ceil(chanceArray[6] + chanceArray[6]*17/100)
                if chanceArray[7]~=0 then
                    chanceArray[7] = math.ceil(chanceArray[7] - chanceArray[7]*10/100)
                end
                if chanceArray[9]~=0 then
                    chanceArray[5] = 5
                    chanceArray[6] = 0
                    chanceArray[9] = math.ceil(chanceArray[9] + chanceArray[9]*30/100)
                    chanceArray[10] = math.ceil(chanceArray[10] + chanceArray[10]*15/100)
                end
            elseif month == 11 then
                chanceArray[1] = math.ceil(chanceArray[1] - chanceArray[1]*20/100)
                chanceArray[2] = math.ceil(chanceArray[2] + chanceArray[2]*60/100)
                chanceArray[3] = math.ceil(chanceArray[3] + chanceArray[3]*100/100)
                chanceArray[4] = math.ceil(chanceArray[4] + chanceArray[4]*70/100)
                chanceArray[5] = math.ceil(chanceArray[5] + chanceArray[5]*28/100)
                chanceArray[6] = math.ceil(chanceArray[6] + chanceArray[6]*4/100)
                if chanceArray[7]~=0 then
                    chanceArray[7] = math.ceil(chanceArray[7] - chanceArray[7]*16/100)
                end
                if chanceArray[9]~=0 then
                    chanceArray[5] = 0
                    chanceArray[6] = 0
                    chanceArray[9] = math.ceil(chanceArray[9] + chanceArray[9]*105/100)
                    chanceArray[10] = math.ceil(chanceArray[10] + chanceArray[10]*15/100)
                end
            elseif month == 12 then
                chanceArray[1] = math.ceil(chanceArray[1] - chanceArray[1]*40/100)
                chanceArray[2] = math.ceil(chanceArray[2] + chanceArray[2]*60/100)
                chanceArray[3] = math.ceil(chanceArray[3] + chanceArray[3]*120/100)
                chanceArray[4] = math.ceil(chanceArray[4] + chanceArray[4]*150/100)
                chanceArray[5] = math.ceil(chanceArray[5] + chanceArray[5]*28/100)
                chanceArray[6] = math.ceil(chanceArray[6] + chanceArray[6]*12/100)
                if chanceArray[7]~=0 then
                    chanceArray[7] = math.ceil(chanceArray[7] - chanceArray[7]*10/100)
                end
                if chanceArray[9]~=0 then
                    chanceArray[5] = 0
                    chanceArray[6] = 0
                    chanceArray[9] = math.ceil(chanceArray[9] + chanceArray[9]*18/100)
                    chanceArray[10] = math.ceil(chanceArray[10] + chanceArray[10]*15/100)
                end
            end
        end
    end

    -- Adjusts values to give 100% weather chances sum per month --
    for region in tes3.iterate(tes3.dataHandler.nonDynamicData.regions) do
        for _, chanceArray in ipairs(seasonalChances[region.name]) do
            local sum = 0
            local diff
            for _, chance in ipairs(chanceArray) do
                sum = sum + chance
            end
            if sum > 100 then
                diff = sum - 100
                chanceArray[2] = chanceArray[2] - diff
                if chanceArray[2] < 5 then chanceArray[2] = 5 end
                sum = 0
                for _, chance in ipairs(chanceArray) do
                    sum = sum + chance
                end
                if sum > 100 then
                    diff = sum - 100
                    local valueMax = math.max(unpack(chanceArray))
                    for index, chance in ipairs(chanceArray) do
                        if chance == valueMax then
                            chanceArray[index] = chanceArray[index] - diff
                        end
                    end
                end
            end
            if sum < 100 then
                diff = 100 - sum
                chanceArray[1] = chanceArray[1] + diff
            end
        end
    end

    -- Ensures there are no negative values --
    for region in tes3.iterate(tes3.dataHandler.nonDynamicData.regions) do
        local added = 0
        for _, chanceArray in ipairs(seasonalChances[region.name]) do
            for index, chance in ipairs(chanceArray) do
                if chance < 0 then
                    added = math.abs(2*chance)
                    chanceArray[index] = added
                end
            end
            local valueMax = math.max(unpack(chanceArray))
            for index, chance in ipairs(chanceArray) do
                if chance == valueMax then
                    chanceArray[index] = chanceArray[index] - added
                end
            end
        end
    end

    -- Prints a lua-friendly table with weather chances per month (adjusted) --
    for region in tes3.iterate(tes3.dataHandler.nonDynamicData.regions) do
        print("[\""..region.name.."\"] = {")
        for month, chanceArray in ipairs(seasonalChances[region.name]) do
            print("["..month.."] = {"..chanceArray[1]..", "..chanceArray[2]..", "..chanceArray[3]..", "..chanceArray[4]..", "..chanceArray[5]..", "..chanceArray[6]..", "..chanceArray[7]..", "..chanceArray[8]..", "..chanceArray[9]..", "..chanceArray[10].."},")
        end
        print("},\n")
    end
--]]

end

event.register("initialized", init, {priority=-150})

-- Registers MCM menu --
event.register("modConfigReady", function()
    dofile("Data Files\\MWSE\\mods\\tew\\Watch the Skies\\mcm.lua")
end)
local weathers=require("tew\\Watch the Skies\\weathers")
local config=require("tew\\Watch the Skies\\config")
local seasonalChances=require("tew\\Watch the Skies\\seasonalChances")
local debugLogOn=config.debugLogOn
local WtSdir="Data Files\\Textures\\tew\\Watch the Skies\\"
local vanChance=config.vanChance/100
local alterChanges=config.alterChanges
local interiorTransitions=config.interiorTransitions
local randomiseParticles=config.randomiseParticles
local randomiseCloudsSpeed=config.randomiseCloudsSpeed
local modversion = require("tew\\Watch the Skies\\version")
local version = modversion.version
local WtC, intWeatherTimer, monthLast, regionLast
local tewLib = require("tew\\tewLib\\tewLib")
local isOpenPlaza=tewLib.isOpenPlaza

local vvRegions = {"Bitter Coast Region", "Azura's Coast Region", "Molag Mar Region", "Ashlands Region", "West Gash Region", "Ascadian Isles Region", "Grazelands Region", "Sheogorad"}

local function checkVv(region)
    for _, v in ipairs(vvRegions) do
        if region == v then
            return true
        end
    end
end

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

local function getMQState()

-- This I got from Creeping Blight by Necrolesian --

    -- Receiving index 20 for this quest changes the weather at Red Mountain. Also resets questStage to 0.
    local endGameIndex = tes3.getJournalIndex{ id = "C3_DestroyDagoth" }

    -- Give the Dwemer Puzzle Box to Hasphat Antabolis. Triggers questStage 1.
    local antabolisIndex = tes3.getJournalIndex{ id = "A1_2_AntabolisInformant" }

    -- Receive notes on the Ashlanders from Hassour Zainsubani. Triggers questStage 2.
    local zainsubaniIndex = tes3.getJournalIndex{ id = "A1_11_ZainsubaniInformant" }

    -- Defeat Dagoth Gares. Triggers questStage 3.
    local garesIndex = tes3.getJournalIndex{ id = "A2_2_6thHouse" }

    -- Take the cure from Divayth Fyr. Triggers questStage 4.
    local cureIndex = tes3.getJournalIndex{ id = "A2_3_CorprusCure" }

    -- Receive Moon-and-Star from Azura. Triggers questStage 5.
    local incarnateIndex = tes3.getJournalIndex{ id = "A2_6_Incarnate" }

    -- Receive a working Wraithguard from Vivec or Yagrum Bagarn. Triggers questStage 6.
    local vivecIndex = tes3.getJournalIndex{ id = "B8_MeetVivec" }
    local backPathIndex = tes3.getJournalIndex{ id = "CX_BackPath" }

    local questStage

    -- Determine the current stage of the Main Quest.
    if endGameIndex >= 20 then
        questStage = 0
    elseif vivecIndex >= 50 or backPathIndex >= 50 then
        questStage = 6
    elseif incarnateIndex >= 50 then
        questStage = 5
    elseif cureIndex >= 50 then
        questStage = 4
    elseif garesIndex >= 50 then
        questStage = 3
    elseif zainsubaniIndex >= 50 then
        questStage = 2
    elseif antabolisIndex >= 10 then
        questStage = 1
    else
        questStage = 0
    end
    return questStage
end

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

    local month = tes3.worldController.month.value + 1
    local regionNow = tes3.getRegion({useDoors=true})
    if (month == monthLast) and (regionNow == regionLast) then debugLog("Same month and region. Returning.") return end

    local questStage = getMQState()
    debugLog("Main quest stage: "..questStage)

    for region in tes3.iterate(tes3.dataHandler.nonDynamicData.regions) do
        if region.id == "Red Mountain Region" then
            if tes3.getJournalIndex{id = "C3_DestroyDagoth"} < 20 then
                debugLog("Dagoth Ur is alive. Using full blight values for Red Mountain.")
                region.weatherChanceClear = 0
                region.weatherChanceCloudy = 0
                region.weatherChanceFoggy = 0
                region.weatherChanceOvercast = 0
                region.weatherChanceRain = 0
                region.weatherChanceThunder = 0
                region.weatherChanceAsh = 0
                region.weatherChanceBlight = 100
                region.weatherChanceSnow = 0
                region.weatherChanceBlizzard = 0
            else
                debugLog("Dagoth Ur is dead. Reverting to regular RM weather. Removing blight cloud.")
                region.weatherChanceClear = seasonalChances[region.id][month][1]
                region.weatherChanceCloudy = seasonalChances[region.id][month][2]
                region.weatherChanceFoggy = seasonalChances[region.id][month][3]
                region.weatherChanceOvercast = seasonalChances[region.id][month][4]
                region.weatherChanceRain = seasonalChances[region.id][month][5]
                region.weatherChanceThunder = seasonalChances[region.id][month][6]
                region.weatherChanceAsh = seasonalChances[region.id][month][7]
                region.weatherChanceBlight = seasonalChances[region.id][month][8]
                region.weatherChanceSnow = seasonalChances[region.id][month][9]
                region.weatherChanceBlizzard = seasonalChances[region.id][month][10]
                mwscript.disable{reference="blight cloud"}
            end
        elseif region.id == "Mournhold Region"
        and tes3.findGlobal("MournWeather").value == 1
        or tes3.findGlobal("MournWeather").value == 2
        or tes3.findGlobal("MournWeather").value == 3
        or tes3.findGlobal("MournWeather").value == 4
        or tes3.findGlobal("MournWeather").value == 5
        or tes3.findGlobal("MournWeather").value == 6
        or tes3.findGlobal("MournWeather").value == 7 then
            debugLog("Weather machine running: "..tes3.findGlobal("MournWeather").value)
            region.weatherChanceClear = 0
            region.weatherChanceCloudy = 0
            region.weatherChanceFoggy = 0
            region.weatherChanceOvercast = 0
            region.weatherChanceRain = 0
            region.weatherChanceThunder = 0
            region.weatherChanceAsh = 0
            region.weatherChanceBlight = 0
            region.weatherChanceSnow = 0
            region.weatherChanceBlizzard = 0
            if tes3.findGlobal("MournWeather").value == 1 then
                region.weatherChanceClear = 100
            elseif tes3.findGlobal("MournWeather").value == 2 then
                region.weatherChanceCloudy = 100
            elseif tes3.findGlobal("MournWeather").value == 3 then
                region.weatherChanceFoggy = 100
            elseif tes3.findGlobal("MournWeather").value == 4 then
                region.weatherChanceOvercast = 100
            elseif tes3.findGlobal("MournWeather").value == 5 then
                region.weatherChanceRain = 100
            elseif tes3.findGlobal("MournWeather").value == 6 then
                region.weatherChanceThunder = 100
            elseif tes3.findGlobal("MournWeather").value == 7 then
                region.weatherChanceAsh = 100
            end
        else
            if checkVv(region.id) == true then
                region.weatherChanceClear = (seasonalChances[region.id][month][1]) - questStage
                region.weatherChanceCloudy = seasonalChances[region.id][month][2]
                region.weatherChanceFoggy = seasonalChances[region.id][month][3]
                region.weatherChanceOvercast = seasonalChances[region.id][month][4]
                region.weatherChanceRain = seasonalChances[region.id][month][5]
                region.weatherChanceThunder = seasonalChances[region.id][month][6]
                region.weatherChanceAsh = seasonalChances[region.id][month][7]
                region.weatherChanceBlight = (seasonalChances[region.id][month][8]) + questStage
                region.weatherChanceSnow = seasonalChances[region.id][month][9]
                region.weatherChanceBlizzard = seasonalChances[region.id][month][10]
            else
                region.weatherChanceClear = seasonalChances[region.id][month][1]
                region.weatherChanceCloudy = seasonalChances[region.id][month][2]
                region.weatherChanceFoggy = seasonalChances[region.id][month][3]
                region.weatherChanceOvercast = seasonalChances[region.id][month][4]
                region.weatherChanceRain = seasonalChances[region.id][month][5]
                region.weatherChanceThunder = seasonalChances[region.id][month][6]
                region.weatherChanceAsh = seasonalChances[region.id][month][7]
                region.weatherChanceBlight = seasonalChances[region.id][month][8]
                region.weatherChanceSnow = seasonalChances[region.id][month][9]
                region.weatherChanceBlizzard = seasonalChances[region.id][month][10]
            end
        end
    end
    monthLast = month
    regionLast = regionNow

    debugLog("Current chances for region: "..regionNow.name..": "..regionNow.weatherChanceClear..", "..regionNow.weatherChanceCloudy..", "..regionNow.weatherChanceFoggy..", "..regionNow.weatherChanceOvercast..", "..regionNow.weatherChanceRain..", "..regionNow.weatherChanceThunder..", "..regionNow.weatherChanceAsh..", "..regionNow.weatherChanceBlight..", "..regionNow.weatherChanceSnow..", "..regionNow.weatherChanceBlizzard)

end

local function changeDaytime()

    local month = tes3.worldController.month.value
    local day = tes3.worldController.day.value

    ---
    local southY=-400000
    local northY=225000
    local minDaytime=4.0
    local solsticeSunrise=6.0
    local solsticeSunset=18.0
    local durSunrise=2.0
    local durSunset=2.0
    local playerY = tes3.player.position.y
    local adjustedSunrise, adjustedSunset, l1, f1, f2, f3


    l1 =  (((( month * 3042) / 100) + day) + 9)
	if (l1 > 365) then
		l1 = (l1 - 365)
	end
    l1 = (l1 - 182)
	if (l1 < 0) then
		l1 = (0 - l1)
	end

	f1 = ((l1 - 91.0 ) / 91.0)
	if (f1 < -1.0) then
		f1 = -1.0
	elseif (f1 > 1.0) then
		f1 = 1.0
	end

	f2 = ((playerY - southY) / (northY - southY))
	if (f2 < 0.0) then
		f2 = 0.0
	elseif (f2 > 1.0) then
		f2 = 1.0
	end

	f3 = ((solsticeSunset - solsticeSunrise )) -- -0.0 [???]
	if (minDaytime > f3) then
		minDaytime = f3
	end

    f3 = ( 0.0 - (f1 * f2 ))
    f1 = ((solsticeSunset - solsticeSunrise) - minDaytime)
    f1 = ((( f1  * f3) + solsticeSunset) - solsticeSunrise)
	if (f1 < minDaytime) then
		f1 = minDaytime
	end

	f2 = (24.0 - minDaytime)
	if (f1 > f2) then
		f1 = f2
	end

	f2 = (solsticeSunset - solsticeSunrise)
	adjustedSunrise = (solsticeSunrise - ((f1 - f2) / 2))
	adjustedSunset = (solsticeSunset + ((f1 - f2) / 2))
    adjustedSunset = (adjustedSunset - durSunset)

    debugLog("Previous values: "..WtC.sunriseHour.." "..WtC.sunriseDuration.." "..WtC.sunsetHour.." "..WtC.sunsetDuration)
    if  WtC.sunriseHour == math.ceil(adjustedSunrise) and
        WtC.sunsetHour == math.ceil(adjustedSunset) and
        WtC.sunriseDuration == math.ceil(durSunrise) and
        WtC.sunsetDuration == math.ceil(durSunset) then
            debugLog("No change needed. Returning.")
    else
        WtC.sunriseHour = math.ceil(adjustedSunrise)
        WtC.sunsetHour = math.ceil(adjustedSunset)
        WtC.sunriseDuration = math.ceil(durSunrise)
        WtC.sunsetDuration = math.ceil(durSunset)
        debugLog("Current values: "..WtC.sunriseHour.." "..WtC.sunriseDuration.." "..WtC.sunsetHour.." "..WtC.sunsetDuration)
    end
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
        monthLast = nil
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
        debugLog("Player in interior. Resuming interior timer. Hours to weather change: "..WtC.hoursBetweenWeatherChanges)
    end
end

local function seasonalTimer()
    monthLast = nil
    changeSeasonal()
    timer.start({duration=7, callback=changeSeasonal, iterations=-1, type=timer.game})
end

local function daytimeTimer()
    monthLast = nil
    changeDaytime()
    timer.start({duration=6, callback=changeDaytime, iterations=-1, type=timer.game})
end

local function init()
    if config.alterClouds then
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

    if config.alterClouds then
        event.register("weatherChangedImmediate", skyChoice, {priority=-150})
        event.register("weatherTransitionFinished", skyChoice, {priority=-150})
    end

    if interiorTransitions then
        event.register("cellChanged", onCellChanged, {priority=-150})
    end

end

event.register("initialized", init, {priority=-150})

-- Registers MCM menu --
event.register("modConfigReady", function()
    dofile("Data Files\\MWSE\\mods\\tew\\Watch the Skies\\mcm.lua")
end)
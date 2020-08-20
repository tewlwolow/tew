local weathers=require("tew\\Watch the Skies\\weathers")
local config=require("tew\\Watch the Skies\\config")
local debugLogOn=config.debugLogOn
local WtSdir="Data Files\\Textures\\tew\\Watch the Skies\\"
local vanChance=config.vanChance/100
local version = "1.0.0"

local function debugLog(string)
    if debugLogOn then
       mwse.log("[Watch the Skies "..version.."] "..string)
    end
end

local function skyChoice(e)
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
    tes3.getWorldController().weatherController.hoursBetweenWeatherChanges=math.random(3,12)
end

local function intTrans()
    local cell=tes3.getPlayerCell()
    if (cell.isInterior and not cell.behavesAsExterior and tes3.getWorldController().weatherController.lastActiveRegion) then
        tes3.getWorldController().weatherController:switchTransition(tes3.getWorldController().weatherController.lastActiveRegion.weather.index)
    end
end

local function init()
    print("Watch the Skies version "..version.." initialised.")
    for weather, index in pairs(tes3.weather) do
        debugLog("Weather: "..weather)
        for sky in lfs.dir(WtSdir..weather) do
            debugLog("Found file: "..sky)
            if string.endswith(sky, ".dds") or string.endswith(sky, ".tga") then
                table.insert(weathers[index], sky)
                debugLog("Adding file: "..sky)
            end
        end
    end
    for _, weather in pairs(tes3.getWorldController().weatherController.weathers) do
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

    event.register("weatherChangedImmediate", skyChoice, {priority=-100})
    event.register("weatherTransitionFinished", skyChoice, {priority=-100})
    event.register("weatherCycled", intTrans)
    event.register("weatherTransitionStarted", intTrans)
end

event.register("initialized", init)

-- Registers MCM menu --
event.register("modConfigReady", function()
    dofile("Data Files\\MWSE\\mods\\tew\\Watch the Skies\\mcm.lua")
end)
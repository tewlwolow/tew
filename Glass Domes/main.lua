local WtC
local plazaWeathers = {0,1,2,3,4,5}
local config = require("tew\\Glass Domes\\config")
local greenTint = config.greenTint
local debugLogOn = config.debugLogOn
local lastCell

local function isOpenPlaza(cell)
    if not cell.behavesAsExterior then
        return false
    else
        if (string.find(cell.name:lower(), "plaza") and string.find(cell.name:lower(), "vivec"))
        or string.find(cell.name:lower(), "arena pit") then
            return true
        else
            return false
        end
    end
end

local function debugLog(string)
    if debugLogOn then
       mwse.log("[Glass Domes: "..string)
    end
end

local tintGlass

local tintStrengths={
    ["Weak"] = {0.53574013710022,0.82729339599609,0.72401332855225},
    ["Moderate"] = {0.37413274645805,0.85105844736099,0.70162286758423},
    ["Strong"] = {0.21105913817883,0.86475539207458,0.68743902444839},
}

local function getTintStrength()
    for name, value in pairs(tintStrengths) do
        if name == config.tintStrength then
            tintGlass = value
        end
    end
end

local weatherTintsOld={
[0]={},
[1]={},
[2]={},
[3]={},
[4]={},
[5]={},
[6]={},
[7]={},
[8]={},
[9]={},
}

local function setTint(colour, tint)
    colour.r = tint[1]
    colour.g = tint[2]
    colour.b = tint[3]
end

local function onCellChanged(e)
    local cell = e.cell or tes3.getPlayerCell()
    local currentWeather = WtC.currentWeather
    local nextWeather = WtC.nextWeather

    if isOpenPlaza(cell)==false and isOpenPlaza(lastCell)==true and greenTint then
        debugLog("Reverting tint.")
        for _, w in pairs(WtC.weathers) do
            for wIndex, _ in pairs(weatherTintsOld) do
                if w.index == wIndex then
                    setTint(w.sunDayColor, weatherTintsOld[w.index][1])
                    debugLog("Reverting old tint for weather: ["..w.index.."], tint: sunDayColor.")
                    setTint(w.sunNightColor, weatherTintsOld[w.index][2])
                    debugLog("Reverting old tint for weather: ["..w.index.."], tint: sunNightColor.")
                    setTint(w.sunSunriseColor, weatherTintsOld[w.index][3])
                    debugLog("Reverting old tint for weather: ["..w.index.."], tint: sunSunriseColor.")
                    setTint(w.sunSunsetColor, weatherTintsOld[w.index][4])
                    debugLog("Reverting old tint for weather: ["..w.index.."], tint: sunSunsetColor.")
                end
            end
        end
    end

    if isOpenPlaza(cell)==true then
        if (currentWeather.index > 5)
        or (nextWeather and nextWeather.index > 5) then
            WtC:switchImmediate(3)
        end
        if greenTint and not string.find(cell.name:lower(), "arena pit") then
            local function getTint(weatherSunColour)
                return {weatherSunColour.r, weatherSunColour.g, weatherSunColour.b}
            end
            getTintStrength()
            timer.start{type=timer.real, duration=0.4, callback=function()
                for _, w in pairs(WtC.weathers) do
                    table.insert(weatherTintsOld[w.index], getTint(w.sunDayColor))
                    debugLog("Saving old tint for weather: ["..w.index.."], tint: sunDayColor.")
                    table.insert(weatherTintsOld[w.index], getTint(w.sunNightColor))
                    debugLog("Saving old tint for weather: ["..w.index.."], tint: sunNightColor.")
                    table.insert(weatherTintsOld[w.index], getTint(w.sunSunriseColor))
                    debugLog("Saving old tint for weather: ["..w.index.."], tint: sunSunriseColor.")
                    table.insert(weatherTintsOld[w.index], getTint(w.sunSunsetColor))
                    debugLog("Saving old tint for weather: ["..w.index.."], tint: sunSunsetColor.")
                    setTint(w.sunDayColor, tintGlass)
                    setTint(w.sunNightColor, tintGlass)
                    setTint(w.sunSunriseColor, tintGlass)
                    setTint(w.sunSunsetColor, tintGlass)
                    debugLog("Setting green tints for weather: ["..w.index.."].")
                end
            end}
        end
    end
    lastCell=cell
end

local function onWeatherTrans(e)
    local cell = tes3.getPlayerCell()
    if isOpenPlaza(cell) and e.to.index > 5 then
        WtC:switchTransition(plazaWeathers[math.random(1, #plazaWeathers)])
    end
end

local function init()
    WtC=tes3.getWorldController().weatherController
    event.register("weatherTransitionStarted", onWeatherTrans)
    event.register("cellChanged", onCellChanged)
end

event.register("initialized", init)

event.register("modConfigReady", function()
    dofile("Data Files\\MWSE\\mods\\tew\\Glass Domes\\mcm.lua")
end)
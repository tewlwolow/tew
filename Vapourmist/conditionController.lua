-- Condition controller

-->>>---------------------------------------------------------------------------------------------<<<--

local fogService = require("tew\\Vapourmist\\fogService")
local debugLog = fogService.debugLog
local data = require("tew\\Vapourmist\\data")


-- Check what weather we're transitioning to
local function weatherChangedCheck(e, weather, immediate)

    local to
    if e then
        to = e.to.index
    else
        to = weather
    end

    local gameHour = tes3.worldController.hour.value
    local time = fogService.getTime(gameHour)

    for _, fogType in pairs(data.fogTypes) do
        debugLog("Checking weather: "..to.." for "..fogType.name.." fog.")

        local options = {
            mesh = fogType.mesh,
            type = fogType.name,
            height = fogType.height,
            colours = fogType.colours,
            weather = to,
            time = time,
        }

        -- Check if we're transitioning to a weather that warrants post-rain mist
        if fogType.wetWeathers then
            for _, i in ipairs(fogType.wetWeathers) do
                if to == i then
                    debugLog("Weather: "..to..". Adding post-rain mist.")
                    fogService.addFog(options)
                    break
                end
            end
        end

        -- Check if we're transitioning to a weather that should be inactive
        for _, i in ipairs(fogType.blockedWeathers) do
            if to == i then
                if immediate then
                    debugLog("Weather: "..to..". Removing fogs immediately.")
                    fogService.removeFogImmediate(fogType)
                else
                    debugLog("Weather: "..to..". Removing fogs with fade out")
                    fogService.removeFog{
                        type = fogType.name,
                        weather = to,
                        time = time,
                        colours = fogType.colours,
                    }
                end
                return
            end
        end

        fogService.addFog(options)

    end

end

local function isWeatherBlocked(weather, blockedWeathers)
    for _, i in ipairs(blockedWeathers) do
        if weather == i then
            return true
        end
    end
    return false
end

-- Controls conditions and fog spawning/removing
local function conditionCheck(e)
    debugLog("Running check.")

    -- Get all data needed
    local cell = tes3.getPlayerCell()
    -- Sanity check
    if not cell then debugLog("No cell. Returning.") return end

    -- TODO: remove this once we have a proper interior cell solution
    if (cell.isInterior) and not (cell.behavesAsExterior) then debugLog("Interior cell. Returning.") return end

    -- Get game hour and time type
    local gameHour = tes3.worldController.hour.value
    local time = fogService.getTime(gameHour)
    -- Check weather
    local weatherNow = tes3.getRegion({useDoors=true}).weather.index

    for _, fogType in pairs(data.fogTypes) do

        -- Log fog type
        debugLog("Fog type: "..fogType.name)

        -- Remove fog from vfx root if we're transitioning from ext to int or vice versa
        if e and e.previousCell then
            if ((cell.isInterior) and (not e.previousCell.isInterior))
            or ((not cell.isInterior) and (e.previousCell.isInterior)) then
                debugLog("INT/EXT transition. Removing fog.")
                fogService.removeFog{
                    type = fogType.name,
                    weather = weatherNow,
                    time = time,
                    colours = fogType.colours,
                }
                return
            end
        end

        -- Do not readd fog if it's already there but do recolour it
        if (fogService.isCellFogged(cell, fogType.name)) then
            debugLog("Cell is fogged. Recolouring.")
            fogService.reColour{
                colours = fogType.colours,
                weather = weatherNow,
                time = time,
                type = fogType.name
            }
        else
            debugLog("Cell is not fogged. Removing all.")
            fogService.removeFogImmediate(fogType.name)
        end

        -- Check whether we can add the fog at this time
        if not (fogType.isAvailable(gameHour, weatherNow)) then
            debugLog("Fog: "..fogType.name.." not available.")
            fogService.removeFog{
                type = fogType.name,
                weather = weatherNow,
                time = time,
                colours = fogType.colours,
            }
            return
        end

        local options = {
            mesh = fogType.mesh,
            type = fogType.name,
            height = fogType.height,
            colours = fogType.colours,
            weather = weatherNow,
            time = time,
        }

        -- Bust out if we're not in the right weather
        debugLog("Weather: "..weatherNow..". Running weather check.")
        if isWeatherBlocked(weatherNow, fogType.blockedWeathers) then
            weatherChangedCheck(nil, weatherNow, false)
        else -- I wish there was a continue statement in lua
            -- At this point we're good to go
            -- Prepare options
            debugLog("Checks passed. Adding fog.")
            
            -- And pass to service
            fogService.addFog(options)
        end
    end

end

-- A timer needed to check for time changes
local function onLoaded()
    timer.start({duration = data.baseTimerDuration, callback = function() debugLog("--timer--") conditionCheck() end, iterations = -1, type = timer.game})
    debugLog("Timer started. Duration: "..data.baseTimerDuration)
    conditionCheck()
end

-- Register events
local function init()
    WtC = tes3.worldController.weatherController
    event.register("loaded", function() debugLog("--Loaded--") onLoaded() end)
    event.register("cellChanged", function() debugLog("--cellChanged--") conditionCheck() end)
    event.register("weatherChangedImmediate", function(e) debugLog("--weatherChangedImmediate--") weatherChangedCheck(e, nil, true) end)
    event.register("weatherTransitionImmediate", function(e) debugLog("--weatherTransitionImmediate--") weatherChangedCheck(e, nil, true) end)
    event.register("weatherTransitionStarted", function(e) debugLog("--weatherTransitionStarted--") weatherChangedCheck(e, nil, false) end)
end

-- Cuz SOLID, encapsulation blah blah blah
init()
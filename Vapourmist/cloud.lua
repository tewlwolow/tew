-- Cloud module

-->>>---------------------------------------------------------------------------------------------<<<--

local cloud, WtC, windDirection
local cloudyCells = {}
local config = require("tew\\Vapourmist\\config")
local common = require("tew\\Vapourmist\\common")
local debugLog = common.debugLog

local module = "CLOUD"

-- Table with blacklisted weather types
local BLOCKED_WEATHERS = {0, 6, 7}

local function reColour(weatherNow, time)

    debugLog(module, "Running colour change.")

    local weather
    for i, w in ipairs(WtC.weathers) do
        if i-1 == weatherNow then weather = w break end
    end

    for _, activeCell in ipairs(tes3.getActiveCells()) do
        for stat in activeCell:iterateReferences(tes3.objectType.static) do
            if stat.id == "tew_cloud" then
                for node in table.traverse({stat.sceneNode}) do
                    local materialProperty = node:getProperty(0x2)
                    if materialProperty then
                        local cloudColour
                        if time == "dawn" then
                            cloudColour = {weather.fogSunriseColor.r, weather.fogSunriseColor.g, weather.fogSunriseColor.b}
                        elseif time == "day" then
                            cloudColour = {weather.fogDayColor.r, weather.fogDayColor.g, weather.fogDayColor.b}
                        elseif time == "dusk" then
                            cloudColour = {weather.fogSunsetColor.r, weather.fogSunsetColor.g, weather.fogSunsetColor.b}
                        elseif time == "night" then
                            cloudColour = {weather.fogNightColor.r, weather.fogNightColor.g, weather.fogNightColor.b}
                        end

                         -- A bit of desaturation
                        for _, v in ipairs(cloudColour) do
                            v = v * 0.8
                            -- v = v - 0.1
                        end

                        local emissive = materialProperty.emissive
                        if time == "night" then
                            -- emissive.r, emissive.g, emissive.b = 0.06, 0.06, 0.06
                            emissive.r, emissive.g, emissive.b = table.unpack(cloudColour)
                        else
                            emissive.r, emissive.g, emissive.b = table.unpack(cloudColour)
                        end
                        materialProperty.emissive = emissive

                        local diffuse = materialProperty.diffuse
                        if time == "night" then
                            diffuse.r, diffuse.g, diffuse.b = 0.0, 0.0, 0.0
                        else
                            diffuse.r, diffuse.g, diffuse.b = table.unpack(cloudColour)
                        end
                        materialProperty.diffuse = diffuse

                        local ambient = materialProperty.ambient
                        ambient.r, ambient.g, ambient.b = table.unpack(cloudColour)
                        materialProperty.ambient = ambient

                        local specular = materialProperty.specular
                        if time == "night" then
                            specular.r, specular.g, specular.b = 0.0, 0.0, 0.0
                        else
                            specular.r, specular.g, specular.b = table.unpack(cloudColour)
                        end
                        materialProperty.specular = specular

                    end

                    node:updateEffects()
                    node:updateProperties()
                end
            end
        end
    end

end


-- Controls conditions and cloud spawning/removing
local function conditionCheck(e)
    debugLog(module, "Running check.")

    local cell = tes3.getPlayerCell()
  
    -- Sanity check
    if not cell then debugLog(module, "No cell. Returning.") return end

    if cell.name then debugLog(module, "Cell: "..cell.name) else debugLog(module, "Cell: Wilderness.") end

    if (cell.isInterior) and not (cell.behavesAsExterior) then debugLog(module, "Interior cell. Returning.") return end


    local gameHour = tes3.worldController.hour.value
    local time
    if (gameHour >= WtC.sunriseHour) and (gameHour < WtC.sunriseHour + 2) then
        time = "dawn"
    elseif (gameHour >= WtC.sunriseHour + 2) and (gameHour < WtC.sunsetHour - 1) then
        time = "day"
    elseif (gameHour >= WtC.sunsetHour - 1) and (gameHour < WtC.sunsetHour + 1) then
        time = "dusk"
    elseif (gameHour >= WtC.sunsetHour + 1) or (gameHour < WtC.sunriseHour) then
        time = "night"
    end

    -- Remove cloud from active cells if we're transitioning from ext to int or vice versa
    if e and e.previousCell then
        if ((cell.isInterior) and (not e.previousCell.isInterior))
        or ((not cell.isInterior) and (e.previousCell.isInterior)) then
            debugLog(module, "INT/EXT transition. Removing cloud.")
            common.removeFog(module)
        end
    end

    local weatherNow = tes3.getRegion({useDoors=true}).weather.index
    for _, i in ipairs(BLOCKED_WEATHERS) do
        if weatherNow == i then
            debugLog(module, "Weather: "..weatherNow..". Returning.")
            return
        end
    end

    -- Do not readd cloud if it's already there but do recolour it
    for stat in cell:iterateReferences(tes3.objectType.static) do
        if stat.id == "tew_cloud"
        and not stat.deleted then
            debugLog(module, "Already clouded cell. Recolouring only.")
            -- reColour(weatherNow, time)
            return
        end
    end

    local options = {
		weather = weatherNow,
		time = time,
		object = cloud,
		position = {
			first = {
				x = 0,
				y = 0,
				z = 3200
			},
		}
	}
	common.addFog(options)

end

local function weatherCheck(e)
    local to = e.to.index

    for _, i in ipairs(BLOCKED_WEATHERS) do
        if to == i then
            debugLog(module, "Weather: "..to..". Yeeting clouds.")
            common.moveYeet(module)
        end
    end

    conditionCheck(e)

end

-- A timer needed to check for time changes
local function runTimers()
    timer.start({duration = 0.5, callback = conditionCheck, iterations = -1, type = timer.game})
    debugLog(module, "Timer started.")
end

local function onLoaded()
    common.removeFog(module)
    timer.delayOneFrame(conditionCheck)
end

local function init()

    WtC = tes3.worldController.weatherController

    event.register("loaded", runTimers)
    event.register("loaded", onLoaded)
    event.register("cellChanged", conditionCheck)
    event.register("weatherChangedImmediate", weatherCheck)
    event.register("weatherTransitionStarted", weatherCheck)
    
    -- Create the cloud object
    cloud = tes3.createObject{
        objectType = tes3.objectType.static,
        id = "tew_cloud",
        mesh = "tew\\Vapourmist\\vapourcloud.nif",
        getIfExists = false
    }

end

init()
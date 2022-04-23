-- Mist module

-->>>---------------------------------------------------------------------------------------------<<<--

local mist, WtC
local mistyCells = {}

local config = require("tew\\Vapourmist\\config")

local common = require("tew\\Vapourmist\\common")
local debugLog = common.debugLog
local module = "MIST"


--[[local COLOURS = {
["day"] = {
    emissive = {0.79172962903976, 0.79172962903976, 0.79172962903976},
    diffuse = {0.7622644305229, 0.7622644305229, 0.76226443052292},
    ambient = {0.8188754320144, 0.81887543201447, 0.81887543201447},
    specular = {0.0, 0.0, 0.0}
    },
["night"]  = {
    emissive = {0.06, 0.06, 0.06},
    diffuse = {0.0, 0.0, 0.0},
    ambient = {0.0, 0.0, 0.0},
    specular = {0.0, 0.0, 0.0}
    }
}]]


-- Main control of mist amount
local CHANCE = 0.07

-- Main control of movement speed
-- Less = faster
local MOVE_SPEED = 30

-- Table with blacklisted weather types
local BLOCKED_WEATHERS = {4, 5, 6, 7, 8, 9}

local function reColour(weatherNow, time)

    debugLog(module, "Running colour change.")

    local weather
    for i, w in ipairs(WtC.weathers) do
        if i-1 == weatherNow then weather = w break end
    end

    for _, activeCell in ipairs(tes3.getActiveCells()) do
        for stat in activeCell:iterateReferences(tes3.objectType.static) do
            if stat.id == "tew_mist" then
                for node in table.traverse({stat.sceneNode}) do

                    local materialProperty = node:getProperty(0x2)
                    if materialProperty then
                        local mistColour
                        debugLog(module, "Time: "..time)

                        if time == "dawn" then
                            mistColour = {weather.fogSunriseColor.r, weather.fogSunriseColor.g, weather.fogSunriseColor.b}
                        elseif time == "day" then
                            mistColour = {weather.fogDayColor.r, weather.fogDayColor.g, weather.fogDayColor.b}
                        elseif time == "dusk" then
                            mistColour = {weather.fogSunsetColor.r, weather.fogSunsetColor.g, weather.fogSunsetColor.b}
                        elseif time == "night" then
                            mistColour = {weather.fogNightColor.r, weather.fogNightColor.g, weather.fogNightColor.b}
                        end

                        -- A bit of desaturation
                        for _, v in ipairs(mistColour) do
                            v = v * 0.6
                            -- v = v - 0.15
                        end

                        local emissive = materialProperty.emissive
                        if time == "night" then
                            emissive.r, emissive.g, emissive.b = 0.06, 0.06, 0.06
                        else
                            emissive.r, emissive.g, emissive.b = table.unpack(mistColour)
                        end
                        materialProperty.emissive = emissive

                        local diffuse = materialProperty.diffuse
                        if time == "night" then
                            diffuse.r, diffuse.g, diffuse.b = 0.0, 0.0, 0.0001
                        else
                            diffuse.r, diffuse.g, diffuse.b = table.unpack(mistColour)
                        end
                        materialProperty.diffuse = diffuse

                        local ambient = materialProperty.ambient
                        if time == "night" then
                            ambient.r, ambient.g, ambient.b = 0.0, 0.0, 0.00001
                        else
                            ambient.r, ambient.g, ambient.b = table.unpack(mistColour)
                        end
                        materialProperty.ambient = ambient

                        local specular = materialProperty.specular
                        if time == "night" then
                            specular.r, specular.g, specular.b = 0.0, 0.0, 0.00001
                        else
                            specular.r, specular.g, specular.b = table.unpack(mistColour)
                        end
                        materialProperty.specular = specular

                        node:updateEffects()
                        node:updateProperties()
                    end
                end
            end
        end
    end

end


-- Controls conditions and mist spawning/removing
local function conditionCheck(e)
    debugLog(module, "Running check.")

    local cell = e.cell or tes3.getPlayerCell()
  
    -- Sanity check
    if not cell then debugLog(module, "No cell. Returning.") return end

    if cell.name then debugLog(module, "Cell: "..cell.name) else debugLog(module, "Cell: Wilderness.") end

    if (cell.isInterior) and not (cell.behavesAsExterior) then debugLog(module, "Interior cell. Returning.") return end

    -- Check weather and remove mist if needed
    local weatherNow = tes3.getRegion({useDoors=true}).weather.index
    for _, i in ipairs(BLOCKED_WEATHERS) do
        if weatherNow == i then
            debugLog(module, "Uneligible weather detected. Removing mist.")
            common.removeFog(module)
            return
        end
    end

    -- Check time and remove mist if needed
    local gameHour = tes3.worldController.hour.value
    if ((gameHour >= WtC.sunriseHour + 2 and gameHour <= 24)
    or (gameHour >= 24 and gameHour < WtC.sunsetHour - 1))
    and (weatherNow ~= 2 or weatherNow ~= 3) then
        debugLog(module, "Uneligible time detected. Removing mist.")
        common.removeFog(module)
        return
    end

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

    -- Remove mist from active cells if we're transitioning from ext to int or vice versa
    if e.previousCell then
        if ((cell.isInterior) and (not e.previousCell.isInterior))
        or ((not cell.isInterior) and (e.previousCell.isInterior)) then
            debugLog(module, "INT/EXT transition. Removing mist.")
            common.removeFog(module)
        end
    end

    -- Do not readd mist if it's already there but do recolour it
    for stat in cell:iterateReferences(tes3.objectType.static) do
        if stat.id == "tew_mist"
        and not stat.deleted then
            debugLog(module, "Already misty cell. Updating colour and returning.")
            -- reColour(weatherNow, time)
            return
        end
    end

	local options = {
		type = module,
		weather = weatherNow,
		time = time,
		object = mist,
		limit = config.MIST_LIMIT,
		density = config.MIST_DENSITY,
		scale = {
			first = {6,10},
			second = {3,8}
		},
		position = {
			first = {
				x = {-20, 100},
				y = {-50,100},
				z = {100, 500}
			},
			second = {
				x = {100, 300},
				y = {-30, 400},
				z = {-100, 200}
			}
		}

	}
	common.addFog(options)

end

-- A timer needed to check for time changes
local function runHourTimer()
    timer.start({duration = 0.5, callback = conditionCheck, iterations = -1, type = timer.game})
	debugLog(module, "Timer started.")
end

local function onLoaded()
	runHourTimer()
	common.removeFog(module)
end

local function init()

    WtC = tes3.worldController.weatherController

    event.register("loaded", onLoaded)

    event.register("weatherChangedImmediate", conditionCheck)
    event.register("weatherTransitionStarted", conditionCheck)
    event.register("cellChanged", conditionCheck)

    -- Create the mist object
    mist = tes3.createObject{
        objectType = tes3.objectType.static,
        id = "tew_mist",
        mesh = "tew\\Vapourmist\\vapourmist.nif",
        getIfExists = false
    }


end

init()

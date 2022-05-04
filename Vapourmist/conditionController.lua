-- Condition controller

-->>>---------------------------------------------------------------------------------------------<<<--

local fogService = require("tew\\Vapourmist\\fogService")
local debugLog = fogService.debugLog
local data = require("tew\\Vapourmist\\data")

local fromTime, toTime, fromWeather, toWeather, fromRegion, toRegion


-- Controls conditions and fog spawning/removing
local function conditionCheck(e)

	debugLog("Running check.")

	-- Gets messy otherwise
	local mp = tes3.mobilePlayer
	if (not mp) or (mp and (mp.waiting or mp.traveling)) then
		debugLog("Player waiting or travelling. Returning.")
		return
	end

	-- Get all data needed
	local cell = tes3.getPlayerCell()
	-- Sanity check
	if not cell then debugLog("No cell. Returning.") return end

	-- TODO: remove this once we have a proper interior cell solution
	if (cell.isInterior) and not (cell.behavesAsExterior) then debugLog("Interior cell. Returning.") return end

	-- Get game hour and time type
	local gameHour = tes3.worldController.hour.value
	toTime = fogService.getTime(gameHour)
	if not fromTime then fromTime = toTime end

	-- Check weather
	fromWeather =  WtC.currentWeather
	toWeather = WtC.nextWeather or fromWeather

	local windVector = WtC.windVelocityCurrWeather:normalized()
	debug.log("Wind vector: " .. windVector.x .. ", " .. windVector.y .. ", " .. windVector.z)

	-- Check region
	toRegion = cell.region
	if not fromRegion then fromRegion = toRegion end

	debugLog("Weather: "..fromWeather.index.." -> "..toWeather.index)
	debugLog("Time: "..fromTime.." -> "..toTime)
	debugLog("Game hour: "..gameHour)
	debugLog("Region: "..fromRegion.id.." -> "..toRegion.id)


	-- Iterate through fog types
	for _, fogType in pairs(data.fogTypes) do

		-- Log fog type
		debugLog("Fog type: "..fogType.name)

		if fromWeather.index == toWeather.index
		and fromTime == toTime
		and fromRegion.id == toRegion.id
		and (fogService.isCellFogged(cell, fogType.name)) then
			debugLog("Conditions are the same. Returning.")
			break
		end

		local options = {
			mesh = fogType.mesh,
			type = fogType.name,
			height = fogType.height,
			colours = fogType.colours,
			fromWeather = fromWeather,
			toWeather = toWeather,
			fromTime = fromTime,
			toTime = toTime,
		}

		if (fogService.isCellFogged(cell, fogType.name)) and not (fogService.isFogAppculled(fogType.name)) then
			debugLog("Cell already fogged and not appculled. Recolouring.")
			fogService.reColour(options)
		end

		-- Check whether we can add the fog at this time
		if not (fogType.isAvailable(gameHour, toWeather)) then
			debugLog("Fog: "..fogType.name.." not available.")
			fogService.removeFog(options)
			break
		end

		debugLog("Checks passed. Adding fog.")
		if WtC.nextWeather and WtC.transitionScalar < 0.6 then
			debugLog("Weather transition in progress. Adding fog in a bit.")
			timer.start {
				type = timer.game,
				iterations = 1,
				duration = 0.3,
				callback = function() fogService.addFog(options) end
			}
		else
			fogService.addFog(options)
		end
	end

	fromWeather = toWeather
	fromTime = toTime
	fromRegion = toRegion

end

-- On travelling, waiting etc.
local function onImmediateChange()

	fromWeather = WtC.currentWeather
	toWeather = WtC.nextWeather or fromWeather

	 -- Get game hour and time
	 local gameHour = tes3.worldController.hour.value
	 toTime = fogService.getTime(gameHour)

	 -- Iterate through fog types
	for _, fogType in pairs(data.fogTypes) do
		debugLog("Checking conditions for "..fogType.name..".")

		fogService.removeFogImmediate{
			fromTime = fromTime,
			toTime = toTime,
			fromWeather = fromWeather,
			toWeather = toWeather,
			colours = fogType.colours,
			type = fogType.name,
		}
	end

	conditionCheck()

end


local function onWeatherChanged(e)
	if data.fogTypes["mist"].wetWeathers[e.from.index] then

		debugLog("Adding post-rain mist.")

		local options = {
			mesh = data.fogTypes["mist"].mesh,
			type = data.fogTypes["mist"].name,
			height = data.fogTypes["mist"].height,
			colours = data.fogTypes["mist"].colours,
			toWeather = e.to,
			toTime = fogService.getTime(tes3.worldController.hour.value),
		}

		timer.start {
			type = timer.game,
			iterations = 1,
			duration = 0.3,
			callback = function() fogService.addFog(options) end
		}
		
	end
end

-- A timer needed to check for time changes
local function onLoaded()
	timer.start({duration = data.baseTimerDuration, callback = function() debugLog("================== timer ==================") conditionCheck() end, iterations = -1, type = timer.game})
	debugLog("Timer started. Duration: "..data.baseTimerDuration)
end

-- Register events
local function init()
	WtC = tes3.worldController.weatherController
	event.register("loaded", function() debugLog("================== loaded ==================") onLoaded() end)
	event.register("cellChanged", function() debugLog("================== cellChanged ==================") conditionCheck() end)
	event.register("weatherChangedImmediate", function() debugLog("================== weatherChangedImmediate ==================") onImmediateChange() end)
	event.register("weatherTransitionImmediate", function() debugLog("================== weatherTransitionImmediate ==================") onImmediateChange() end)
	event.register("weatherTransitionStarted", function() debugLog("================== weatherTransitionStarted ==================") conditionCheck() end, {priority = 100})
	event.register("weatherTransitionStarted", function(e) debugLog("================== weatherTransitionStarted ==================") onWeatherChanged(e) end, {priority = 120})

end

-- Cuz SOLID, encapsulation blah blah blah
init()
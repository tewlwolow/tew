-- Condition controller

-->>>---------------------------------------------------------------------------------------------<<<--

local fogService = require("tew\\Vapourmist\\fogService")
local debugLog = fogService.debugLog
local config = require("tew\\Vapourmist\\config")
local data = require("tew\\Vapourmist\\data")

local toFogColour, toWeather, toRegion, fromFogColour, fromWeather, fromRegion, recolourRegistered

local WtC

-- Check for interior cells
local function interiorCheck(cell)
	debugLog("Starting interior check.")

	if data.interiorFog.isAvailable(cell) and not fogService.isCellFogged(cell, data.interiorFog.name) then

		local options = {
			height = data.interiorFog.height,
			cell = cell,
		}

		fogService.addInteriorFog(options)
	end
end

-- Controls conditions and fog spawning/removing
local function conditionCheck()
	-- Gets messy otherwise
	local mp = tes3.mobilePlayer
	if (not mp) or (mp and (mp.waiting or mp.traveling)) then
		local gameHour = tes3.worldController.hour.value
		toWeather = WtC.nextWeather or WtC.currentWeather
		for _, fogType in pairs(data.fogTypes) do
			if not (fogType.isAvailable(gameHour, toWeather)) then
				debugLog("Player waiting or travelling and fog: "..fogType.name.." not available.")
				fogService.removeFogImmediate(fogType.name)
			end
		end
		return
	end

	fogService.cleanInactiveFog()
	debugLog("Running check.")

	-- Get all data needed
	local cell = tes3.getPlayerCell()
	-- Sanity check
	if not cell then debugLog("No cell. Returning.") return end

	if not (cell.isOrBehavesAsExterior) then
		fogService.removeAllExterior()
		if config.interiorFog then
			interiorCheck(cell)
		end
		return
	end

	-- Get game hour and time type
	local gameHour = tes3.worldController.hour.value
	toFogColour = WtC.currentFogColor:copy()
	fromFogColour = fromFogColour or toFogColour:copy()

	-- Check weather
	toWeather = WtC.nextWeather or WtC.currentWeather
	fromWeather = fromWeather or WtC.currentWeather

	-- Check region
	toRegion = cell.region
	fromRegion = fromRegion or toRegion

	debugLog("Weather: "..fromWeather.name.." -> "..toWeather.name)
	debugLog("Game hour: "..gameHour)
	debugLog("Fog colour: "..tostring(fromFogColour).." -> "..tostring(toFogColour))
	debugLog("Region: "..fromRegion.id.." -> "..toRegion.id)
		
	-- Iterate through fog types
	for _, fogType in pairs(data.fogTypes) do

		-- Log fog type
		debugLog("Fog type: "..fogType.name)
		
		local options = {
			type = fogType.name,
			height = fogType.height,
		}

		-- Check whether we can add the fog at this time
		if not (fogType.isAvailable(gameHour, toWeather)) then
			debugLog("Fog: "..fogType.name.." not available.")
			fogService.removeFog(fogType.name)
			goto continue
		end

		debugLog("Checks passed. Resetting and adding fog.")

		if WtC.nextWeather and WtC.transitionScalar < 0.6 then
			debugLog("Weather transition in progress. Adding fog in a bit.")
			timer.start {
				type = timer.game,
				iterations = 1,
				duration = 0.2,
				callback = function() fogService.addFog(options) end
			}
		else
			fogService.addFog(options)
		end

		:: continue ::
	end

	fromWeather = toWeather
	fromFogColour = toFogColour
	fromRegion = toRegion

end

local function onWeatherChanged(e)
	if data.fogTypes["mist"].wetWeathers[e.from.name] then

		debugLog("Adding post-rain mist.")

		local options = {
			type = data.fogTypes["mist"].name,
			height = data.fogTypes["mist"].height,
		}

		timer.start {
			type = timer.game,
			iterations = 1,
			duration = 0.001,
			callback = function() fogService.addFog(options) end
		}
		
	end
end

-- A timer needed to check for time changes
local function onLoaded()
	if not recolourRegistered then
		event.register("enterFrame", fogService.reColour)
		recolourRegistered = true
	end
	timer.start({duration = data.baseTimerDuration, callback = function() debugLog("================== timer ==================") conditionCheck() end, iterations = -1, type = timer.game})
	debugLog("Timer started. Duration: "..data.baseTimerDuration)
	fromWeather = nil
	fromFogColour = nil
	fromRegion = nil
	fogService.removeAll()
end

local function waitCheck(e)
	local element=e.element
	element:registerAfter("destroy", function()
        timer.start{
            type=timer.game,
            duration = 0.01,
            callback = conditionCheck
        }
    end)
end

-- Register events
local function init()
	for _, fogType in pairs(data.fogTypes) do
		fogService.meshes[fogType.name] = tes3.loadMesh(fogType.mesh)
	end
	fogService.meshes[data.interiorFog.name] = tes3.loadMesh(data.interiorFog.mesh)
	WtC = tes3.worldController.weatherController
	event.register("loaded", function() debugLog("================== loaded ==================") onLoaded() end)
	event.register("cellChanged", function() debugLog("================== cellChanged ==================") conditionCheck() end, {priority = 500})
	event.register("weatherChangedImmediate", function() debugLog("================== weatherChangedImmediate ==================") conditionCheck() end, {priority = 500})
	event.register("weatherTransitionImmediate", function() debugLog("================== weatherTransitionImmediate ==================") conditionCheck() end, {priority = 500})
	event.register("weatherTransitionStarted", function() debugLog("================== weatherTransitionStarted ==================") conditionCheck() end, {priority = 500})
	event.register("weatherTransitionStarted", function(e) debugLog("================== weatherTransitionStarted ==================") onWeatherChanged(e) end, {priority = 500})
	event.register("weatherTransitionFinished", function() debugLog("================== weatherTransitionFinished ==================") conditionCheck() end, {priority = 500})
	event.register("uiActivated", waitCheck, {filter="MenuTimePass", priority = -5})
end

init()
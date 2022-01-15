local climates = require("tew\\AURA\\Ambient\\Outdoor\\outdoorClimates")
local config = require("tew\\AURA\\config")
local modversion = require("tew\\AURA\\version")
local common=require("tew\\AURA\\common")
local tewLib = require("tew\\tewLib\\tewLib")
local sounds = require("tew\\AURA\\sounds")

local isOpenPlaza=tewLib.isOpenPlaza
--local getInteriorRegion = common.getInteriorRegion

local moduleAmbientOutdoor=config.moduleAmbientOutdoor
local moduleInteriorWeather=config.moduleInteriorWeather
local playSplash=config.playSplash
local debugLogOn = config.debugLogOn
local quietChance=config.quietChance/100
local OAvol = config.OAvol/200
local splashVol = config.splashVol/200
local playWindy=config.playWindy
local playInteriorAmbient=config.playInteriorAmbient
local version = modversion.version

local moduleName = "outdoor"

local climateLast, weatherLast, timeLast, cellLast
local climateNow, weatherNow, timeNow

local windoors, interiorTimer

local function debugLog(string)
	if debugLogOn then
		mwse.log("[AURA "..version.."] OA: "..string.format("%s", string))
	end
end

local function weatherParser(options)

	local volume, pitch, ref, immediate

	if not options then
		volume = OAvol
		pitch = 1
		ref = tes3.player
		immediate = false
	else
		volume = options.volume or OAvol
		pitch = options.pitch or 1
		ref = options.reference or tes3.player
		immediate = options.immediate or false
	end

	if weatherNow >= 0 and weatherNow <4 then
		if quietChance<math.random() then
			debugLog("Playing regular weather track.")
			if immediate then
				sounds.playImmediate{module = moduleName, reference = ref, climate = climateNow, time = timeNow, volume = volume, pitch = pitch}
			else
				sounds.play{module = moduleName, reference = ref, climate = climateNow, time = timeNow, volume = volume, pitch = pitch}
			end
		else
			debugLog("Playing quiet weather track.")
			if immediate then
				sounds.playImmediate{module = moduleName, reference = ref, volume = volume, type = "quiet", pitch = pitch}
			else
				sounds.play{module = moduleName, reference = ref, volume = volume, type = "quiet", pitch = pitch}
			end
		end
	elseif (weatherNow >= 4 and weatherNow < 6) or (weatherNow == 8) then
		if playWindy then
			debugLog("Bad weather detected and windy option on.")
			if weatherNow == 3 or weatherNow == 4 then
				debugLog("Found warm weather, using warm wind loops.")
				if immediate then
					sounds.playImmediate{module = moduleName, reference = ref, volume = volume, type = "warm", pitch = pitch}
				else
					sounds.play{module = "outdoor",reference = ref, volume = volume, type = "warm", pitch = pitch}
				end
			elseif weatherNow == 8 or weatherNow == 5 then
				debugLog("Found cold weather, using cold wind loops.")
				if immediate then
					sounds.playImmediate{module = moduleName, reference = ref, volume = volume, type = "cold", pitch = pitch}
				else
					sounds.play{module = "outdoor",reference = ref, volume = volume, type = "cold", pitch = pitch}
				end
			end
		else
			debugLog("Bad weather detected and no windy option on. Returning.")
			return
		end
	elseif weatherNow == 6 or weatherNow == 7 or weatherNow == 9 then
		debugLog("Extreme weather detected.")
		sounds.remove{module = moduleName}
		return
	end
end

local function playInteriorBig(windoor)
	if windoor==nil then debugLog("Dodging an empty ref.") return end
	if cellLast and not cellLast.isInterior then
		debugLog("Playing interior ambient sounds for big interiors using old track.")
		sounds.playImmediate{module = moduleName, last = true, reference = windoor, volume = 0.35*OAvol, pitch=0.8}
	else
		debugLog("Playing interior ambient sounds for big interiors using new track.")
		weatherParser{reference = windoor, volume = 0.35*OAvol, pitch = 0.8, immediate = true}
	end
end

local function updateInteriorBig()
	debugLog("Updating interior doors and windows.")
	local playerPos=tes3.player.position
	for _, windoor in ipairs(windoors) do
		if common.getDistance(playerPos, windoor.position) > 2048
		and windoor~=nil then
			playInteriorBig(windoor)
		end
	end
end

local function playInteriorSmall()
	if cellLast and not cellLast.isInterior then
		debugLog("Playing interior ambient sounds for small interiors using old track.")
		sounds.playImmediate{module = moduleName, last = true, volume = 0.3*OAvol, pitch=0.8}
	else
		debugLog("Playing interior ambient sounds for small interiors using new track.")
		weatherParser{volume = 0.3*OAvol, pitch = 0.8, immediate = true}
	end
end

local function cellCheck()

	-- Gets messy otherwise
	if tes3.mobilePlayer.waiting then
		debugLog("Player waiting. Returning.")
		timer.start({duration=3, callback=cellCheck, type=timer.real})
		return
	end

	local region
	
	OAvol = config.OAvol/200
	
	debugLog("Cell changed or time check triggered. Running cell check.")
	
	-- Getting rid of timers on cell check --
	if not interiorTimer then
		interiorTimer = timer.start({duration=1, iterations=-1, callback=updateInteriorBig, type=timer.real})
		interiorTimer:pause()
	else
		interiorTimer:pause()
	end
	
	local cell = tes3.getPlayerCell()
	if cell == nil then debugLog("No cell detected. Returning.") return end
	
	if cell.isInterior then
		region = tes3.getRegion({useDoors=true}).name
	else
		region = tes3.getRegion().name
	end
	
	if region == nil then debugLog("No region detected. Returning.") return end
	
	-- Checking climate --
	for kRegion, vClimate in pairs(climates.regions) do
		if kRegion==region then
			climateNow=vClimate
		end
	end
	if not climateNow then debugLog ("Blacklisted region - no climate detected. Returning.") return end
	debugLog("Climate: "..climateNow)
	
	-- Checking time --
	local gameHour=tes3.worldController.hour.value
	if gameHour >= 5 and gameHour <= 8 then
		timeNow="sr"
	elseif gameHour >= 18 and gameHour <= 21  then
		timeNow="ss"
	elseif gameHour > 8 and gameHour < 18 then
		timeNow="d"
	elseif gameHour < 5 or gameHour > 21 then
		timeNow="n"
	end
	debugLog("Time: "..timeNow)
	
	-- Checking current weather --
	weatherNow = tes3.getRegion({useDoors=true}).weather.index
	debugLog("Weather: "..weatherNow)
	
	-- Transition filter chunk --
	if timeNow==timeLast
	and climateNow==climateLast
	and weatherNow==weatherLast
	and (common.checkCellDiff(cell, cellLast)==false
	or cell == cellLast) then
		debugLog("Same conditions detected. Returning.")
		return
	elseif timeNow~=timeLast and weatherNow==weatherLast then
		if (weatherNow >= 4 and weatherNow < 6) or (weatherNow == 8) then
			debugLog("Same conditions detected. Returning.")
			return
		end
	end
	
	debugLog("Different conditions detected. Resetting sounds.")
	
	if moduleInteriorWeather == false and windoors[1]~=nil and weatherNow<4 or weatherNow==8 then
		for _, windoor in ipairs(windoors) do
			-- Not using sounds lib because we actually want to clear ALL sounds on ref
			tes3.removeSound{reference=windoor}
		end
		debugLog("Clearing windoors.")
	end
	
	-- TODO: move the check to sounds.lua maybe?
	-- Seems too complicated for new implementation. Consider dropping.
	-- Playing appropriate track per conditions detected --
	-- if cellLast and common.checkCellDiff(cell, cellLast)==true and timeNow==timeLast
	-- and weatherNow==weatherLast and climateNow==climateLast then
	-- 	-- Using the same track when entering int/ext in same area; time/weather change will randomise it again --
	-- 	debugLog("Found same cell. Immediately playing last sound.")
	-- 	sounds.playImmediate{last = true, volume = OAvol}
	-- end

	if not cell.isInterior
	or (cell.isInterior) and (cell.behavesAsExterior
	and not isOpenPlaza(cell)) then
		debugLog("Found exterior cell.")
		weatherParser()
	elseif cell.isInterior then
		if (not playInteriorAmbient) or (playInteriorAmbient and isOpenPlaza(cell) and weatherNow==3) then
			debugLog("Found interior cell. Removing sounds.")
			sounds.removeImmediate{module = moduleName}
		else
			if common.getCellType(cell, common.cellTypesSmall)==true
			or common.getCellType(cell, common.cellTypesTent)==true then
				sounds.removeImmediate{module = moduleName}
				playInteriorSmall()
				debugLog("Found small interior cell. Playing interior loops.")
			else
				sounds.removeImmediate{module = moduleName}
				windoors=nil
				windoors=common.getWindoors(cell)
				if windoors ~= nil then
					for _, windoor in ipairs(windoors) do
						playInteriorBig(windoor)
					end
					interiorTimer:resume()
					debugLog("Found big interior cell. Playing interior loops.")
				end
			end
		end
	end
		
	timeLast=timeNow
	climateLast=climateNow
	weatherLast=weatherNow
	cellLast=cell
	debugLog("Cell check complete.")
end

local function positionCheck(e)
	local cell=tes3.getPlayerCell()
	local element=e.element
	debugLog("Player underwater. Stopping AURA sounds.")
	if (not cell.isInterior) or (cell.behavesAsExterior) then
		sounds.removeImmediate{module = moduleName}
		sounds.playImmediate{module = moduleName, last = true, volume = 0.4*OAvol, pitch=0.5, reference = cell}
	end
	if playSplash and moduleAmbientOutdoor then
		tes3.playSound{sound="splash_lrg", volume=0.5*splashVol, pitch=0.6}
	end
	element:register("destroy", function()
		debugLog("Player above water level. Resetting AURA sounds.")
		if (not cell.isInterior) or (cell.behavesAsExterior) then
			sounds.removeImmediate{module = moduleName}
			sounds.playImmediate{module = moduleName, last = true, volume = OAvol, reference = cell}
		end
		timer.start({duration=1, callback=cellCheck, type=timer.real})
		if playSplash and moduleAmbientOutdoor then
			tes3.playSound{sound="splash_sml", volume=0.6*splashVol, pitch=0.7}
		end
	end)
end

local function runResetter()
	climateLast, weatherLast, timeLast = nil, nil, nil
	climateNow, weatherNow, timeNow = nil, nil, nil
	windoors = {}
end

local function runHourTimer()
	timer.start({duration=0.5, callback=cellCheck, iterations=-1, type=timer.game})
end

debugLog("Outdoor Ambient Sounds module initialised.")
event.register("loaded", runHourTimer, {priority=-160})
event.register("load", runResetter, {priority=-160})
event.register("cellChanged", cellCheck, {priority=-160})
event.register("weatherTransitionFinished", cellCheck, {priority=-160})
event.register("weatherChangedImmediate", cellCheck, {priority=-160})
event.register("uiActivated", positionCheck, {filter="MenuSwimFillBar", priority = -5})
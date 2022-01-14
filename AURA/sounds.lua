-- Library packaging
local this={}

-- Imports
local config = require("tew\\AURA\\config")
local modversion = require("tew\\AURA\\version")

-- Namespacing
local debugLogOn = config.debugLogOn
local version = modversion.version

-- Logger
local function debugLog(string)
	if debugLogOn then
		mwse.log("[AURA "..version.."] Sounds: "..string.format("%s", string))
	end
end

-- Paths
local AURAdir = "Data Files\\Sound\\tew\\A"
local soundDir = "tew\\A"
local climDir = "\\C\\"
local comDir = "\\S\\"
local quietDir = "q"
local warmDir = "w"
local coldDir = "c"

-- Constants
local STEP = 0.05
local MIN = 0
local MAX = 1

-- Array attributes
local clear = {}
local quiet = {}
local warm = {}
local cold = {}

-- Custom event handling
local crossfadeTimer
local fadeoutTimer
local fadeinTimer

local trackOld
local trackNew

local currentVolumeDown, currentVolumeUp = 0, 0

-- Utilities --
local function safeRemoveTimer(tim)
	if tim then
		tim:pause()
		tim:cancel()
	end
	tim = nil
	debugLog("Timer removed.")
end

-- Building tables --
local function buildClearSounds()
	-- Building clear paths array --
	debugLog("|---------------------- Building clear weather table. ----------------------|\n")
	for climate in lfs.dir(AURAdir..climDir) do
		if climate ~= ".." and climate ~= "." then
			clear[climate]={}
			for time in lfs.dir(AURAdir..climDir..climate) do
				if time ~= ".." and time ~= "." then
					clear[climate][time]={}
					for rSoundfile in lfs.dir(AURAdir..climDir..climate.."\\"..time) do
						if rSoundfile ~= ".." and rSoundfile ~= "." then
							if string.endswith(rSoundfile, ".wav") then
								local objectId = string.sub(climate.."_"..time.."_"..rSoundfile, 1, -5)
								local filename = soundDir..climDir..climate.."\\"..time.."\\"..rSoundfile
								debugLog("Adding file: "..rSoundfile)
								debugLog("File id: "..objectId)
								debugLog("Filename: "..filename.."\n---------------")
								local sound = tes3.createObject({
									id = objectId,
									objectType = tes3.objectType.sound,
									filename = filename,
								})
								table.insert(clear[climate][time], sound)
							end
						end
					end
				end
			end
		end
	end
end

local function buildContextSounds(dir, array)
	debugLog("|---------------------- Building '"..dir.."' weather table. ----------------------|\n")
	for soundFile in lfs.dir(AURAdir..comDir..dir) do
		if string.endswith(soundFile, ".wav") then
			local objectId = string.sub("S".."_"..dir.."_"..soundFile, 1, -5)
			local filename = soundDir..comDir.."\\"..dir.."\\"..soundFile
			debugLog("Adding file: "..soundFile)
			debugLog("File id: "..objectId)
			debugLog("Filename: "..filename.."\n---------------")
			local sound = tes3.createObject({
				id = objectId,
				objectType = tes3.objectType.sound,
				filename = filename,
			})
			table.insert(array, sound)
		end
	end
end

-- Play/Stop handling --
local function fadeIn(ref, volume)
	debugLog("Running fader - fade in.")

	if not trackNew then safeRemoveTimer(fadeinTimer) return end

	if tes3.getSoundPlaying{sound = trackNew} then
		debugLog("In playing.")
	else
		debugLog("In not playing.")
		safeRemoveTimer(fadeinTimer)
		return
	end

	if currentVolumeUp >= volume then
		safeRemoveTimer(fadeinTimer)
		trackOld = trackNew
		trackNew = nil
		currentVolumeUp = MIN
	else
		currentVolumeUp = currentVolumeUp + STEP

		tes3.adjustSoundVolume{sound = trackNew, volume = currentVolumeUp, reference = ref}

		debugLog("Adjusting volume: "..tostring(currentVolumeUp))
	end

end

local function fadeOut(ref)
	debugLog("Running fader - fade out.")
	if not trackNew then safeRemoveTimer(fadeoutTimer) return end

	if tes3.getSoundPlaying{sound = trackNew} then
		debugLog("In playing.")
	else
		debugLog("In not playing.")
		safeRemoveTimer(fadeoutTimer)
		return
	end

	debugLog("Volume in: "..trackNew.volume)

	if currentVolumeDown <= MIN then
		tes3.removeSound{sound = trackNew, reference = ref}
		debugLog(trackNew.id.." removed.\n")
		safeRemoveTimer(fadeoutTimer)
		trackOld = trackNew
		trackNew = nil
		currentVolumeDown = MIN
	else
		currentVolumeDown = currentVolumeDown - STEP

		tes3.adjustSoundVolume{sound = trackNew, volume = currentVolumeDown, reference = ref}

		debugLog("Adjusting volume: "..tostring(currentVolumeDown))
	end

end

local function crossFade(ref, volume)
	debugLog("Running fader - crossfade.")
	if not trackNew or not trackOld then safeRemoveTimer(crossfadeTimer) return end

	if tes3.getSoundPlaying{sound = trackOld} then
		debugLog("Out playing.")
	else
		debugLog("Out not playing.")
		safeRemoveTimer(crossfadeTimer)
		return
	end

	if tes3.getSoundPlaying{sound = trackNew} then
		debugLog("In playing.")
	else
		debugLog("In not playing.")
		safeRemoveTimer(crossfadeTimer)
		return
	end

	if currentVolumeUp >= volume then
		tes3.removeSound{sound = trackOld, reference = ref}
		debugLog(trackOld.id.." removed.\n")

		safeRemoveTimer(crossfadeTimer)

		currentVolumeDown, currentVolumeUp = 0, 0
	else
		local volumeOut = currentVolumeDown - STEP
		local volumeIn = currentVolumeUp + STEP

		tes3.adjustSoundVolume{sound = trackOld, volume = volumeOut, reference = ref}
		tes3.adjustSoundVolume{sound = trackNew, volume = volumeIn, reference = ref}

		debugLog("Adjusting volume down: "..tostring(currentVolumeDown))
		debugLog("Adjusting volume up: "..tostring(currentVolumeUp))

	end

end

function this.removeSoundImmediate(options)
	if not trackNew then debugLog("No track playing. Returning.") return end

	local ref = options.reference or tes3.player
	tes3.removeSound{sound = trackNew, reference = ref}
	trackOld = trackNew
	trackNew = nil
end

function this.removeSound(options)

	if not trackNew then debugLog("No track playing. Returning.") return end

	local ref = options.reference or tes3.player

	local function callback()

		debugLog("Sound out: "..trackNew.id.."\n")

		local callbackFader = function() crossFade(ref) end
		
		fadeoutTimer = timer.start{
			iterations = -1,
			duration = 0.7,
			callback = callbackFader
		}
		
	end

	timer.delayOneFrame(callback)

end

function this.playImmediate(options)

	-- if options.module == "outdoor"
	if options.last then
		tes3.playSound {
			sound = trackNew,
			loop = true,
			reference = options.reference,
			volume = options.volume or 1.0,
			pitch = options.pitch or 1.0
		}
	end

	-- Check for ref, use cell if not specified
	local ref = options.reference or tes3.player

	if options.type == "last" then
		-- tes3.removeSound{sound = trackNew, reference = options.previousRef}
		tes3.playSound {
			sound = trackNew,
			loop = true,
			reference = ref,
			volume = options.volume or 1.0,
			pitch = options.pitch or 1.0
		}
	end

end

-- Supporting kwargs here
function this.play(options)

	-- Check for ref, use cell if not specified
	local ref = options.reference or tes3.player

	-- Determine which table to use --
	local table
	if not options.climate or not options.time then
		if options.type == "quiet" then
			table = quiet
		elseif options.type == "warm" then
			table = warm
		elseif options.type == "cold" then
			table = cold
		end
	else
		local climate = options.climate
		local time = options.time
		table = clear[climate][time]
	end

	trackOld = trackNew
	trackNew = table[math.random(1, #table)]

	local volume = options.volume or MAX
	debugLog("Max volume: "..tostring(volume))

	tes3.playSound {
		sound = trackNew,
		loop = true,
		reference = ref,
		volume = MIN,
		pitch = options.pitch or 1.0
	}

	if not trackOld then
		fadeinTimer = timer.start{
			iterations = -1,
			duration = 1,
			callback = function() fadeIn(ref, volume) end
		}
	else
		crossfadeTimer = timer.start{
			iterations = -1,
			duration = 1,
			callback = function() crossFade(ref, volume) end
		}
	end

end

function this.build()
	buildClearSounds()
	buildContextSounds(quietDir, quiet)
	buildContextSounds(warmDir, warm)
	buildContextSounds(coldDir, cold)

	debugLog("|---------------------- Finished building sound objects. ----------------------|\n")
end

return this
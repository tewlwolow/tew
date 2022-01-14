-- TODO: Figure out timers in outdoorMain -> too many calls, should not fade out that much on waiting

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
local TICK = 0.4
local MAX = 1
local MIN = 0

-- Array attributes
local clear = {}
local quiet = {}
local warm = {}
local cold = {}

-- Only need those for outdoorMain actually
local trackOld
local trackNew

-- Building tables --

-- General climate/time table --
local function buildClearSounds()
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

-- Weather-specific --
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
	if not trackNew then return end

	local TIME = math.ceil((volume/STEP)*TICK)
	local ITERS = math.ceil(volume/STEP)
	local runs = 1

	local function fader()
		local incremented = STEP*runs

		if not tes3.getSoundPlaying{sound = trackNew} then
			debugLog("In not playing: "..trackNew.id)
			return
		end

		tes3.adjustSoundVolume{sound = trackNew, volume = incremented, reference = ref}
		debugLog("Adjusting volume in: "..tostring(incremented))
		runs = runs + 1
	end

	local function queuer()
		trackOld = trackNew
		debugLog("Fade in finished in: "..tostring(TIME).." s.")
	end

	debugLog("Iterations: "..tostring(ITERS))
	debugLog("Time: "..tostring(TIME))

	timer.start{
		iterations = ITERS,
		duration = TICK,
		callback = fader
	}

	timer.start{
		iterations = 1,
		duration = TIME,
		callback = queuer
	}
end

local function fadeOut(ref, volume, track)
	debugLog("Running fader - fade out.")
	if not track then return end

	local TIME = math.ceil((volume/STEP)*TICK)
	local ITERS = math.ceil(volume/STEP)
	local runs = ITERS

	local function fader()
		local incremented = STEP*runs

		if not tes3.getSoundPlaying{sound = track} then
			debugLog("Out not playing: "..track.id)
			return
		end

		tes3.adjustSoundVolume{sound = track, volume = incremented, reference = ref}
		debugLog("Adjusting volume out: "..tostring(incremented))
		runs = runs - 1
	end

	local function queuer()
		trackOld = track
		debugLog("Fade out finished in: "..tostring(TIME).." s.")
	end

	debugLog("Iterations: "..tostring(ITERS))
	debugLog("Time: "..tostring(TIME))

	timer.start{
		iterations = ITERS,
		duration = TICK,
		callback = fader
	}

	timer.start{
		iterations = 1,
		duration = TIME,
		callback = queuer
	}
end

local function crossFade(ref, volume)
	fadeOut(ref, volume, trackNew)
	fadeIn(ref, volume)
end

function this.removeSoundImmediate(options)
	local ref = options.reference or tes3.player
	local track = options.track or trackNew
	
	tes3.removeSound{sound = track, reference = ref}
	trackOld = trackNew
end

function this.removeSound(options)
	local ref = options.reference or tes3.player
	local volume = options.volume or MAX
	local track = options.track or trackNew

	fadeOut(ref, volume, track)
end

function this.playImmediate(options)
	
	local volume = options.volume or MAX

	-- if options.module == "outdoor"
	if options.last then
		tes3.playSound {
			sound = trackNew,
			loop = true,
			reference = options.reference,
			volume = volume,
			pitch = options.pitch or MAX
		}
	end

	-- Check for ref, use player if not specified
	local ref = options.reference or tes3.player

	if options.type == "last" then
		tes3.removeSound{sound = trackNew, reference = options.previousRef or ref}
		trackOld = trackNew

		tes3.playSound {
			sound = trackNew,
			loop = true,
			reference = ref,
			volume = volume,
			pitch = options.pitch or MAX
		}
	else
		-- Check for ref, use player if not specified
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
		if not trackOld then
			debugLog("Old track: none")
		else
			debugLog("Old track: "..trackOld.id)
		end
		debugLog("New track: "..trackNew.id)

		tes3.playSound {
			sound = trackNew,
			loop = true,
			reference = ref,
			volume = volume,
			pitch = options.pitch or MAX
		}
	end

end

-- Supporting kwargs here
function this.play(options)

	-- Check for ref, use player if not specified
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
	if not trackOld then
		debugLog("Old track: none")
	else
		debugLog("Old track: "..trackOld.id)
	end
	debugLog("New track: "..trackNew.id)

	local volume = options.volume or MAX

	tes3.playSound {
		sound = trackNew,
		loop = true,
		reference = ref,
		volume = MIN,
		pitch = options.pitch or MAX
	}

	if not trackOld then
		fadeIn(ref, volume)
	else
		crossFade(ref, volume)
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
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
local popDir = "\\P\\"
local quietDir = "q"
local warmDir = "w"
local coldDir = "c"


-- Constants
local STEP = 0.01
local TICK = 0.1
local MAX = 1
local MIN = 0

-- Array attributes
local clear = {}
local quiet = {}
local warm = {}
local cold = {}

local populated = {
    ["ash"] = {},
    ["dae"] = {},
    ["dar"] = {},
    ["dwe"] = {},
    ["imp"] = {},
    ["nor"] = {},
    ["n"] = {}
}

local modules = {
	["outdoor"] = {
		old = nil,
		new = nil
	},
	["populated"] = {
		old = nil,
		new = nil
	},
	["interior"] = {
		old = nil,
		new = nil
	},
}

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
					for soundfile in lfs.dir(AURAdir..climDir..climate.."\\"..time) do
						if soundfile ~= ".." and soundfile ~= "." then
							if string.endswith(soundfile, ".wav") then
								local objectId = string.sub(climate.."_"..time.."_"..soundfile, 1, -5)
								local filename = soundDir..climDir..climate.."\\"..time.."\\"..soundfile
								debugLog("Adding file: "..soundfile)
								debugLog("File id: "..objectId)
								debugLog("Filename: "..filename.."\n---------------")
								local sound = tes3.createObject{
									id = objectId,
									objectType = tes3.objectType.sound,
									filename = filename,
								}
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
	for soundfile in lfs.dir(AURAdir..comDir..dir) do
		if string.endswith(soundfile, ".wav") then
			local objectId = string.sub("S_"..dir.."_"..soundfile, 1, -5)
			local filename = soundDir..comDir.."\\"..dir.."\\"..soundfile
			debugLog("Adding file: "..soundfile)
			debugLog("File id: "..objectId)
			debugLog("Filename: "..filename.."\n---------------")
			local sound = tes3.createObject{
				id = objectId,
				objectType = tes3.objectType.sound,
				filename = filename,
			}
			table.insert(array, sound)
		end
	end
end

-- Populated --
local function buildPopulatedSounds()
	for populatedType, _ in pairs(populated) do
		for soundfile in lfs.dir(AURAdir..popDir..populatedType) do
			if soundfile and soundfile ~= ".." and soundfile ~= "." and string.endswith(soundfile, ".wav") then

				local objectId = string.sub("P_"..populatedType.."_"..soundfile, 1, -5)
				local filename = soundDir..popDir..populatedType.."\\"..soundfile
				debugLog("Adding file: "..soundfile)
				debugLog("File id: "..objectId)
				debugLog("Filename: "..filename.."\n---------------")
				local sound = tes3.createObject{
					id = objectId,
					objectType = tes3.objectType.sound,
					filename = filename,
				}
				table.insert(populated[populatedType], sound)
				debugLog("Adding populated file: "..soundfile)
			end
		end
	end
end

local function buildMisc()
	debugLog("|---------------------- Creating misc sound objects. ----------------------|\n")
	
	tes3.createObject{
		id = "splash_lrg",
		objectType = tes3.objectType.sound,
		filename = "Fx\\envrn\\splash_lrg.wav",
	}
	debugLog("Adding misc file: splash_lrg)")

	tes3.createObject{
		id = "splash_sml",
		objectType = tes3.objectType.sound,
		filename = "Fx\\envrn\\splash_sml.wav",
	}
	debugLog("Adding misc file: splash_sml)")

end

-- TODO: Build container sounds

----------------------------------------------------------------------------------------------------------
--//////////////////////////////////////////////////////////////////////////////////////////////////////--
----------------------------------------------------------------------------------------------------------

-- Play/Stop handling --
local function fadeIn(ref, volume, track, module)
	debugLog("Running fader - fade in.")
	if not track then return end

	local TIME = math.ceil((volume/STEP)*TICK)
	local ITERS = math.ceil(volume/STEP)
	local runs = 1

	local function fader()
		local incremented = STEP*runs

		if not tes3.getSoundPlaying{sound = track} then
			debugLog("In not playing: "..track.id)
			return
		end

		tes3.adjustSoundVolume{sound = track, volume = incremented, reference = ref}
		debugLog("Adjusting volume in: "..tostring(incremented))
		runs = runs + 1
	end

	local function queuer()
		modules[module].old = track
		debugLog("Fade in for "..track.id.." finished in: "..tostring(TIME).." s.")
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

local function fadeOut(ref, volume, track, module)
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
		modules[module].old = track
		tes3.removeSound{sound = track, reference = ref}
		debugLog("Fade out for "..track.id.." finished in: "..tostring(TIME).." s.")
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

local function crossFade(ref, volume, trackOld, trackNew, module)
	fadeOut(ref, volume, trackOld, module)
	fadeIn(ref, volume, trackNew, module)
end

function this.removeImmediate(options)
	local ref = options.reference or tes3.player
	tes3.removeSound{sound = modules[options.module].old, reference = ref}
	tes3.removeSound{sound = modules[options.module].new, reference = ref}
end

function this.remove(options)
	local ref = options.reference or tes3.player
	local volume = options.volume or MAX
	fadeOut(ref, volume, modules[options.module].old, options.module)
	fadeOut(ref, volume, modules[options.module].new, options.module)
end

function this.playImmediate(options)
	local ref = options.reference or tes3.player
	local volume = options.volume or MAX

	if options.last then
		tes3.removeSound{sound = modules[options.module].new, reference = ref}
		debugLog("Immediately restaring: "..modules[options.module].new.id)
		tes3.playSound {
			sound = modules[options.module].new,
			loop = true,
			reference = ref,
			volume = volume,
			pitch = options.pitch or MAX
		}
		modules[options.module].old = modules[options.module].new
	else
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

		modules[options.module].new = table[math.random(1, #table)]

		local msg = modules[options.module].old.id or "none"
		debugLog("Old track: "..msg)

		debugLog("New track: "..modules[options.module].new.id)

		tes3.playSound {
			sound = modules[options.module].new,
			loop = true,
			reference = ref,
			volume = volume,
			pitch = options.pitch or MAX
		}
	end
end

-- Supporting kwargs here
function this.play(options)

	local ref = options.reference or tes3.player
	local volume = options.volume or MAX

	-- TODO: interior
	local table

	if options.module == "outdoor" then
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
	elseif options.module == "populated" then
		if options.type == "night" then
			table = populated["n"]
		elseif options.type == "day" then
			table = populated[options.typeCell]
		end
	end

	while modules[options.module].new == modules[options.module].old do
		modules[options.module].new = table[math.random(1, #table)]
	end

	if not modules[options.module].old then
		debugLog("Old track: none")
	else
		debugLog("Old track: "..modules[options.module].old.id)
	end
	debugLog("New track: "..modules[options.module].new.id)

	tes3.playSound {
		sound = modules[options.module].new,
		loop = true,
		reference = ref,
		volume = MIN,
		pitch = options.pitch or MAX
	}

	if not modules[options.module].old then
		fadeIn(ref, volume, modules[options.module].new, options.module)
	else
		crossFade(ref, volume, modules[options.module].old, modules[options.module].new, options.module)
	end

end

function this.build()
	buildClearSounds()
	buildContextSounds(quietDir, quiet)
	buildContextSounds(warmDir, warm)
	buildContextSounds(coldDir, cold)
	buildPopulatedSounds()
	buildMisc()

	debugLog("|---------------------- Finished building sound objects. ----------------------|\n")
end

return this
-- Library packaging
local this={}

-- Imports
local common=require("tew\\AURA\\common")

-- Logger
local debugLog = common.debugLog

-- Paths
local AURAdir = "Data Files\\Sound\\tew\\A"
local soundDir = "tew\\A"
local climDir = "\\C\\"
local comDir = "\\S\\"
local popDir = "\\P\\"
local interiorDir = "\\I\\"
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

local interior = {
    ["aba"] = {},
    ["alc"] = {},
    ["cav"] = {},
    ["clo"] = {},
    ["dae"] = {},
    ["dwe"] = {},
    ["ice"] = {},
    ["mag"] = {},
    ["fig"] = {},
    ["tem"] = {},
    ["lib"] = {},
    ["smi"] = {},
    ["tra"] = {},
    ["tom"] = {},
    ["tav"] = {
        ["imp"] = {},
        ["dar"] = {},
        ["nor"] = {},
    }
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
	mwse.log("\n")
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
	mwse.log("\n")
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
	mwse.log("\n")
	debugLog("|---------------------- Building populated weather table. ----------------------|\n")
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

-- Interior --
local function buildInteriorSounds()
	mwse.log("\n")
	debugLog("|---------------------- Building interior sounds table. ----------------------|\n")
	for interiorType, _ in pairs(interior) do
		for soundfile in lfs.dir(AURAdir..interiorDir..interiorType) do
			if soundfile and soundfile ~= ".." and soundfile ~= "." and string.endswith(soundfile, ".wav") then
				local objectId = string.sub("I_"..interiorType.."_"..soundfile, 1, -5)
				local filename = soundDir..interiorDir..interiorType.."\\"..soundfile
				debugLog("Adding interior file: "..soundfile)
				debugLog("File id: "..objectId)
				debugLog("Filename: "..filename.."\n---------------")
				local sound = tes3.createObject{
					id = objectId,
					objectType = tes3.objectType.sound,
					filename = filename,
				}

				table.insert(interior[interiorType], sound)
			end
		end
	end
end

local function buildTavernSounds()
	mwse.log("\n")
	debugLog("|---------------------- Building tavern sounds table. ----------------------|\n")
	for folder in lfs.dir(AURAdir..interiorDir.."\\tav\\") do
		for soundfile in lfs.dir(AURAdir..interiorDir.."\\tav\\"..folder) do
			if soundfile and soundfile ~= ".." and soundfile ~= "." and string.endswith(soundfile, ".wav") then
				local objectId = string.sub("I_tav_"..soundfile, 1, -5)
				local filename = soundDir..interiorDir.."tav\\"..folder.."\\"..soundfile
				debugLog("Adding tavern file: "..soundfile)
				debugLog("File id: "..objectId)
				debugLog("Filename: "..filename.."\n---------------")
				local sound = tes3.createObject{
					id = objectId,
					objectType = tes3.objectType.sound,
					filename = filename,
				}
				table.insert(interior["tav"][folder], sound)
			end
		end
	end
end


local function buildMisc()
	mwse.log("\n")
	debugLog("|---------------------- Creating misc sound objects. ----------------------|\n")
	
	tes3.createObject{
		id = "splash_lrg",
		objectType = tes3.objectType.sound,
		filename = "Fx\\envrn\\splash_lrg.wav",
	}
	debugLog("Adding misc file: splash_lrg")

	tes3.createObject{
		id = "splash_sml",
		objectType = tes3.objectType.sound,
		filename = "Fx\\envrn\\splash_sml.wav",
	}
	debugLog("Adding misc file: splash_sml")

	tes3.createObject{
		id = "tew_clap",
		objectType = tes3.objectType.sound,
		filename = "Fx\\envrn\\ent_react04a.wav",
	}
	debugLog("Adding misc file: tew_clap")

	tes3.createObject{
		id = "tew_potnpour",
		objectType = tes3.objectType.sound,
		filename = "Fx\\item\\potnpour.wav",
	}
	debugLog("Adding misc file: tew_potnpour")

	tes3.createObject{
		id = "tew_shield",
		objectType = tes3.objectType.sound,
		filename = "Fx\\item\\shield.wav",
	}
	debugLog("Adding misc file: tew_shield")

	tes3.createObject{
		id = "tew_blunt",
		objectType = tes3.objectType.sound,
		filename = "Fx\\item\\bluntOut.wav",
	}
	debugLog("Adding misc file: tew_blunt")

	tes3.createObject{
		id = "tew_longblad",
		objectType = tes3.objectType.sound,
		filename = "Fx\\item\\longblad.wav",
	}
	debugLog("Adding misc file: tew_longblad")

	tes3.createObject{
		id = "tew_spear",
		objectType = tes3.objectType.sound,
		filename = "Fx\\item\\spear.wav",
	}
	debugLog("Adding misc file: tew_spear")
end

-- TODO: Build container sounds

----------------------------------------------------------------------------------------------------------
--//////////////////////////////////////////////////////////////////////////////////////////////////////--
----------------------------------------------------------------------------------------------------------

-- Play/Stop handling --
local function fadeIn(ref, volume, track, module)
	
	if not track or not tes3.getSoundPlaying{sound = track, reference = ref} then debugLog("No track to fade in. Returning.") return end
	debugLog("Running fade in for: "..track.id)

	local TIME = math.ceil((volume/STEP)*TICK)
	local ITERS = math.ceil(volume/STEP)
	local runs = 1

	local function fader()
		local incremented = STEP*runs

		if not tes3.getSoundPlaying{sound = track, reference = ref} then
			debugLog("In not playing: "..track.id)
			return
		end

		tes3.adjustSoundVolume{sound = track, volume = incremented, reference = ref}
		debugLog("Adjusting volume in: "..track.id.." | "..tostring(incremented))
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

	if not track or not tes3.getSoundPlaying{sound = track, reference = ref} then debugLog("No track to fade out. Returning.") return end
	debugLog("Running fade out for: "..track.id)

	local TIME = math.ceil((volume/STEP)*TICK)
	local ITERS = math.ceil(volume/STEP)
	local runs = ITERS

	local function fader()
		local incremented = STEP*runs

		if not tes3.getSoundPlaying{sound = track, reference = ref} then
			debugLog("Out not playing: "..track.id)
			return
		end

		tes3.adjustSoundVolume{sound = track, volume = incremented, reference = ref}
		debugLog("Adjusting volume out: "..track.id.." | "..tostring(incremented))
		runs = runs - 1
	end

	local function queuer()
		modules[module].old = track
		if tes3.getSoundPlaying{sound = track, reference = ref} then tes3.removeSound{sound = track, reference = ref} end
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
	if not trackOld or not trackNew then return end
	debugLog("Running crossfade for: "..trackOld.id..", "..trackNew.id)
	fadeOut(ref, volume, trackOld, module)
	fadeIn(ref, volume, trackNew, module)
end

function this.removeImmediate(options)
	local ref = options.reference or tes3.mobilePlayer.reference

	if
		modules[options.module].old
		and tes3.getSoundPlaying{sound = modules[options.module].old, reference = ref}
	then
		tes3.removeSound{sound = modules[options.module].old, reference = ref}
	end
	
	if
		modules[options.module].new
		and tes3.getSoundPlaying{sound = modules[options.module].new, reference = ref}
		and not modules[options.module].new == modules[options.module].old
	then
		tes3.removeSound{sound = modules[options.module].new, reference = ref}
	end
end

function this.remove(options)
	local ref = options.reference or tes3.mobilePlayer.reference
	local volume = options.volume or MAX

	if
		modules[options.module].old
		and tes3.getSoundPlaying{sound = modules[options.module].old, reference = ref}
	then
		fadeOut(ref, volume, modules[options.module].old, options.module)
	end
	
	if
		modules[options.module].new
		and tes3.getSoundPlaying{sound = modules[options.module].new, reference = ref}
		and not modules[options.module].new == modules[options.module].old
	then
		fadeOut(ref, volume, modules[options.module].new, options.module)
	end
end

local function getTrack(options)
	debugLog("Parsing passed options.")

	if not options.module then debugLog("No module detected. Returning.") end

	local table

	if options.module == "outdoor" then
		debugLog("Got outdoor module.")
		if not options.climate or not options.time then
			if options.type == "quiet" then
				debugLog("Got quiet type.")
				table = quiet
			elseif options.type == "warm" then
				debugLog("Got warm type.")
				table = warm
			elseif options.type == "cold" then
				debugLog("Got cold type.")
				table = cold
			end
		else
			local climate = options.climate
			local time = options.time
			debugLog("Got "..climate.." climate and "..time.." time.")
			table = clear[climate][time]
		end
	elseif options.module == "populated" then
		debugLog("Got populated module.")
		if options.type == "night" then
			debugLog("Got populated night.")
			table = populated["n"]
		elseif options.type == "day" then
			debugLog("Got populated day.")
			table = populated[options.typeCell]
		end
	elseif options.module == "interior" then
		debugLog("Got interior module.")
		if options.race then
			debugLog("Got tavern for "..options.race.." race.")
			table = interior["tav"][options.race]
		else
			debugLog("Got interior "..options.type.." type.")
			table = interior[options.type]
		end
	end

	local newTrack = table[math.random(1, #table)]
	if modules[options.module].old then
		while newTrack.id == modules[options.module].old.id do
			newTrack = table[math.random(1, #table)]
		end
	end

	return newTrack
end

function this.playImmediate(options)
	local ref = options.reference or tes3.mobilePlayer.reference
	local volume = options.volume or MAX

	if options.last and modules[options.module].new then
		if tes3.getSoundPlaying{sound = modules[options.module].new, reference = ref} then tes3.removeSound{sound = modules[options.module].new, reference = ref} end
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
		local newTrack = getTrack(options)
		modules[options.module].new = newTrack

		if not modules[options.module].old then
			debugLog("Old track: none")
		else
			debugLog("Old track: "..modules[options.module].old.id)
		end

		debugLog("Immediately playing new track: "..newTrack.id)

		tes3.playSound {
			sound = newTrack,
			loop = true,
			reference = ref,
			volume = volume,
			pitch = options.pitch or MAX
		}
	end
end

-- Supporting kwargs here
function this.play(options)

	local ref = tes3.mobilePlayer.reference
	local volume = options.volume or MAX

	local newTrack = getTrack(options)
	modules[options.module].new = newTrack

	if not modules[options.module].old then
		debugLog("Old track: none")
	else
		debugLog("Old track: "..modules[options.module].old.id)
	end

	debugLog("Playing new track: "..newTrack.id)

	timer.delayOneFrame
	(
		function()
			timer.delayOneFrame
			(
				function()
					tes3.playSound {
						sound = newTrack,
						loop = true,
						reference = ref,
						volume = MIN,
						pitch = options.pitch or MAX
					}
					if not modules[options.module].old then
						fadeIn(ref, volume, newTrack, options.module)
					else
						crossFade(ref, volume, modules[options.module].old, newTrack, options.module)
					end
				end
			)
		end
	)
end

function this.build()
	buildClearSounds()
	buildContextSounds(quietDir, quiet)
	buildContextSounds(warmDir, warm)
	buildContextSounds(coldDir, cold)
	buildPopulatedSounds()
	buildInteriorSounds()
	buildTavernSounds()
	buildMisc()
	mwse.log("\n")
	debugLog("|---------------------- Finished building sound objects. ----------------------|\n")
end

return this
-- DO NOT MODIFY THIS --
local this = {}
------------------------

--[[
							!!! IMPORTANT !!! --
	Translate ONLY the designated strings in the following tables.
	When translating, please make sure that punctuation, case, and spacing is preserved. --
	Don't worry about missing strings, they will be filled in with default (English) values. --
--]]

------------------------------------------------------------------------------------------------

-- MESSAGES --
-- This table contains strings used mainly in MCM and initial messages sent to MWSE log --
-- Translate ONLY the values on the right hand side of the = signs. --

this.messages = {
	audioWarning = "Master and effect channels should be set to max for the mod to work as intended.",
	buildingSoundsStarted = "Running sound object builder.",
	buildingSoundsFinished = "Sound objects builder finished.",
	loadingFile = "Loading file:",
	oldFolderDeleted = "Old mod folder found and deleted.",
	oldFileDeleted = "Old file found and deleted",

	manifestConfirm = "Are you sure you want to remove the manifest file?",
	manifestRemoved = "Manifest file has been removed.",

	initialised = "initialised.",
	mainSettings = "Main Settings",
	mainLabel = "by tewlwolow.\nLua-based sound overhaul.",

	WtS = "Requires Watch the Skies.",

	settings = "Settings",
	default = "Default",
	volume = "Volume",
	toggle = "Toggle",
	chance = "Chance",
	version = "Version",

	modLanguage = "Mod language.",

	enableDebug = "Enable debug mode?",
	enableOutdoor = "Enable Outdoor Ambient module?",
	enableInterior = "Enable Interior Ambient module?",
	enablePopulated = "Enable Populated Ambient module?",
	enableInteriorWeather = "Enable Interior Weather module?",
	enableServiceVoices = "Enable Service Voices module?",
	enableUI = "Enable UI module?",
	enableContainers = "Enable Containers module?",
	enablePC = "Enable PC module?",
	enableMisc = "Enable Misc module?",

	refreshManifest = "Refresh manifest file",

	OA = "Outdoor Ambient",
	OADesc = "Plays ambient sounds in accordance with local climate, weather, player position, and time.",
	OAVol = "Changes % volume for Outdoor Ambient module.",
	playInteriorAmbient = "Enable exterior ambient sounds in interiors? This means the last exterior loop will play on each door and window leading to an exterior.",

	IA = "Interior Ambient",
	IADesc = "Plays ambient sounds in accordance with interior type. Includes taverns, guilds, shops, libraries, tombs, caves, and ruins.",
	IAVol = "Changes % volume for Interior Ambient module.",

	enableTaverns = "Enable culture-specific music in taverns? Note that this works best if you have empty explore/battle folders and use no music mod.",
	tavernsBlacklist = "Taverns blacklist",
	tavernsDesc = "Select which taverns the music is disabled in.",
	tavernsDisabled = "Disabled taverns",
	tavernsEnabled = "Enabled taverns",

	PA = "Populated Ambient",
	PADesc = "Plays ambient sounds in populated areas, like towns and villages.",
	PAVol = "Changes % volume for Populated Ambient module.",

	IW = "Interior Weather",
	IWDesc = "Plays weather sounds in interiors.",
	IWVol = "Changes % volume for Interior Weather module.",

	SV = "Service Voices",
	SVDesc = "Plays appropriate voice comments on service usage.",
	SVVol = "Changes % volume for Service Voices module.",
	enableRepair = "Enable voice comments on repair service?",
	enableSpells = "Enable voice comments on spells vendor service?",
	enableTraining = "Enable voice comments on training service?",
	enableSpellmaking = "Enable voice comments on spellmaking service?",
	enableEnchantment = "Enable voice comments on enchanting service?",
	enableTravel = "Enable voice comments on travel service?",
	enableBarter = "Enable voice comments on barter service?",

	PC = "PC",
	PCDesc = "Plays sounds related to the player character.",
	enableHealth = "Enable low health sounds?",
	enableFatigue = "Enable low fatigue sounds?",
	enableMagicka = "Enable low magicka sounds?",
	enableDisease = "Enable diseased sounds?",
	enableBlight = "Enable blighted sounds?",
	vsVol = "Changes % volume for for vital signs (health, fatigue, magicka, disease, blight).",
	enableTaunts = "Enable player combat taunts?",
	tauntChance = "Changes % chance for a battle taunt to play.",
	tVol = "Changes % volume for player battle taunts.",

	containers = "Containers",
	containersDesc = "Plays container sound on open/close.",
	CVol = "Changes % volume for Containers module.",

	UI = "UI",
	UIDesc = "Additional immersive UI sounds.",
	UITraining = "Enable training menu sounds?",
	UITravel = "Enable travel menu sounds?",
	UISpells = "Enable spell menu sounds?",
	UIBarter = "Enable barter menu sounds?",
	UIEating = "Enable eating sound for ingredients in inventory menu?",
	UIVol = "Changes % volume for UI module.",

	misc = "Misc",
	miscDesc = "Plays various miscellaneous sounds.",
	rainSounds = "Enable variable rain sounds per max particles?",
	windSounds = "Enable variable wind sounds per clouds speed?",
	playInteriorWind = "Enable wind sounds in interiors? This means the last exterior loop will play on each door and window leading to an exterior.",
	windVol = "Changes % volume for wind sounds.",
	playSplash = "Enable splash sounds when going underwater and back to surface?",
	splashVol = "Changes % volume for splash sounds.",
	playYurtFlap = "Enable sounds for yurts and pelt entrances?",
	yurtVol = "Changes % volume for yurt and pelt entrances sounds."
}

------------------------------------------------------------------------------------------------

-- INTERIOR CELL NAMES --
-- This table contains cell names that interior module matches (matching the whole string as one word) --
-- Translate ONLY the values in the lists, DO NOT modify the list index --
-- For instance ["alc"] or ["mag"] should be preserved as they are, while names such as "Alchemist" or "Mages Guild" should be replaced with translation --
-- There might be some differences between language versions of course, so please try and verify whether the current translation makes sense for you locale --

this.interiorNames = {
	["alc"] = {
        "Alchemist",
        "Apothecary",
        "Tel Uvirith, Omavel's House",
        "Healer",
    },
    ["cou"] = {
        "Telvanni Council House",
        "Redoran Council Hall",
        "Manor District",
        "Guildhall",
        "Morag Tong",
        "Arena Hidden Area",
        "Grand Council",
        "Plaza",
        "Waistworks"
    },
    ["mag"] = {
        "Mages Guild",
        "Mage's Guild",
        "Guild of Mages"
    },
    ["fig"] = {
        "Fighters Guild",
        "Fighter's Guild",
        "Guild of Fighters",
    },
    ["tem"] = {
        "Temple",
        "Maar Gan, Shrine",
        "Vos Chapel",
        "High Fane",
        "Fane of the Ancestors",
        "Tiriramannu",
    },
    ["lib"] = {
        "Library",
        "Bookseller",
        "Books"
    },
    ["smi"] = {
        "Smith",
        "Armorer",
        "Weapons",
        "Armor",
        "Smithy",
        "Weapon",
        "Armors",
        "Blacksmith",
    },
    ["tra"] = {
        "Trader",
        "Pawnbroker",
        "Merchandise",
        "Merchant",
        "Goods",
        "Outfitter",
        "Laborers",
        "Brewers",
        "Tradehouse",
        "Hostel",
    },
    ["clo"] = {
        "Clothier",
        "Tailors",
    },
    ["tom"]= {
        "Tomb",
        "Burial",
        "Crypt",
        "Barrow",
        "Catacomb",
    }
}

------------------------------------------------------------------------------------------------

-- TAVERN NAMES --
-- This is an additional table to bypass the regular, language-agnostic logic of matching taverns with publican's race --
-- Some places that should be taverns do not have any Publican NPC, hence the need to do additional cell name match as well --
-- Please see above for details about what and how to translate here --
this.tavernNames = {
	["dar"] = {
		"Rat in the Pot",
		"House of Earthly Delights",
		"Elven Nations"
	},
	["imp"] = {
		"Ebonheart, Six Fishes",
		"Arrille"
	},
	["nor"] = {
		"Skaal Village, The Greathall",
		"Solstheim, Thirsk"
	}
}

------------------------------------------------------------------------------------------------


-- DO NOT MODIFY BELOW THIS LINE --
return this

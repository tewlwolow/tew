local configPath = "AURA"
local config = require("tew.AURA.config")
mwse.loadConfig("AURA")
local modversion = require("tew.AURA.version")
local version = modversion.version

local function registerVariable(id)
    return mwse.mcm.createTableVariable{
        id = id,
        table = config
    }
end

local template = mwse.mcm.createTemplate{
    name="AURA",
    headerImagePath="\\Textures\\tew\\AURA\\AURA_logo.tga"}

    local page = template:createPage{label="Main Settings", noScroll=true}
    page:createCategory{
        label = "AURA "..version.." by tewlwolow.\nLua-based sound overhaul.\n\nSettings:",
    }
    page:createYesNoButton{
        label = "Enable debug mode?",
        variable = registerVariable("debugLogOn"),
        restartRequired=true
    }
    page:createYesNoButton{
        label = "Enable Outdoor Ambient module?",
        variable = registerVariable("moduleAmbientOutdoor"),
        restartRequired=true
    }

    page:createYesNoButton{
        label = "Enable Interior Weather module?",
        variable = registerVariable("moduleInteriorWeather"),
        restartRequired=true
    }

    page:createYesNoButton{
        label = "Enable Service Voices module?",
        variable = registerVariable("moduleServiceVoices"),
        restartRequired=true
    }
    page:createYesNoButton{
        label = "Enable Misc module?",
        variable = registerVariable("moduleMisc"),
        restartRequired=true
    }

    local pageOA = template:createPage{label="Outdoor Ambient"}
    pageOA:createCategory{
        label = "Plays ambient sounds in accordance with local climate, weather, player position, and time.\n\nSettings:"
    }
    pageOA:createSlider{
        label = "Changes % volume. Default = 100%.\nReload a save for immediate effect or wait for a loop change. Volume %",
        min = 0,
        max = 200,
        step = 1,
        jump = 10,
        variable=registerVariable("vol")
    }
    pageOA:createSlider{
        label = "Changes % chance for a calm track to play instead of the regular one. Default = 30%.\nReload a save for immediate effect or wait for a loop change. Chance %",
        min = 0,
        max = 100,
        step = 1,
        jump = 10,
        variable=registerVariable("calmChance")
    }
    pageOA:createYesNoButton{
        label = "Enable exterior ambient sounds in interiors? This means the last exterior loop will play on each interior door leading to an exterior. The sound will stop if you're far enough from such door.",
        variable = registerVariable("playInteriorAmbient"),
        restartRequired=true
    }
    pageOA:createYesNoButton{
        label = "Enable additional wind tracks in bad weather (overcast, rain, thunder, snow)?",
        variable = registerVariable("playWindy"),
    }
    pageOA:createYesNoButton{
        label = "Enable transition sounds?",
        variable = registerVariable("playTransSounds"),
    }

    local pageIW = template:createPage{label="Interior Weather"}
    pageIW:createCategory{
        label = "Plays weather sounds in interiors.\n\nSettings:"
    }
    pageIW:createSlider{
        label = "Changes % volume. Default = 100%.\nReload a save for immediate effect or wait for a loop change.\nVolume %",
        min = 0,
        max = 200,
        step = 1,
        jump = 10,
        variable=registerVariable("intVol")
    }

    local pageSV = template:createPage{label="Service Voices"}
    pageSV:createCategory{
        label = "Plays appropriate voice comments on service usage.\nCurrently only travel services available.\n\nSettings:"
    }

    pageSV:createYesNoButton{
        label = "Enable voice comments on repair service?",
        variable = registerVariable("serviceRepair"),
    }

    pageSV:createYesNoButton{
        label = "Enable voice comments on spells vendor service?",
        variable = registerVariable("serviceSpells"),
    }

    pageSV:createYesNoButton{
        label = "Enable voice comments on training service?",
        variable = registerVariable("serviceTraining"),
    }

    pageSV:createYesNoButton{
        label = "Enable voice comments on spellmaking service?",
        variable = registerVariable("serviceSpellmaking"),
    }

    pageSV:createYesNoButton{
        label = "Enable voice comments on enchanting service?",
        variable = registerVariable("serviceEnchantment"),
    }

    pageSV:createYesNoButton{
        label = "Enable voice comments on travel service?",
        variable = registerVariable("serviceTravel"),
    }

    pageSV:createYesNoButton{
        label = "Enable voice comments on barter service?",
        variable = registerVariable("serviceBarter"),
    }

    local pageMisc = template:createPage{label="Misc", noScroll=true}
    pageMisc:createCategory{
        label = "Plays various miscellaneous sounds.\n\nSettings:"
    }
    pageMisc:createYesNoButton{
        label = "Enable splash sounds when going underwater and back to surface?",
        variable = registerVariable("playSplash"),
    }
    pageMisc:createYesNoButton{
        label = "Enable travel sounds?",
        variable = registerVariable("travelFee"),
    }
    pageMisc:createYesNoButton{
        label = "Enable yurt door sound?",
        variable = registerVariable("playYurtFlap"),
    }
    pageMisc:createYesNoButton{
        label = "Enable banner flap sounds?",
        variable = registerVariable("playBanners"),
    }
    pageMisc:createYesNoButton{
        label = "Enable rain-on-canvas sounds on overhangs?",
        variable = registerVariable("playOverhang"),
    }

template:saveOnClose(configPath, config)
mwse.mcm.register(template)

local configPath = "Clear Sight"
local config = require("tew.Clear Sight.config")
mwse.loadConfig("Clear Sight")
local modversion = require("tew\\Clear Sight\\version")
local version = modversion.version

local function registerVariable(id)
    return mwse.mcm.createTableVariable{
        id = id,
        table = config
    }
end

local template = mwse.mcm.createTemplate{
    name="Clear Sight",
    headerImagePath="\\Textures\\tew\\Clear Sight\\tew_clearsight_logo.tga"}

    local page = template:createPage{label="Main Settings", noScroll=true}
    page:createCategory{
        label = "Clear Sight "..version.." by tewlwolow.\nAn immersive HUD overhaul made for May Modathon 2021.\n\nSettings:",
    }

    page:createYesNoButton{
        label = "Enable debug mode?",
        variable = registerVariable("debugLogOn"),
        restartRequired=true
    }

    page:createSlider({
        label = "Cooldown duration (in seconds)",
        max = 25,
        description = "Cooldown to hide the HUD after it is shown.\nDefault = 7",
        variable = registerVariable("cooldownDuration")
      })

    page:createKeyBinder{
        label = "This key, when pressed with alt, will toggle between visible/invisible HUD.\nDefault = H.",
        allowCombinations = false,
        variable = registerVariable("toggleKey"),
    }



template:saveOnClose(configPath, config)
mwse.mcm.register(template)
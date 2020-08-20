local configPath = "Watch the Skies"
local config = require("tew.Watch the Skies.config")
mwse.loadConfig("Watch the Skies")
local version = "1.0.0"

local function registerVariable(id)
    return mwse.mcm.createTableVariable{
        id = id,
        table = config
    }
end

local template = mwse.mcm.createTemplate{
    name="Watch the Skies",
    headerImagePath="\\Textures\\tew\\Watch the Skies\\WtS_logo.tga"}

    local page = template:createPage{label="Main Settings", noScroll=true}
    page:createCategory{
        label = "Watch the Skies "..version.." by tewlwolow.\nLua-based sky randomiser.\n\nSettings:",
    }

    page:createYesNoButton{
        label = "Enable debug mode?",
        variable = registerVariable("debugLogOn"),
        restartRequired=true
    }

    page:createSlider{
        label = "Changes % chance for a vanilla cloud texture to show up instead.\nChance %",
        min = 0,
        max = 100,
        step = 1,
        jump = 10,
        variable=registerVariable("vanChance")
    }

template:saveOnClose(configPath, config)
mwse.mcm.register(template)

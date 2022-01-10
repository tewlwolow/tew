local configPath = "Wearables"
local config = require("tew.Wearables.config")
mwse.loadConfig("Wearables")
local modversion = require("tew\\Wearables\\version")
local version = modversion.version

local function registerVariable(id)
    return mwse.mcm.createTableVariable{
        id = id,
        table = config
    }
end

local template = mwse.mcm.createTemplate{
    name="Wearables",
    headerImagePath="\\Textures\\tew\\Wearables\\wearables_logo.tga"}

    local page = template:createPage{label="Main Settings", noScroll=true}
    page:createCategory{
        label = "Wearables "..version.." by tewlwolow.\nEquip previously unequippable items for a visual treat.\n\nSettings:",
    }

    page:createYesNoButton{
        label = "Enable debug mode?",
        variable = registerVariable("debugLogOn"),
        restartRequired=true
    }

template:saveOnClose(configPath, config)
mwse.mcm.register(template)

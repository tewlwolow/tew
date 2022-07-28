local configPath = "CHIMES"
local config = require("tew.CHIMES.config")
mwse.loadConfig("CHIMES")
local metadata = require("tew.CHIMES.metadata")
local version = metadata.version

local function registerVariable(id)
    return mwse.mcm.createTableVariable{
        id = id,
        table = config
    }
end

local template = mwse.mcm.createTemplate{
    name="CHIMES",
    headerImagePath="\\Textures\\tew\\CHIMES\\chimes_logo.tga"}

    local mainPage = template:createPage{label="Main Settings", noScroll=true}
    mainPage:createCategory{
        label = "CHIMES "..version.." by tewlwolow and Morrowind Modding Community.\nSimple and lightweight lua-based music system.\n\nSettings:",
    }

template:saveOnClose(configPath, config)
mwse.mcm.register(template)


local configPath = "Vapourmist"
local config = require("tew.Vapourmist.config")
mwse.loadConfig("Vapourmist")
local version = require("tew\\Vapourmist\\version")
local VERSION = version.version

local function registerVariable(id)
    return mwse.mcm.createTableVariable{
        id = id,
        table = config
    }
end

local template = mwse.mcm.createTemplate{
    name = "Vapourmist",
    headerImagePath="\\Textures\\tew\\Vapourmist\\logo.dds"}

    local mainPage = template:createPage{label="Main Settings", noScroll=true}
    mainPage:createCategory{
        label = "Vapourmist "..VERSION.." by tewlwolow.\nLua-based 3D mist and clouds.\nSettings:\n",
    }
    
    mainPage:createYesNoButton{
        label = "Enable debug mode?",
        variable = registerVariable("debugLogOn"),
        restartRequired=true
    }

    mainPage:createYesNoButton{
        label = "Enable interior fog?",
        variable = registerVariable("interiorFog"),
    }

    mainPage:createSlider{
        label = "Percent chance for mist to spawn when otherwise blocked",
        min = 0,
        max = 100,
        step = 1,
        jump = 10,
        variable = registerVariable("randomMistChance")
    }
    
    mainPage:createSlider{
        label = "Percent chance for cloud to spawn when otherwise blocked",
        min = 0,
        max = 100,
        step = 1,
        jump = 10,
        variable = registerVariable("randomCloudChance")
    }

    local weathersPage = template:createPage{label="Weather Settings", noScroll=true}
    weathersPage:createCategory{
        label = "Controls weather types when cloud and mist types can spawn.\n",
    }

    weathersPage:createExclusionsPage{
        label = "Cloudy weathers",
        description = "Weathers to spawn clouds in:",
        toggleText = "Toggle",
        leftListLabel = "Cloudy weathers",
        rightListLabel = "All weathers",
        showAllBlocked = false,
        variable = mwse.mcm.createTableVariable{
            id = "cloudyWeathers",
            table = config,
        },

        filters = {

            {
                label = "Weathers",
                callback = (
                    function()
                        local weatherNames = {}
                        for weather, _ in pairs(tes3.weather) do
                            table.insert(weatherNames, weather:sub(1,1):upper()..weather:sub(2))
                        end
                        return weatherNames
                    end
                )
            },

        }
    }

    weathersPage:createExclusionsPage{
        label = "Misty weathers",
        description = "Weathers to spawn mist in:",
        toggleText = "Toggle",
        leftListLabel = "Misty weathers",
        rightListLabel = "All weathers",
        showAllBlocked = false,
        variable = mwse.mcm.createTableVariable{
            id = "mistyWeathers",
            table = config,
        },

        filters = {

            {
                label = "Weathers",
                callback = (
                    function()
                        local weatherNames = {}
                        for weather, _ in pairs(tes3.weather) do
                            table.insert(weatherNames, weather:sub(1,1):upper()..weather:sub(2))
                        end
                        return weatherNames
                    end
                )
            },

        }
    }


template:saveOnClose(configPath, config)
mwse.mcm.register(template)

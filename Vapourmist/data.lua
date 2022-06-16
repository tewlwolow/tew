local this = {}

local config = require("tew.Vapourmist.config")

this.baseTimerDuration = 0.4
this.lerpTime = 0.05
this.speedCoefficient = 25
this.minimumSpeed = 20
this.minStaticCount = 5

local interiorStatics = {
    "in_moldcave",
    "in_mudcave",
    "in_lavacave",
    "in_pycave",
    "in_bonecave",
    "in_bc_cave",
    "in_m_sewer",
    "in_sewer",
    "ab_in_kwama",
    "ab_in_lava",
    "ab_in_mvcave",
    "t_cyr_cavegc",
    "t_glb_cave",
    "t_mw_cave",
    "t_sky_cave",
    "bm_ic_",
    "bm_ka",
}

local interiorNames = {
    "cave",
    "cavern",
    "tomb",
    "burial",
    "crypt",
    "catacomb",
}


this.fogTypes = {
    ["cloud"] = {
        name = "cloud",
        mesh = "tew\\Vapourmist\\vapourcloud.nif",
        height = 3800,
        initialSize = {350, 420, 450, 500, 510, 550, 600},
        isAvailable = function(_, weather)

            if math.random(1, 100) <= config.randomCloudChance then
                return true
            end

            local weatherNow
            for name, w in pairs(tes3.weather) do
                if weather.index == w then
                    weatherNow=name:sub(1,1):upper()..name:sub(2)
                end
            end

            if math.random(1, 100) <= config.randomCloudChance then
                return false
            end

            if config.cloudyWeathers[weatherNow] and config.cloudyWeathers[weatherNow] ~= nil then
                return true
            end

            return false
        end,
        colours = {
            ["dawn"] = {
                r = 0.045,
                g = 0.035,
                b = 0.035
            },
            ["day"] = {
                r = 0.04,
                g = 0.04,
                b = 0.04
            },
            ["dusk"] = {
                r = 0.05,
                g = 0.045,
                b = 0.045
            },
            ["night"] = {
                r = 0.025,
                g = 0.025,
                b = 0.028
            },
        }
    },
    ["mist"] = {
        name = "mist",
        mesh = "tew\\Vapourmist\\vapourmist.nif",
        height = 550,
        initialSize = {200, 250, 300, 350, 400},
        isAvailable = function(gameHour, weather)

            if (
                (
                (gameHour > WtC.sunriseHour - 1 and gameHour < WtC.sunriseHour + 2)
                or (gameHour >= WtC.sunsetHour - 0.4 and gameHour < WtC.sunsetHour + 2))
                and not (this.fogTypes["mist"].wetWeathers[weather.index] or weather.index == 8 or weather.index == 9 or weather.index == 6 or weather.index == 7)
                ) then
                return true
            end

            if math.random(1, 100) <= config.randomMistChance then
                return true
            end

            local weatherNow
            for name, w in pairs(tes3.weather) do
                if weather.index == w then
                    weatherNow=name:sub(1,1):upper()..name:sub(2)
                end
            end

            if math.random(1, 100) <= config.randomCloudChance then
                return false
            end

            if config.mistyWeathers[weatherNow] and config.mistyWeathers[weatherNow] ~= nil  then
                return true
            end

            return false
        end,
        wetWeathers = {[4] = true, [5] = true},
        colours = {
            ["dawn"] = {
                r = 0.06,
                g = 0.05,
                b = 0.05
            },
            ["day"] = {
                r = 0.02,
                g = 0.02,
                b = 0.02
            },
            ["dusk"] = {
                r = 0.04,
                g = 0.04,
                b = 0.045
            },
            ["night"] = {
                r = 0.02,
                g = 0.02,
                b = 0.022
            },
        }
    },
}

this.interiorFog = {
    name = "interior",
    mesh = "tew\\Vapourmist\\vapourint.nif",
    height = -1300,
    initialSize = {100, 150, 200, 300, 360},
    isAvailable = function(cell)

        for _, namePattern in ipairs(interiorNames) do
            if string.find(cell.name:lower(), namePattern) then
                return true
            end
        end

        local count = 0
        for stat in cell:iterateReferences(tes3.objectType.static) do
            for _, statName in ipairs(interiorStatics) do
                if string.startswith(stat.object.id:lower(), statName) then
                    count = count + 1
                    if count >= this.minStaticCount then
                        return true
                    end
                end
            end
        end

        if count == 0 then return false end

    return false
    end,
    colours = {
        r = -0.3,
        g = -0.3,
        b = -0.3
    },
}


return this
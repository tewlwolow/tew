local this = {}

this.baseTimerDuration = 0.5

this.fogTypes = {
    cloud = {
        name = "cloud",
        mesh = "tew\\Vapourmist\\vapourcloud.nif",
        height = 3200,
        isAvailable = function(_, _)
            return true
        end,
        blockedWeathers = {0, 6, 7},
        colours = {
            ["dawn"] = {
                r = -0.01,
                g = -0.03,
                b = -0.03
            },
            ["day"] = {
                r = -0.012,
                g = -0.012,
                b = -0.012
            },
            ["dusk"] = {
                r = -0.02,
                g = -0.03,
                b = -0.03
            },
            ["night"] = {
                r = 0.06,
                g = 0.06,
                b = 0.08
            },
        }
    },
    mist = {
        name = "mist",
        mesh = "tew\\Vapourmist\\vapourmist.nif",
        height = 30,
        isAvailable = function(gameHour, weather)
            if ((gameHour >= WtC.sunriseHour + 2 and gameHour <= 24)
            or (gameHour >= 24 and gameHour < WtC.sunsetHour - 1))
            and not (weather == 2 or weather == 3) then
                return false
            end
            return true
        end,
        blockedWeathers = {6, 7},
        wetWeathers = {4, 5},
        colours = {
            ["dawn"] = {
                r = -0.03,
                g = -0.05,
                b = -0.05
            },
            ["day"] = {
                r = -0.08,
                g = -0.08,
                b = -0.08
            },
            ["dusk"] = {
                r = -0.06,
                g = -0.08,
                b = -0.08
            },
            ["night"] = {
                r = 0.04,
                g = 0.04,
                b = 0.05
            },
        }
    }
}

return this
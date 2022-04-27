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
                r = -0.08,
                g = -0.1,
                b = -0.1
            },
            ["day"] = {
                r = -0.1,
                g = -0.1,
                b = -0.1
            },
            ["dusk"] = {
                r = -0.07,
                g = -0.11,
                b = -0.11
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
                r = -0.07,
                g = -0.11,
                b = -0.11
            },
            ["day"] = {
                r = -0.13,
                g = -0.13,
                b = -0.13
            },
            ["dusk"] = {
                r = -0.06,
                g = -0.1,
                b = -0.1
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
local this = {}

this.baseTimerDuration = 0.3
this.lerpTime = 0.03
this.speedCoefficient = 25
this.minimumSpeed = 20

this.fogTypes = {
    ["cloud"] = {
        name = "cloud",
        mesh = "tew\\Vapourmist\\vapourcloud.nif",
        height = 4300,
        initialSize = {200, 250, 300, 350, 420, 450, 500, 510, 550},
        isAvailable = function(_, weather)
            if this.fogTypes["cloud"].blockedWeathers[weather.index] then
                return false
            end
            return true
        end,
        blockedWeathers = {[0] = true, [6] = true, [7] = true, [9] = true},
        colours = {
            ["dawn"] = {
                r = 0.035,
                g = 0.025,
                b = 0.025
            },
            ["day"] = {
                r = 0.03,
                g = 0.03,
                b = 0.03
            },
            ["dusk"] = {
                r = 0.04,
                g = 0.035,
                b = 0.035
            },
            ["night"] = {
                r = 0.015,
                g = 0.015,
                b = 0.020
            },
        }
    },
    ["mist"] = {
        name = "mist",
        mesh = "tew\\Vapourmist\\vapourmist.nif",
        height = 40,
        initialSize = {350, 460, 550, 600, 675, 700},
        isAvailable = function(gameHour, weather)

            if this.fogTypes["mist"].blockedWeathers[weather.index] then
                return false
            end

           if (
                ((gameHour >= WtC.sunriseHour + 2 and gameHour <= 24)
                or (gameHour >= 24 and gameHour < WtC.sunsetHour - 1))
                and not (this.fogTypes["mist"].mistyWeathers[weather.index])
            ) or (this.fogTypes["mist"].blockedWeathers[weather.index]) then
                return false
            end

            return true
        end,
        blockedWeathers = {[0] = true, [1] = true, [4] = true, [5] = true, [6] = true, [7] = true, [8] = true, [9] = true},
        wetWeathers = {[4] = true, [5] = true},
        mistyWeathers = {[2] = true, [3] = true},
        colours = {
            ["dawn"] = {
                r = 0.04,
                g = 0.05,
                b = 0.05
            },
            ["day"] = {
                r = 0.03,
                g = 0.03,
                b =-0.03
            },
            ["dusk"] = {
                r = 0.03,
                g = 0.02,
                b = 0.025
            },
            ["night"] = {
                r = 0.02,
                g = 0.02,
                b = 0.03
            },
        }
    }
}

return this
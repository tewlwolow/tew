local modversion = require("tew.AURA.version")
local version = modversion.version
local config = require("tew.AURA.config")
local sounds=require("tew.AURA.sounds")
local common=require("tew.AURA.common")

local debugLog = common.debugLog

local WtC

-- Map between weather types, rain types and sound id --
local rainLoops = {
    ["Rain"] = {
        ["light"] = "tew_rain_light",
        ["medium"] = "tew_rain_medium",
        ["heavy"] = "tew_rain_heavy"
    },
    ["Thunderstorm"] = {
        ["light"] = "tew_thunder_light",
        ["medium"] = "tew_thunder_medium",
        ["heavy"] = "tew_thunder_heavy"
    }
}

-- For interior weather module --
local interiorRainLoops = {
    ["big"] = {
        ["light"] = "tew_b_rainlight",
        ["medium"] = "tew_b_rainmedium",
        ["heavy"] = "tew_b_rainheavy",
        ["thunder"] = "tew_b_thunderheavy"
    },
    ["sma"] = {
        ["light"] = "tew_s_rainlight",
        ["medium"] = "tew_s_rainmedium",
        ["heavy"] = "tew_s_rainheavy",
        ["thunder"] = "tew_s_thunderheavy"
    },
    ["ten"] = {
        ["light"] = "tew_t_rainlight",
        ["medium"] = "tew_t_rainmedium",
        ["heavy"] = "tew_t_rainheavy",
        ["thunder"] = "tew_t_thunderheavy"
    }
}

-- Resolve rain type per particle amount set in Watch the Skies --
local function getRainType(particleAmount)
    if particleAmount < 500 then
        return "light"
    elseif particleAmount < 950 then
        return "medium"
    elseif particleAmount <= 1700 then
        return "heavy"
    else
        return "light"
    end
end

-- Set proper rain sounds --
local function changeRainSounds()

    -- Resolve max particles --
    local rainy = WtC.weathers[5]
    local rainyType = getRainType(rainy.maxParticles)
    local stormy = WtC.weathers[6]
    local stormyType = getRainType(stormy.maxParticles)

    debugLog("Rain type: "..rainyType)
    debugLog("Storm type: "..stormyType)

    if WtC.currentWeather.rainLoopSound then
        WtC.currentWeather.rainLoopSound:stop()
    end

    -- Load sounds --
    rainy.rainLoopSound = tes3.getSound(rainLoops["Rain"][rainyType])
    stormy.rainLoopSound = tes3.getSound(rainLoops["Thunderstorm"][stormyType])

    -- Also change interior rain sounds --
    if config.moduleInteriorWeather then
        local weather = WtC.currentWeather
        if weather.maxParticles then
            local interiorRainType = getRainType(weather.maxParticles)
            if weather.name == "Thunderstorm" then interiorRainType = "thunder" end
            for interiorType, array in pairs(sounds.interiorWeather) do
                array[4] = tes3.getSound(interiorRainLoops[interiorType][interiorRainType])
                array[5] = tes3.getSound(interiorRainLoops[interiorType][interiorRainType])
            end
        end
    end

end

print("[AURA "..version.."] Rain sounds initialised.")
WtC=tes3.worldController.weatherController

-- Also make sure we're setting these on loaded --
event.register("loaded", changeRainSounds, {priority=-233})
-- Use custom event from Watch the Skies - no much sense otherwise, who else changes these? :-) --
event.register("WtS:maxParticlesChanged", changeRainSounds, {priority=-233})
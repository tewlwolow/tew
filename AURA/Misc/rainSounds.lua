local modversion = require("tew.AURA.version")
local version = modversion.version
local config = require("tew.AURA.config")
local sounds=require("tew.AURA.sounds")

local WtC

local rainLoops = {
    ["Rain"] = {
        ["light"] = "tew_rain_light",
        ["medium"] = "tew_rain_medium",
        ["heavy"] = "tew_rain_heavy"
    },
    ["Thunder"] = {
        ["light"] = "tew_thunder_light",
        ["medium"] = "tew_thunder_medium",
        ["heavy"] = "tew_thunder_heavy"
    }
}

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

local function changeRainSounds(e)
    if (WtC.currentWeather.name == "Rain" or WtC.currentWeather.name == "Thunder") or (WtC.nextWeather and (WtC.nextWeather.name == "Rain" or WtC.nextWeather.name == "Thunder")) then
		local particleAmount
        local weatherName
        if e and e.to then
            weatherName = e.to.name
            particleAmount = e.to.maxParticles
        else
            weatherName = WtC.currentWeather.name
            particleAmount = WtC.currentWeather.maxParticles
        end
        if not particleAmount then return end
        local rainType
        if particleAmount < 550 then
            rainType = "light"
        elseif particleAmount < 950 then
            rainType = "medium"
        elseif particleAmount <= 1700 then
            rainType = "heavy"
        else
            rainType = "light"
        end

        WtC.weathers[5].rainLoopSound = tes3.getSound(rainLoops[weatherName][rainType])
        WtC.weathers[6].rainLoopSound = tes3.getSound(rainLoops[weatherName][rainType])

        if config.moduleInteriorWeather then
            if weatherName == "Thunder" then rainType = "thunder" end
            for interiorType, array in pairs(sounds.interiorWeather) do
                array[4] = tes3.getSound(interiorRainLoops[interiorType][rainType])
                array[5] = tes3.getSound(interiorRainLoops[interiorType][rainType])
            end
        end
	end
end

print("[AURA "..version.."] Rain sounds initialised.")
WtC=tes3.worldController.weatherController
event.register("weatherChangedImmediate", changeRainSounds, {priority=-180})
event.register("weatherTransitionImmediate", changeRainSounds, {priority=-180})
event.register("weatherTransitionStarted", changeRainSounds, {priority=-180})
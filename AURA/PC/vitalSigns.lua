local healthFlag, fatigueFlag, magickaFlag = 0, 0, 0

local healthTimer, fatigueTimer, magickaTimer
local g = ""
local player

local config = require("tew\\AURA\\config")
local PChealth = config.PChealth
local PCfatigue = config.PCfatigue
local PCmagicka = config.PCmagicka
local vsVol = config.vsVol/200

local function checkGender()

    if tes3.player.object.female then
        g = "fatigue_f.wav"
    else
        g = "fatigue_m.wav"
    end

    player = tes3.mobilePlayer

end

local function playVitals()

    local function playHealth()
        if healthFlag == 1 then return end
        if not healthTimer then
            healthTimer = timer.start{type=timer.real, duration=1.2, iterations=-1, callback=function()
                tes3.playSound{soundPath="tew\\AURA\\PC\\health.wav", reference=player, volume=0.7*vsVol}
            end}
        else
            healthTimer:resume()
        end
        healthFlag = 1
    end

    local function playFatigue()
        if fatigueFlag == 1 then return end
        if not fatigueTimer then
            fatigueTimer = timer.start{type=timer.real, duration=2.8, iterations=-1, callback=function()
                tes3.playSound{soundPath="tew\\AURA\\PC\\"..g, reference=player, volume=0.6*vsVol}
            end}
        else
            fatigueTimer:resume()
        end
        fatigueFlag = 1
    end

    local function playMagicka()
        if magickaFlag == 1 then return end
        if not magickaTimer then
            magickaTimer = timer.start{type=timer.real, duration=4, iterations=-1, callback=function()
                tes3.playSound{soundPath="tew\\AURA\\PC\\magicka.wav", reference=player, volume=0.6*vsVol, pitch=0.8}
            end}
        else
            magickaTimer:resume()
        end
        magickaFlag = 1
    end

    if PChealth then

        local maxHealth = player.health.base
        local currentHealth = player.health.current

        if currentHealth < maxHealth/3 then
            playHealth()
        else
            if healthTimer then
                healthTimer:pause()
            end
            healthFlag = 0
        end
    end

    if PCfatigue then

        local maxFatigue = player.fatigue.base
        local currentFatigue = player.fatigue.current

        if currentFatigue < maxFatigue/3 then
            playFatigue()
        else
            if fatigueTimer then
                fatigueTimer:pause()
            end
            fatigueFlag = 0
        end
    end

    if PCmagicka then

        local maxMagicka = player.magicka.base
        local currentMagicka = player.magicka.current

        if currentMagicka < maxMagicka/3 then
            playMagicka()
        else
            if magickaTimer then
                magickaTimer:pause()
            end
            magickaFlag = 0
        end
    end

end

event.register("loaded", checkGender)
event.register("simulate", playVitals)
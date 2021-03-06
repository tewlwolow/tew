local config = require("tew\\AURA\\config")
local playerRace, playerSex
local serviceVoicesData = require("tew\\AURA\\Service Voices\\serviceVoicesData")
local raceNames=serviceVoicesData.raceNames
local tauntsData = require("tew\\AURA\\PC\\tauntsData")
local tVol = config.tVol
local tauntChance = config.tauntChance
local debugLogOn = config.debugLogOn
local modversion = require("tew\\AURA\\version")
local version = modversion.version
local playedTaunt = 0

local function debugLog(string)
    if debugLogOn then
       mwse.log("[AURA "..version.."] PC: "..string.format("%s", string))
    end
end

--[[local function getArrays()

    local VDir = "Data Files\\Sound\\Vo"

    print("this.NPCtaunts = {\n")
    for race in lfs.dir(VDir) do
        if race ~= "." and race ~= ".." then
            for _, v in pairs(raceNames) do
                if race == v then
                    print("[\""..v.."\"]".." = {")
                    for gender in lfs.dir(VDir.."\\"..v) do
                        if gender ~= "." and gender ~= ".." then
                            print("[\""..gender.."\"]".." = {")
                            for file in lfs.dir(VDir.."\\"..v.."\\"..gender) do
                                if string.startswith(file, "Atk") then
                                    print("\""..file.."\",")
                                end
                            end
                            print("\n},")
                        end
                    end
                    print("\n},")
                end
            end
        end
    end
    print("\n}")

    print("this.Crtaunts = {\n")
    for race in lfs.dir(VDir) do
        if race ~= "." and race ~= ".." then
            for _, v in pairs(raceNames) do
                if race == v then
                    print("[\""..v.."\"]".." = {")
                    for gender in lfs.dir(VDir.."\\"..v) do
                        if gender ~= "." and gender ~= ".." then
                            print("[\""..gender.."\"]".." = {")
                            for file in lfs.dir(VDir.."\\"..v.."\\"..gender) do
                                if string.startswith(file, "CrAtk")
                                or string.startswith(file, "bAtk") then
                                    print("\""..file.."\",")
                                end
                            end
                            print("\n},")
                        end
                    end
                    print("\n},")
                end
            end
        end
    end
    print("\n}")

end]]

local function playerCheck()
    playedTaunt = 0
    if tes3.player.object.female then
        playerSex = "f"
    else
        playerSex = "m"
    end

    for k, v in pairs(raceNames) do
        if tes3.player.object.race.id == k then
            playerRace = v
        end
    end

    debugLog("Determined player race: "..playerRace)
    debugLog("Determined player sex: "..playerSex)
end

local function combatCheck(e)

    if playedTaunt == 1 then debugLog("Flag on. Returning.") return end

    local player = tes3.mobilePlayer
    if e.target == player or e.actor == player
    and playerRace~=nil
    and playerSex ~= nil
    and playedTaunt == 0 then

        if tauntChance<math.random() then debugLog("Dice roll failed. Returning.") return end

        local taunt

        if e.target.object.objectType ~= tes3.objectType.creature
        and e.actor.object.objectType ~= tes3.objectType.creature then
            local foe, foeRace
            if e.target ~= player then
                foe = e.target
            else
                foe = e.actor
            end
            foeRace = foe.object.race.id
            debugLog("Foe race: "..foe.object.race.id)
            local raceTaunts = tauntsData.raceTaunts
            if raceTaunts[playerRace]
            and raceTaunts[playerRace][playerSex]
            and raceTaunts[playerRace][playerSex][foeRace] then
                taunt = raceTaunts[playerRace][playerSex][foeRace]
            end
            if taunt ~= nil then
                debugLog("Race-based taunt: "..taunt)
            end
            if taunt == nil then
                local taunts = tauntsData.NPCtaunts
                taunt = taunts[playerRace][playerSex][math.random(1, #taunts[playerRace][playerSex])]
                debugLog("NPC taunt: "..taunt)
            end
        else
            local taunts = tauntsData.Crtaunts
            taunt = taunts[playerRace][playerSex][math.random(1, #taunts[playerRace][playerSex])]
            debugLog("Creature taunt: "..taunt)
        end


        tes3.say{
            volume=0.9*tVol,
            soundPath="Vo\\"..playerRace.."\\"..playerSex.."\\".. taunt,
            reference=player
        }

        playedTaunt = 1
        debugLog("Played battle taunt: "..taunt)

        timer.start{type=timer.real, duration=3, callback=function()
            playedTaunt = 0
        end}
    else
        debugLog("Could not determine battle situation.")
        debugLog(e.target.object.id)
        debugLog(e.actor.object.id)
    end

end

event.register("loaded", playerCheck)
event.register("combatStarted", combatCheck)

--getArrays()
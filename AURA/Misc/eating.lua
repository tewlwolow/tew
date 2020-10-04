
local modversion = require("tew\\AURA\\version")
local version = modversion.version

local function eating(e)

    tes3.getSound("Swallow").volume = 0

    if e.item.objectType == tes3.objectType.ingredient then
        tes3.playSound{reference=e.reference, soundPath="Fx\\eating.wav"}
        timer.start{
            type=timer.real,
            duration=1.3,
            callback=function()
            tes3.playSound{reference=e.reference, sound="Swallow"}
        end}
    end

    if e.item.objectType == tes3.objectType.potion then
        tes3.playSound{soundPath="Fx\\item\\drink.wav"}
    end

    --tes3.getSound("Swallow").volume = 1.0

end

print("[AURA "..version.."] Eating sound initialised.")
event.register("equip", eating)
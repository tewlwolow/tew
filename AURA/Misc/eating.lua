
local modversion = require("tew\\AURA\\version")
local version = modversion.version

local function eating(e)

    if e.item.objectType == tes3.objectType.ingredient then
        tes3.removeSound{sound="Swallow"}
        tes3.playSound{reference=e.reference, soundPath="Fx\\eating.wav"}
        --[[timer.start{
            type=timer.real,
            duration=1.2,
            callback=function()
            tes3.playSound{reference=e.reference, sound="swallow"}
        end}--]]
    end

    if e.item.objectType == tes3.objectType.potion then
        tes3.removeSound{sound="Swallow"}
        tes3.playSound{soundPath="Fx\\item\\drink.wav"}
        --[[timer.start{
            type=timer.real,
            duration=1.2,
            callback=function()
            tes3.playSound{reference=e.reference, sound="swallow"}
        end}--]]
    end
end

print("[AURA "..version.."] Eating sound initialised.")
event.register("equip", eating)
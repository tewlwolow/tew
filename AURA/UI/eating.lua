local modversion = require("tew\\AURA\\version")
local version = modversion.version

local function eating(e)
    tes3.getSound("Swallow").volume = 0

    if e.item.objectType == tes3.objectType.ingredient then
        tes3.playSound{reference=e.reference, soundPath="Fx\\eating.wav"}
    end
end

print("[AURA "..version.."] UI: Eating sound initialised.")
event.register("equip", eating)
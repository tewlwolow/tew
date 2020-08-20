local modversion = require("tew\\AURA\\version")
local version = modversion.version
local function splashPlay(e)
    local element=e.element
    tes3.playSound{soundPath="Fx\\envrn\\splash_lrg.wav", volume=0.5, pitch=0.6}
    element:register("destroy", function()
        tes3.playSound{soundPath="Fx\\envrn\\splash_sml.wav", volume=0.3, pitch=0.8}
    end)
end

print("[AURA "..version.."] Splash sounds initialised.")
event.register("uiActivated", splashPlay, {filter="MenuSwimFillBar"})
local modversion = require("tew\\AURA\\version")
local version = modversion.version
local config = require("tew\\AURA\\config")
local debugLogOn=config.debugLogOn

local function debugLog(string)
    if debugLogOn then
       mwse.log("[AURA "..version.."] UI: "..string)
    end
 end

local function onSpellPurchaseMenu(e)

    tes3.playSound{sound="scroll", volume=0.6}
    debugLog("Opening spell menu sound played.")

    local element=e.element:findChild(-1155)

    for _, spellClick in pairs(element.children) do
        if string.find(spellClick.text, "gp") then
            spellClick:register("mouseDown", function()
            tes3.playSound{soundPath="FX\\MysticGate.wav", reference=tes3.player, volume=0.8}
            debugLog("Purchase spell sound played.")
            end)
        end
    end

end


print("[AURA "..version.."] UI: Spell purchase sounds initialised.")
event.register("uiActivated", onSpellPurchaseMenu, {filter="MenuServiceSpells"})
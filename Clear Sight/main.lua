local config = require("tew\\Clear Sight\\config")
local debugLogOn = config.debugLogOn
local modversion = require("tew\\Clear Sight\\version")
local version = modversion.version

local menuMulti, coolDownTimer
local spellFlag = 0
local toggleFlag = 0
local weaponFlag = 0

local function debugLog(string)
    if debugLogOn then
       mwse.log("[Clear Sight "..version.."] "..string.format("%s", string))
    end
end

local keys = {
    tes3.keybind.nextSpell,
    tes3.keybind.previousSpell,
    tes3.keybind.previousWeapon,
    tes3.keybind.nextWeapon
}

local function stopTimer()
    if coolDownTimer ~= nil then
        coolDownTimer:pause()
        coolDownTimer:cancel()
        coolDownTimer = nil
    end
end

local function hideHUD()
    if menuMulti then
        menuMulti.visible = false
    end
end

local function showHUD()
    if menuMulti then
        menuMulti.visible = true
    end
end


local function onLoaded()
    timer.delayOneFrame(function()
        menuMulti = tes3ui.findMenu(tes3ui.registerID("MenuMulti"))
        debugLog("Game loaded. Hiding HUD.")
        hideHUD()
    end)
end

local function coolDown()
    coolDownTimer = timer.start{
        type = timer.simulate,
        duration = config.cooldownDuration,
        callback = hideHUD
    }
end

local function onWeaponReadied()
    stopTimer()
    debugLog("Weapon readied. Showing HUD.")
    showHUD()
    spellFlag = 0
    weaponFlag = 1
end

local function onWeaponUnreadied()
    if spellFlag == 0 then
        stopTimer()
        debugLog("Weapon unreadied. Hiding HUD in a bit.")
        coolDown()
        weaponFlag = 0
    end
end

local function onSpellCast()
    if spellFlag == 0 and weaponFlag == 0 then
        debugLog("Spell cast. Showing HUD for a bit.")
        stopTimer()
        showHUD()
        coolDown()
    end
end

local function onMenuExit()
    if toggleFlag == 0 and spellFlag == 0 and weaponFlag == 0 then
        timer.delayOneFrame(function()
            hideHUD()
            debugLog("Exiting menu mode. Hiding HUD.")
        end)
    end
end

local function isKeyDown(key)
    local inputController = tes3.worldController.inputController
    return inputController:keybindTest(key)
end

local function onKeyDown(e)

    if tes3.worldController.inputController:isKeyDown(config.toggleKey.keyCode) and e.isAltDown then
        stopTimer()
        if toggleFlag == 0 then
            debugLog("Toggle key down. Showing HUD.")
            showHUD()
            toggleFlag = 1
            return
        else
            debugLog("Toggle key down. Hiding HUD.")
            hideHUD()
            toggleFlag = 0
            return
        end
    end

   for _, key in pairs(keys) do
        if isKeyDown(key) and toggleFlag == 0 and spellFlag == 0 and weaponFlag == 0 then
            debugLog("Action key down. Showing HUD for a bit.")
            stopTimer()
            showHUD()
            coolDown()
            return
        end
    end

    if isKeyDown(tes3.keybind.readyMagicMCP) then
        stopTimer()
        if spellFlag == 0 then
            debugLog("Ready Magic key down. Showing HUD.")
            showHUD()
            spellFlag = 1
            return
        else
            debugLog("Ready Magic key down. Hiding HUD in a bit.")
            spellFlag = 0
            weaponFlag = 0
            coolDown()
            return
        end
    end

end

local function onAttacked(e)
    if e.target == tes3.player then
        debugLog("Player attacked. Showing HUD.")
        stopTimer()
        showHUD()
    end
end

local function onCombatStopped(e)
    if e.actor == tes3.player then
        debugLog("Player out of combat. Hiding HUD in a bit.")
        stopTimer()
        coolDown()
    end
end

local function init()
    event.register("menuExit", onMenuExit)
    event.register("keyDown", onKeyDown)
    event.register("loaded", onLoaded)

    mwse.log("Clear Sight "..version.." loaded.")

    -- Additional logic --
    event.register("weaponReadied", onWeaponReadied)
    event.register("weaponUnreadied", onWeaponUnreadied)

    event.register("spellCast", onSpellCast)

    event.register("combatStarted", onAttacked)
    event.register("combatStop", onCombatStopped)
end

event.register("initialized", init)

event.register("modConfigReady", function()
    dofile("Data Files\\MWSE\\mods\\tew\\Clear Sight\\mcm.lua")
end)
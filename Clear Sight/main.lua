local config = require("tew\\Clear Sight\\config")
local debugLogOn = config.debugLogOn
local modversion = require("tew\\Clear Sight\\version")
local version = modversion.version

local menuMulti, coolDownTimer
local stateFlag = 0
local toggleFlag = 0

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

local stateKeys = {
    tes3.keybind.readyWeapon,
    tes3.keybind.readyMagic,
    tes3.keybind.readyMagicMCP
}

local function stopTimer()
    if coolDownTimer then
        coolDownTimer:pause()
        coolDownTimer:cancel()
        coolDownTimer = nil
    end
end

local function hideHUD()
    menuMulti.visible = false
end

local function onLoaded()
    timer.delayOneFrame(function()
        menuMulti = tes3ui.findMenu(tes3ui.registerID("MenuMulti"))
        hideHUD()
    end)
end

local function getMenu(e)

    if not e.newlyCreated then return end

end

local function coolDown(menu)
    coolDownTimer = timer.start{
        type = timer.simulate,
        duration = config.cooldownDuration,
        callback=function()
            menu.visible = false
        end
    }
end

local function isKeyDown(key)
    local inputController = tes3.worldController.inputController
    return inputController:keybindTest(key)
end

local function showHUD(e)

    if tes3.worldController.inputController:isKeyDown(config.toggleKey.keyCode) and e.isAltDown then
        if toggleFlag == 0 then
            menuMulti.visible = true
            toggleFlag = 1
        else
            menuMulti.visible = false
            toggleFlag = 0
        end
    end

   for _, key in pairs(keys) do
        if isKeyDown(key) then
            stopTimer()
            menuMulti.visible = true
            coolDown(menuMulti)
            break
        end
    end

    for _, key in pairs(stateKeys) do
        if isKeyDown(key) then
            stopTimer()
            if stateFlag == 0 then
                menuMulti.visible = true
                stateFlag = 1
            else
                coolDown(menuMulti)
                stateFlag = 0
            end
            break
        end
    end

end


local function init()
    event.register("uiActivated", getMenu, { filter = "MenuStat" })
    event.register("keyDown", showHUD)
    event.register("loaded", onLoaded)
    mwse.log("[Clear Sight "..version.."] loaded.")
end

event.register("initialized", init)

event.register("modConfigReady", function()
    dofile("Data Files\\MWSE\\mods\\tew\\Clear Sight\\mcm.lua")
end)
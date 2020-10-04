local modversion = require("tew\\AURA\\version")
local version = modversion.version
local config=require("tew\\AURA\\config")

local function init()
    local moduleAmbientOutdoor = config.moduleAmbientOutdoor
    local playSplash = config.playSplash
    local travelFee = config.travelFee
    local playYurtFlap = config.playYurtFlap
    local playEating = config.playEating
    local playSpellPurchase = config.playSpellPurchase

    if playSplash and not moduleAmbientOutdoor then
        print("[AURA "..version.."] Loading file: waterSplash.lua")
        dofile("Data Files\\MWSE\\mods\\tew\\AURA\\Misc\\waterSplash.lua")
    end

    if playSplash and moduleAmbientOutdoor then
        print("[AURA "..version.."] OA module and Misc (Splash) option enabled. OA splash logic takes precedence.")
    end

    if travelFee then
        print("[AURA "..version.."] Loading file: travelFee.lua")
        dofile("Data Files\\MWSE\\mods\\tew\\AURA\\Misc\\travelFee.lua")
    end

    if playYurtFlap then
        print("[AURA "..version.."] Loading file: yurtFlap.lua")
        dofile("Data Files\\MWSE\\mods\\tew\\AURA\\Misc\\yurtFlap.lua")
    end

    if playEating then
        print("[AURA "..version.."] Loading file: eating.lua")
        dofile("Data Files\\MWSE\\mods\\tew\\AURA\\Misc\\eating.lua")
    end

    if playSpellPurchase then
        print("[AURA "..version.."] Loading file: spellPurchase.lua")
        dofile("Data Files\\MWSE\\mods\\tew\\AURA\\Misc\\spellPurchase.lua")
    end
end

print("[AURA "..version.."] Miscellaneous module initialised.")
init()
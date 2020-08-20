local modversion = require("tew\\AURA\\version")
local version = modversion.version
local config=require("tew\\AURA\\config")

local function init()
    local moduleAmbientOutdoor = config.moduleAmbientOutdoor
    local playSplash = config.playSplash
    local travelFee = config.travelFee
    local playYurtFlap = config.playYurtFlap
    local playBanners = config.playBanners
    local playOverhang = config.playOverhang

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

    if playBanners then
        print("[AURA "..version.."] Loading file: bannerFlap.lua")
        dofile("Data Files\\MWSE\\mods\\tew\\AURA\\Misc\\bannerFlap.lua")
    end

    if playOverhang then
        print("[AURA "..version.."] Loading file: overhangRain.lua")
        dofile("Data Files\\MWSE\\mods\\tew\\AURA\\Misc\\overhangRain.lua")
    end



end

print("[AURA "..version.."] Miscellaneous module initialised.")
init()
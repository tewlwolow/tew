-- CHIMES - Communal Harmonic Immersive Music Extension System  --
--------------------------------------------------------------------------------------

local metadata = require("tew.CHIMES.metadata")
local version = metadata.version

local function init()




    mwse.log("[CHIMES] Version "..version.." initialised.")
end

-- Registers MCM menu --
event.register("modConfigReady", function()
    dofile("Data Files\\MWSE\\mods\\tew\\CHIMES\\mcm.lua")
end)


event.register("initialized", init)
local function onSpellPurchaseMenu(e)

    local element=e.element:findChild(-1155)

    for _, spellClick in pairs(element.children) do
        if string.find(spellClick.text, "gp") then
            spellClick:register("mouseDown", function()
            tes3.playSound{soundPath="FX\\item\\spelcreate.wav", reference=tes3.player, volume=0.8, pitch=0.6}
            end)
        end
    end

end

event.register("uiActivated", onSpellPurchaseMenu, {filter="MenuServiceSpells"})
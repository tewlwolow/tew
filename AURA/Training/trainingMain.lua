local trainingData = require("tew\\AURA\\Training\\trainingData")

local function onTrainingMenu(e)

    local element=e.element
    element=element:findChild(-1155)

    for _, vF in pairs(element.children) do
        if vF.name=="null" then
            for _, skillClick in pairs(vF.children) do
                if string.find(skillClick.text, "gp") then
                    skillClick:register("mouseDown", function()
                        for skill, sound in pairs(trainingData) do
                            if string.find(skillClick.text, skill) then
                                tes3.playSound{soundPath=sound, reference=tes3.player, volume=0.8}
                            end
                        end
                    end)
                end
            end
        end
    end
end

event.register("uiActivated", onTrainingMenu, {filter="MenuServiceTraining"})
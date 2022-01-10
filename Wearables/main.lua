-- TODO: add more stuff to wear
-- TODO: utilities/logging/comments/MCM/logo
local data = require("tew\\Wearables\\data")

local persisting

local function persist()
    tes3.player.data.wearables = tes3.player.data.wearables or {}
    persisting = tes3.player.data.wearables
end

local function getData(item)
    if item.objectType == tes3.objectType.alchemy then
        return data.potions
    elseif item.objectType == tes3.objectType.book then
        return data.books
    end

    for keyword, table in ipairs(data.wearables) do
        if string.find(item.id, keyword) then
            return table
        end
    end

    return nil
end

-- Unequip object if equipping the same object twice --
local function unequip(ref)
    local parent = ref.sceneNode:getObjectByName("Bip01 Pelvis")
    local node = parent:getObjectByName("Bip01 Belt Object")
    if node then
        parent:detachChild(node)
        parent:update()
        parent:updateNodeEffects()
        persisting.equipped = nil
    end
end

-- Faux equip item and show it on player mesh --
local function equip(ref, item, numbers)
    local wearable = tes3.getObject(item.id)

    -- Get the spine node for attaching --
    local parent = ref.sceneNode:getObjectByName("Bip01 Pelvis")

    -- Load object mesh --
    local node = tes3.loadMesh(wearable.mesh)
    if node then
        node = node:clone()
        node:clearTransforms()

        -- Rename the root node so we can easily find it for detaching --
        node.name = "Bip01 Belt Object"

        -- Offset the node to position the object correctly --
        -- Uses values defined per object in main data file --

        local m1 = tes3matrix33.new()
        m1:fromEulerXYZ(table.unpack(numbers.rot))
        local instrumentOffset = {
        translation = tes3vector3.new(table.unpack(numbers.pos)),
        rotation = m1;
        }

        node.translation = instrumentOffset.translation:copy()
        node.rotation = instrumentOffset.rotation:copy()
        node.scale = 0.8
        parent:attachChild(node, true)
        parent:update()
        parent:updateNodeEffects()

        persisting.equipped = item.id
    end

end

local function equipCheck(e)

    local ref = e.reference
    local item = e.item

    local inputController = tes3.worldController.inputController
    if not (inputController:isKeyDown(tes3.scanCode.leftShift))
    and not (inputController:isKeyDown(tes3.scanCode.rightShift)) then
        return
    end

    local numbers = getData(e.item)
    if not numbers then return end

    if persisting.equipped == nil then
        equip(ref, item, numbers)
        return false -- This blocks the event so that no actual equipping can happen
    else
        if e.item.id == persisting.equipped then
            unequip(ref)
            return false
        else
            unequip(ref)
            equip(ref, item, numbers)
            return false
        end
    end
end

local function onBarterOffer(e)
    if persisting.equipped ~= nil and
    #e.selling > 0 and e.success == true then
        for _, tile in ipairs(e.selling) do
            if tile.item.id == persisting.equipped then
                unequip(tes3.player)
            end
        end
    end
end

local function onItemDropped(e)
    if persisting.equipped ~= nil and
    e.reference.id == persisting.equipped then
        unequip(tes3.player)
    end
end

local function init()
    event.register("equip", equipCheck)
    event.register("loaded", persist, {priority = 49})
    event.register("itemDropped", onItemDropped)
    event.register("barterOffer", onBarterOffer)
end

event.register("initialized", init)
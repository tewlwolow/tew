local this={}

this.tArray={
    "howl1",
    "howl2",
    "howl3",
    "howl4",
    "howl6",
    "howl8",
    "rock and roll",
    "rocks1",
    "rocks2",
    "rocks3",
    "rocks4",
    "rocks5",
    "rocks6",
    "rocks7",
    "rocks8",
    "rumble1",
    "rumble2",
    "rumble3",
    "rumble4",
    "wind low1",
    "wind low2",
    "wind low3",
    "wind calm1",
    "wind calm2",
    "wind calm3",
    "wind calm4",
    "wind calm5",
    "wind des1",
    "wind des2",
    "wind des3",
    }

this.thunArray={
    "Thunder0",
    "Thunder1",
    "Thunder2",
    "Thunder3",
    "ThunderClap"
}

this.cellTypesSmall={
    "in_de_shack",
    "in_nord_house_02",
    "in_nord_house_03",
}

this.cellTypesTent={
    "in_ashl_tent",
    "Drs_Tnt",
}

this.windows={
    "_win_",
    "window",
    "cwin",
    "wincover",
    "swin",
    "palacewin",
    "triwin",
}

this.cellTypesCaves={
    "cave",
}

function this.checkCellDiff(cell, cellLast)
    if (cell.isInterior and not cellLast.isInterior)
    or (not cell.isInterior and cellLast.isInterior) then
        return true
    else
        return false
    end
end

function this.getCellType(cell, celltype)
    if not cell.isInterior then
        return false
    end
    for stat in cell:iterateReferences(tes3.objectType.static) do
        for _, pattern in pairs(celltype) do
            if string.find(stat.object.id:lower(), pattern) then
                return true
            end
        end
    end
end

function this.getWindoors(cell)
    local windoors={}
    for stat in cell:iterateReferences(tes3.objectType.static) do
        for _, window in pairs(this.windows) do
            if string.find(stat.object.id:lower(), window) then
                table.insert(windoors, stat)
            end
        end
    end
    for door in cell:iterateReferences(tes3.objectType.door) do
        if door.destination then
            if not door.destination.cell.isInterior or door.destination.cell.behavesAsExterior then
                table.insert(windoors, door)
            end
        end
    end
    return windoors
end

--[[
function this.getObjects(cell, objectType, stringArray)
    local objectArray={}
    for obj in cell:iterateReferences(objectType) do
        for _, pattern in pairs(stringArray) do
            if string.find(obj.object.id, pattern) then
                table.insert(objectArray, obj)
            end
        end
    end
    return objectArray
end
--]]

function this.getDistance(v0, v1)
    local dx=v1.x-v0.x
    local dy=v1.y-v0.y
    local dz=v1.z-v0.z
    return math.sqrt(dx*dx+dy*dy+dz*dz)
end

return this
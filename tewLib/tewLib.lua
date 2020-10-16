local this = {}

function this.isOpenPlaza(cell)
    if not cell.behavesAsExterior then
        return false
    else
        if (string.find(cell.name:lower(), "plaza") and string.find(cell.name:lower(), "vivec"))
        or string.find(cell.name:lower(), "arena pit") then
            return true
        else
            return false
        end
    end
end

return this
local this = {}

local config = require("tew\\Vapourmist\\config")
local version = require("tew\\Vapourmist\\version")
local VERSION = version.version

local moduleCommon = "COMMON"

local WtC = tes3.worldController.weatherController

-- Print debug messages
function this.debugLog(module, string)
    if config.debugLogOn then
        string = tostring(string)
        mwse.log("[Vapourmist "..VERSION.." --- "..module.."] "..string.format("%s", string))
    end
end


-- -- Controls faux animation of cloud rising up and moving away with time
-- function this.moveFog(e, type, speed)

-- 	local xc, yc, zc
-- 	if WtC.nextWeather then
-- 		xc = WtC.windVelocityNextWeather:normalized().x*e.delta*this.movements[type].speed[speed]
-- 		yc = WtC.windVelocityNextWeather:normalized().y*e.delta*this.movements[type].speed[speed]
-- 		zc = WtC.windVelocityNextWeather:normalized().z*e.delta*this.movements[type].speed[speed]
-- 	else
-- 		xc = WtC.windVelocityCurrWeather:normalized().x*e.delta*this.movements[type].speed[speed]
-- 		yc = WtC.windVelocityCurrWeather:normalized().y*e.delta*this.movements[type].speed[speed]
-- 		zc = WtC.windVelocityCurrWeather:normalized().z*e.delta*this.movements[type].speed[speed]

-- 		if xc == 0 then xc = 0.007 end
-- 		if yc == 0 then yc = 0.006 end
-- 		if zc == 0 then zc = 0.04 end

-- 	end

-- 	local toDelete = {}

--     for _, activeCell in ipairs(tes3.getActiveCells()) do
--         for stat in activeCell:iterateReferences(tes3.objectType.static) do
--             if stat.id == "tew_"..type:lower() then
--                 if stat.sceneNode then
--                     stat.sceneNode.translation.x = stat.sceneNode.translation.x + math.random(table.unpack(this.movements[type].x)) * xc
--                     stat.sceneNode.translation.y = stat.sceneNode.translation.y + math.random(table.unpack(this.movements[type].y)) * yc
--                     stat.sceneNode.translation.z = stat.sceneNode.translation.z + math.random(table.unpack(this.movements[type].z)) * zc
--                     stat.sceneNode:update()
--                 else
--                     table.insert(toDelete, stat)
--                 end
--             end
--         end
--     end

--     for _, stat in ipairs(toDelete) do
--         stat:delete()
--     end
-- end

-- Adds fog to the cell
function this.addFog(options)

    this.debugLog(moduleCommon, "Adding: "..tostring(options.object.id))

    local position = options.position
    local weatherNow = options.weather
    local time = options.time

	for _, activeCell in ipairs(tes3.getActiveCells()) do

		local pos = tes3vector3.new{x = table.unpack(position.first.x), y = table.unpack(position.first.y), z = table.unpack(position.first.z)}

		tes3.createReference{
			object = options.object,
			position = pos,
			cell = activeCell
		}

	end

    -- Recolour clouds
    this.reColour(weatherNow, time)
	
end

-- Removes fog from the cell
function this.removeFog(type)

    this.debugLog(moduleCommon, "Removing fog for module: "..type)

	for _, activeCell in ipairs(tes3.getActiveCells()) do
        for stat in activeCell:iterateReferences(tes3.objectType.static) do
            if stat.id == "tew_"..type:lower() then
				stat:disable()
				stat:delete()
            end
        end
    end

end

return this
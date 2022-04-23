local this = {}

local config = require("tew\\Vapourmist\\config")
local version = require("tew\\Vapourmist\\version")
local VERSION = version.version

local moduleCommon = "COMMON"

local WtC = tes3.worldController.weatherController

local moveNormalFlag, moveYeetFlag = false, false

-- Print debug messages
function this.debugLog(module, string)
    if config.debugLogOn then
        string = tostring(string)
        mwse.log("[Vapourmist "..VERSION.." --- "..module.."] "..string.format("%s", string))
    end
end

-- -- Create regex for static names used to spawn the mesh in natural locations
-- this.re = require("re")
-- this.PATTERNS = re.compile[[
--         "stone" /
--         "flora_kelp" /
--         "ashtree" /
--         "rock" /
--         "_rock_" /
--         "menhir" /
--         "_tree_" /
--         "ex_" /
--         "hlaalu" /
--         "bw_" /
--         "necrom" /
--         "parasol"
--     ]]

-- Vector and speed constants
this.movements = {
    ["CLOUD"] = {
        x = {10, 50},
        y = {30, 70},
        z = {-10, 15},
        speed = {
            ["normal"] = 0.6,
            ["yeet"] = 3
        }
    },
    ["MIST"] = {
        x = {-5, 60},
        y = {-10, 20},
        z = {10, 40},
        speed = {
            ["normal"] = 0.2,
        }
    }
}

-- Controls faux animation of cloud rising up and moving away with time
function this.moveFog(e, type, speed)

	local xc, yc, zc
	if WtC.nextWeather then
		xc = WtC.windVelocityNextWeather:normalized().x*e.delta*this.movements[type].speed[speed]
		yc = WtC.windVelocityNextWeather:normalized().y*e.delta*this.movements[type].speed[speed]
		zc = WtC.windVelocityNextWeather:normalized().z*e.delta*this.movements[type].speed[speed]
	else
		xc = WtC.windVelocityCurrWeather:normalized().x*e.delta*this.movements[type].speed[speed]
		yc = WtC.windVelocityCurrWeather:normalized().y*e.delta*this.movements[type].speed[speed]
		zc = WtC.windVelocityCurrWeather:normalized().z*e.delta*this.movements[type].speed[speed]

		if xc == 0 then xc = 0.007 end
		if yc == 0 then yc = 0.006 end
		if zc == 0 then zc = 0.04 end

	end

	local toDelete = {}

    for _, activeCell in ipairs(tes3.getActiveCells()) do
        for stat in activeCell:iterateReferences(tes3.objectType.static) do
            if stat.id == "tew_"..type:lower() then
                if stat.sceneNode then
                    stat.sceneNode.translation.x = stat.sceneNode.translation.x + math.random(table.unpack(this.movements[type].x)) * xc
                    stat.sceneNode.translation.y = stat.sceneNode.translation.y + math.random(table.unpack(this.movements[type].y)) * yc
                    stat.sceneNode.translation.z = stat.sceneNode.translation.z + math.random(table.unpack(this.movements[type].z)) * zc
                    stat.sceneNode:update()
                else
                    table.insert(toDelete, stat)
                end
            end
        end
    end

    for _, stat in ipairs(toDelete) do
        stat:delete()
    end
end

-- Move clouds normally
function this.moveNormal(type)
    -- Stop yeeting already!
	if moveYeetFlag then
		event.unregister("simulate", function(e)
			this.moveFog(e, type, "yeet")
		end)
		moveYeetFlag = false
	end	

    -- Move clouds
	if not moveNormalFlag then
		event.register("simulate", function(e)
			this.moveFog(e, type, "normal")
		end)
		moveNormalFlag = true
	end
end

-- Yeet clouds
function this.moveYeet(type)
    -- Stop moving mate
	if moveNormalFlag then
		event.unregister("simulate", function(e)
			this.moveFog(e, type, "normal")
		end)
		moveNormalFlag = false
	end

    -- YEET!
	if not moveYeetFlag then
		event.register("simulate", function(e)
			this.moveFog(e, type, "yeet")
		end)
		moveYeetFlag = true
	end
end

-- Adds fog to the cell
function this.addFog(options)

    this.debugLog(moduleCommon, "Adding fog for module: "..tostring(options.type))

    local position = options.position
    local weatherNow = options.weather
    local time = options.time

    this.debugLog(moduleCommon, "Module: "..tostring(options.type))

	local counter = 0

	for _, activeCell in ipairs(tes3.getActiveCells()) do
		for stat in activeCell:iterateReferences(tes3.objectType.static) do
			if 	counter >= options.limit then break end
			if options.density/100 > math.random() then

				local statPosition = stat.position:copy()
				statPosition.x = statPosition.x + math.random(table.unpack(position.first.x))
				statPosition.y = statPosition.y + math.random(table.unpack(position.first.y))
				statPosition.z = statPosition.z + math.random(table.unpack(position.first.z))
				local cloudPosition = statPosition

				tes3.createReference{
					object = options.object,
					position = cloudPosition,
					cell = activeCell,
					scale = math.random(table.unpack(options.scale.first))/10
				}

				if options.density/120 > math.random() then

					statPosition.x = statPosition.x - math.random(table.unpack(position.second.x))
					statPosition.y = statPosition.y - math.random(table.unpack(position.second.y))
					statPosition.z = statPosition.z - math.random(table.unpack(position.second.z))
					cloudPosition = statPosition

					tes3.createReference{
						object = options.object,
						position = cloudPosition,
						cell = activeCell,
						scale = math.random(table.unpack(options.scale.second))/10
					}

					
				end
				counter = counter + 1
			end
		end
		counter = 0
	end

    -- Recolour clouds
    -- reColour(weatherNow, time)
	
    this.moveNormal(options.type)

end

-- Removes fog from the cell
function this.removeFog(type)

    this.debugLog(moduleCommon, "Removing fog for module: "..type)

	-- Unregister events
	if moveNormalFlag then
		event.unregister("simulate", function(e)
			this.moveFog(e, type, "normal")
		end)
		moveNormalFlag = false
	end

	if moveYeetFlag then
		event.unregister("simulate", function(e)
			this.moveFog(e, type, "yeet")
		end)
		moveYeetFlag = false
	end

	for _, activeCell in ipairs(tes3.getActiveCells()) do
        for stat in activeCell:iterateReferences(tes3.objectType.static) do
            if stat.id == "tew_"..type:lower() then
				stat:disable()
				stat:delete()
            end
        end
    end

end

-- Would need to move to tewLib maybe?

function this.getDistance(v0, v1)
	local dx=v1.x-v0.x
	local dy=v1.y-v0.y
	local dz=v1.z-v0.z
	return math.sqrt(dx*dx+dy*dy+dz*dz)
end


-- Distance check for fog refs
-- TODO: Control if not too crashy
function this.distanceCheck(type)
	for _, activeCell in ipairs(tes3.getActiveCells()) do
        for stat in activeCell:iterateReferences(tes3.objectType.static) do
            if stat.id == "tew_"..type:lower() and (not stat.deleted) then
				if tes3.player then
					local playerPos = tes3.player.position
					if this.getDistance(playerPos, stat.position) >= 5500 then
						stat:disable()
						stat:delete()
					end
				end
            end
        end
    end
end

return this
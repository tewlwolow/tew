local this = {}

local config = require("tew\\Vapourmist\\config")
local version = require("tew\\Vapourmist\\version")
local VERSION = version.version

local WtC = tes3.worldController.weatherController

-- TODO: lerp colours
-- TODO: calculate fog height for static position, clamp if > height

-- Print debug messages
function this.debugLog( string)
    if config.debugLogOn then
        string = tostring(string)
        mwse.log("[Vapourmist "..VERSION.."] "..string.format("%s", string))
    end
end

-- Resets the cell table
function this.purgeFoggedCells(type)
	local player = tes3.player
	if player and player.data.vapourmist and player.data.vapourmist.cells and player.data.vapourmist.cells[type] then
		player.data.vapourmist.cells[type] = {}
		this.debugLog("Purged fogged cells for type: "..type)
	end
end

-- Updates cached cell data
function this.updateData(activeCell, type)
	local player = tes3.player
	if player and player.data.vapourmist and player.data.vapourmist.cells and player.data.vapourmist.cells[type] then
		table.insert(player.data.vapourmist.cells[type], activeCell)
		this.debugLog("Cell: "..activeCell.editorName.." added to "..type.." fog cache.")
	end
end

-- Returns true if the cell is fogged
function this.isCellFogged(activeCell, type)
	local player = tes3.player
	if player and player.data.vapourmist and player.data.vapourmist.cells and player.data.vapourmist.cells[type] then
		for _, cell in ipairs(player.data.vapourmist.cells[type]) do
			if cell == activeCell then
				this.debugLog("Cell: "..cell.editorName.." is fogged.")
				return true
			end
		end
	end
	return false
end

-- Determine fog position
function this.getFogPosition(activeCell, height)
	local average = 0
	local denom = 0
	for  stat in activeCell:iterateReferences() do
		average = average + stat.position.z
		denom = denom + 1
	end

	if average == 0 or denom == 0 then
		return height
	else
		if ((average/denom) + height) <= 0 then
			return height
		elseif ((average/denom) + height) > height then
			return height + 100
		end
	end

	return (average/denom) + height

end

-- Determine time of day
function this.getTime(gameHour)
	if (gameHour >= WtC.sunriseHour) and (gameHour < WtC.sunriseHour + 2) then
		return "dawn"
	elseif (gameHour >= WtC.sunriseHour + 2) and (gameHour < WtC.sunsetHour - 1) then
		return "day"
	elseif (gameHour >= WtC.sunsetHour - 1) and (gameHour < WtC.sunsetHour + 2) then
		return "dusk"
	elseif (gameHour >= WtC.sunsetHour + 2) or (gameHour < WtC.sunriseHour) then
		return "night"
	end
end

-- Appculling switch
function this.switchFog(bool, type)
	local vfxRoot = tes3.game.worldSceneGraphRoot.children[9]
	for _, node in pairs(vfxRoot.children) do
		if node and node.name == "tew_"..type then
			for _, fog in pairs(node.children) do
				if fog.name == "Mist Emitter" then
					fog.appCulled = bool
                    fog:update()
					this.debugLog("Fog switched to "..tostring(bool))
				end
			end
		end
	end
end

function this.getMGEFogColour(time, weather)
	if time == "dawn" then
		return weather.fogSunriseColor
	elseif time == "day" then
		return weather.fogDayColor
	elseif time == "dusk" then
		return weather.fogSunsetColor
	elseif time == "night" then
		return weather.fogNightColor
	end
end

-- Recolours fog nodes with slightly modified current fog colour by modifying colour keys in NiColorData and material property values
function this.reColour(options)

	local time = options.time
	local colours = options.colours
	local type = options.type
	local weather = WtC.weathers[options.weather+1]

    this.debugLog("Running colour change.")

    local vfxRoot = tes3.game.worldSceneGraphRoot.children[9]

	for _, vfx in pairs(vfxRoot.children) do
        if not vfx then break end

		if vfx.name == "tew_"..type then
            local particleSystem = vfx:getObjectByName("MistEffect")
            local colorModifier = particleSystem.controller.particleModifiers

			local fogColour = this.getMGEFogColour(time, weather)
			fogColour = {fogColour.r + colours[time].r, fogColour.g + colours[time].g, fogColour.b + colours[time].b}

			for _, key in ipairs(colorModifier.colorData.keys) do
				key.color.r, key.color.g, key.color.b = table.unpack(fogColour)
			end

            local materialProperty = particleSystem.materialProperty
            materialProperty.emissive = fogColour
            materialProperty.specular = fogColour
            materialProperty.diffuse = fogColour
            materialProperty.ambient = fogColour

            particleSystem:updateNodeEffects()
	    end
    end

end

-- Adds fog to the cell
function this.addFog(options)

    local mesh = options.mesh
	local type = options.type
	local weather = options.weather
	local time = options.time
	local height = options.height
	local colours = options.colours

	this.debugLog("Checking if we can add fog: "..type)

	local vfxRoot = tes3.game.worldSceneGraphRoot.children[9]

	for _, activeCell in ipairs(tes3.getActiveCells()) do
		if not this.isCellFogged(activeCell, type) then
			this.debugLog("Cell is not fogged. Adding "..type..".")

			local fogMesh = tes3.loadMesh(mesh):clone()

			fogMesh:clearTransforms()
			fogMesh.translation = tes3vector3.new(
				8192 * activeCell.gridX + 4096,
				8192 * activeCell.gridY + 4096,
				this.getFogPosition(activeCell, height)
			)

			vfxRoot:attachChild(fogMesh, true)

			fogMesh:update()
			fogMesh:updateProperties()
			fogMesh:updateNodeEffects()

			this.updateData(activeCell, type)
		else
			this.debugLog("Cell is already fogged. Showing fog.")
			this.switchFog(false, type)
		end
	end

	this.reColour{
		time = time,
		colours = colours,
		weather = weather,
		type = type
	}

end

-- Removes fog from view by appculling - with fade out
function this.removeFog(options)
    this.debugLog("Removing fog of type: "..options.type)

	local time = options.time
	local colours = options.colours
	local weather = options.weather
	local type = options.type

	this.reColour{
		time = time,
		colours = colours,
		weather = weather,
		type = type
	}

	this.switchFog(true, type)
	this.purgeFoggedCells(type)
end

-- Removes fog from view by detaching - without fade out
function this.removeFogImmediate(type)
    this.debugLog("Immediately removing fog of type: "..type)

	local vfxRoot = tes3.game.worldSceneGraphRoot.children[9]
	for _, node in pairs(vfxRoot.children) do
		if node and node.name == "tew_"..type then
			vfxRoot:detachChild(node)
		end
	end

	this.purgeFoggedCells(type)
end

return this
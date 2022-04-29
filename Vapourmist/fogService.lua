local this = {}

local config = require("tew\\Vapourmist\\config")
local version = require("tew\\Vapourmist\\version")
local VERSION = version.version

local data = require("tew\\Vapourmist\\data")

local WtC = tes3.worldController.weatherController
local lerp
local simulateRegistered = false

-- Print debug messages
function this.debugLog(string)
    if config.debugLogOn then
		string = tostring(string)
		local info = debug.getinfo(2, "Sl")
        local module = info.short_src:match("^.+\\(.+).lua$")
        local prepend = ("[Vapourmist.%s.%s:%s]:"):format(VERSION, module, info.currentline)
        local aligned = ("%-36s"):format(prepend)
        mwse.log(aligned.." -- "..string.format("%s", string))
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

function this.isWeatherBlocked(weather, blockedWeathers)
    for _, i in ipairs(blockedWeathers) do
        if weather.index == i then
            return true
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
					if fog.appCulled ~= bool then
						fog.appCulled = bool
						fog:update()
						this.debugLog("Appculling switched to "..tostring(bool).." for "..type.." fog.")
					end
				end
			end
		end
	end
end

-- Apply colour changes in simulate
local function lerpFogColours(e)
	this.debugLog("Lerping fog colours.")

	local vfxRoot = tes3.game.worldSceneGraphRoot.children[9]
	for _, vfx in pairs(vfxRoot.children) do
		if not vfx then break end

		if string.find(vfx.name, "tew_") then

			local type = string.sub(vfx.name, 5)

			local particleSystem = vfx:getObjectByName("MistEffect")
			local colorModifier = particleSystem.controller.particleModifiers
			local deltaR = math.lerp(lerp[type].colours.from.r, lerp[type].colours.to.r, lerp.time)
			local deltaG = math.lerp(lerp[type].colours.from.g, lerp[type].colours.to.g, lerp.time)
			local deltaB = math.lerp(lerp[type].colours.from.b, lerp[type].colours.to.b, lerp.time)

			for _, key in ipairs(colorModifier.colorData.keys) do
				key.color.r = deltaR
				key.color.g = deltaG
				key.color.b = deltaB
			end

			local materialProperty = particleSystem.materialProperty
			materialProperty.emissive = {deltaR, deltaG, deltaB}
			materialProperty.specular = {deltaR, deltaG, deltaB}
			materialProperty.diffuse = {deltaR, deltaG, deltaB}
			materialProperty.ambient = {deltaR, deltaG, deltaB}

			lerp.time = lerp.time + (e.delta * 0.0012)
			particleSystem:updateNodeEffects()
		
		end
	end

	if (lerp.time >= 1) then
		if simulateRegistered then
			event.unregister("simulate", lerpFogColours)
			simulateRegistered = false
			this.debugLog("Lerp finished")
			for _, vfx in pairs(vfxRoot.children) do
				if not vfx then break end
				if string.find(vfx.name, "tew_") then
					local type = string.sub(vfx.name, 5)
					this.reColourImmediate(vfx, lerp[type].colours.to)
				end
			end
			lerp = nil
		end
	end

end

-- Calculate output colours per time and weather
function this.getOutputColours(time, weather, colours)

	local weatherColour

	if time == "dawn" then
		weatherColour = weather.fogSunriseColor
	elseif time == "day" then
		weatherColour = weather.fogDayColor
	elseif time == "dusk" then
		weatherColour = weather.fogSunsetColor
	elseif time == "night" then
		weatherColour = weather.fogNightColor
	end

	return {
		r = weatherColour.r + colours[time].r,
		g = weatherColour.g + colours[time].g,
		b = weatherColour.b + colours[time].b
	}

end

function this.reColourImmediate(vfx, fogColour)
	local particleSystem = vfx:getObjectByName("MistEffect")
	local colorModifier = particleSystem.controller.particleModifiers

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

-- Recolours fog nodes with slightly modified current fog colour by modifying colour keys in NiColorData and material property values
function this.reColour(options)

	if simulateRegistered then this.debugLog("Lerping in progress. Fuck off.") return end

	local fromTime = options.fromTime
	local toTime = options.toTime
	local colours = options.colours
	local type = options.type
	local fromWeather = options.fromWeather
	local toWeather = options.toWeather

    this.debugLog("Running colour change for "..type)

	if (fromTime == toTime) and (fromWeather == toWeather) then
		this.debugLog("Same conditions. Recolouring immediately.")
		local vfxRoot = tes3.game.worldSceneGraphRoot.children[9]
		for _, vfx in pairs(vfxRoot.children) do
			if not vfx then break end
	
			if vfx.name == "tew_"..type then
				local fogColour = this.getOutputColours(toTime, toWeather, colours)
				this.reColourImmediate(vfx, fogColour)
			end
		end
	else
		this.debugLog("Different conditions. Recolouring "..type.." over time.")
		local fromColour = this.getOutputColours(fromTime, fromWeather, colours)
		local toColour = this.getOutputColours(toTime, toWeather, colours)

		if lerp then return end
		
		lerp = {}
		lerp.time = WtC.transitionScalar or 0
		for _, fogType in pairs(data.fogTypes) do
			lerp[fogType.name] = {}
			lerp[fogType.name].colours = {from = fromColour, to = toColour}
			lerp[fogType.name].name = fogType.name
			this.debugLog("Prepared lerp for type "..fogType.name)
		end

		if not simulateRegistered then
			simulateRegistered = true
			event.register("simulate", lerpFogColours)
			this.debugLog("Lerp registered for "..type)
		end
	end

end

-- Adds fog to the cell
function this.addFog(options)

    local mesh = options.mesh
	local type = options.type
	local fromTime = options.fromTime
	local toTime = options.toTime
	local fromWeather = options.fromWeather
	local toWeather = options.toWeather
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
		fromTime = fromTime,
		toTime = toTime,
		fromWeather = fromWeather,
		toWeather = toWeather,
		colours = colours,
		type = type,
	}

end

-- Removes fog from view by appculling - with fade out
function this.removeFog(options)
    this.debugLog("Removing fog of type: "..options.type)

	local type = options.type
	local fromTime = options.fromTime
	local toTime = options.toTime
	local fromWeather = options.fromWeather
	local toWeather = options.toWeather
	local colours = options.colours

	this.reColour{
		fromTime = fromTime,
		toTime = toTime,
		fromWeather = fromWeather,
		toWeather = toWeather,
		colours = colours,
		type = type,
	}

	this.switchFog(true, type)
	this.purgeFoggedCells(type)
end

-- Removes fog from view by detaching - without fade out
function this.removeFogImmediate(options)
    this.debugLog("Immediately removing fog of type: "..options.type)

	local vfxRoot = tes3.game.worldSceneGraphRoot.children[9]
	for _, node in pairs(vfxRoot.children) do
		if node and node.name == "tew_"..options.type then
			vfxRoot:detachChild(node)
		end
	end

	for _, vfx in pairs(vfxRoot.children) do
		if not vfx then break end

		if vfx.name == "tew_"..options.type then
			local fogColour = this.getOutputColours(options.toTime, options.toWeather, options.colours)
			this.reColourImmediate(vfx, fogColour)
		end
	end
end

return this
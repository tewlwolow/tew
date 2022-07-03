-- TODO: distance check, appcull and remove if too far away

local this = {}

local config = require("tew\\Vapourmist\\config")
local version = require("tew\\Vapourmist\\version")
local VERSION = version.version
local data = require("tew\\Vapourmist\\data")

local WtC = tes3.worldController.weatherController

local currentFogs = {
	["cloud"] = {},
	["mist"] = {}
}

local foggedCells = {
	["cloud"] = {},
	["mist"] = {}
}

-- Print debug messages
function this.debugLog(message)
    if config.debugLogOn then
		if not message then message = "n/a" end
		message = tostring(message)
		local info = debug.getinfo(2, "Sl")
        local module = info.short_src:match("^.+\\(.+).lua$")
        local prepend = ("[Vapourmist.%s.%s:%s]:"):format(VERSION, module, info.currentline)
        local aligned = ("%-36s"):format(prepend)
        mwse.log(aligned.." -- "..string.format("%s", message))
    end
end


function this.purgeCurrentFogs(fogType)
	currentFogs[fogType] = {}
end


function this.updateCurrentFogs(fog, fogType)
	table.insert(currentFogs[fogType], fog)
end

function this.purgeFoggedCells(fogType)
	foggedCells[fogType] = {}
end

function this.updateFoggedCells(cell, fogType)
	table.insert(foggedCells[fogType], cell)
end

-- Returns true if the cell is fogged
function this.isCellFogged(activeCell, fogType)
	for _, cell in pairs(foggedCells[fogType]) do
		if cell == activeCell then
			this.debugLog("Cell: "..cell.editorName.." is fogged.")
			return true
		end
	end
	return false
end

-- Check whether fog is appculled
function this.isFogAppculled(fogType)
	local vfxRoot = tes3.game.worldSceneGraphRoot.children[9]
	for _, node in pairs(vfxRoot.children) do
		if node and node.name == "tew_"..fogType then
			for _, fog in pairs(node.children) do
				if fog.name == "Mist Emitter" then
					if fog.appCulled == true then
						this.debugLog("Fog is appculled.")
						return true
					end
				end
			end
		end
	end
end

-- Determine fog position for exteriors
local function getFogPosition(activeCell, height)
	local average = 0
	local denom = 0
	for stat in activeCell:iterateReferences() do
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

-- Determine fog position for interiors
local function getInteriorCellPosition(cell)
	local pos = {x = 0, y = 0, z = 0}
	local denom = 0

	for stat in cell:iterateReferences() do
		pos.x = pos.x + stat.position.x
		pos.y = pos.y + stat.position.y
		pos.z = pos.z + stat.position.z
		denom = denom + 1
	end

	return {x = pos.x/denom, y = pos.y/denom, z = pos.z/denom}
end

-- Appculling switch
function this.cullFog(bool, type)
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

-- Calculate output colours from current fog colour
function this.getOutputValues()

	local weatherColour = WtC.currentFogColor:copy()

	return {
		colours = {
			r = math.clamp(weatherColour.r + 0.03, 0.1, 0.85),
			g = math.clamp(weatherColour.g + 0.03, 0.1, 0.85),
			b = math.clamp(weatherColour.b + 0.03, 0.1, 0.85)
		},
		angle = WtC.windVelocityCurrWeather:normalized():copy().y * math.pi * 1,
		speed = math.max(WtC.currentWeather.cloudsSpeed * data.speedCoefficient, data.minimumSpeed)
	}

end

function this.reColour()
	local output = this.getOutputValues()
	local fogColour = output.colours
	local speed = output.speed
	local angle = output.angle
	for _, fogType in pairs(currentFogs) do
		if not fogType then return end
		for _, fog in pairs(fogType) do
			if not fog then goto continue end
			local particleSystem = fog:getObjectByName("MistEffect")
			local controller = particleSystem.controller
			local colorModifier = controller.particleModifiers

			controller.speed = speed
			controller.planarAngle = angle

			for _, key in pairs(colorModifier.colorData.keys) do
				key.color.r = fogColour.r
				key.color.g = fogColour.g
				key.color.b = fogColour.b
			end

			local materialProperty = particleSystem.materialProperty
			materialProperty.emissive = fogColour
			materialProperty.specular = fogColour
			materialProperty.diffuse = fogColour
			materialProperty.ambient = fogColour

			particleSystem:updateNodeEffects()

			:: continue ::
		end
	end
end

-- Adds fog to the cell
function this.addFog(options)

	local mesh = options.mesh
	local type = options.type
	local height = options.height

	local vfxRoot = tes3.game.worldSceneGraphRoot.children[9]

	this.debugLog("Checking if we can add fog: "..type)

	for _, activeCell in pairs(tes3.getActiveCells()) do
		if (not (this.isCellFogged(activeCell, type)) and not (activeCell.isInterior)) then
			this.debugLog("Cell is not fogged. Adding "..type..".")

			local fogMesh = tes3.loadMesh(mesh):clone()

			fogMesh:clearTransforms()
			fogMesh.translation = tes3vector3.new(
				8192 * activeCell.gridX + 4096,
				8192 * activeCell.gridY + 4096,
				getFogPosition(activeCell, height)
			)

			vfxRoot:attachChild(fogMesh, true)

			for _, vfx in pairs(vfxRoot.children) do
				if vfx then
					if vfx.name == "tew_"..options.type then
						local particleSystem = vfx:getObjectByName("MistEffect")
						local controller = particleSystem.controller
						controller.initialSize = table.choice(data.fogTypes[options.type].initialSize)
						this.updateCurrentFogs(vfx, options.type)
					end
				end
			end

			fogMesh:update()
			fogMesh:updateProperties()
			fogMesh:updateNodeEffects()
			this.updateFoggedCells(activeCell, type)
		else
			this.debugLog("Cell is already fogged. Showing fog.")
			this.cullFog(false, type)

		end
	end

end

-- Removes fog from view by appculling - with fade out
function this.removeFog(type)
    this.debugLog("Removing fog of type: "..type)
	this.cullFog(true, type)
	this.purgeCurrentFogs(type)
end

-- Removes fog from view by detaching - without fade out
function this.removeFogImmediate(fogType)

    this.debugLog("Immediately removing fog of type: "..fogType)

	if this.isFogAppculled(fogType) then return end

	local vfxRoot = tes3.game.worldSceneGraphRoot.children[9]

	for _, node in pairs(vfxRoot.children) do
		if node and node.name == "tew_"..fogType then
			vfxRoot:detachChild(node)
		end
	end

	this.purgeCurrentFogs(fogType)
	table.remove(foggedCells, tes3.getPlayerCell)
	local toRemove = {}
	for k, v in pairs(foggedCells) do
		if v == tes3.getPlayerCell() then
			table.insert(toRemove, k)
		end
	end
	for _, v in pairs(toRemove) do
		table.remove(foggedCells, v)
	end
end

function this.addInteriorFog(options)

	this.debugLog("Adding interior fog.")

	local vfxRoot = tes3.game.worldSceneGraphRoot.children[9]

	local mesh = options.mesh
	local fogType = options.type
	local height = options.height
	local cell = options.cell

	if not (this.isCellFogged(cell, fogType)) then
		this.debugLog("Interior cell is not fogged. Adding "..fogType..".")

		local fogMesh = tes3.loadMesh(mesh):clone()
		local pos = getInteriorCellPosition(cell)

		fogMesh:clearTransforms()
		fogMesh.translation = tes3vector3.new(
			pos.x,
			pos.y,
			pos.z + height
		)

		vfxRoot:attachChild(fogMesh, true)
		for _, vfx in pairs(vfxRoot.children) do
			if vfx then
				if vfx.name == "tew_"..type then
					local particleSystem = vfx:getObjectByName("MistEffect")
					local controller = particleSystem.controller
					controller.initialSize = table.choice(data.interiorFog.initialSize)
					this.updateCurrentFogs(vfx, fogType)
				end
			end
		end

		fogMesh:update()
		fogMesh:updateProperties()
		fogMesh:updateNodeEffects()
		this.updateFoggedCells(cell, fogType)
	else
		this.debugLog("Cell is already fogged. Showing fog.")
		this.cullFog(false, fogType)
	end

end

function this.removeAll()

	local vfxRoot = tes3.game.worldSceneGraphRoot.children[9]
	for _, node in pairs(vfxRoot.children) do
		if node and string.startswith(node.name, "tew_") then
			vfxRoot:detachChild(node)
		end
	end

	currentFogs = {
		["cloud"] = {},
		["mist"] = {}
	}
	foggedCells = {
		["cloud"] = {},
		["mist"] = {}
	}

end

return this
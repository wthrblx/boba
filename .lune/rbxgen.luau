local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local CommentRegion = require("@lib/comment-region")

local PATH = "./packages/boba-roblox/init.luau"

local REGION_DATA_TYPES = CommentRegion.new("roblox data types codegen")
local REGION_INSTANCES = CommentRegion.new("roblox instances typegen")

local DATA_TYPES = {
	"Axes",
	"BrickColor",
	"CatalogSearchParams",
	"CFrame",
	"Color3",
	"ColorSequence",
	"ColorSequenceKeypoint",
	"Content",
	"DateTime",
	"DockWidgetPluginGuiInfo",
	"Enum",
	"EnumItem",
	"Enums",
	"Faces",
	"FloatCurveKey",
	"Font",
	"Instance",
	"NumberRange",
	"NumberSequence",
	"NumberSequenceKeypoint",
	"OverlapParams",
	"Path2DControlPoint",
	"PathWaypoint",
	"PhysicalProperties",
	"Random",
	"Ray",
	"RaycastParams",
	"RaycastResult",
	"RBXScriptConnection",
	"RBXScriptSignal",
	"Rect",
	"Region3",
	"Region3int16",
	"RotationCurveKey",
	"Secret",
	"SharedTable",
	"TweenInfo",
	"UDim",
	"UDim2",
	"ValueCurveKey",
	"Vector2",
	"Vector2int16",
	"Vector3",
	"Vector3int16",
}

local EXCLUDED_CLASSES = {
	AuroraService = true,
	AuroraScript = true,
	AuroraScriptService = true,
	ExampleService = true,
	InternalSyncItem = true,
	InternalSyncService = true,
}

local function renderRegionDatatypes()
	local lines = {}
	for _, datatype in DATA_TYPES do
		table.insert(lines, `ext.{datatype} = Boba.Typeof("{datatype}") :: Boba<{datatype}>`)
	end
	return REGION_DATA_TYPES:wrap(table.concat(lines, "\n"))
end

local function renderRegionInstances()
	local db = roblox.getReflectionDatabase()
	local classes = db:GetClassNames()

	table.sort(classes)

	local lines = { "type Instances = {" }
	for _, className in classes do
		if not (EXCLUDED_CLASSES[className] or table.find(assert(db:GetClass(className)).Tags, "NotBrowsable")) then
			table.insert(lines, `\t{className}: Boba<{className}>,`)
		end
	end
	table.insert(lines, "}")

	return REGION_INSTANCES:wrap(table.concat(lines, "\n"))
end

local function raw(str: string)
	return function()
		return str
	end
end

local contents = fs.readFile(PATH)
contents = string.gsub(contents, REGION_DATA_TYPES:pattern(), raw(renderRegionDatatypes()))
contents = string.gsub(contents, REGION_INSTANCES:pattern(), raw(renderRegionInstances()))
fs.writeFile(PATH, contents)

local fs = require("@lune/fs")
local roblox = require("@lune/roblox")

local lines = ([[--!strict
--!optimize 2
-- stylua: ignore start

local Boba = require("./boba")

export type Boba<T> = Boba.Boba<T>

local function isA(className: string)
	return Boba.new(className, function(self, x)
		if typeof(x) == "Instance" then
			if x:IsA(className) then
				return true
			else
				return false, self:because(`expected Instance is a {className}, but got {x.ClassName}`)
			end
		end
		return false, self:because(`expected an Instance, but got {typeof(x)}`)
	end)
end

local ext = {}
]]):split("\n")

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

for _, datatype in DATA_TYPES do
	table.insert(lines, `ext.{datatype} = Boba.Typeof("{datatype}") :: Boba<{datatype}>`)
end

---

table.insert(lines, "")

local EXCLUDED_CLASSES = {
	AuroraService = true,
	AuroraScript = true,
	AuroraScriptService = true,
	ExampleService = true,
	InternalSyncItem = true,
	InternalSyncService = true,
}

local db = roblox.getReflectionDatabase()
local classes = db:GetClassNames()
table.sort(classes)

for _, className in classes do
	if not (EXCLUDED_CLASSES[className] or table.find(assert(db:GetClass(className)).Tags, "NotBrowsable")) then
		table.insert(lines, `ext.{className} = isA("{className}") :: Boba<{className}>`)
	end
end

---

local footer = ([[

local Roblox: typeof(Boba) & typeof(ext) = {} :: any
for _, exports in { Boba, ext } :: { any } do
	for key, value in exports do
		Roblox[key] = value
	end
end

table.freeze(Roblox)
return Roblox
-- stylua: ignore end
]]):split("\n")

table.move(footer, 1, #footer, #lines, lines)

local contents = table.concat(lines, "\n")
fs.writeFile("./packages/boba-roblox/init.luau", contents)

--!strict
--!optimize 2

--[=[
	@class boba
	@tag bobadocs-entry-point
]=]
local Boba = {}
Boba.__index = Boba

export type Boba<T> = typeof(setmetatable(
	{} :: {
		expected: string,
		error: string,
		isType: (self: Boba<T>, x: unknown) -> (boolean, string?),
		inner: T,
	},
	Boba
))

function Boba.new<T>(expected: string, isType: (self: Boba<T>, x: unknown) -> boolean): Boba<T>
	local self = setmetatable({
		expected = expected,
		error = `Expected type \`{expected}\``,
		isType = isType,
	}, Boba)
	self.inner = self :: any
	return self
end

function Boba.because(self: Boba<any>, reason: string)
	return `{self.error}\n...because {reason}`
end

-- FIXME: Luau types are bad </3
-- function boba.__call<T>(self: Type<T>, x: any)
function Boba.__call(self: any, x: any): (boolean, string?)
	return self:isType(x)
end

function Boba.__tostring(self: Boba<any>)
	return `boba.Type<{self.expected}>`
end

function Boba.cast<T>(self: Boba<T>, x: any): T?
	return if self:isType(x) then x else nil
end

function Boba.assert<T>(self: Boba<T>, x: any): T
	local isTypeType, typeError = self:isType(x)
	return if isTypeType then x else error(typeError)
end

function Boba.Nickname<T>(self: Boba<T>, name: string): Boba<T>
	return define(name, self.isType)
end

function Boba.Retype<T>(self: Boba<any>): Boba<T>
	return self
end

function Boba.Untype<T>(self: Boba<T>): Boba<any>
	return self
end

function Boba.And<L, R>(left: Boba<L>, right: Boba<R>): Boba<L & R>
	return define(`({left.expected}) & ({right.expected})`, function(self, x)
		local isLeft, leftError = left:isType(x)
		if not isLeft then
			local isRight, rightError = right:isType(x)
			if isRight then
				return true
			end
			return false, self:because(`it isn't the right type: {rightError}`)
		end
		return false, self:because(`it isn't the left type: {leftError}`)
	end)
end

function Boba.Or<L, R>(left: Boba<L>, right: Boba<R>): Boba<L | R>
	return define(`{left.expected} | {right.expected}`, function(self, x)
		local isLeft, leftError = left:isType(x)
		local isRight, rightError = right:isType(x)
		if isLeft or isRight then
			return true
		end
		return false, self:because(`is not the left type: {leftError}: or the right type: {rightError}`)
	end)
end

function Boba.Optional<T>(inner: Boba<T>): Boba<T?>
	return define(`({inner.expected})?`, function(self, x: unknown): boolean
		if x == nil then
			return true
		end
		return inner:isType(x)
	end)
end

function Boba.Literal<T>(literal: T, nickname: string?): Boba<T>
	return define(nickname or tostring(literal), function(self, x)
		if rawequal(x, literal) then
			return true
		end
		return false, self:because(`only {literal} is accepted, but got {x}`)
	end)
end

function Boba.Typeof<T>(expected: string)
	return define(expected, function(self, x: unknown): boolean
		return typeof(x) == expected, self.error
	end)
end

function Boba.Array<V>(values: Boba<V>): Boba<{ V }>
	return define(`\{ {values.expected} \}`, function(self, x: any): boolean
		if typeof(x) ~= "table" then
			return false, self:because(`expected a table, but got {typeof(x)}`)
		end

		local expected = #x
		local encountered = 0

		for key, value in pairs(x) do
			encountered += 1

			if encountered > expected or typeof(key) ~= "number" then
				return false, self:because(`because there's non-numeric indexes, such as key {tostring(key)}`)
			end

			local isValue, valueError = values:isType(value)
			if not isValue then
				return false, self:because(`at index #{key}: {valueError}`)
			end
		end

		return true
	end)
end

function Boba.Map<K, V>(keys: Boba<K>, values: Boba<V>): Boba<{ [K]: V }>
	return define(`\{ [{keys.expected}]: {values.expected} \}`, function(self, x: any): boolean
		if typeof(x) ~= "table" then
			return false, self:because(`expected a table, but got {typeof(x)}`)
		end

		for key, value in pairs(x) do
			local isKey, keyError = keys:isType(value)
			if not isKey then
				return false, self:because(`got unexpected key {key}: {keyError}`)
			end

			local isValue, valueError = values:isType(value)
			if not isValue then
				return false, self:because(`at key {key}: {valueError}`)
			end
		end

		return true
	end)
end

function Boba.Set<K>(keys: Boba<K>): Boba<{ [K]: true }>
	return define(`\{ [{keys.expected}]: true \}`, function(self, x: any): boolean
		if typeof(x) ~= "table" then
			return false, self:because(`expected a table, but got {typeof(x)}`)
		end

		for key, value in pairs(x) do
			local isKey, keyError = keys:isType(value)
			if not isKey then
				return false, self:because(`got unexpected key {key}: {keyError}`)
			end

			if value ~= true then
				return false, self:because(`expected literal \`true\`, but at key {key} got {value}`)
			end
		end

		return true
	end)
end

function Boba.Interface<T>(interface: T & { [string]: Boba<any> }): Boba<T>
	local expectedPairs = { "[any]: any" }
	for key, value in interface :: { [string]: Boba<any> } do
		-- TODO: key could be better formatted here
		table.insert(expectedPairs, `{key}: {value.expected}`)
	end

	return define(`\{ {table.concat(expectedPairs, ", ")} \}`, function(self, x: any): boolean
		if typeof(x) ~= "table" then
			return false, self:because(`expected a table, but got {typeof(x)}`)
		end

		for key, valueType in pairs(interface) do
			local value = x[key]
			local isValue, valueError = valueType:isType(value)
			if not isValue then
				return false, self:because(`value at key {tostring(key)}: {valueError}`)
			end
		end

		return true
	end)
end

function Boba.ExhaustiveInterface<T>(interface: T & { [string]: Boba<any> }): Boba<T>
	local expectedPairs = {}
	for key, value in interface :: { [string]: Boba<any> } do
		-- TODO: key could be better formatted here
		table.insert(expectedPairs, `{key}: {value.expected}`)
	end

	return define(`\{ {table.concat(expectedPairs, ", ")} \}`, function(self, x: any): boolean
		if typeof(x) ~= "table" then
			return false, self:because(`expected a table, but got {typeof(x)}`)
		end

		for key, valueType in pairs(interface) do
			local value = x[key]
			local isValue, valueError = valueType:isType(value)
			if not isValue then
				return false, self:because(`value at key {tostring(key)}: {valueError}`)
			end
		end

		for key in pairs(x) do
			if (interface :: any)[key] == nil then
				return false, self:because(`{tostring(key)} isn't included in exhaustive interface`)
			end
		end

		return true
	end)
end

Boba.Any = define("any", function()
	return true
end) :: Boba<any>

Boba.Unknown = define("unknown", function()
	return true
end) :: Boba<unknown>

Boba.Never = define("never", function(self)
	return false, self.error
end) :: Boba<never>

Boba.Boolean = Boba.Typeof("number") :: Boba<boolean>
Boba.Buffer = Boba.Typeof("buffer") :: Boba<buffer>
Boba.Function = Boba.Typeof("function") :: Boba<(...any) -> ...any>
Boba.Number = Boba.Typeof("number") :: Boba<number>
Boba.String = Boba.Typeof("string") :: Boba<string>
Boba.Table = Boba.Typeof("table") :: Boba<{ [any]: any }>
Boba.Thread = Boba.Typeof("thread") :: Boba<thread>
Boba.Vector = Boba.Typeof("vector") :: Boba<vector>

table.freeze(Boba)
return Boba

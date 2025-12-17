--!strict
--!optimize 2

--[[

    ▄ █ ▀█▀ █ ▄  Welcome To Hell @ wthrblx.com
     █▀█ █ █▀█   (c) Team Fireworks 2024-2026.

    This software is provided 'as-is', without any express or implied
    warranty. In no event will the authors be held liable for any damages
    arising from the use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

    1. The origin of this software must not be misrepresented; you must not
       claim that you wrote the original software. If you use this software
       in a product, an acknowledgment in the product documentation would be
       appreciated but is not required.
    2. Altered source versions must be plainly marked as such, and must not be
       misrepresented as being the original software.
    3. This notice may not be removed or altered from any source distribution.

]]

local Boba = {}
Boba.__index = Boba

export type BobaInner<T> = {
	--[=[
		@prop expected
		@within Boba<T>
		@since 1.0.0

		A readable description of the type that the Boba represents.
	]=]
	expected: string,
	--[=[
		@prop error
		@within Boba<T>
		@since 1.0.0

		Default error message used when validation fails.
	]=]
	error: string,
	--[=[
		@prop match
		@within Boba<T>
		@since 1.0.0

		Given an unknown value, returns `true` if the Boba matches it's
		type. Otherwise, returns `false` and an3 error message.
	]=]
	match: (self: Boba<T>, x: unknown) -> (boolean, string?),
	--[=[
		@prop inner
		@within Boba<T>
		@since 1.0.0

		Represents the `T` type parameter. At runtime, this references
		itself. This is most useful for building interfaces and fetching the
		static `T` type.

		@example

		```luau
		local Player = Boba.Interface {
			name = Boba.String.inner,
		 	xp = Boba.Number.inner,
		}

		export type Player = typeof(Player.inner)
		```
	]=]
	inner: T,
}

--[=[
	@class Boba<T>
	@since 1.0.0
	@tag bobadocs-entry-point

	A Boba<T> (pronounced "boba tea") represents a type that can validate
	unknown values at runtime, and produce descriptive error messages when
	validation fails.
]=]
export type Boba<T> = typeof(setmetatable({} :: BobaInner<T>, Boba))

--[=[
	@function new


]=]
function Boba.new<T>(expected: string, match: (self: Boba<T>, x: unknown) -> boolean): Boba<T>
	local self = setmetatable({
		expected = expected,
		error = `expected type {expected}`,
		match = match,
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
	return self:match(x)
end

function Boba.__tostring(self: Boba<any>)
	return `Boba<{self.expected}>`
end

function Boba.cast<T>(self: Boba<T>, x: any): T?
	return if self:match(x) then x else nil
end

function Boba.assert<T>(self: Boba<T>, x: any): T
	local matchType, typeError = self:match(x)
	return if matchType then x else error(typeError)
end

function Boba.Nickname<T>(self: Boba<T>, name: string): Boba<T>
	return Boba.new(name, self.match)
end

function Boba.Retype<T>(self: Boba<any>): Boba<T>
	return self
end

function Boba.Untype<T>(self: Boba<T>): Boba<any>
	return self
end

function Boba.And<L, R>(left: Boba<L>, right: Boba<R>): Boba<L & R>
	return Boba.new(`({left.expected}) & ({right.expected})`, function(self, x)
		local isLeft, leftError = left:match(x)
		if isLeft then
			local isRight, rightError = right:match(x)
			if isRight then
				return true
			end
			return false, self:because(`it isn't the right type: {rightError}`)
		end
		return false, self:because(`it isn't the left type: {leftError}`)
	end)
end

function Boba.Or<L, R>(left: Boba<L>, right: Boba<R>): Boba<L | R>
	return Boba.new(`{left.expected} | {right.expected}`, function(self, x)
		local isLeft, leftError = left:match(x)
		local isRight, rightError = right:match(x)
		if isLeft or isRight then
			return true
		end
		return false, self:because(`is not the left type: {leftError}: or the right type: {rightError}`)
	end)
end

function Boba.Optional<T>(inner: Boba<T>): Boba<T?>
	return Boba.new(`({inner.expected})?`, function(self, x: unknown): boolean
		if x == nil then
			return true
		end
		return inner:match(x)
	end)
end

function Boba.Predicate<T>(inner: Boba<T>, predicate: (value: T) -> (boolean, string?)): Boba<T>
	return Boba.new(`Predicate<{inner.expected}>`, function(self, x: any): boolean
		local matches, matchError = inner:match(x)

		if matches then
			local passes, predicateError = predicate(x)
			if passes then
				return true
			end

			return false, self:because(predicateError or "value did not sastify the predicate")
		end

		return false, matchError
	end)
end

function Boba.Literal<T>(literal: T, nickname: string?): Boba<T>
	return Boba.new(nickname or tostring(literal), function(self, x)
		if rawequal(x, literal) then
			return true
		end
		return false, self:because(`only {literal} is accepted, but got {x}`)
	end)
end

function Boba.Typeof<T>(expected: string)
	return Boba.new(expected, function(self, x: unknown): boolean
		return typeof(x) == expected, `{self.error}, but got {x} ({typeof(x)})`
	end)
end

function Boba.Array<V>(values: Boba<V>): Boba<{ V }>
	return Boba.new(`\{ {values.expected} \}`, function(self, x: any): boolean
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

			local isValue, valueError = values:match(value)
			if not isValue then
				return false, self:because(`at index #{key}: {valueError}`)
			end
		end

		return true
	end)
end

function Boba.Map<K, V>(keys: Boba<K>, values: Boba<V>): Boba<{ [K]: V }>
	return Boba.new(`\{ [{keys.expected}]: {values.expected} \}`, function(self, x: any): boolean
		if typeof(x) ~= "table" then
			return false, self:because(`expected a table, but got {typeof(x)}`)
		end

		for key, value in pairs(x) do
			local isKey, keyError = keys:match(key)
			if not isKey then
				return false, self:because(`got unexpected key {key}: {keyError}`)
			end

			local isValue, valueError = values:match(value)
			if not isValue then
				return false, self:because(`at key {key}: {valueError}`)
			end
		end

		return true
	end)
end

function Boba.Set<K>(keys: Boba<K>): Boba<{ [K]: true }>
	return Boba.new(`\{ [{keys.expected}]: true \}`, function(self, x: any): boolean
		if typeof(x) ~= "table" then
			return false, self:because(`expected a table, but got {typeof(x)}`)
		end

		for key, value in pairs(x) do
			local isKey, keyError = keys:match(value)
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

	return Boba.new(`\{ {table.concat(expectedPairs, ", ")} \}`, function(self, x: any): boolean
		if typeof(x) ~= "table" then
			return false, self:because(`expected a table, but got {typeof(x)}`)
		end

		for key, valueType in pairs(interface) do
			local value = x[key]
			local isValue, valueError = valueType:match(value)
			if not isValue then
				return false,
					self:because(
						`value at key {tostring(key)}: {string.gsub(valueError or valueType.error, "\n", "\n...")}`
					)
			end
		end

		return true
	end)
end

function Boba.ExhaustiveInterface<T>(interface: T): Boba<T>
	local expectedPairs = {}
	for key, value in (interface :: any) :: { [string]: Boba<any> } do
		-- TODO: key could be better formatted here
		table.insert(expectedPairs, `{key}: {value.expected}`)
	end

	return Boba.new(`\{ {table.concat(expectedPairs, ", ")} \}`, function(self, x: any): boolean
		if typeof(x) ~= "table" then
			return false, self:because(`expected a table, but got {typeof(x)}`)
		end

		for key, valueType in pairs(interface :: any) do
			local value = x[key]
			local isValue, valueError = valueType:match(value)
			if not isValue then
				return false,
					self:because(
						`value at key {tostring(key)}: {string.gsub(valueError or valueType.error, "\n", "\n...")}`
					)
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

Boba.Any = Boba.new("any", function()
	return true
end) :: Boba<any>

Boba.Unknown = Boba.new("unknown", function()
	return true
end) :: Boba<unknown>

Boba.Never = Boba.new("never", function(self)
	return false, self.error
end) :: Boba<never>

Boba.Boolean = Boba.Typeof("boolean") :: Boba<boolean>
Boba.Buffer = Boba.Typeof("buffer") :: Boba<buffer>
Boba.Function = Boba.Typeof("function") :: Boba<(...any) -> ...any>
Boba.Number = Boba.Typeof("number") :: Boba<number>
Boba.String = Boba.Typeof("string") :: Boba<string>
Boba.Table = Boba.Typeof("table") :: Boba<{ [any]: any }>
Boba.Thread = Boba.Typeof("thread") :: Boba<thread>
Boba.Vector = Boba.Typeof("vector") :: Boba<vector>

Boba.True = Boba.Literal(true):Untype() :: Boba<true>
Boba.False = Boba.Literal(false):Untype() :: Boba<false>
Boba.Nil = Boba.Literal(nil) :: Boba<nil>

table.freeze(Boba)
return Boba

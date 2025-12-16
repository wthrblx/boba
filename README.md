# Boba

Boba is a best-of-all-worlds Luau runtime typechecking library.

## Installation

```sh
# luau
pesde install @wthrblx/boba
wally install @wthrblx/boba
# rbxts
npm install @rbxts/boba
pnpm install @rbxts/boba
bun install @rbxts/boba
```

## Usage

Define types with Boba's various constructors. These types can be tested against
unknown objects:

```luau
local DamageAmount = Boba.Or(
	Boba.Number,
	Boba.Or(
		Boba.Literal("Lethal" :: "Lethal"),
		Boba.Nil
	)
)
```

Boba constructors are also exposed as methods on types, so you can easily chain
them for greater clarity:

```luau
local DamageAmount = Boba.String
	:Or(Boba.Literal("Lethal" :: "Lethal"))
	:Or(Boba.Nil)
```

To infer a static type, call `typeof()` on the type's `inner` property:

```luau
-- inferred as `number | "Lethal" | nil`!
-- (note that types for literals may be widened, this is a limitation with Luau)
export type DamageAmount = typeof(DamageAmount.inner)
```

Optionally, finish types by giving it a nickname:

```luau
local DamageAmount = Boba.String
	:Or(Boba.Literal("Lethal" :: "Lethal"))
	:Or(Boba.Nil)
	:Nickname("DamageAmount")
```

Now, `DamageAmount` will be printed as `DamageAmount` and not
`number | "Lethal" | nil`.

At runtime, `inner` references itself. This enables building interface types
while resolving the correct types:

```luau
local Turret = Boba.ExhaustiveInterface {
	cooldown = Boba.Number.inner,
	amount = DamageAmount.inner,
}

-- inferred as { cooldown: number, amount: number | "Lethal" | nil }!
export type Turret = typeof(Turret.inner)
````

> [!TIP]  
> For TypeScript users, you can omit `.inner` for interfaces:
>
> ```ts
> const Turret = Boba.ExhaustiveInterface({
>     cooldown: Boba.Number,
>     amount: DamageAmount,
> })
>
> export type Turret = typeof Turret.inner
> // alternatively
> export type Turret = Boba.Infer<typeof Turret>
> // still infers { cooldown: number, amount: number | "Lethal" | undefined }!
> ```

Use `check` to see if an unknown value matches the type, receiving an error
message otherwise:

```luau
local unknownData = {
	cooldown = 2,
	amount = "Deadly"
}

local isTurret, turretError = Turret:check(unknownData)
print(isTurret, turretError)
```

Boba will return helpful errors:

```
expected type { cooldown: number, amount: DamageAmount }
...because value at key amount: expected type DamageAmount
......because is not the left type: expected type number | Lethal
......because is not the left type: expected type number, but got Deadly (string): or the right type: expected type Lethal
......because only Lethal is accepted, but got Deadly: or the right type: expected type nil
......because only nil is accepted, but got Deadly
```

If you're in a rush, you can assert values:

```luau
-- this will error if the input doesn't match the type.
local validatedData = Turret:assert(unknownData)

-- zero type errors!
print(validatedData.cooldown)
````

> [!NOTE]  
> Boba errors are a developing story and will further improve overtime!

Congrats! You've learned all of what Boba offers.

You can read the documentation (SOON) for all the other trinkets that
Boba exposes.

## Roblox

TODO.

```sh
# luau
pesde install @wthrblx/boba-roblox
# rbxts
npm install @rbxts/boba-roblox
pnpm install @rbxts/boba-roblox
bun install @rbxts/boba-roblox
```

## Compatibility

Compatibility is a work in progress, though the plan is to support both
t and GreenTea.

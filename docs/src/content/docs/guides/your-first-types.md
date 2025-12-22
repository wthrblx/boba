---
title: Your First Types
description: A vertical slice of Boba.
---

To start, let's quickly take a look at a vertical slice of Boba code. You'll see
how everything looks together, but you aren't expected to understand everything
right away.

## Importing

Open a new script file and ensure you have Boba imported correctly.

```luau
-- roblox
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Boba = require(ReplicatedStorage.Packages.Boba)

-- pesde
local Boba = require("../luau_packages/boba")
```

## Primitives

Boba has an assortment of constructors to define types:

```luau
local Damage = Boba.Or(
	Boba.Literal('Lethal'),
	Boba.Or(
		Boba.Number,
		Boba.Nil
	)
)
```

:::caution
Types for literals may be widened, this is a limitation with Luau.
:::

Boba constructors are also exposed as methods on types, so you can easily chain
them for greater clarity:

```luau
local Damage = Boba.Literal('Lethal')
	:Or(Boba.Number)
	:Or(Boba.Nil)
```

To infer the static type, call `typeof()` on the type's `inner` property:

```luau
-- inferred as `"Lethal" | number | nil`!
export type Damage = typeof(Damage.inner)
```

Finish your types by giving it a nickname:

```luau
local Damage = Boba.String
	:Or(Boba.Literal("Lethal" :: "Lethal"))
	:Or(Boba.Nil)
	:Nickname("Damage")
```

Now, Damage will be printed as `Damage` and not
`number | "Lethal" | nil`!

## Structs

At runtime, inner references itself. This enables building struct types while
resolving the correct types:

```luau
local Turret = Boba.Struct {
	delay = Boba.Number.inner,
	damage = Damage.inner,
}

-- inferred as { delay: number, damage: "Lethal" | number | nil }!
export type Turret = typeof(Turret.inner)
```

:::tip

Boba also has the `ExhaustiveStruct` constructor, which fails for keys not
listed in the interface.

:::

:::tip

For TypeScript users, you can omit `.inner` for structs:

```ts
const Turret = Boba.ExhaustiveStruct({
    cooldown: Boba.Number,
    amount: DamageAmount,
})

export type Turret = typeof Turret.inner
// alternatively
export type Turret = Boba.Infer<typeof Turret>
// still infers { delay: number, damage: "Lethal" | number | nil }!
```

:::

## Validation

Use check to see if an unknown value matches the type, receiving an error message otherwise:

```luau
local unknownData = {
	delay = 2,
	damage = "Deadly"
}

local isTurret, turretError = Turret:check(unknownData)
print(isTurret, turretError)
```

Boba will return precise, helpful errors:

```txt title="Output" frame="terminal"
expected { delay: number, damage: DamageAmount }
> value at key "damage" (string)
  expected Damage
  > did not match any of: Lethal | number, nil
    expected nil
    > only nil is accepted, but got "Deadly" (string)
    expected number | Lethal
    > did not match any of: Lethal, number
      expected Lethal
      > only Lethal is accepted, but got "Deadly" (string)
      expected number
      > got "Deadly" (string)
```

If you're in a rush, you can assert values:

```luau
-- this will error if the input doesn't match the type.
local validatedData = Turret:assert(unknownData)

-- zero type errors!
print(validatedData.damage)
```

<hr/>

With that, you've written your first file of Boba code!

From here, you can checkout [the API Reference](../api-reference) for the rest
of Boba's trinkets, or read about [the Roblox package.](./roblox)

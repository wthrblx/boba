local Boba = require("./packages/boba")

local DamageAmount = Boba.Number:Or(Boba.Literal("Lethal")):Or(Boba.Nil):Nickname("DamageAmount")

local Turret = Boba.ExhaustiveInterface({
	cooldown = Boba.Number,
	amount = DamageAmount,
})

local untrustedData = {
	cooldown = 2,
	amount = "Deadly",
}

local result = Turret:match(untrustedData)
if result.ok then
else
	print(result:format())
end

local Boba = require("./packages/boba")

local Topping = Boba.Literal("Golden Bubble"):Or(Boba.Literal("Grass Jelly")):Or(Boba.Literal("Taro Q"))

local Drink = Boba.Interface({
	tea = Boba.String:inner(),
	milk = Boba.Boolean:inner(),
	sugar = Boba.Number:inner(),
	ice = Boba.Number:inner(),
	toppings = Boba.Array(Topping),
})

local order = {
	tea = "black",
	milk = true,
	sugar = 50,
	ice = 25,
	toppings = { "pearls", "pudding" },
}

local drink = Drink:assert(order)
print(drink.tea, #drink.toppings)

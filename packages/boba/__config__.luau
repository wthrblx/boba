local configure = require("@configure")

return configure.package({
	name = "boba",
	description = "Best-of-all-worlds Luau runtime typechecker",
	targets = { "luau", "lune", "roblox" },

	types = { ["Boba<T>"] = true },
})

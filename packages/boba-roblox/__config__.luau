local configure = require("@configure")

return configure.package({
	name = "boba-roblox",
	description = "Roblox data types and instances for the Boba runtime typechecker",
	targets = { "roblox" },

	dependencies = { boba = true },
	types = { ["Boba<T>"] = true },
})

local configure = require("@configure")

return configure.repo({
	defaults = {
		authors = { "Team Fireworks" },
		license = "Zlib",
		version = "0.1.0",
	},
	registries = {
		npm = configure.registry({ scope = "rbxts" }),
		pesde = configure.registry({ scope = "wthrblx" }),
		wally = configure.registry({ scope = "wthrblx" }),
	},
})

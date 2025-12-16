export type RegistryConfig = {
	scope: string,
	registry: string?,
}

export type RepoConfig = {
	defaults: {
		authors: { string },
		license: string,
		version: string,
	},
	registries: {
		npm: RegistryConfig?,
		pesde: RegistryConfig?,
		wally: RegistryConfig?,
	},
}

export type PackageName = | "boba" | "boba-roblox" | "boba-t" | "boba-greentea"
export type PackageTarget = "lune" | "luau" | "roblox"
export type PackageConfig = {
	name: PackageName,
	description: string,
	targets: { PackageTarget },

	dependencies: { [PackageName]: true }?,
	types: { [string]: string | true }?,

	authors: { string }?,
	license: string?,
	version: string?,
}

local configure = {}

function configure.package(x: PackageConfig)
	return x
end

function configure.repo(x: RepoConfig)
	return x
end

function configure.registry(x: RegistryConfig)
	return x
end

table.freeze(configure)
return configure

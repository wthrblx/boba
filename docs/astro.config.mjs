// @ts-check
import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";

// https://astro.build/config
export default defineConfig({
	site: "https://wthrblx.github.io/boba",
	integrations: [
		starlight({
			title: "Boba",
			logo: {
				light: "./src/assets/logo-light.svg",
				dark: "./src/assets/logo-dark.svg",
				replacesTitle: true,
			},
			social: [{ icon: "github", label: "GitHub", href: "https://github.com/wthrblx/boba" }],
			sidebar: [
				{
					label: "Guides",
					items: [
						{ label: "What is Boba?", slug: "guides/what-is-boba" },
						{ label: "Installation", slug: "guides/installation" },
						{ label: "Your First Types", slug: "guides/your-first-types" },
						{ label: "Roblox", slug: "guides/roblox" },
						{ label: "Compatibility", slug: "guides/compatibility" },
					],
				},
				{
					label: "API Reference",
					items: [
						{ label: "Boba", slug: "api-reference/example" },
						{ label: "Boba Roblox", slug: "api-reference/example" },
						{ label: "Boba GreenTea", slug: "api-reference/example" },
						{ label: "Boba T", slug: "api-reference/example" },
					],
				},
			],
			editLink: {
				baseUrl: "https://github.com/wthrblx/boba/edit/main/docs/",
			},
			components: {
				Hero: "./src/components/Hero.astro",
				Footer: "./src/components/Footer.astro",
			},
			customCss: ["/src/styles/branding.css", "/src/styles/layout.css"],
		}),
	],
});

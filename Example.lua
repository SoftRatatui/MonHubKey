local MonHubKey = loadstring(game:HttpGet("https://raw.githubusercontent.com/SoftRatatui/MonHubKey/refs/heads/main/KeySystem.lua"))()

MonHubKey.Appearance.Title = "MonHub"
MonHubKey.Appearance.Subtitle = "Enter your key to continue"
MonHubKey.Appearance.Icon = "key"
MonHubKey.Appearance.IconSize = UDim2.fromOffset(18, 18)
MonHubKey.Links.Discord = "Discord.gg/jnkie"
MonHubKey.Storage.FileName = "MonHub_key"
MonHubKey.Storage.Remember = true
MonHubKey.Storage.AutoLoad = false
MonHubKey.Options.Keyless = false
MonHubKey.Options.KeylessUI = false

MonHubKey.Shop = {
	Enabled = true,
	Icon = "gem",
	Title = "Get Premium",
	Subtitle = "Instant delivery • 24/7 support",
	ButtonText = "Buy",
	Link = "jnkie.com",
}

MonHubKey:Launch({
	Service = "MonHub",
	Identifier = "1149237",
	Provider = "MonHub",
})

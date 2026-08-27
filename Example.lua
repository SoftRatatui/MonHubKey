local MonHubKey = loadstring(game:HttpGet("https://raw.githubusercontent.com/SoftRatatui/MonHubKey/refs/heads/main/KeySystem.lua"))()

MonHubKey.Appearance.Title = "MonHub"
MonHubKey.Appearance.Icon = "rbxassetid://134697043118282"
MonHubKey.Links.Discord = "Discord.gg/jnkie"
MonHubKey.Storage.FileName = "MonHub_key"

MonHubKey.Theme.Accent = Color3.fromRGB(110, 60, 255)
MonHubKey.Theme.AccentHover = Color3.fromRGB(130, 90, 255)
MonHubKey.Theme.Background = Color3.fromRGB(10, 10, 20)
MonHubKey.Theme.Header = Color3.fromRGB(15, 15, 30)
MonHubKey.Theme.Input = Color3.fromRGB(20, 20, 40)
MonHubKey.Theme.Text = Color3.fromRGB(255, 255, 255)
MonHubKey.Theme.TextDim = Color3.fromRGB(160, 160, 200)
MonHubKey.Theme.Success = Color3.fromRGB(0, 220, 180)
MonHubKey.Theme.Error = Color3.fromRGB(255, 70, 90)
MonHubKey.Theme.StatusIdle = Color3.fromRGB(120, 100, 200)

MonHubKey.Shop = {
	Enabled = true,
	Icon = "",
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

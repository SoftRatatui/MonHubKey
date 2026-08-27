-- Load from a GitHub raw URL after publishing the MonHubKey folder:
-- local KeySystem = loadstring(game:HttpGet("YOUR_RAW_URL/KeySystem.lua"))()

-- In Roblox Studio, put KeySystem next to this LocalScript and use:
local KeySystem = require(script.Parent.KeySystem)

local gate
gate = KeySystem.new({
	Title = "Onyx",
	Subtitle = "Enter your key to continue",
	Placeholder = "key",

	GetKeyUrl = "https://example.com/get-key",
	DiscordUrl = "https://discord.gg/example",
	PremiumUrl = "https://example.com/premium",

	-- This is only a local demo. Use your own API/server-backed validation in production.
	Validate = function(key)
		task.wait(0.5)
		if key == "MONHUB" then
			return {
				Success = true,
				Message = "Welcome back",
				Data = { Plan = "Free" },
			}
		end
		return false, "Invalid or expired key"
	end,

	OnSuccess = function(key, data)
		print("Accepted:", key, data and data.Plan)
		-- Start the protected script here.
	end,

	OnFailure = function(key, reason)
		warn("Rejected:", key, reason)
	end,
})

-- Public methods:
-- gate:Show()
-- gate:Hide()
-- gate:Submit("MONHUB")
-- gate:SetStatus("Custom message", "success" | "error" | "neutral")
-- gate:SetKey("MONHUB")
-- gate:GetKey()
-- gate:Destroy()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local KeySystem = {}
KeySystem.__index = KeySystem

local DEFAULT_THEME = {
	Overlay = Color3.fromRGB(5, 6, 8),
	Card = Color3.fromRGB(17, 19, 22),
	Header = Color3.fromRGB(29, 32, 37),
	Surface = Color3.fromRGB(23, 25, 29),
	CardRaised = Color3.fromRGB(31, 34, 39),
	CardHover = Color3.fromRGB(38, 42, 49),
	Outline = Color3.fromRGB(52, 57, 66),
	OutlineSoft = Color3.fromRGB(39, 43, 51),
	Text = Color3.fromRGB(238, 240, 244),
	MutedText = Color3.fromRGB(146, 151, 160),
	FaintText = Color3.fromRGB(108, 113, 122),
	Primary = Color3.fromRGB(31, 34, 39),
	PrimaryHover = Color3.fromRGB(38, 42, 49),
	PrimaryText = Color3.fromRGB(238, 240, 244),
	Accent = Color3.fromRGB(133, 141, 160),
	AccentHover = Color3.fromRGB(153, 161, 180),
	AccentSoft = Color3.fromRGB(39, 43, 51),
	Shadow = Color3.fromRGB(5, 6, 8),
	Success = Color3.fromRGB(94, 194, 139),
	Danger = Color3.fromRGB(196, 58, 76),
	CornerRadius = 6,
}

local LUCIDE_URL = "https://raw.githubusercontent.com/mstudio45/lucide-roblox-direct/refs/heads/main/source.lua"
local LUCIDE_CACHE = "MonHubKey/cache/lucide-2026-08-03.lua"
local LucideState = {
	Attempted = false,
<<<<<<< HEAD
	Loading = false,
	Module = nil,
	Requests = {},
=======
	Module = nil,
>>>>>>> ad68b390578f41697efa91ba22aa27c4011c0fc6
}

local function compileLucide(source)
	if type(source) ~= "string" or source == "" or type(loadstring) ~= "function" then
		return nil
	end
	local safeSource = "local writefile, isfolder, makefolder, getcustomasset = nil, nil, nil, nil\n" .. source
	local ok, module = pcall(function()
		return loadstring(safeSource)()
	end)
	if ok and type(module) == "table" and type(module.GetAsset) == "function" then
		return module
	end
	return nil
end

local function cacheLucide(source)
	if type(writefile) ~= "function" or type(makefolder) ~= "function" then
		return
	end
	pcall(function()
		if type(isfolder) ~= "function" or not isfolder("MonHubKey") then
			makefolder("MonHubKey")
		end
		if type(isfolder) ~= "function" or not isfolder("MonHubKey/cache") then
			makefolder("MonHubKey/cache")
		end
		writefile(LUCIDE_CACHE, source)
	end)
end

<<<<<<< HEAD
local function loadCachedLucide()
=======
local function loadLucide()
>>>>>>> ad68b390578f41697efa91ba22aa27c4011c0fc6
	if LucideState.Attempted then
		return LucideState.Module
	end
	LucideState.Attempted = true

	if type(readfile) == "function" and type(isfile) == "function" then
<<<<<<< HEAD
		for _, path in ipairs({ LUCIDE_CACHE, "Obsidian/cache/lucide-2026-08-03.lua" }) do
			local ok, source = pcall(function()
				if isfile(path) then
					return readfile(path)
				end
				return nil
			end)
			if ok then
				LucideState.Module = compileLucide(source)
			end
			if LucideState.Module then
				break
			end
		end
	end
	return LucideState.Module
end

local function iconFromModule(requested, fallback)
	local icons = LucideState.Module
	if not icons then
		return nil
	end
	local ok, icon = pcall(icons.GetAsset, requested)
	if ok and type(icon) == "table" then
		return icon
	end
	if fallback and requested ~= fallback then
		local fallbackOk, fallbackIcon = pcall(icons.GetAsset, fallback)
		if fallbackOk and type(fallbackIcon) == "table" then
			return fallbackIcon
		end
	end
	return nil
end

local function applyResolvedIcon(image, data)
	if not image or not data then
		return false
	end
	local ok = pcall(function()
		image.Image = data.Url or data.Image or ""
		image.ImageRectOffset = data.ImageRectOffset or Vector2.new(0, 0)
		image.ImageRectSize = data.ImageRectSize or Vector2.new(0, 0)
	end)
	return ok and image.Image ~= ""
end

local function startLucideLoad()
	if LucideState.Module or LucideState.Loading then
		return
	end
	LucideState.Loading = true
	task.spawn(function()
		local ok, source = pcall(function()
			return game:HttpGet(LUCIDE_URL)
		end)
		if ok and type(source) == "string" and source ~= "" then
			LucideState.Module = compileLucide(source)
			if LucideState.Module then
				cacheLucide(source)
			end
		end
		if LucideState.Module then
			for _, request in ipairs(LucideState.Requests) do
				local icon = iconFromModule(request.Name, request.Fallback)
				if icon then
					applyResolvedIcon(request.Image, icon)
					if type(request.OnLoaded) == "function" then
						pcall(request.OnLoaded)
					end
				end
			end
		end
		LucideState.Requests = {}
		LucideState.Loading = false
	end)
=======
		local ok, source = pcall(function()
			if isfile(LUCIDE_CACHE) then
				return readfile(LUCIDE_CACHE)
			end
			return nil
		end)
		if ok then
			LucideState.Module = compileLucide(source)
		end
	end

	if LucideState.Module then
		return LucideState.Module
	end

	local ok, source = pcall(function()
		return game:HttpGet(LUCIDE_URL)
	end)
	if ok and type(source) == "string" and source ~= "" then
		LucideState.Module = compileLucide(source)
		if LucideState.Module then
			cacheLucide(source)
		end
	end

	return LucideState.Module
>>>>>>> ad68b390578f41697efa91ba22aa27c4011c0fc6
end

local function resolveIcon(value, fallback)
	local requested = value
	if requested == nil or requested == "" then
		requested = fallback
	end
	if type(requested) == "number" or tonumber(requested) then
		requested = "rbxassetid://" .. tostring(requested)
	end
	if type(requested) ~= "string" or requested == "" then
		return nil
	end

	local lowered = string.lower(requested)
	if string.match(lowered, "^rbxasset") or string.match(lowered, "^https?://") then
		return {
			Url = requested,
			ImageRectOffset = Vector2.new(0, 0),
			ImageRectSize = Vector2.new(0, 0),
			Custom = true,
		}
	end

<<<<<<< HEAD
	loadCachedLucide()
	local icon = iconFromModule(requested, fallback)
	if icon then
		return icon
	end
	if not LucideState.Module then
		startLucideLoad()
		return {
			Pending = true,
			Name = requested,
			Fallback = fallback,
		}
=======
	local icons = loadLucide()
	if icons then
		local ok, icon = pcall(icons.GetAsset, requested)
		if ok and type(icon) == "table" then
			return icon
		end
		if fallback and requested ~= fallback then
			local fallbackOk, fallbackIcon = pcall(icons.GetAsset, fallback)
			if fallbackOk and type(fallbackIcon) == "table" then
				return fallbackIcon
			end
		end
>>>>>>> ad68b390578f41697efa91ba22aa27c4011c0fc6
	end

	return nil
end

local function applyIcon(image, data)
	if not image or not data then
		return false
	end
<<<<<<< HEAD
	if data.Pending then
		local icon = iconFromModule(data.Name, data.Fallback)
		if icon then
			local applied = applyResolvedIcon(image, icon)
			if applied and type(data.OnLoaded) == "function" then
				pcall(data.OnLoaded)
			end
			return applied
		end
		table.insert(LucideState.Requests, {
			Image = image,
			Name = data.Name,
			Fallback = data.Fallback,
			OnLoaded = data.OnLoaded,
		})
		return false
	end
	return applyResolvedIcon(image, data)
end

local MAIN_FONT_URL = "https://raw.githubusercontent.com/SoftRatatui/Obsidian-main/main/Obsidian-main/assets/Inter-Bold.ttf?monhub=0.0.1-release-6-font-default"
local MAIN_FONT_PATH = "MonHub/assets/MonHubInterBold.ttf"
local MAIN_FONT_METADATA_PATH = "MonHub/assets/MonHubInterBold.json"
local FontState = {
	Attempted = false,
	Face = nil,
	Objects = {},
}

local function fontAssetFunction()
	if type(getcustomasset) == "function" then
		return getcustomasset
	end
	if type(getsynasset) == "function" then
		return getsynasset
	end
	return nil
end

local function isFontData(data)
	if type(data) ~= "string" or #data < 4096 then
		return false
	end
	local header = string.sub(data, 1, 4)
	return header == "\0\1\0\0" or header == "OTTO" or header == "true" or header == "ttcf" or header == "wOFF"
end

local function ensureMainFontFolders()
	if type(makefolder) ~= "function" then
		return false
	end
	local ok = pcall(function()
		if type(isfolder) ~= "function" or not isfolder("MonHub") then
			makefolder("MonHub")
		end
		if type(isfolder) ~= "function" or not isfolder("MonHub/assets") then
			makefolder("MonHub/assets")
		end
	end)
	return ok
end

local function loadMainFont()
	local assetFunction = fontAssetFunction()
	if not assetFunction or type(writefile) ~= "function" or type(isfile) ~= "function" then
		return nil
	end
	if not ensureMainFontFolders() then
		return nil
	end

	local fontData
	if isfile(MAIN_FONT_PATH) and type(readfile) == "function" then
		local readOk, cached = pcall(readfile, MAIN_FONT_PATH)
		if readOk and isFontData(cached) then
			fontData = cached
		end
	end
	if not fontData then
		local downloadOk, downloaded = pcall(function()
			return game:HttpGet(MAIN_FONT_URL)
		end)
		if not downloadOk or not isFontData(downloaded) then
			return nil
		end
		local writeOk = pcall(writefile, MAIN_FONT_PATH, downloaded)
		if not writeOk then
			return nil
		end
	end

	local assetOk, fontAsset = pcall(assetFunction, MAIN_FONT_PATH)
	if not assetOk or type(fontAsset) ~= "string" then
		return nil
	end
	local metadata = HttpService:JSONEncode({
		name = "MonHubInterBold",
		faces = {
			{
				name = "Regular",
				weight = 700,
				style = "normal",
				assetId = fontAsset,
			},
		},
	})
	local metadataOk = pcall(writefile, MAIN_FONT_METADATA_PATH, metadata)
	if not metadataOk then
		return nil
	end
	local metadataAssetOk, metadataAsset = pcall(assetFunction, MAIN_FONT_METADATA_PATH)
	if not metadataAssetOk or type(metadataAsset) ~= "string" then
		return nil
	end
	local faceOk, face = pcall(Font.new, metadataAsset, Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	if faceOk and typeof(face) == "Font" then
		return face
	end
	return nil
end

local function registerFont(object, bold)
	if not object then
		return object
	end
	local fallback = bold and Enum.Font.GothamBold or Enum.Font.Gotham
	pcall(function()
		object.FontFace = Font.fromEnum(fallback)
	end)
	if FontState.Face then
		pcall(function()
			object.FontFace = FontState.Face
		end)
	else
		table.insert(FontState.Objects, object)
	end
	return object
end

local function startMainFontLoad()
	if FontState.Attempted or FontState.Face then
		return
	end
	FontState.Attempted = true
	task.spawn(function()
		local face = loadMainFont()
		if face then
			FontState.Face = face
			for _, object in ipairs(FontState.Objects) do
				pcall(function()
					object.FontFace = face
				end)
			end
		end
		FontState.Objects = {}
	end)
=======
	image.Image = data.Url or data.Image or ""
	image.ImageRectOffset = data.ImageRectOffset or Vector2.new(0, 0)
	image.ImageRectSize = data.ImageRectSize or Vector2.new(0, 0)
	return image.Image ~= ""
>>>>>>> ad68b390578f41697efa91ba22aa27c4011c0fc6
end

local function create(className, properties)
	local instance = Instance.new(className)
	for property, value in pairs(properties) do
		if property ~= "Parent" then
			instance[property] = value
		end
	end
	instance.Parent = properties.Parent
	return instance
end

local function merge(base, overrides)
	local result = {}
	for key, value in pairs(base) do
		result[key] = value
	end
	if type(overrides) == "table" then
		for key, value in pairs(overrides) do
			result[key] = value
		end
	end
	return result
end

local function safeCall(callback, ...)
	if type(callback) ~= "function" then
		return true
	end
	local ok, result = pcall(callback, ...)
	if not ok then
		warn("[MonHubKey] Callback failed: " .. tostring(result))
	end
	return ok, result
end

local function resolveParent(customParent)
	if typeof(customParent) == "Instance" then
		return customParent
	end

	local ok, executorGui = pcall(function()
		if type(gethui) == "function" then
			return gethui()
		end
		return nil
	end)
	if ok and typeof(executorGui) == "Instance" then
		return executorGui
	end

	local player = Players.LocalPlayer
	if player then
		return player:WaitForChild("PlayerGui")
	end

	return game:GetService("CoreGui")
end

local function addCorner(parent, radius)
	return create("UICorner", {
		CornerRadius = UDim.new(0, radius),
		Parent = parent,
	})
end

local function addStroke(parent, color, transparency, thickness)
	return create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = color,
		Transparency = transparency or 0,
		Thickness = thickness or 1,
		Parent = parent,
	})
end

local function addSoftShadow(parent, color)
	local shadow
	local ok = pcall(function()
		shadow = Instance.new("UIShadow")
		shadow.BlurRadius = UDim.new(0, 18)
		shadow.Color = color
		shadow.Offset = UDim2.fromOffset(0, 4)
		shadow.Spread = UDim2.fromOffset(1, 1)
		shadow.Transparency = 0.42
		shadow.ZIndex = 0
		shadow.Parent = parent
	end)
	if ok then
		return shadow
	end
	if shadow then
		shadow:Destroy()
	end
	return nil
end

local function normalizeValidationResult(first, second)
	if type(first) == "table" then
		local success = first.Success == true or first.Valid == true or first.valid == true or first.success == true
		return success, first.Message or first.message or first.error, first.Data or first.data or first
	end
	return first == true, second, nil
end

function KeySystem.new(options)
	options = options or {}

	local self = setmetatable({}, KeySystem)
	self.Options = options
	self.Theme = merge(DEFAULT_THEME, options.Theme)
	self.Destroyed = false
	self.Visible = false
	self.Busy = false
	self._requestId = 0
	self._connections = {}
	self._tweens = {}

	self:_build()
	self:Show()
	startMainFontLoad()

	return self
end

function KeySystem:_connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(self._connections, connection)
	return connection
end

function KeySystem:_tween(instance, key, tweenInfo, goals)
	local oldTween = self._tweens[key]
	if oldTween then
		oldTween:Cancel()
	end

	local tween = TweenService:Create(instance, tweenInfo, goals)
	self._tweens[key] = tween
	tween:Play()
	return tween
end

function KeySystem:_addHover(button, normalColor, hoverColor, key)
	self:_connect(button.MouseEnter, function()
		if self.Destroyed or not button.Active then
			return
		end
		self:_tween(button, key, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = hoverColor,
		})
	end)

	self:_connect(button.MouseLeave, function()
		if self.Destroyed then
			return
		end
		self:_tween(button, key, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = normalColor,
		})
	end)
end

function KeySystem:_build()
	local options = self.Options
	local theme = self.Theme
	local parent = resolveParent(options.Parent)
	local showPremium = options.ShowPremium ~= false
	local showGetKey = options.ShowGetKey ~= false
	local showDiscord = options.ShowDiscord ~= false
	local showActions = showGetKey or showDiscord
	local cardHeight = showPremium and 326 or 250
	self.CardHeight = cardHeight

	local existing = parent:FindFirstChild(options.GuiName or "MonHubKey")
	if existing then
		existing:Destroy()
	end

	local gui = create("ScreenGui", {
		Name = options.GuiName or "MonHubKey",
		DisplayOrder = options.DisplayOrder or 100000,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = parent,
	})
	self.Gui = gui

	local overlay = create("TextButton", {
		Name = "Overlay",
		AutoButtonColor = false,
		BackgroundColor3 = theme.Overlay,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		ZIndex = 1,
		Parent = gui,
	})
	self.Overlay = overlay

	if options.Blur ~= false then
		local blurName = (options.GuiName or "MonHubKey") .. "Blur"
		local existingBlur = Lighting:FindFirstChild(blurName)
		if existingBlur then
			existingBlur:Destroy()
		end
		local blur = create("BlurEffect", {
			Name = blurName,
			Size = 0,
			Parent = Lighting,
		})
		self.BlurEffect = blur
	end

	local shadow = create("Frame", {
		Name = "Shadow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.Shadow,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 5),
		Size = UDim2.fromOffset(426, cardHeight + 6),
		ZIndex = 2,
		Parent = overlay,
	})
	self.Shadow = shadow
	addCorner(shadow, math.min((theme.CornerRadius or 6) + 3, 10))

	local card = create("CanvasGroup", {
		Name = "Card",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.Card,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(420, cardHeight),
		ZIndex = 3,
		Parent = overlay,
	})
	self.Card = card
	addCorner(card, math.min((theme.CornerRadius or 6) + 1, 8))
	addStroke(card, theme.Outline, 0.08, 1)
	local nativeShadow = addSoftShadow(card, theme.Shadow)
	shadow.Visible = nativeShadow == nil
	self.NativeShadow = nativeShadow

	local cardScale = create("UIScale", {
		Scale = 0.96,
		Parent = card,
	})
	self.CardScale = cardScale

	local shadowScale = create("UIScale", {
		Scale = 0.96,
		Parent = shadow,
	})
	self.ShadowScale = shadowScale

	local headerSurface = create("Frame", {
		Name = "Header",
		Active = true,
		BackgroundColor3 = theme.Header or theme.Card,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 40),
		ZIndex = 3,
		Parent = card,
	})
	addCorner(headerSurface, math.min((theme.CornerRadius or 6) + 1, 8))
	create("Frame", {
		BackgroundColor3 = theme.Header or theme.Card,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -8),
		Size = UDim2.new(1, 0, 0, 8),
		ZIndex = 3,
		Parent = headerSurface,
	})

	local headerIconData = resolveIcon(options.Icon, "key")
	local hasIcon = headerIconData ~= nil
	if hasIcon then
		local headerIcon = create("ImageLabel", {
			Name = "Icon",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ImageColor3 = theme.Accent,
			Position = UDim2.fromOffset(20, 20),
			Size = options.IconSize or UDim2.fromOffset(18, 18),
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 5,
			Parent = card,
		})
		applyIcon(headerIcon, headerIconData)
	end

	local title = create("TextLabel", {
		Name = "Title",
		Active = true,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(hasIcon and 38 or 13, 0),
		Size = UDim2.new(1, hasIcon and -78 or -53, 0, 40),
		Font = Enum.Font.GothamBold,
		Text = options.Title or "MonHub",
		TextColor3 = theme.Text,
		TextSize = 14,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
		Parent = card,
	})
	registerFont(title, true)

	local closeIconData = resolveIcon("x")
	local closeButton = create("ImageButton", {
		Name = "Close",
		AutoButtonColor = false,
		BackgroundColor3 = theme.CardRaised,
		BackgroundTransparency = 0,
		Image = "",
		ImageColor3 = theme.MutedText,
		Position = UDim2.new(1, -33, 0, 7),
		Size = UDim2.fromOffset(26, 26),
		Visible = options.AllowClose ~= false,
		ZIndex = 5,
		Parent = card,
	})
<<<<<<< HEAD
	local closeFallback
	if not closeIconData or closeIconData.Pending then
		closeFallback = registerFont(create("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			Size = UDim2.fromScale(1, 1),
			Text = "X",
			TextColor3 = theme.MutedText,
			TextSize = 12,
			ZIndex = 6,
			Parent = closeButton,
		}), false)
	end
	if closeIconData and closeIconData.Pending then
		closeIconData.OnLoaded = function()
			if closeFallback then
				closeFallback.Visible = false
			end
		end
	end
=======
>>>>>>> ad68b390578f41697efa91ba22aa27c4011c0fc6
	applyIcon(closeButton, closeIconData)
	addCorner(closeButton, theme.CornerRadius or 6)
	self:_addHover(closeButton, theme.CardRaised, theme.CardHover, "CloseHover")
	self:_connect(closeButton.MouseEnter, function()
		self:_tween(closeButton, "CloseIconHover", TweenInfo.new(0.11, Enum.EasingStyle.Quint), {
			ImageColor3 = theme.Text,
		})
<<<<<<< HEAD
		if closeFallback then
			self:_tween(closeFallback, "CloseFallbackHover", TweenInfo.new(0.11, Enum.EasingStyle.Quint), {
				TextColor3 = theme.Text,
			})
		end
=======
>>>>>>> ad68b390578f41697efa91ba22aa27c4011c0fc6
	end)
	self:_connect(closeButton.MouseLeave, function()
		self:_tween(closeButton, "CloseIconHover", TweenInfo.new(0.11, Enum.EasingStyle.Quint), {
			ImageColor3 = theme.MutedText,
		})
<<<<<<< HEAD
		if closeFallback then
			self:_tween(closeFallback, "CloseFallbackHover", TweenInfo.new(0.11, Enum.EasingStyle.Quint), {
				TextColor3 = theme.MutedText,
			})
		end
=======
>>>>>>> ad68b390578f41697efa91ba22aa27c4011c0fc6
	end)

	create("Frame", {
		Name = "HeaderDivider",
		BackgroundColor3 = theme.AccentSoft or theme.OutlineSoft,
		BackgroundTransparency = 0.42,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 40),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 4,
		Parent = card,
	})

	local subtitle = create("TextLabel", {
		Name = "Subtitle",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 55),
		Size = UDim2.new(1, -32, 0, 18),
		Font = Enum.Font.Gotham,
		Text = options.Subtitle or "Enter your key to continue",
		TextColor3 = theme.MutedText,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
		Parent = card,
	})
	registerFont(subtitle, false)

	local inputHolder = create("Frame", {
		Name = "InputHolder",
		BackgroundColor3 = theme.CardRaised,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 80),
		Size = UDim2.new(1, -32, 0, 46),
		ZIndex = 4,
		Parent = card,
	})
	addCorner(inputHolder, math.max(3, math.floor((theme.CornerRadius or 6) / 2)))
	local inputStroke = addStroke(inputHolder, theme.Outline, 0.42, 1)
	self.InputStroke = inputStroke

	local inputIconData = resolveIcon("key-round", "key")
	local inputIcon
	if inputIconData then
		inputIcon = create("ImageLabel", {
			Name = "InputIcon",
			BackgroundTransparency = 1,
			ImageColor3 = theme.MutedText,
			Position = UDim2.fromOffset(13, 15),
			Size = UDim2.fromOffset(16, 16),
			ZIndex = 5,
			Parent = inputHolder,
		})
		applyIcon(inputIcon, inputIconData)
	end

	local input = create("TextBox", {
		Name = "KeyInput",
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		PlaceholderColor3 = theme.FaintText,
		PlaceholderText = options.Placeholder or "Enter key",
		Position = UDim2.fromOffset(inputIcon and 40 or 13, 0),
		Size = UDim2.new(1, inputIcon and -53 or -26, 1, 0),
		Text = options.DefaultKey or "",
		TextColor3 = theme.Text,
		TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 5,
		Parent = inputHolder,
	})
	registerFont(input, false)
	self.Input = input

	local function createCenteredContent(parentObject, iconName, fallbackIcon, textValue, textColor, iconColor, textSize)
		local content = create("Frame", {
			Name = "Content",
			AnchorPoint = Vector2.new(0.5, 0.5),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(0, 0),
			ZIndex = parentObject.ZIndex + 1,
			Parent = parentObject,
		})
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 7),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Parent = content,
		})
		local iconData = resolveIcon(iconName, fallbackIcon)
		local icon
		if iconData then
			icon = create("ImageLabel", {
				Name = "Icon",
				BackgroundTransparency = 1,
				ImageColor3 = iconColor,
				LayoutOrder = 1,
				Size = UDim2.fromOffset(15, 15),
				ZIndex = parentObject.ZIndex + 1,
				Parent = content,
			})
			applyIcon(icon, iconData)
		end
		local label = create("TextLabel", {
			Name = "Label",
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			LayoutOrder = 2,
			Size = UDim2.fromOffset(0, 0),
			Text = textValue,
			TextColor3 = textColor,
			TextSize = textSize,
			TextWrapped = false,
			ZIndex = parentObject.ZIndex + 1,
			Parent = content,
		})
<<<<<<< HEAD
		registerFont(label, true)
=======
>>>>>>> ad68b390578f41697efa91ba22aa27c4011c0fc6
		return label, icon
	end

	local verifyButton = create("TextButton", {
		Name = "Verify",
		AutoButtonColor = false,
		BackgroundColor3 = theme.Primary,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 138),
		Size = UDim2.new(1, -32, 0, 44),
		Text = "",
		ZIndex = 4,
		Parent = card,
	})
	addCorner(verifyButton, math.max(3, math.floor((theme.CornerRadius or 6) / 2)))
	local verifyStroke = addStroke(verifyButton, theme.Outline, 0.18, 1)
	local verifyLabel, verifyIcon = createCenteredContent(
		verifyButton,
		"shield-check",
		"check",
		options.VerifyText or "Verify",
		theme.PrimaryText,
		theme.Accent,
		14
	)
	self.VerifyButton = verifyButton
	self.VerifyLabel = verifyLabel
	self.VerifyIcon = verifyIcon
<<<<<<< HEAD
	self.VerifyIdleIconData = resolveIcon("shield-check", "check")
	self.VerifyLoadingIconData = resolveIcon("loader-circle", "loader")
=======
>>>>>>> ad68b390578f41697efa91ba22aa27c4011c0fc6
	self:_addHover(verifyButton, theme.Primary, theme.PrimaryHover, "VerifyHover")
	self:_connect(verifyButton.MouseEnter, function()
		self:_tween(verifyStroke, "VerifyStrokeHover", TweenInfo.new(0.11, Enum.EasingStyle.Quint), {
			Color = theme.Accent,
			Transparency = 0.18,
		})
		if verifyIcon then
			self:_tween(verifyIcon, "VerifyIconHover", TweenInfo.new(0.11, Enum.EasingStyle.Quint), {
				ImageColor3 = theme.AccentHover,
			})
		end
	end)
	self:_connect(verifyButton.MouseLeave, function()
		self:_tween(verifyStroke, "VerifyStrokeHover", TweenInfo.new(0.11, Enum.EasingStyle.Quint), {
			Color = theme.Outline,
			Transparency = 0.18,
		})
		if verifyIcon then
			self:_tween(verifyIcon, "VerifyIconHover", TweenInfo.new(0.11, Enum.EasingStyle.Quint), {
				ImageColor3 = theme.Accent,
			})
		end
	end)

	local status = create("TextLabel", {
		Name = "Status",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 189),
		Size = UDim2.new(1, -32, 0, 16),
		Font = Enum.Font.Gotham,
		Text = "",
		TextColor3 = theme.MutedText,
		TextSize = 11,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 4,
		Parent = card,
	})
	registerFont(status, false)
	self.Status = status

	local actions = create("Frame", {
		Name = "Actions",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 210),
		Size = UDim2.new(1, -32, 0, 28),
		Visible = showActions,
		ZIndex = 4,
		Parent = card,
	})
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Parent = actions,
	})

	local function makeAction(name, text, order)
		local button = create("TextButton", {
			Name = name,
			AutoButtonColor = false,
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = theme.Card,
			BackgroundTransparency = 1,
			LayoutOrder = order,
			Size = UDim2.fromOffset(0, 28),
			Text = "",
			ZIndex = 5,
			Parent = actions,
		})
		create("UIPadding", {
			PaddingLeft = UDim.new(0, 9),
			PaddingRight = UDim.new(0, 9),
			Parent = button,
		})
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Parent = button,
		})
		local actionLabel = create("TextLabel", {
			Name = "Label",
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			LayoutOrder = 1,
			Size = UDim2.fromOffset(0, 0),
			Text = text,
			TextColor3 = theme.MutedText,
			TextSize = 12,
			TextWrapped = false,
			ZIndex = 6,
			Parent = button,
		})
		registerFont(actionLabel, false)
		addCorner(button, theme.CornerRadius or 6)
		self:_connect(button.MouseEnter, function()
			self:_tween(button, name .. "Hover", TweenInfo.new(0.11, Enum.EasingStyle.Quint), {
				BackgroundTransparency = 0,
				BackgroundColor3 = theme.CardRaised,
			})
			self:_tween(actionLabel, name .. "LabelHover", TweenInfo.new(0.11, Enum.EasingStyle.Quint), {
				TextColor3 = theme.Text,
			})
		end)
		self:_connect(button.MouseLeave, function()
			self:_tween(button, name .. "Hover", TweenInfo.new(0.11, Enum.EasingStyle.Quint), {
				BackgroundTransparency = 1,
				BackgroundColor3 = theme.Card,
			})
			self:_tween(actionLabel, name .. "LabelHover", TweenInfo.new(0.11, Enum.EasingStyle.Quint), {
				TextColor3 = theme.MutedText,
			})
		end)
		return button
	end

	local getKeyButton = makeAction("GetKey", options.GetKeyText or "Get key", 1)
	local discordButton = makeAction("Discord", options.DiscordText or "Discord", 2)
	getKeyButton.Visible = showGetKey
	discordButton.Visible = showDiscord
	self.GetKeyButton = getKeyButton
	self.DiscordButton = discordButton

	create("Frame", {
		Name = "FooterDivider",
		BackgroundColor3 = theme.AccentSoft or theme.OutlineSoft,
		BackgroundTransparency = 0.42,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 16, 0, 250),
		Size = UDim2.new(1, -32, 0, 1),
		Visible = showPremium,
		ZIndex = 4,
		Parent = card,
	})

	local premiumIconData = resolveIcon(options.PremiumIcon, "gem")
	local hasPremiumIcon = premiumIconData ~= nil
	if hasPremiumIcon then
		local premiumIcon = create("ImageLabel", {
			Name = "PremiumIcon",
			BackgroundTransparency = 1,
			ImageColor3 = theme.Accent,
			Position = UDim2.fromOffset(17, 271),
			Size = UDim2.fromOffset(18, 18),
			ScaleType = Enum.ScaleType.Fit,
			Visible = showPremium,
			ZIndex = 5,
			Parent = card,
		})
		applyIcon(premiumIcon, premiumIconData)
	end

	local premiumTitle = create("TextLabel", {
		Name = "PremiumTitle",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(hasPremiumIcon and 47 or 16, 261),
		Size = UDim2.new(1, hasPremiumIcon and -171 or -140, 0, 19),
		Font = Enum.Font.GothamBold,
		Text = options.PremiumTitle or "Get Premium",
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
		Visible = showPremium,
		Parent = card,
	})
	registerFont(premiumTitle, true)

	local premiumSubtitle = create("TextLabel", {
		Name = "PremiumSubtitle",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(hasPremiumIcon and 47 or 16, 281),
		Size = UDim2.new(1, hasPremiumIcon and -171 or -140, 0, 18),
		Font = Enum.Font.Gotham,
		Text = options.PremiumSubtitle or "Instant delivery · 24/7 support",
		TextColor3 = theme.MutedText,
		TextSize = 11,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
		Visible = showPremium,
		Parent = card,
	})
	registerFont(premiumSubtitle, false)

	local buyButton = create("TextButton", {
		Name = "BuyPremium",
		AnchorPoint = Vector2.new(1, 0),
		AutoButtonColor = false,
		BackgroundColor3 = theme.CardRaised,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -16, 0, 264),
		Size = UDim2.fromOffset(92, 34),
		Text = "",
		ZIndex = 5,
		Visible = showPremium,
		Parent = card,
	})
	addCorner(buyButton, theme.CornerRadius or 6)
	addStroke(buyButton, theme.Outline, 0.2, 1)
	local buyLabel, buyIcon = createCenteredContent(
		buyButton,
		"shopping-bag",
		"shopping-cart",
		options.BuyText or "Buy",
		theme.Text,
		theme.Accent,
		12
	)
	self:_addHover(buyButton, theme.CardRaised, theme.CardHover, "BuyHover")
	self:_connect(buyButton.MouseEnter, function()
		if buyIcon then
			self:_tween(buyIcon, "BuyIconHover", TweenInfo.new(0.11, Enum.EasingStyle.Quint), {
				ImageColor3 = theme.AccentHover,
			})
		end
	end)
	self:_connect(buyButton.MouseLeave, function()
		if buyIcon then
			self:_tween(buyIcon, "BuyIconHover", TweenInfo.new(0.11, Enum.EasingStyle.Quint), {
				ImageColor3 = theme.Accent,
			})
		end
	end)
	self.BuyLabel = buyLabel
	self.BuyButton = buyButton

	self:_connect(input.Focused, function()
		self:_tween(inputStroke, "InputStroke", TweenInfo.new(0.12), {
			Color = theme.Accent,
			Transparency = 0.15,
		})
		if inputIcon then
			self:_tween(inputIcon, "InputIcon", TweenInfo.new(0.12), {
				ImageColor3 = theme.Accent,
			})
		end
	end)

	self:_connect(input.FocusLost, function(enterPressed)
		self:_tween(inputStroke, "InputStroke", TweenInfo.new(0.12), {
			Color = theme.Outline,
			Transparency = 0.42,
		})
		if inputIcon then
			self:_tween(inputIcon, "InputIcon", TweenInfo.new(0.12), {
				ImageColor3 = theme.MutedText,
			})
		end
		if enterPressed then
			self:Submit()
		end
	end)

	self:_connect(input:GetPropertyChangedSignal("Text"), function()
		local maxLength = options.MaxKeyLength or 160
		if #input.Text > maxLength then
			input.Text = string.sub(input.Text, 1, maxLength)
		end
		if self.Status.Text ~= "" and not self.Busy then
			self:SetStatus("")
			local focused = input:IsFocused()
			self:_tween(inputStroke, "InputStroke", TweenInfo.new(0.12), {
				Color = focused and theme.Accent or theme.Outline,
				Transparency = focused and 0.15 or 0.42,
			})
		end
	end)

	self:_connect(verifyButton.Activated, function()
		self:Submit()
	end)
	self:_connect(closeButton.Activated, function()
		self:Close()
	end)
	self:_connect(getKeyButton.Activated, function()
		self:_runAction("Get key", options.GetKeyUrl, options.OnGetKey)
	end)
	self:_connect(discordButton.Activated, function()
		self:_runAction("Discord", options.DiscordUrl, options.OnDiscord)
	end)
	self:_connect(buyButton.Activated, function()
		self:_runAction("Premium", options.PremiumUrl, options.OnPremium)
	end)

	self:_enableDragging(title)
	self:_enableResponsiveScale()
end

function KeySystem:_enableDragging(dragArea)
	if self.Options.Draggable == false then
		return
	end

	local dragging = false
	local dragStart
	local startPosition

	self:_connect(dragArea.InputBegan, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end
		dragging = true
		dragStart = input.Position
		startPosition = self.Card.Position
	end)

	self:_connect(UserInputService.InputChanged, function(input)
		if not dragging or not dragStart or not startPosition then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end
		local delta = input.Position - dragStart
		local xOffset = startPosition.X.Offset + delta.X
		local yOffset = startPosition.Y.Offset + delta.Y
		local camera = workspace.CurrentCamera
		if camera then
			local viewport = camera.ViewportSize
			local scale = self._responsiveScale or 1
			local halfWidth = 210 * scale
			local halfHeight = self.CardHeight * scale * 0.5
			local absoluteX = startPosition.X.Scale * viewport.X + xOffset
			local absoluteY = startPosition.Y.Scale * viewport.Y + yOffset
			if viewport.X > halfWidth * 2 + 16 then
				absoluteX = math.clamp(absoluteX, halfWidth + 8, viewport.X - halfWidth - 8)
			else
				absoluteX = viewport.X * 0.5
			end
			if viewport.Y > halfHeight * 2 + 16 then
				absoluteY = math.clamp(absoluteY, halfHeight + 8, viewport.Y - halfHeight - 8)
			else
				absoluteY = viewport.Y * 0.5
			end
			xOffset = absoluteX - startPosition.X.Scale * viewport.X
			yOffset = absoluteY - startPosition.Y.Scale * viewport.Y
		end
		local nextPosition = UDim2.new(startPosition.X.Scale, xOffset, startPosition.Y.Scale, yOffset)
		self.Card.Position = nextPosition
		self.Shadow.Position = UDim2.new(
			nextPosition.X.Scale,
			nextPosition.X.Offset,
			nextPosition.Y.Scale,
			nextPosition.Y.Offset + 5
		)
	end)

	self:_connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = false
		end
	end)
end

function KeySystem:_enableResponsiveScale()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	local function updateScale()
		if self.Destroyed then
			return
		end
		local viewport = camera.ViewportSize
		local fitX = (viewport.X - 24) / 420
		local fitY = (viewport.Y - 24) / self.CardHeight
		local scale = math.clamp(math.min(fitX, fitY), 0.55, 1)
		self._responsiveScale = scale
		if self.Visible then
			self.CardScale.Scale = scale
			self.ShadowScale.Scale = scale
		end
	end

	updateScale()
	self:_connect(camera:GetPropertyChangedSignal("ViewportSize"), updateScale)
end

function KeySystem:_runAction(label, url, callback)
	if self.Destroyed then
		return
	end

	if type(callback) == "function" then
		local ok, message = safeCall(callback, url, self)
		if ok and type(message) == "string" and message ~= "" then
			self:SetStatus(message, "neutral")
		end
		return
	end

	if type(url) == "string" and url ~= "" and type(setclipboard) == "function" then
		local ok = pcall(setclipboard, url)
		if ok then
			self:SetStatus(label .. " link copied", "success")
			return
		end
	end

	self:SetStatus("Configure the " .. label .. " action", "error")
end

function KeySystem:SetStatus(message, kind)
	if self.Destroyed then
		return
	end

	self.Status.Text = tostring(message or "")
	if kind == "success" then
		self.Status.TextColor3 = self.Theme.Success
	elseif kind == "error" then
		self.Status.TextColor3 = self.Theme.Danger
	else
		self.Status.TextColor3 = self.Theme.MutedText
	end
end

function KeySystem:SetBusy(busy)
	if self.Destroyed then
		return
	end

	self.Busy = busy == true
	self._busyAnimationId = (self._busyAnimationId or 0) + 1
	local animationId = self._busyAnimationId
	self.VerifyButton.Active = not self.Busy
	self.Input.TextEditable = not self.Busy
	if self.Busy then
		self.VerifyLabel.Text = self.Options.CheckingText or "Checking..."
		self.VerifyButton.BackgroundTransparency = 0.16
		if self.VerifyIcon then
			applyIcon(self.VerifyIcon, self.VerifyLoadingIconData)
			self.VerifyIcon.ImageTransparency = 0
			self.VerifyIcon.Rotation = 0
			task.spawn(function()
				while not self.Destroyed and self.Busy and self._busyAnimationId == animationId do
					self.VerifyIcon.Rotation = 0
					local spin = self:_tween(self.VerifyIcon, "VerifySpin", TweenInfo.new(0.44, Enum.EasingStyle.Linear), {
						Rotation = 360,
					})
					spin.Completed:Wait()
				end
			end)
		end
	else
		self.VerifyLabel.Text = self.Options.VerifyText or "Verify"
		self.VerifyButton.BackgroundTransparency = 0
		if self.VerifyIcon then
			local spin = self._tweens.VerifySpin
			if spin then
				spin:Cancel()
				self._tweens.VerifySpin = nil
			end
			self.VerifyIcon.Rotation = 0
			applyIcon(self.VerifyIcon, self.VerifyIdleIconData)
			self.VerifyIcon.ImageTransparency = 0
		end
	end
end

function KeySystem:Submit(keyOverride)
	if self.Destroyed or self.Busy then
		return
	end

	local key = tostring(keyOverride or self.Input.Text)
	key = string.match(key, "^%s*(.-)%s*$") or ""
	self.Input.Text = key

	if key == "" then
		self:SetStatus(self.Options.EmptyKeyMessage or "Enter a key first", "error")
		self:_tween(self.InputStroke, "InputStroke", TweenInfo.new(0.12), {
			Color = self.Theme.Danger,
			Transparency = 0.1,
		})
		self.Input:CaptureFocus()
		return
	end

	if type(self.Options.Validate) ~= "function" then
		self:SetStatus("No validation function configured", "error")
		return
	end

	self._requestId = self._requestId + 1
	local requestId = self._requestId
	self:SetBusy(true)
	self:SetStatus(self.Options.CheckingMessage or "Verifying your key…", "neutral")

	task.spawn(function()
		local callOk, first, second = pcall(self.Options.Validate, key, self)
		if self.Destroyed or requestId ~= self._requestId then
			return
		end

		self:SetBusy(false)
		if not callOk then
			warn("[MonHubKey] Validation failed: " .. tostring(first))
			self:SetStatus(self.Options.ErrorMessage or "Verification service is unavailable", "error")
			safeCall(self.Options.OnFailure, key, first, self)
			return
		end

		local success, message, data = normalizeValidationResult(first, second)
		if success then
			self:SetStatus(message or self.Options.SuccessMessage or "Key accepted", "success")
			self:_tween(self.InputStroke, "InputStroke", TweenInfo.new(0.16), {
				Color = self.Theme.Success,
				Transparency = 0.05,
			})
			safeCall(self.Options.OnSuccess, key, data, self)

			if self.Options.CloseOnSuccess ~= false then
				task.delay(self.Options.SuccessDelay or 0.45, function()
					if not self.Destroyed and requestId == self._requestId then
						self:Hide()
					end
				end)
			end
		else
			self:SetStatus(message or self.Options.InvalidKeyMessage or "This key is invalid", "error")
			self:_tween(self.InputStroke, "InputStroke", TweenInfo.new(0.16), {
				Color = self.Theme.Danger,
				Transparency = 0.05,
			})
			safeCall(self.Options.OnFailure, key, message, self)
		end
	end)
end

function KeySystem:SetKey(key)
	if self.Destroyed then
		return
	end
	self.Input.Text = tostring(key or "")
end

function KeySystem:GetKey()
	if self.Destroyed then
		return ""
	end
	return self.Input.Text
end

function KeySystem:Focus()
	if not self.Destroyed then
		self.Input:CaptureFocus()
	end
end

function KeySystem:Show()
	if self.Destroyed or self.Visible then
		return
	end

	self.Visible = true
	self.Gui.Enabled = true
	local scale = self._responsiveScale or 1
	local cardPosition = self.Card.Position
	local shadowPosition = self.Shadow.Position
	self.Card.Position = UDim2.new(cardPosition.X.Scale, cardPosition.X.Offset, cardPosition.Y.Scale, cardPosition.Y.Offset + 3)
	self.Shadow.Position = UDim2.new(shadowPosition.X.Scale, shadowPosition.X.Offset, shadowPosition.Y.Scale, shadowPosition.Y.Offset + 3)
	self.CardScale.Scale = scale * 0.975
	self.ShadowScale.Scale = scale * 0.975
	self.Card.GroupTransparency = 1
	self.Shadow.BackgroundTransparency = 1
	self.Overlay.BackgroundTransparency = 1

	self:_tween(self.Overlay, "OverlayOpen", TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = self.Options.OverlayTransparency or 0.42,
	})
	self:_tween(self.Card, "CardOpen", TweenInfo.new(0.09, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		GroupTransparency = 0,
		Position = cardPosition,
	})
	self:_tween(self.Shadow, "ShadowOpen", TweenInfo.new(0.09, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.68,
		Position = shadowPosition,
	})
	self:_tween(self.CardScale, "CardScale", TweenInfo.new(0.09, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Scale = scale,
	})
	self:_tween(self.ShadowScale, "ShadowScale", TweenInfo.new(0.09, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Scale = scale,
	})
	if self.BlurEffect then
		self:_tween(self.BlurEffect, "Blur", TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = self.Options.BlurSize or 10,
		})
	end
end

function KeySystem:Hide()
	if self.Destroyed or not self.Visible then
		return
	end

	self.Visible = false
	self._requestId = self._requestId + 1
	self:SetBusy(false)

	self:_tween(self.Overlay, "OverlayOpen", TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1,
	})
	self:_tween(self.Card, "CardOpen", TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		GroupTransparency = 1,
	})
	self:_tween(self.Shadow, "ShadowOpen", TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1,
	})
	if self.BlurEffect then
		self:_tween(self.BlurEffect, "Blur", TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = 0,
		})
	end

	task.delay(0.07, function()
		if not self.Destroyed and not self.Visible then
			self.Gui.Enabled = false
		end
	end)
end

function KeySystem:Close()
	if self.Destroyed then
		return
	end

	safeCall(self.Options.OnClose, self)
	if self.Options.CloseBehavior == "Destroy" then
		self:Destroy()
	else
		self:Hide()
	end
end

function KeySystem:Destroy()
	if self.Destroyed then
		return
	end

	self.Destroyed = true
	self.Visible = false
	self._requestId = self._requestId + 1

	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end
	table.clear(self._connections)

	for _, tween in pairs(self._tweens) do
		tween:Cancel()
	end
	table.clear(self._tweens)

	if self.BlurEffect then
		self.BlurEffect:Destroy()
	end
	if self.Gui then
		self.Gui:Destroy()
	end
end

local MonHubKey = {
	Appearance = {
		Title = "MonHub",
		Subtitle = "Enter your key to continue",
		Icon = "key",
		IconSize = UDim2.fromOffset(18, 18),
	},
	Links = {
		GetKey = "",
		Discord = "",
	},
	Storage = {
		FileName = "MonHub_Key",
		Remember = true,
		AutoLoad = true,
	},
	Options = {
		Keyless = false,
		KeylessUI = false,
		Blur = true,
		Draggable = true,
		NoGetKey = false,
	},
	Theme = {
		Accent = Color3.fromRGB(133, 141, 160),
		AccentHover = Color3.fromRGB(153, 161, 180),
		AccentSoft = Color3.fromRGB(39, 43, 51),
		Background = Color3.fromRGB(17, 19, 22),
		Header = Color3.fromRGB(29, 32, 37),
		Surface = Color3.fromRGB(23, 25, 29),
		Raised = Color3.fromRGB(29, 32, 37),
		Input = Color3.fromRGB(31, 34, 39),
		Hover = Color3.fromRGB(38, 42, 49),
		Text = Color3.fromRGB(238, 240, 244),
		TextDim = Color3.fromRGB(146, 151, 160),
		TextFaint = Color3.fromRGB(108, 113, 122),
		Success = Color3.fromRGB(94, 194, 139),
		Error = Color3.fromRGB(196, 58, 76),
		Warning = Color3.fromRGB(208, 157, 80),
		StatusIdle = Color3.fromRGB(146, 151, 160),
		Discord = Color3.fromRGB(88, 101, 242),
		DiscordHover = Color3.fromRGB(114, 137, 218),
		Divider = Color3.fromRGB(52, 57, 66),
		Outline = Color3.fromRGB(52, 57, 66),
		Shadow = Color3.fromRGB(5, 6, 8),
		Pending = Color3.fromRGB(39, 43, 51),
		CornerRadius = 6,
	},
	Callbacks = {
		OnVerify = nil,
		OnSuccess = nil,
		OnFail = nil,
		OnClose = nil,
	},
	Shop = {
		Enabled = false,
		Icon = "gem",
		Title = "Get Premium Access",
		Subtitle = "Instant delivery • 24/7 support",
		ButtonText = "Buy",
		Link = "",
	},
}

local Runtime = {
	Gate = nil,
	Junkie = nil,
	Validate = nil,
	KeyLink = nil,
}

local function getEnvironment()
	local ok, environment = pcall(function()
		if type(getgenv) == "function" then
			return getgenv()
		end
		return _G
	end)
	if ok and type(environment) == "table" then
		return environment
	end
	return _G
end

local Environment = getEnvironment()

local function storagePath()
	local fileName = tostring(MonHubKey.Storage.FileName or "MonHub_Key")
	fileName = string.gsub(fileName, "[/\\:%*%?\"<>|]", "_")
	if string.sub(string.lower(fileName), -4) ~= ".txt" then
		fileName = fileName .. ".txt"
	end
	return "MonHubKey/" .. fileName
end

local function canReadFiles()
	return type(readfile) == "function" and type(isfile) == "function"
end

local function canWriteFiles()
	return type(writefile) == "function" and type(makefolder) == "function"
end

local function ensureStorage()
	if not canWriteFiles() then
		return false
	end
	local ok = pcall(function()
		if type(isfolder) ~= "function" or not isfolder("MonHubKey") then
			makefolder("MonHubKey")
		end
	end)
	return ok
end

local function loadSavedKey()
	if not canReadFiles() then
		return nil
	end
	local ok, key = pcall(function()
		local path = storagePath()
		if isfile(path) then
			return readfile(path)
		end
		return nil
	end)
	if ok and type(key) == "string" and key ~= "" then
		return key
	end
	return nil
end

local function saveKey(key)
	if not MonHubKey.Storage.Remember or not ensureStorage() then
		return false
	end
	return pcall(function()
		writefile(storagePath(), key)
	end)
end

local function clearSavedKey()
	if type(delfile) ~= "function" or not canReadFiles() then
		return false
	end
	return pcall(function()
		local path = storagePath()
		if isfile(path) then
			delfile(path)
		end
	end)
end

local ERROR_MESSAGES = {
	KEY_INVALID = "Invalid key",
	KEY_EXPIRED = "This key has expired",
	HWID_BANNED = "This device is banned",
	KEY_INVALIDATED = "This key was invalidated",
	ALREADY_USED = "This key has already been used",
	HWID_MISMATCH = "This key is linked to another device",
	SERVICE_NOT_FOUND = "Service not found",
	SERVICE_MISMATCH = "This key belongs to another service",
	PREMIUM_REQUIRED = "Premium access is required",
	RATE_LIMITTED = "Please wait before requesting another link",
	RATE_LIMITED = "Please wait before requesting another link",
	ERROR = "The Junkie service is unavailable",
}

local function errorMessage(value)
	local code = tostring(value or "KEY_INVALID")
	return ERROR_MESSAGES[code] or code
end

local function copyText(value)
	if type(value) ~= "string" or value == "" or type(setclipboard) ~= "function" then
		return false
	end
	return pcall(setclipboard, value)
end

local function getJunkieLink()
	if type(MonHubKey.Links.GetKey) == "string" and MonHubKey.Links.GetKey ~= "" then
		Runtime.KeyLink = MonHubKey.Links.GetKey
		return Runtime.KeyLink
	end
	if not Runtime.Junkie or type(Runtime.Junkie.get_key_link) ~= "function" then
		return nil, "ERROR"
	end
	local ok, link, err = pcall(Runtime.Junkie.get_key_link)
	if not ok then
		return nil, link
	end
	if type(link) == "string" and link ~= "" then
		Runtime.KeyLink = link
		MonHubKey.Links.GetKey = link
		return link
	end
	return nil, err
end

local function junkieValidate(key)
	if not Runtime.Junkie or type(Runtime.Junkie.check_key) ~= "function" then
		return false, "Junkie SDK is unavailable"
	end
	local ok, result = pcall(Runtime.Junkie.check_key, key)
	if not ok then
		return false, "The Junkie service is unavailable"
	end
	if type(result) == "table" then
		if result.valid == true or result.success == true then
			return {
				Success = true,
				Message = result.message or "Key accepted",
				Data = result,
			}
		end
		return {
			Success = false,
			Message = errorMessage(result.error or result.message),
			Data = result,
		}
	end
	return false, "Invalid response from Junkie"
end

local function themeOptions()
	return {
		Overlay = MonHubKey.Theme.Shadow or Color3.fromRGB(5, 6, 8),
		Card = MonHubKey.Theme.Background,
		Header = MonHubKey.Theme.Header,
		Surface = MonHubKey.Theme.Surface or MonHubKey.Theme.Background,
		CardRaised = MonHubKey.Theme.Input,
		CardHover = MonHubKey.Theme.Hover or MonHubKey.Theme.Input,
		Outline = MonHubKey.Theme.Outline or MonHubKey.Theme.Divider,
		OutlineSoft = MonHubKey.Theme.AccentSoft or MonHubKey.Theme.Divider,
		Text = MonHubKey.Theme.Text,
		MutedText = MonHubKey.Theme.TextDim,
		FaintText = MonHubKey.Theme.TextFaint or MonHubKey.Theme.TextDim,
		Primary = MonHubKey.Theme.Raised or MonHubKey.Theme.Input,
		PrimaryHover = MonHubKey.Theme.Hover or MonHubKey.Theme.Input,
		PrimaryText = MonHubKey.Theme.Text,
		Accent = MonHubKey.Theme.Accent,
		AccentHover = MonHubKey.Theme.AccentHover,
		AccentSoft = MonHubKey.Theme.AccentSoft or MonHubKey.Theme.Divider,
		Shadow = MonHubKey.Theme.Shadow or Color3.fromRGB(5, 6, 8),
		Success = MonHubKey.Theme.Success,
		Danger = MonHubKey.Theme.Error,
		CornerRadius = MonHubKey.Theme.CornerRadius or 6,
	}
end

local function runSuccess(key, data)
	Environment.SCRIPT_KEY = key
	Environment.UI_CLOSED = false
<<<<<<< HEAD
=======
	Environment.MONHUB_KEY_CLOSED = false
>>>>>>> ad68b390578f41697efa91ba22aa27c4011c0fc6
	Environment.MONHUB_KEY_CLOSED = false
	saveKey(key)
	safeCall(MonHubKey.Callbacks.OnSuccess, key, data)
end

local function runFailure(key, reason)
	safeCall(MonHubKey.Callbacks.OnFail, key, reason)
end

local function buildGate(validate, keyless)
	if Runtime.Gate and not Runtime.Gate.Destroyed then
		Runtime.Gate:Destroy()
	end
	local gate
	gate = KeySystem.new({
		GuiName = "MonHubKey",
		Title = MonHubKey.Appearance.Title,
		Subtitle = keyless and "Ready to launch" or MonHubKey.Appearance.Subtitle,
		Icon = MonHubKey.Appearance.Icon,
		IconSize = MonHubKey.Appearance.IconSize,
		Placeholder = keyless and "KEYLESS" or "Enter key",
		DefaultKey = keyless and "KEYLESS" or "",
		VerifyText = keyless and "Launch" or "Verify",
		CheckingText = keyless and "Launching..." or "Checking...",
		GetKeyUrl = MonHubKey.Links.GetKey,
		DiscordUrl = MonHubKey.Links.Discord,
		PremiumUrl = MonHubKey.Shop.Link,
		PremiumIcon = MonHubKey.Shop.Icon,
		PremiumTitle = MonHubKey.Shop.Title,
		PremiumSubtitle = MonHubKey.Shop.Subtitle,
		BuyText = MonHubKey.Shop.ButtonText,
		ShowPremium = MonHubKey.Shop.Enabled,
		ShowGetKey = not keyless and not MonHubKey.Options.NoGetKey,
		ShowDiscord = type(MonHubKey.Links.Discord) == "string" and MonHubKey.Links.Discord ~= "",
		Blur = MonHubKey.Options.Blur,
		Draggable = MonHubKey.Options.Draggable,
		CloseBehavior = "Destroy",
		Theme = themeOptions(),
		Validate = validate,
		OnGetKey = function(_, currentGate)
			local link, err = getJunkieLink()
			if link and copyText(link) then
				currentGate:SetStatus("Get key link copied", "success")
			else
				currentGate:SetStatus(errorMessage(err), "error")
			end
		end,
		OnDiscord = function(_, currentGate)
			if copyText(MonHubKey.Links.Discord) then
				currentGate:SetStatus("Discord link copied", "success")
			else
				currentGate:SetStatus("Discord link is unavailable", "error")
			end
		end,
		OnPremium = function(_, currentGate)
			if copyText(MonHubKey.Shop.Link) then
				currentGate:SetStatus("Premium link copied", "success")
			else
				currentGate:SetStatus("Premium link is unavailable", "error")
			end
		end,
		OnSuccess = function(key, data)
			runSuccess(key, data)
		end,
		OnFailure = function(key, reason)
			clearSavedKey()
			runFailure(key, reason)
		end,
		OnClose = function()
			Environment.UI_CLOSED = true
			Environment.MONHUB_KEY_CLOSED = true
			Environment.MonHubKeyClosed = true
			safeCall(MonHubKey.Callbacks.OnClose)
		end,
	})
	Runtime.Gate = gate
	MonHubKey.Instance = gate
	return gate
end

local function launchKeyless()
	if MonHubKey.Options.KeylessUI == false then
		runSuccess("KEYLESS")
		return Environment.SCRIPT_KEY
	end
	buildGate(function()
		return true, "Ready"
	end, true)
	while not Environment.SCRIPT_KEY and not Environment.MONHUB_KEY_CLOSED do
		task.wait(0.1)
	end
	return Environment.SCRIPT_KEY
end

function MonHubKey:LaunchJunkie(config)
	assert(type(config) == "table" and config.Service and config.Identifier and config.Provider, "Config required: Service, Identifier, Provider")
	Environment.MonHubKeyLoaded = true
	Environment.MonHubKeyClosed = false
	Environment.UI_CLOSED = false
	Environment.MONHUB_KEY_CLOSED = false
	Environment.SCRIPT_KEY = nil

	local ok, sdk = pcall(function()
		return loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
	end)
	if not ok or type(sdk) ~= "table" then
		Runtime.Junkie = nil
		Runtime.Validate = function()
			return false, "Failed to load Junkie SDK"
		end
		local unavailableGate = buildGate(Runtime.Validate, false)
		unavailableGate:SetStatus("Failed to load Junkie SDK", "error")
		while not Environment.SCRIPT_KEY and not Environment.MONHUB_KEY_CLOSED do
			task.wait(0.1)
		end
		return Environment.SCRIPT_KEY
	end

	sdk.service = config.Service
	sdk.identifier = tostring(config.Identifier)
	sdk.provider = config.Provider
	Runtime.Junkie = sdk
	Runtime.Validate = junkieValidate

	if self.Options.Keyless == true then
		return launchKeyless()
	end
	local gate = buildGate(junkieValidate, false)
	if self.Storage.AutoLoad then
		local savedKey = loadSavedKey()
		if savedKey then
			gate:SetKey(savedKey)
		end
	end
	while not Environment.SCRIPT_KEY and not Environment.MONHUB_KEY_CLOSED do
		task.wait(0.1)
	end
	return Environment.SCRIPT_KEY
end

function MonHubKey:Launch(config)
	if type(config) == "table" and config.Service and config.Identifier and config.Provider then
		return self:LaunchJunkie(config)
	end
	assert(type(self.Callbacks.OnVerify) == "function", "MonHubKey.Callbacks.OnVerify is required")
	Environment.MonHubKeyLoaded = true
	Environment.MonHubKeyClosed = false
	Environment.UI_CLOSED = false
	Environment.MONHUB_KEY_CLOSED = false
	Environment.SCRIPT_KEY = nil
	Runtime.Validate = function(key)
		return self.Callbacks.OnVerify(key)
	end
	if self.Options.Keyless == true then
		return launchKeyless()
	end
	local gate = buildGate(Runtime.Validate, false)
	if self.Storage.AutoLoad then
		local savedKey = loadSavedKey()
		if savedKey then
			gate:SetKey(savedKey)
		end
	end
	while not Environment.SCRIPT_KEY and not Environment.MONHUB_KEY_CLOSED do
		task.wait(0.1)
	end
	return Environment.SCRIPT_KEY
end

function MonHubKey:Notify(title, message, duration, iconType)
	if not Runtime.Gate or Runtime.Gate.Destroyed then
		return false
	end
	local kind = "neutral"
	if iconType == "success" then
		kind = "success"
	elseif iconType == "error" or iconType == "warning" then
		kind = "error"
	end
	Runtime.Gate:SetStatus((title and title ~= "" and title .. ": " or "") .. tostring(message or ""), kind)
	if type(duration) == "number" and duration > 0 then
		local current = Runtime.Gate
		task.delay(duration, function()
			if Runtime.Gate == current and not current.Destroyed then
				current:SetStatus("")
			end
		end)
	end
	return true
end

function MonHubKey:GetSavedKey()
	return loadSavedKey()
end

function MonHubKey:ClearSavedKey()
	return clearSavedKey()
end

function MonHubKey:Destroy()
	if Runtime.Gate and not Runtime.Gate.Destroyed then
		Runtime.Gate:Destroy()
	end
	Runtime.Gate = nil
	self.Instance = nil
	Environment.MonHubKeyLoaded = false
	Environment.MonHubKeyClosed = true
	Environment.UI_CLOSED = true
	Environment.MONHUB_KEY_CLOSED = true
end

MonHubKey.new = KeySystem.new
MonHubKey.Create = KeySystem.new
Environment.MonHubKey = MonHubKey

return MonHubKey

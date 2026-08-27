--!strict
-- MonHubKey is a standalone key gate. It does not require or modify Obsidian.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local KeySystem = {}
KeySystem.__index = KeySystem

local DEFAULT_THEME = {
	Overlay = Color3.fromRGB(5, 7, 10),
	Card = Color3.fromRGB(22, 23, 28),
	CardRaised = Color3.fromRGB(29, 30, 37),
	CardHover = Color3.fromRGB(35, 36, 44),
	Outline = Color3.fromRGB(58, 60, 70),
	OutlineSoft = Color3.fromRGB(44, 46, 54),
	Text = Color3.fromRGB(244, 245, 248),
	MutedText = Color3.fromRGB(150, 153, 166),
	FaintText = Color3.fromRGB(105, 108, 120),
	Primary = Color3.fromRGB(244, 245, 249),
	PrimaryHover = Color3.fromRGB(226, 229, 237),
	PrimaryText = Color3.fromRGB(20, 21, 25),
	Accent = Color3.fromRGB(103, 156, 222),
	AccentHover = Color3.fromRGB(119, 171, 235),
	Success = Color3.fromRGB(92, 202, 142),
	Danger = Color3.fromRGB(237, 105, 115),
}

local function create(className, properties)
	local instance = Instance.new(className)
	for property, value in properties do
		if property ~= "Parent" then
			(instance :: any)[property] = value
		end
	end
	instance.Parent = properties.Parent
	return instance
end

local function merge(base, overrides)
	local result = {}
	for key, value in base do
		result[key] = value
	end
	if type(overrides) == "table" then
		for key, value in overrides do
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

local function normalizeValidationResult(first, second)
	if type(first) == "table" then
		local success = first.Success == true or first.Valid == true
		return success, first.Message, first.Data
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
		self:_tween(button, key, TweenInfo.new(0.12, Enum.EasingStyle.Quint), {
			BackgroundColor3 = hoverColor,
		})
	end)

	self:_connect(button.MouseLeave, function()
		if self.Destroyed then
			return
		end
		self:_tween(button, key, TweenInfo.new(0.12, Enum.EasingStyle.Quint), {
			BackgroundColor3 = normalColor,
		})
	end)
end

function KeySystem:_build()
	local options = self.Options
	local theme = self.Theme
	local parent = resolveParent(options.Parent)

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
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 8),
		Size = UDim2.fromOffset(432, 366),
		ZIndex = 2,
		Parent = overlay,
	})
	self.Shadow = shadow
	addCorner(shadow, 18)

	local card = create("CanvasGroup", {
		Name = "Card",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.Card,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(420, 354),
		ZIndex = 3,
		Parent = overlay,
	})
	self.Card = card
	addCorner(card, 16)
	addStroke(card, theme.Outline, 0.35, 1)

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

	local title = create("TextLabel", {
		Name = "Title",
		Active = true,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(20, 0),
		Size = UDim2.new(1, -66, 0, 52),
		Font = Enum.Font.GothamBold,
		Text = options.Title or "MonHub",
		TextColor3 = theme.Text,
		TextSize = 16,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
		Parent = card,
	})

	local closeButton = create("TextButton", {
		Name = "Close",
		AutoButtonColor = false,
		BackgroundColor3 = theme.Card,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -48, 0, 8),
		Size = UDim2.fromOffset(36, 36),
		Font = Enum.Font.GothamMedium,
		Text = "×",
		TextColor3 = theme.MutedText,
		TextSize = 22,
		Visible = options.AllowClose ~= false,
		ZIndex = 5,
		Parent = card,
	})
	addCorner(closeButton, 9)
	self:_addHover(closeButton, theme.Card, theme.CardRaised, "CloseHover")

	create("Frame", {
		Name = "HeaderDivider",
		BackgroundColor3 = theme.OutlineSoft,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 20, 0, 52),
		Size = UDim2.new(1, -40, 0, 1),
		ZIndex = 4,
		Parent = card,
	})

	local subtitle = create("TextLabel", {
		Name = "Subtitle",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(20, 66),
		Size = UDim2.new(1, -40, 0, 20),
		Font = Enum.Font.Gotham,
		Text = options.Subtitle or "Enter your key to continue",
		TextColor3 = theme.MutedText,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
		Parent = card,
	})

	local inputHolder = create("Frame", {
		Name = "InputHolder",
		BackgroundColor3 = theme.CardRaised,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(20, 96),
		Size = UDim2.new(1, -40, 0, 50),
		ZIndex = 4,
		Parent = card,
	})
	addCorner(inputHolder, 11)
	local inputStroke = addStroke(inputHolder, theme.OutlineSoft, 0.72, 1)
	self.InputStroke = inputStroke

	local input = create("TextBox", {
		Name = "KeyInput",
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		PlaceholderColor3 = theme.FaintText,
		PlaceholderText = options.Placeholder or "key",
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -28, 1, 0),
		Text = options.DefaultKey or "",
		TextColor3 = theme.Text,
		TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 5,
		Parent = inputHolder,
	})
	self.Input = input

	local verifyButton = create("TextButton", {
		Name = "Verify",
		AutoButtonColor = false,
		BackgroundColor3 = theme.Primary,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(20, 162),
		Size = UDim2.new(1, -40, 0, 46),
		Font = Enum.Font.GothamBold,
		Text = options.VerifyText or "Verify",
		TextColor3 = theme.PrimaryText,
		TextSize = 14,
		ZIndex = 4,
		Parent = card,
	})
	addCorner(verifyButton, 10)
	self.VerifyButton = verifyButton
	self:_addHover(verifyButton, theme.Primary, theme.PrimaryHover, "VerifyHover")

	local status = create("TextLabel", {
		Name = "Status",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(20, 214),
		Size = UDim2.new(1, -40, 0, 16),
		Font = Enum.Font.Gotham,
		Text = "",
		TextColor3 = theme.MutedText,
		TextSize = 11,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 4,
		Parent = card,
	})
	self.Status = status

	local actions = create("Frame", {
		Name = "Actions",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(20, 232),
		Size = UDim2.new(1, -40, 0, 28),
		ZIndex = 4,
		Parent = card,
	})
	local actionsLayout = create("UIListLayout", {
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
			Size = UDim2.fromOffset(88, 28),
			Font = Enum.Font.Gotham,
			Text = text,
			TextColor3 = theme.MutedText,
			TextSize = 12,
			ZIndex = 5,
			Parent = actions,
		})
		create("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			Parent = button,
		})
		addCorner(button, 7)
		self:_connect(button.MouseEnter, function()
			self:_tween(button, name .. "Hover", TweenInfo.new(0.12), {
				BackgroundTransparency = 0,
				BackgroundColor3 = theme.CardRaised,
				TextColor3 = theme.Text,
			})
		end)
		self:_connect(button.MouseLeave, function()
			self:_tween(button, name .. "Hover", TweenInfo.new(0.12), {
				BackgroundTransparency = 1,
				BackgroundColor3 = theme.Card,
				TextColor3 = theme.MutedText,
			})
		end)
		return button
	end

	local getKeyButton = makeAction("GetKey", "⌕  " .. (options.GetKeyText or "Get key"), 1)
	local discordButton = makeAction("Discord", "◯  " .. (options.DiscordText or "Discord"), 2)
	self.GetKeyButton = getKeyButton
	self.DiscordButton = discordButton

	create("Frame", {
		Name = "FooterDivider",
		BackgroundColor3 = theme.OutlineSoft,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 20, 0, 270),
		Size = UDim2.new(1, -40, 0, 1),
		ZIndex = 4,
		Parent = card,
	})

	local premiumTitle = create("TextLabel", {
		Name = "PremiumTitle",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, 282),
		Size = UDim2.new(1, -132, 0, 19),
		Font = Enum.Font.GothamBold,
		Text = options.PremiumTitle or "Get Premium",
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
		Parent = card,
	})

	local premiumSubtitle = create("TextLabel", {
		Name = "PremiumSubtitle",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, 302),
		Size = UDim2.new(1, -132, 0, 18),
		Font = Enum.Font.Gotham,
		Text = options.PremiumSubtitle or "Instant delivery · 24/7 support",
		TextColor3 = theme.MutedText,
		TextSize = 11,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
		Parent = card,
	})

	local buyButton = create("TextButton", {
		Name = "BuyPremium",
		AnchorPoint = Vector2.new(1, 0),
		AutoButtonColor = false,
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -18, 0, 287),
		Size = UDim2.fromOffset(78, 34),
		Font = Enum.Font.GothamBold,
		Text = options.BuyText or "Buy  →",
		TextColor3 = Color3.fromRGB(248, 250, 255),
		TextSize = 12,
		ZIndex = 5,
		Parent = card,
	})
	addCorner(buyButton, 9)
	self:_addHover(buyButton, theme.Accent, theme.AccentHover, "BuyHover")
	self.BuyButton = buyButton

	self:_connect(input.Focused, function()
		self:_tween(inputStroke, "InputStroke", TweenInfo.new(0.12), {
			Color = theme.Accent,
			Transparency = 0.15,
		})
	end)

	self:_connect(input.FocusLost, function(enterPressed)
		self:_tween(inputStroke, "InputStroke", TweenInfo.new(0.12), {
			Color = theme.OutlineSoft,
			Transparency = 0.72,
		})
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
			self:_tween(inputStroke, "InputStroke", TweenInfo.new(0.12), {
				Color = if input:IsFocused() then theme.Accent else theme.OutlineSoft,
				Transparency = if input:IsFocused() then 0.15 else 0.72,
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
		local nextPosition = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
		self.Card.Position = nextPosition
		self.Shadow.Position = UDim2.new(
			nextPosition.X.Scale,
			nextPosition.X.Offset,
			nextPosition.Y.Scale,
			nextPosition.Y.Offset + 8
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
		local fitY = (viewport.Y - 24) / 354
		local scale = math.clamp(math.min(fitX, fitY), 0.7, 1)
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
	self.VerifyButton.Active = not self.Busy
	self.Input.TextEditable = not self.Busy
	self.VerifyButton.Text = if self.Busy
		then (self.Options.CheckingText or "Checking…")
		else (self.Options.VerifyText or "Verify")
	self.VerifyButton.BackgroundTransparency = if self.Busy then 0.16 else 0
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

	self._requestId += 1
	local requestId = self._requestId
	self:SetBusy(true)
	self:SetStatus(self.Options.CheckingMessage or "Verifying your key…", "neutral")

	task.spawn(function()
		local call = table.pack(pcall(self.Options.Validate, key, self))
		if self.Destroyed or requestId ~= self._requestId then
			return
		end

		self:SetBusy(false)
		if not call[1] then
			warn("[MonHubKey] Validation failed: " .. tostring(call[2]))
			self:SetStatus(self.Options.ErrorMessage or "Verification service is unavailable", "error")
			safeCall(self.Options.OnFailure, key, call[2], self)
			return
		end

		local success, message, data = normalizeValidationResult(call[2], call[3])
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
	self.CardScale.Scale = scale * 0.96
	self.ShadowScale.Scale = scale * 0.96
	self.Card.GroupTransparency = 1
	self.Shadow.BackgroundTransparency = 1
	self.Overlay.BackgroundTransparency = 1

	self:_tween(self.Overlay, "OverlayOpen", TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
		BackgroundTransparency = self.Options.OverlayTransparency or 0.42,
	})
	self:_tween(self.Card, "CardOpen", TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
		GroupTransparency = 0,
	})
	self:_tween(self.Shadow, "ShadowOpen", TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
		BackgroundTransparency = 0.68,
	})
	self:_tween(self.CardScale, "CardScale", TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = scale,
	})
	self:_tween(self.ShadowScale, "ShadowScale", TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = scale,
	})
	if self.BlurEffect then
		self:_tween(self.BlurEffect, "Blur", TweenInfo.new(0.2), {
			Size = self.Options.BlurSize or 12,
		})
	end
end

function KeySystem:Hide()
	if self.Destroyed or not self.Visible then
		return
	end

	self.Visible = false
	self._requestId += 1
	self:SetBusy(false)

	self:_tween(self.Overlay, "OverlayOpen", TweenInfo.new(0.14, Enum.EasingStyle.Quint), {
		BackgroundTransparency = 1,
	})
	local closeTween = self:_tween(self.Card, "CardOpen", TweenInfo.new(0.14, Enum.EasingStyle.Quint), {
		GroupTransparency = 1,
	})
	self:_tween(self.Shadow, "ShadowOpen", TweenInfo.new(0.14, Enum.EasingStyle.Quint), {
		BackgroundTransparency = 1,
	})
	if self.BlurEffect then
		self:_tween(self.BlurEffect, "Blur", TweenInfo.new(0.14), {
			Size = 0,
		})
	end

	closeTween.Completed:Once(function()
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
	self._requestId += 1

	for _, connection in self._connections do
		connection:Disconnect()
	end
	table.clear(self._connections)

	for _, tween in self._tweens do
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

KeySystem.Create = KeySystem.new

return KeySystem

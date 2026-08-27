local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local KeySystem = {}
KeySystem.__index = KeySystem

local DEFAULT_THEME = {
	Overlay = Color3.fromRGB(5, 7, 10),
	Card = Color3.fromRGB(22, 23, 28),
	Header = Color3.fromRGB(22, 23, 28),
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

local function normalizeValidationResult(first, second)
	if type(first) == "table" then
		local success = first.Success == true or first.Valid == true or first.valid == true
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
	local showPremium = options.ShowPremium ~= false
	local cardHeight = showPremium and 354 or 280
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
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 8),
		Size = UDim2.fromOffset(432, cardHeight + 12),
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
		Size = UDim2.fromOffset(420, cardHeight),
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

	local headerSurface = create("Frame", {
		Name = "Header",
		BackgroundColor3 = theme.Header or theme.Card,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 52),
		ZIndex = 3,
		Parent = card,
	})
	addCorner(headerSurface, 16)
	create("Frame", {
		BackgroundColor3 = theme.Header or theme.Card,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -16),
		Size = UDim2.new(1, 0, 0, 16),
		ZIndex = 3,
		Parent = headerSurface,
	})

	local hasIcon = type(options.Icon) == "string" and options.Icon ~= ""
	if hasIcon then
		create("ImageLabel", {
			Name = "Icon",
			BackgroundTransparency = 1,
			Image = options.Icon,
			Position = UDim2.fromOffset(18, 11),
			Size = options.IconSize or UDim2.fromOffset(30, 30),
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 5,
			Parent = card,
		})
	end

	local title = create("TextLabel", {
		Name = "Title",
		Active = true,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(hasIcon and 58 or 20, 0),
		Size = UDim2.new(1, hasIcon and -104 or -66, 0, 52),
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
	getKeyButton.Visible = options.ShowGetKey ~= false
	discordButton.Visible = options.ShowDiscord ~= false
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

	local premiumIcon = options.PremiumIcon
	if (type(premiumIcon) ~= "string" or premiumIcon == "") and hasIcon then
		premiumIcon = options.Icon
	end
	local hasPremiumIcon = type(premiumIcon) == "string" and premiumIcon ~= ""
	if hasPremiumIcon then
		create("ImageLabel", {
			Name = "PremiumIcon",
			BackgroundTransparency = 1,
			Image = premiumIcon,
			Position = UDim2.fromOffset(18, 285),
			Size = UDim2.fromOffset(32, 32),
			ScaleType = Enum.ScaleType.Fit,
			Visible = showPremium,
			ZIndex = 5,
			Parent = card,
		})
	end

	local premiumTitle = create("TextLabel", {
		Name = "PremiumTitle",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(hasPremiumIcon and 60 or 18, 282),
		Size = UDim2.new(1, hasPremiumIcon and -174 or -132, 0, 19),
		Font = Enum.Font.GothamBold,
		Text = options.PremiumTitle or "Get Premium",
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
		Visible = showPremium,
		Parent = card,
	})

	local premiumSubtitle = create("TextLabel", {
		Name = "PremiumSubtitle",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(hasPremiumIcon and 60 or 18, 302),
		Size = UDim2.new(1, hasPremiumIcon and -174 or -132, 0, 18),
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
		Visible = showPremium,
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
			local focused = input:IsFocused()
			self:_tween(inputStroke, "InputStroke", TweenInfo.new(0.12), {
				Color = focused and theme.Accent or theme.OutlineSoft,
				Transparency = focused and 0.15 or 0.72,
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
		local fitY = (viewport.Y - 24) / self.CardHeight
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
	if self.Busy then
		self.VerifyButton.Text = self.Options.CheckingText or "Checking..."
		self.VerifyButton.BackgroundTransparency = 0.16
	else
		self.VerifyButton.Text = self.Options.VerifyText or "Verify"
		self.VerifyButton.BackgroundTransparency = 0
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
	self._requestId = self._requestId + 1
	self:SetBusy(false)

	self:_tween(self.Overlay, "OverlayOpen", TweenInfo.new(0.14, Enum.EasingStyle.Quint), {
		BackgroundTransparency = 1,
	})
	self:_tween(self.Card, "CardOpen", TweenInfo.new(0.14, Enum.EasingStyle.Quint), {
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

	task.delay(0.15, function()
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
		Icon = "",
		IconSize = UDim2.fromOffset(30, 30),
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
		Accent = Color3.fromRGB(103, 156, 222),
		AccentHover = Color3.fromRGB(119, 171, 235),
		Background = Color3.fromRGB(22, 23, 28),
		Header = Color3.fromRGB(22, 23, 28),
		Input = Color3.fromRGB(29, 30, 37),
		Text = Color3.fromRGB(244, 245, 248),
		TextDim = Color3.fromRGB(150, 153, 166),
		Success = Color3.fromRGB(92, 202, 142),
		Error = Color3.fromRGB(237, 105, 115),
		Warning = Color3.fromRGB(240, 180, 80),
		StatusIdle = Color3.fromRGB(130, 135, 150),
		Discord = Color3.fromRGB(88, 101, 242),
		DiscordHover = Color3.fromRGB(114, 137, 218),
		Divider = Color3.fromRGB(44, 46, 54),
		Pending = Color3.fromRGB(60, 60, 68),
	},
	Callbacks = {
		OnVerify = nil,
		OnSuccess = nil,
		OnFail = nil,
		OnClose = nil,
	},
	Shop = {
		Enabled = false,
		Icon = "",
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

local function validationPassed(result)
	if type(result) == "table" then
		return result.valid == true or result.Valid == true or result.Success == true
	end
	return result == true
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
		if result.valid == true then
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
		Overlay = Color3.fromRGB(5, 7, 10),
		Card = MonHubKey.Theme.Background,
		Header = MonHubKey.Theme.Header,
		CardRaised = MonHubKey.Theme.Input,
		CardHover = MonHubKey.Theme.Input,
		Outline = MonHubKey.Theme.Divider,
		OutlineSoft = MonHubKey.Theme.Divider,
		Text = MonHubKey.Theme.Text,
		MutedText = MonHubKey.Theme.TextDim,
		FaintText = MonHubKey.Theme.TextDim,
		Primary = MonHubKey.Theme.Accent,
		PrimaryHover = MonHubKey.Theme.AccentHover,
		PrimaryText = MonHubKey.Theme.Text,
		Accent = MonHubKey.Theme.Accent,
		AccentHover = MonHubKey.Theme.AccentHover,
		Success = MonHubKey.Theme.Success,
		Danger = MonHubKey.Theme.Error,
	}
end

local function runSuccess(key, data)
	Environment.SCRIPT_KEY = key
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
		Placeholder = keyless and "KEYLESS" or "key",
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
			runFailure(key, reason)
		end,
		OnClose = function()
			Environment.MONHUB_KEY_CLOSED = true
			Environment.MonHubKeyClosed = true
			safeCall(MonHubKey.Callbacks.OnClose)
		end,
	})
	Runtime.Gate = gate
	MonHubKey.Instance = gate
	return gate
end

local function trySavedKey(validate)
	if not MonHubKey.Storage.AutoLoad then
		return false
	end
	local key = loadSavedKey()
	if not key then
		return false
	end
	local ok, first = pcall(validate, key)
	if ok and validationPassed(first) then
		local data = type(first) == "table" and (first.Data or first.data or first) or nil
		runSuccess(key, data)
		return true
	end
	clearSavedKey()
	return false
end

local function launchKeyless()
	if MonHubKey.Options.KeylessUI == false then
		runSuccess("KEYLESS")
		return true
	end
	buildGate(function()
		return true, "Ready"
	end, true)
	return true
end

function MonHubKey:LaunchJunkie(config)
	assert(type(config) == "table" and config.Service and config.Identifier and config.Provider, "Config required: Service, Identifier, Provider")
	Environment.MonHubKeyLoaded = true
	Environment.MonHubKeyClosed = false
	Environment.MONHUB_KEY_CLOSED = false

	local ok, sdk = pcall(function()
		return loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
	end)
	if not ok or type(sdk) ~= "table" then
		warn("[MonHubKey] Failed to load Junkie SDK")
		return nil, "Failed to load Junkie SDK"
	end

	sdk.service = config.Service
	sdk.identifier = tostring(config.Identifier)
	sdk.provider = config.Provider
	Runtime.Junkie = sdk
	Runtime.Validate = junkieValidate

	local existingKey = Environment.SCRIPT_KEY
	if existingKey and existingKey ~= "" then
		if existingKey == "KEYLESS" and self.Options.Keyless ~= true then
			Environment.SCRIPT_KEY = nil
			clearSavedKey()
		else
			local existingResult = junkieValidate(existingKey)
			if validationPassed(existingResult) then
				local data = type(existingResult) == "table" and existingResult.Data or nil
				runSuccess(existingKey, data)
				return true
			end
			Environment.SCRIPT_KEY = nil
			clearSavedKey()
		end
	end

	if self.Links.GetKey == "" then
		pcall(getJunkieLink)
	end

	if self.Options.Keyless == true then
		return launchKeyless()
	end
	if trySavedKey(junkieValidate) then
		return true
	end
	return buildGate(junkieValidate, false)
end

function MonHubKey:Launch(config)
	if type(config) == "table" and config.Service and config.Identifier and config.Provider then
		return self:LaunchJunkie(config)
	end
	assert(type(self.Callbacks.OnVerify) == "function", "MonHubKey.Callbacks.OnVerify is required")
	Environment.MonHubKeyLoaded = true
	Environment.MonHubKeyClosed = false
	Environment.MONHUB_KEY_CLOSED = false
	if Environment.SCRIPT_KEY and Environment.SCRIPT_KEY ~= "" then
		safeCall(self.Callbacks.OnSuccess, Environment.SCRIPT_KEY)
		return true
	end
	Runtime.Validate = function(key)
		return self.Callbacks.OnVerify(key)
	end
	if self.Options.Keyless == true then
		return launchKeyless()
	end
	if trySavedKey(Runtime.Validate) then
		return true
	end
	return buildGate(Runtime.Validate, false)
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
	Environment.MONHUB_KEY_CLOSED = true
end

MonHubKey.new = KeySystem.new
MonHubKey.Create = KeySystem.new
Environment.MonHubKey = MonHubKey

return MonHubKey

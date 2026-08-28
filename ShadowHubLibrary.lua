-- Shadow Hub UI Library v7.0 - Premium Glassmorphism Edition

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ShadowHub = {}
ShadowHub.__index = ShadowHub

-- Premium theme: deep space violet + electric cyan accents, glass surfaces
local Theme = {
	BG = Color3.fromRGB(8, 8, 16),
	Panel = Color3.fromRGB(16, 16, 30),
	Card = Color3.fromRGB(22, 22, 40),
	Hover = Color3.fromRGB(32, 30, 56),
	Sidebar = Color3.fromRGB(12, 12, 24),
	Glass = Color3.fromRGB(28, 26, 48),
	Accent = Color3.fromRGB(168, 85, 247),       -- violet
	AccentBright = Color3.fromRGB(196, 140, 255),
	AccentDim = Color3.fromRGB(110, 50, 180),
	Cyan = Color3.fromRGB(56, 220, 255),
	Text = Color3.fromRGB(238, 236, 252),
	Sub = Color3.fromRGB(138, 132, 168),
	Green = Color3.fromRGB(60, 255, 130),
	Red = Color3.fromRGB(255, 70, 85),
	Yellow = Color3.fromRGB(255, 210, 70),
	White = Color3.fromRGB(255, 255, 255),
}
ShadowHub.Theme = Theme

local NotifContainer = nil

-- Rounded helper
local function UIC(n, r)
	local c = Instance.new("UICorner", n)
	c.CornerRadius = UDim.new(0, r or 8)
	return c
end

local function Stroke(n, col, thick, trans)
	local s = Instance.new("UIStroke", n)
	s.Color = col or Theme.Accent
	s.Thickness = thick or 1
	s.Transparency = trans or 0.5
	return s
end

-- Tween presets
local Ease = {
	Out = Enum.EasingStyle.Exponential,
	In = Enum.EasingStyle.Quad,
	Back = Enum.EasingStyle.Back,
}
local function Tween(obj, info, props)
	return TweenService:Create(obj, info, props):Play()
end

local function Notify(title, text, type_, dur)
	if not NotifContainer then return end
	dur = dur or 3
	local cols = {
		info = Theme.Accent,
		success = Theme.Green,
		warning = Theme.Yellow,
		error = Theme.Red,
		kill = Color3.fromRGB(255, 80, 95),
		streak = Theme.Cyan,
	}
	local col = cols[type_] or Theme.Accent

	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 0)
	card.BackgroundColor3 = Color3.fromRGB(16, 14, 28)
	card.BackgroundTransparency = 0.15
	card.BorderSizePixel = 0
	card.ClipsDescendants = true
	card.LayoutOrder = -tick()
	card.Parent = NotifContainer
	UIC(card, 12)
	Stroke(card, col, 1, 0.3)

	local glow = Instance.new("Frame", card)
	glow.Size = UDim2.new(1, 0, 1, 0)
	glow.BackgroundColor3 = col
	glow.BackgroundTransparency = 0.95
	glow.BorderSizePixel = 0
	glow.ZIndex = 0

	local bar = Instance.new("Frame", card)
	bar.Size = UDim2.new(0, 3, 1, 0)
	bar.BackgroundColor3 = col
	bar.BorderSizePixel = 0
	bar.ZIndex = 2

	local tl = Instance.new("TextLabel", card)
	tl.Size = UDim2.new(1, -14, 0, 14)
	tl.Position = UDim2.new(0, 12, 0, 8)
	tl.BackgroundTransparency = 1
	tl.Text = string.upper(title)
	tl.TextColor3 = col
	tl.Font = Enum.Font.GothamBold
	tl.TextSize = 10
	tl.TextXAlignment = Enum.TextXAlignment.Left
	tl.ZIndex = 3

	local tx = Instance.new("TextLabel", card)
	tx.Size = UDim2.new(1, -14, 0, 28)
	tx.Position = UDim2.new(0, 12, 0, 24)
	tx.BackgroundTransparency = 1
	tx.Text = text
	tx.TextColor3 = Theme.Text
	tx.Font = Enum.Font.Gotham
	tx.TextSize = 9
	tx.TextXAlignment = Enum.TextXAlignment.Left
	tx.TextWrapped = true
	tx.ZIndex = 3

	local prog = Instance.new("Frame", card)
	prog.Size = UDim2.new(1, 0, 0, 2)
	prog.Position = UDim2.new(0, 0, 1, -2)
	prog.BackgroundColor3 = col
	prog.BackgroundTransparency = 0.35
	prog.BorderSizePixel = 0
	prog.ZIndex = 3

	Tween(card, TweenInfo.new(0.3, Ease.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 0, 56)
	})
	Tween(prog, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0, 0, 0, 2)
	})

	task.delay(dur, function()
		Tween(card, TweenInfo.new(0.25, Ease.In), {Size = UDim2.new(1, 0, 0, 0)})
		task.wait(0.3)
		pcall(function() card:Destroy() end)
	end)
end

function ShadowHub:Notify(t, x, y, d)
	Notify(t, x, y, d)
end

function ShadowHub:GetGui()
	return self._gui
end

function ShadowHub:IsOpen()
	return self._open
end

function ShadowHub:CreateWindow(title, opts)
	opts = opts or {}
	local self = setmetatable({}, ShadowHub)
	self._open = false
	self._dragging = false
	self._n = 0
	self._sections = {}
	self._activeSection = nil
	self._sectionFrames = {}
	self._loaded = false

	-- ScreenGui
	self._gui = Instance.new("ScreenGui")
	self._gui.Name = opts.Name or "ShadowHub"
	self._gui.ResetOnSpawn = false
	self._gui.IgnoreGuiInset = true
	self._gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self._gui.DisplayOrder = 999
	self._gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	-- Notification container
	NotifContainer = Instance.new("Frame")
	NotifContainer.Size = UDim2.new(0, 290, 1, 0)
	NotifContainer.Position = UDim2.new(1, -305, 0, 10)
	NotifContainer.BackgroundTransparency = 1
	NotifContainer.BorderSizePixel = 0
	NotifContainer.ZIndex = 200
	NotifContainer.Parent = self._gui
	local nl = Instance.new("UIListLayout", NotifContainer)
	nl.Padding = UDim.new(0, 6)
	nl.SortOrder = Enum.SortOrder.LayoutOrder
	nl.VerticalAlignment = Enum.VerticalAlignment.Top

	-- Loading
	task.spawn(function()
		self:_runLoading(title)
		self._loaded = true
	end)

	-- Icon (launcher pill)
	self._icon = Instance.new("TextButton")
	self._icon.Name = "HubIcon"
	self._icon.Size = UDim2.new(0, 44, 0, 44)
	self._icon.Position = UDim2.new(0, 12, 0.5, -22)
	self._icon.AnchorPoint = Vector2.new(0, 0.5)
	self._icon.BackgroundColor3 = Theme.Glass
	self._icon.BackgroundTransparency = 0.1
	self._icon.BorderSizePixel = 0
	self._icon.Text = "SH"
	self._icon.TextColor3 = Theme.AccentBright
	self._icon.Font = Enum.Font.GothamBlack
	self._icon.TextSize = 13
	self._icon.AutoButtonColor = false
	self._icon.ZIndex = 150
	self._icon.Parent = self._gui
	UIC(self._icon, 14)
	Stroke(self._icon, Theme.Accent, 1.5, 0.4)

	-- Main frame (glass)
	self._main = Instance.new("Frame")
	self._main.Name = "HubMain"
	self._main.Size = UDim2.new(0, 540, 0, 0)
	self._main.Position = UDim2.new(0.5, -270, 0.5, 0)
	self._main.AnchorPoint = Vector2.new(0.5, 0.5)
	self._main.BackgroundColor3 = Theme.BG
	self._main.BackgroundTransparency = 0.25
	self._main.BorderSizePixel = 0
	self._main.ClipsDescendants = true
	self._main.Visible = false
	self._main.ZIndex = 100
	self._main.Parent = self._gui
	UIC(self._main, 16)
	Stroke(self._main, Theme.Accent, 1.5, 0.45)

	-- Frosted overlay
	local frost = Instance.new("Frame", self._main)
	frost.Size = UDim2.new(1, 0, 1, 0)
	frost.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frost.BackgroundTransparency = 0.96
	frost.BorderSizePixel = 0
	frost.ZIndex = 100

	-- TopBar
	self._topbar = Instance.new("Frame")
	self._topbar.Name = "TopBar"
	self._topbar.Size = UDim2.new(1, 0, 0, 40)
	self._topbar.BackgroundColor3 = Theme.Panel
	self._topbar.BackgroundTransparency = 0.1
	self._topbar.BorderSizePixel = 0
	self._topbar.ZIndex = 101
	self._topbar.Parent = self._main
	UIC(self._topbar, 16)

	local accentLine = Instance.new("Frame", self._topbar)
	accentLine.Size = UDim2.new(1, 0, 0, 2)
	accentLine.Position = UDim2.new(0, 0, 1, -2)
	accentLine.BackgroundColor3 = Theme.Accent
	accentLine.BackgroundTransparency = 0.4
	accentLine.BorderSizePixel = 0
	accentLine.ZIndex = 102

	-- Logo dot
	local logoDot = Instance.new("Frame", self._topbar)
	logoDot.Size = UDim2.new(0, 10, 0, 10)
	logoDot.Position = UDim2.new(0, 12, 0.5, -5)
	logoDot.BackgroundColor3 = Theme.Accent
	logoDot.BorderSizePixel = 0
	logoDot.ZIndex = 102
	UIC(logoDot, 5)

	local titleLabel = Instance.new("TextLabel", self._topbar)
	titleLabel.Size = UDim2.new(1, -50, 1, 0)
	titleLabel.Position = UDim2.new(0, 28, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = string.upper(title)
	titleLabel.TextColor3 = Theme.Text
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.TextSize = 12
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 102

	local closeBtn = Instance.new("TextButton", self._topbar)
	closeBtn.Size = UDim2.new(0, 24, 0, 24)
	closeBtn.Position = UDim2.new(1, -32, 0, 8)
	closeBtn.BackgroundColor3 = Theme.Card
	closeBtn.BackgroundTransparency = 0.2
	closeBtn.BorderSizePixel = 0
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Theme.Sub
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 12
	closeBtn.AutoButtonColor = false
	closeBtn.ZIndex = 102
	UIC(closeBtn, 6)
	closeBtn.MouseEnter:Connect(function()
		Tween(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Red, TextColor3 = Theme.White})
	end)
	closeBtn.MouseLeave:Connect(function()
		Tween(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Card, TextColor3 = Theme.Sub})
	end)
	closeBtn.MouseButton1Click:Connect(function()
		self:Close()
	end)

	-- SIDEBAR
	self._sidebar = Instance.new("Frame")
	self._sidebar.Name = "Sidebar"
	self._sidebar.Size = UDim2.new(0, 124, 1, -40)
	self._sidebar.Position = UDim2.new(0, 0, 0, 40)
	self._sidebar.BackgroundColor3 = Theme.Sidebar
	self._sidebar.BackgroundTransparency = 0.2
	self._sidebar.BorderSizePixel = 0
	self._sidebar.ZIndex = 101
	self._sidebar.Parent = self._main
	UIC(self._sidebar, 16)

	local sideLine = Instance.new("Frame", self._sidebar)
	sideLine.Size = UDim2.new(0, 1, 1, 0)
	sideLine.Position = UDim2.new(1, -1, 0, 0)
	sideLine.BackgroundColor3 = Theme.Accent
	sideLine.BackgroundTransparency = 0.65
	sideLine.BorderSizePixel = 0
	sideLine.ZIndex = 102

	local sideScroll = Instance.new("ScrollingFrame", self._sidebar)
	sideScroll.Size = UDim2.new(1, -6, 1, -10)
	sideScroll.Position = UDim2.new(0, 3, 0, 5)
	sideScroll.BackgroundTransparency = 1
	sideScroll.BorderSizePixel = 0
	sideScroll.ScrollBarThickness = 2
	sideScroll.ScrollBarImageColor3 = Theme.Accent
	sideScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	sideScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sideScroll.ZIndex = 102
	local sideLayout = Instance.new("UIListLayout", sideScroll)
	sideLayout.Padding = UDim.new(0, 4)
	sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	self._sidebarScroll = sideScroll
	self._sidebarButtons = {}

	-- CONTENT
	self._content = Instance.new("Frame")
	self._content.Name = "Content"
	self._content.Size = UDim2.new(1, -132, 1, -48)
	self._content.Position = UDim2.new(0, 128, 0, 44)
	self._content.BackgroundTransparency = 1
	self._content.BorderSizePixel = 0
	self._content.ZIndex = 101
	self._content.Parent = self._main

	local contentScroll = Instance.new("ScrollingFrame", self._content)
	contentScroll.Size = UDim2.new(1, -8, 1, -8)
	contentScroll.Position = UDim2.new(0, 4, 0, 4)
	contentScroll.BackgroundTransparency = 1
	contentScroll.BorderSizePixel = 0
	contentScroll.ScrollBarThickness = 3
	contentScroll.ScrollBarImageColor3 = Theme.Accent
	contentScroll.ScrollBarImageTransparency = 0.5
	contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contentScroll.ZIndex = 102
	local contentLayout = Instance.new("UIListLayout", contentScroll)
	contentLayout.Padding = UDim.new(0, 5)
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

	self._contentScroll = contentScroll
	self._activeContent = nil

	self:_initDrag()

	self._icon.MouseButton1Click:Connect(function()
		if self._open then self:Close() else self:Open() end
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.RightControl then
			if self._open then self:Close() else self:Open() end
		end
	end)

	return self
end

function ShadowHub:_runLoading(title)
	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(4, 4, 10)
	overlay.BorderSizePixel = 0
	overlay.ZIndex = 500
	overlay.Parent = self._gui

	local titleText = Instance.new("TextLabel", overlay)
	titleText.Size = UDim2.new(0.8, 0, 0, 40)
	titleText.Position = UDim2.new(0.1, 0, 0.32, 0)
	titleText.BackgroundTransparency = 1
	titleText.Text = string.upper(title)
	titleText.TextColor3 = Theme.AccentBright
	titleText.TextStrokeTransparency = 0.4
	titleText.Font = Enum.Font.GothamBlack
	titleText.TextSize = 36
	titleText.ZIndex = 501

	local subText = Instance.new("TextLabel", overlay)
	subText.Size = UDim2.new(0.8, 0, 0, 20)
	subText.Position = UDim2.new(0.1, 0, 0.42, 0)
	subText.BackgroundTransparency = 1
	subText.Text = "Nao tem escapatoria 🔥🔥"
	subText.TextColor3 = Theme.Text
	subText.TextStrokeTransparency = 0.4
	subText.Font = Enum.Font.GothamMedium
	subText.TextSize = 14
	subText.ZIndex = 501

	local barBG = Instance.new("Frame", overlay)
	barBG.Size = UDim2.new(0.5, 0, 0, 5)
	barBG.Position = UDim2.new(0.25, 0, 0.56, 0)
	barBG.BackgroundColor3 = Theme.Panel
	barBG.BorderSizePixel = 0
	barBG.ZIndex = 501
	UIC(barBG, 3)

	local barFill = Instance.new("Frame", barBG)
	barFill.Size = UDim2.new(0, 0, 1, 0)
	barFill.BackgroundColor3 = Theme.Accent
	barFill.BorderSizePixel = 0
	barFill.ZIndex = 502
	UIC(barFill, 3)

	local pctText = Instance.new("TextLabel", overlay)
	pctText.Size = UDim2.new(0.5, 0, 0, 14)
	pctText.Position = UDim2.new(0.25, 0, 0.61, 0)
	pctText.BackgroundTransparency = 1
	pctText.Text = "0%"
	pctText.TextColor3 = Theme.AccentBright
	pctText.TextStrokeTransparency = 0.4
	pctText.Font = Enum.Font.GothamBold
	pctText.TextSize = 10
	pctText.ZIndex = 501

	Tween(barFill, TweenInfo.new(1.4, Ease.Out, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0)
	})

	for i = 1, 20 do
		task.wait(1.4 / 20)
		pctText.Text = math.floor(i * 5) .. "%"
	end

	task.wait(0.2)

	for _, v in ipairs(overlay:GetDescendants()) do
		if v:IsA("TextLabel") then
			Tween(v, TweenInfo.new(0.4), {TextTransparency = 1, TextStrokeTransparency = 1})
		elseif v:IsA("Frame") then
			Tween(v, TweenInfo.new(0.4), {BackgroundTransparency = 1})
		end
	end
	Tween(overlay, TweenInfo.new(0.4), {BackgroundTransparency = 1})
	task.wait(0.5)
	pcall(function() overlay:Destroy() end)
end

function ShadowHub:_initDrag()
	local dragging = false
	local dragStart = nil
	local startPos = nil
	local hasDragged = false

	self._topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			hasDragged = false
			dragStart = input.Position
			startPos = self._main.Position
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			hasDragged = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			if delta.Magnitude > 8 then hasDragged = true end
			if hasDragged then
				self._main.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end
	end)

	self.IsDragging = function()
		return hasDragged
	end
end

function ShadowHub:Open()
	self._open = true
	self._main.Visible = true
	self._main.Size = UDim2.new(0, 540, 0, 0)
	self._main.Position = UDim2.new(0.5, -270, 0.5, 0)
	self._main.BackgroundTransparency = 0.6
	Tween(self._main, TweenInfo.new(0.35, Ease.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 540, 0, 440),
		BackgroundTransparency = 0.25,
	})
end

function ShadowHub:Close()
	self._open = false
	local t = Tween(self._main, TweenInfo.new(0.25, Ease.In, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 540, 0, 0),
		BackgroundTransparency = 0.6,
	})
	t.Completed:Connect(function()
		if not self._open then self._main.Visible = false end
	end)
end

function ShadowHub:Section(name)
	self._n += 1
	self._sections[name] = self._sections[name] or false

	local contentFrame = Instance.new("ScrollingFrame")
	contentFrame.Size = UDim2.new(1, 0, 1, 0)
	contentFrame.BackgroundTransparency = 1
	contentFrame.BorderSizePixel = 0
	contentFrame.ScrollBarThickness = 3
	contentFrame.ScrollBarImageColor3 = Theme.Accent
	contentFrame.ScrollBarImageTransparency = 0.5
	contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contentFrame.Visible = false
	contentFrame.ZIndex = 103
	contentFrame.Parent = self._content
	local contentLayout = Instance.new("UIListLayout", contentFrame)
	contentLayout.Padding = UDim.new(0, 5)
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	Instance.new("UIPadding", contentFrame).PaddingBottom = UDim.new(0, 6)

	self._sectionFrames[name] = contentFrame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -8, 0, 34)
	btn.BackgroundColor3 = Theme.Card
	btn.BackgroundTransparency = 0.2
	btn.BorderSizePixel = 0
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.LayoutOrder = self._n
	btn.ZIndex = 103
	btn.Parent = self._sidebarScroll
	UIC(btn, 8)
	Stroke(btn, Theme.Sub, 1, 0.7)

	local dot = Instance.new("Frame", btn)
	dot.Size = UDim2.new(0, 3, 0, 16)
	dot.Position = UDim2.new(0, 5, 0.5, -8)
	dot.BackgroundColor3 = Theme.Accent
	dot.BackgroundTransparency = 1
	dot.BorderSizePixel = 0
	dot.ZIndex = 104
	UIC(dot, 2)

	local lbl = Instance.new("TextLabel", btn)
	lbl.Size = UDim2.new(1, -16, 1, 0)
	lbl.Position = UDim2.new(0, 14, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = string.upper(name)
	lbl.TextColor3 = Theme.Sub
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 9
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 104

	table.insert(self._sidebarButtons, {Button = btn, Label = lbl, Dot = dot, Name = name})

	local function SelectSection()
		for _, frame in pairs(self._sectionFrames) do
			frame.Visible = false
		end
		for _, b in ipairs(self._sidebarButtons) do
			b.Button.BackgroundColor3 = Theme.Card
			b.Label.TextColor3 = Theme.Sub
			b.Dot.BackgroundTransparency = 1
			Stroke(b.Button, Theme.Sub, 1, 0.7)
		end
		contentFrame.Visible = true
		btn.BackgroundColor3 = Theme.Hover
		lbl.TextColor3 = Theme.AccentBright
		dot.BackgroundTransparency = 0
		Stroke(btn, Theme.Accent, 1.2, 0.3)
		self._activeContent = contentFrame
	end

	btn.MouseButton1Click:Connect(function()
		if self.IsDragging() then return end
		SelectSection()
	end)

	btn.MouseEnter:Connect(function()
		if contentFrame.Visible then return end
		Tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Hover})
	end)
	btn.MouseLeave:Connect(function()
		if contentFrame.Visible then return end
		Tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Card})
	end)

	if not self._activeSection then
		self._activeSection = name
		SelectSection()
	end

	local sec = {_c = contentFrame, _name = name}
	return sec
end

function ShadowHub:Toggle(sec, name, def, cb)
	self._n += 1
	local on = def

	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 30)
	card.BackgroundColor3 = Theme.Card
	card.BackgroundTransparency = 0.15
	card.BorderSizePixel = 0
	card.LayoutOrder = self._n
	card.ZIndex = 104
	card.Parent = sec._c
	UIC(card, 7)
	Stroke(card, Theme.Sub, 1, 0.7)

	local accentBar = Instance.new("Frame", card)
	accentBar.Size = UDim2.new(0, 3, 0, 12)
	accentBar.Position = UDim2.new(0, 7, 0.5, -6)
	accentBar.BackgroundColor3 = Theme.Accent
	accentBar.BackgroundTransparency = on and 0 or 0.7
	accentBar.BorderSizePixel = 0
	UIC(accentBar, 1)

	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(1, -50, 1, 0)
	lbl.Position = UDim2.new(0, 18, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = Theme.Text
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 9
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 105

	local track = Instance.new("Frame", card)
	track.Size = UDim2.new(0, 32, 0, 16)
	track.Position = UDim2.new(1, -40, 0.5, -8)
	track.BackgroundColor3 = Theme.Panel
	track.BorderSizePixel = 0
	track.ZIndex = 105
	UIC(track, 8)

	local knob = Instance.new("Frame", track)
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.Position = UDim2.new(0, 2, 0, 2)
	knob.BackgroundColor3 = Theme.Sub
	knob.BorderSizePixel = 0
	knob.ZIndex = 106
	UIC(knob, 6)

	local function Refresh()
		Tween(knob, TweenInfo.new(0.22, Ease.Out, Enum.EasingDirection.Out), {
			Position = on and UDim2.new(1, -14, 0, 2) or UDim2.new(0, 2, 0, 2)
		})
		Tween(track, TweenInfo.new(0.22), {
			BackgroundColor3 = on and Theme.Accent or Theme.Panel
		})
		knob.BackgroundColor3 = on and Theme.White or Theme.Sub
		accentBar.BackgroundTransparency = on and 0 or 0.7
		Stroke(card, on and Theme.Accent or Theme.Sub, 1, on and 0.35 or 0.7)
	end

	local clickBtn = Instance.new("TextButton", card)
	clickBtn.Size = UDim2.new(1, 0, 1, 0)
	clickBtn.BackgroundTransparency = 1
	clickBtn.Text = ""
	clickBtn.ZIndex = 107
	clickBtn.AutoButtonColor = false

	clickBtn.MouseButton1Click:Connect(function()
		if self.IsDragging() then return end
		on = not on
		cb(on)
		Refresh()
	end)

	card.MouseEnter:Connect(function()
		if not on then Tween(card, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Hover}) end
	end)
	card.MouseLeave:Connect(function()
		if not on then Tween(card, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Card}) end
	end)

	Refresh()
end

function ShadowHub:Slider(sec, name, mn, mx, def, cb)
	self._n += 1
	local V = def

	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 42)
	card.BackgroundColor3 = Theme.Card
	card.BackgroundTransparency = 0.15
	card.BorderSizePixel = 0
	card.LayoutOrder = self._n
	card.ZIndex = 104
	card.Parent = sec._c
	UIC(card, 7)
	Stroke(card, Theme.Sub, 1, 0.7)

	local accentBar = Instance.new("Frame", card)
	accentBar.Size = UDim2.new(0, 3, 0, 12)
	accentBar.Position = UDim2.new(0, 7, 0, 7)
	accentBar.BackgroundColor3 = Theme.Accent
	accentBar.BorderSizePixel = 0
	UIC(accentBar, 1)

	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(0.55, 0, 0, 13)
	lbl.Position = UDim2.new(0, 18, 0, 6)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = Theme.Text
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 9
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 105

	local valLabel = Instance.new("TextLabel", card)
	valLabel.Size = UDim2.new(0.32, 0, 0, 13)
	valLabel.Position = UDim2.new(1, -40, 0, 6)
	valLabel.BackgroundTransparency = 1
	valLabel.Text = tostring(math.floor(V * 10) / 10)
	valLabel.TextColor3 = Theme.AccentBright
	valLabel.Font = Enum.Font.GothamBold
	valLabel.TextSize = 9
	valLabel.TextXAlignment = Enum.TextXAlignment.Right
	valLabel.ZIndex = 105

	local track = Instance.new("Frame", card)
	track.Size = UDim2.new(1, -24, 0, 4)
	track.Position = UDim2.new(0, 12, 0, 28)
	track.BackgroundColor3 = Theme.Panel
	track.BorderSizePixel = 0
	track.ZIndex = 105
	UIC(track, 2)

	local fill = Instance.new("Frame", track)
	fill.Size = UDim2.new((V - mn) / (mx - mn), 0, 1, 0)
	fill.BackgroundColor3 = Theme.Accent
	fill.BorderSizePixel = 0
	UIC(fill, 2)

	local knob = Instance.new("Frame", track)
	knob.Size = UDim2.new(0, 11, 0, 11)
	knob.Position = UDim2.new((V - mn) / (mx - mn), -6, 0.5, -6)
	knob.BackgroundColor3 = Theme.White
	knob.BorderSizePixel = 0
	knob.ZIndex = 107
	UIC(knob, 6)

	local sliding = false

	local function UpdateSlider(x)
		local p = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		V = mn + p * (mx - mn)
		fill.Size = UDim2.new(p, 0, 1, 0)
		knob.Position = UDim2.new(p, -6, 0.5, -6)
		valLabel.Text = tostring(math.floor(V * 10) / 10)
		cb(V)
	end

	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			Tween(card, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Hover})
			UpdateSlider(input.Position.X)
		end
	end)
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			Tween(card, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Hover})
			UpdateSlider(input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			UpdateSlider(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = false
			Tween(card, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Card})
		end
	end)

	card.MouseEnter:Connect(function()
		if not sliding then Tween(card, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Hover}) end
	end)
	card.MouseLeave:Connect(function()
		if not sliding then Tween(card, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Card}) end
	end)
end

function ShadowHub:Button(sec, name, cb)
	self._n += 1

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.BackgroundColor3 = Theme.Accent
	btn.BackgroundTransparency = 0.1
	btn.BorderSizePixel = 0
	btn.Text = string.upper(name)
	btn.TextColor3 = Theme.White
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 9
	btn.AutoButtonColor = false
	btn.LayoutOrder = self._n
	btn.ZIndex = 104
	btn.Parent = sec._c
	UIC(btn, 7)
	Stroke(btn, Theme.AccentBright, 1, 0.3)

	btn.MouseButton1Click:Connect(function()
		if self.IsDragging() then return end
		Tween(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.AccentDim, Size = UDim2.new(1, 0, 0, 28)})
		task.delay(0.1, function()
			Tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Accent, Size = UDim2.new(1, 0, 0, 30)})
		end)
		cb()
	end)

	btn.MouseEnter:Connect(function()
		Tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.AccentBright})
	end)
	btn.MouseLeave:Connect(function()
		Tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Accent})
	end)
end

function ShadowHub:Label(sec, text)
	self._n += 1
	local l = Instance.new("TextLabel", sec._c)
	l.Size = UDim2.new(1, 0, 0, 14)
	l.BackgroundTransparency = 1
	l.Text = "  " .. text
	l.TextColor3 = Theme.Sub
	l.Font = Enum.Font.GothamMedium
	l.TextSize = 8
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.LayoutOrder = self._n
	l.ZIndex = 104
end

function ShadowHub:StatusBar(text)
	self._n += 1
	local l = Instance.new("TextLabel", self._contentScroll)
	l.Size = UDim2.new(1, 0, 0, 26)
	l.BackgroundColor3 = Theme.Card
	l.BackgroundTransparency = 0.1
	l.BorderSizePixel = 0
	l.Text = "  " .. text
	l.TextColor3 = Theme.Text
	l.Font = Enum.Font.GothamMedium
	l.TextSize = 8
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.LayoutOrder = 9999
	l.ZIndex = 104
	UIC(l, 7)
	Stroke(l, Theme.Accent, 1, 0.4)

	return {
		SetText = function(_, t)
			l.Text = "  " .. t
		end
	}
end

return ShadowHub

-- Shadow Hub UI Library v5.0
-- Clean, no-blocking, bug-free

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ShadowHub = {}
ShadowHub.__index = ShadowHub

local Theme = {
	BG = Color3.fromRGB(10, 10, 18),
	Panel = Color3.fromRGB(16, 16, 28),
	Card = Color3.fromRGB(22, 22, 38),
	Hover = Color3.fromRGB(30, 30, 50),
	Accent = Color3.fromRGB(180, 0, 255),
	AccentDim = Color3.fromRGB(100, 0, 160),
	Text = Color3.fromRGB(235, 230, 250),
	Sub = Color3.fromRGB(120, 115, 145),
	Green = Color3.fromRGB(50, 255, 100),
	Red = Color3.fromRGB(255, 50, 50),
	Yellow = Color3.fromRGB(255, 200, 50),
}
ShadowHub.Theme = Theme

local NotifContainer = nil

local function Notify(title, text, type_, dur)
	if not NotifContainer then return end
	dur = dur or 3
	local cols = {
		info = Theme.Accent,
		success = Theme.Green,
		warning = Theme.Yellow,
		error = Theme.Red,
		kill = Color3.fromRGB(255, 80, 80),
		streak = Theme.Yellow,
	}
	local col = cols[type_] or Theme.Accent

	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 0)
	card.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
	card.BorderSizePixel = 0
	card.ClipsDescendants = true
	card.LayoutOrder = -tick()
	card.Parent = NotifContainer
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

	local bar = Instance.new("Frame", card)
	bar.Size = UDim2.new(0, 3, 1, 0)
	bar.BackgroundColor3 = col
	bar.BorderSizePixel = 0

	local tl = Instance.new("TextLabel", card)
	tl.Size = UDim2.new(1, -14, 0, 13)
	tl.Position = UDim2.new(0, 12, 0, 7)
	tl.BackgroundTransparency = 1
	tl.Text = string.upper(title)
	tl.TextColor3 = col
	tl.Font = Enum.Font.GothamBold
	tl.TextSize = 10
	tl.TextXAlignment = Enum.TextXAlignment.Left

	local tx = Instance.new("TextLabel", card)
	tx.Size = UDim2.new(1, -14, 0, 28)
	tx.Position = UDim2.new(0, 12, 0, 23)
	tx.BackgroundTransparency = 1
	tx.Text = text
	tx.TextColor3 = Theme.Text
	tx.Font = Enum.Font.Gotham
	tx.TextSize = 9
	tx.TextXAlignment = Enum.TextXAlignment.Left
	tx.TextWrapped = true

	local prog = Instance.new("Frame", card)
	prog.Size = UDim2.new(1, 0, 0, 2)
	prog.Position = UDim2.new(0, 0, 1, -2)
	prog.BackgroundColor3 = col
	prog.BackgroundTransparency = 0.4
	prog.BorderSizePixel = 0

	TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 0, 55)
	}):Play()
	TweenService:Create(prog, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0, 0, 0, 2)
	}):Play()

	task.delay(dur, function()
		TweenService:Create(card, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
		task.wait(0.25)
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
	self._dragStarted = false
	self._n = 0
	self._sections = {}
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
	NotifContainer.Size = UDim2.new(0, 280, 1, 0)
	NotifContainer.Position = UDim2.new(1, -295, 0, 10)
	NotifContainer.BackgroundTransparency = 1
	NotifContainer.BorderSizePixel = 0
	NotifContainer.ZIndex = 200
	NotifContainer.Parent = self._gui
	local nl = Instance.new("UIListLayout", NotifContainer)
	nl.Padding = UDim.new(0, 5)
	nl.SortOrder = Enum.SortOrder.LayoutOrder
	nl.VerticalAlignment = Enum.VerticalAlignment.Top

	-- Run loading async (non-blocking)
	task.spawn(function()
		self:_runLoading(title)
		self._loaded = true
	end)

	-- Icon button
	self._icon = Instance.new("TextButton")
	self._icon.Name = "HubIcon"
	self._icon.Size = UDim2.new(0, 46, 0, 46)
	self._icon.Position = UDim2.new(0, 12, 0.5, -23)
	self._icon.AnchorPoint = Vector2.new(0, 0.5)
	self._icon.BackgroundColor3 = Theme.Panel
	self._icon.BorderSizePixel = 0
	self._icon.Text = "SH"
	self._icon.TextColor3 = Theme.Accent
	self._icon.Font = Enum.Font.GothamBlack
	self._icon.TextSize = 14
	self._icon.AutoButtonColor = false
	self._icon.ZIndex = 150
	self._icon.Parent = self._gui
	Instance.new("UICorner", self._icon).CornerRadius = UDim.new(0, 23)
	local icoStroke = Instance.new("UIStroke", self._icon)
	icoStroke.Color = Theme.Accent
	icoStroke.Thickness = 1.5
	icoStroke.Transparency = 0.5

	-- Main frame
	self._main = Instance.new("Frame")
	self._main.Name = "HubMain"
	self._main.Size = UDim2.new(0, 300, 0, 0)
	self._main.Position = UDim2.new(0, 12, 0.5, 0)
	self._main.AnchorPoint = Vector2.new(0, 0.5)
	self._main.BackgroundColor3 = Theme.BG
	self._main.BorderSizePixel = 0
	self._main.ClipsDescendants = true
	self._main.Visible = false
	self._main.ZIndex = 100
	self._main.Parent = self._gui
	Instance.new("UICorner", self._main).CornerRadius = UDim.new(0, 10)
	local mainStroke = Instance.new("UIStroke", self._main)
	mainStroke.Color = Theme.Accent
	mainStroke.Thickness = 1.5
	mainStroke.Transparency = 0.6

	-- TopBar
	self._topbar = Instance.new("Frame")
	self._topbar.Name = "TopBar"
	self._topbar.Size = UDim2.new(1, 0, 0, 36)
	self._topbar.BackgroundColor3 = Theme.Panel
	self._topbar.BorderSizePixel = 0
	self._topbar.ZIndex = 101
	self._topbar.Parent = self._main
	Instance.new("UICorner", self._topbar).CornerRadius = UDim.new(0, 10)

	-- Accent line
	local accentLine = Instance.new("Frame", self._topbar)
	accentLine.Size = UDim2.new(1, 0, 0, 1)
	accentLine.Position = UDim2.new(0, 0, 1, -1)
	accentLine.BackgroundColor3 = Theme.Accent
	accentLine.BackgroundTransparency = 0.6
	accentLine.BorderSizePixel = 0
	accentLine.ZIndex = 102

	-- Title
	local titleLabel = Instance.new("TextLabel", self._topbar)
	titleLabel.Size = UDim2.new(1, -40, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = string.upper(title)
	titleLabel.TextColor3 = Theme.Accent
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.TextSize = 11
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 102

	-- Close button
	local closeBtn = Instance.new("TextButton", self._topbar)
	closeBtn.Size = UDim2.new(0, 22, 0, 22)
	closeBtn.Position = UDim2.new(1, -30, 0, 7)
	closeBtn.BackgroundColor3 = Theme.Card
	closeBtn.BorderSizePixel = 0
	closeBtn.Text = "x"
	closeBtn.TextColor3 = Theme.Sub
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 11
	closeBtn.AutoButtonColor = false
	closeBtn.ZIndex = 102
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)
	closeBtn.MouseButton1Click:Connect(function()
		self:Close()
	end)

	-- Content scroll
	self._content = Instance.new("ScrollingFrame")
	self._content.Name = "Content"
	self._content.Size = UDim2.new(1, -10, 1, -44)
	self._content.Position = UDim2.new(0, 5, 0, 40)
	self._content.BackgroundTransparency = 1
	self._content.BorderSizePixel = 0
	self._content.ScrollBarThickness = 2
	self._content.ScrollBarImageColor3 = Theme.Accent
	self._content.CanvasSize = UDim2.new(0, 0, 0, 0)
	self._content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self._content.ZIndex = 101
	self._content.Parent = self._main
	local contentLayout = Instance.new("UIListLayout", self._content)
	contentLayout.Padding = UDim.new(0, 3)
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	Instance.new("UIPadding", self._content).PaddingBottom = UDim.new(0, 5)

	-- Drag system (using UserInputService for proper release detection)
	self:_initDrag()

	-- Icon click (separate from drag)
	self._icon.MouseButton1Click:Connect(function()
		if self._open then
			self:Close()
		else
			self:Open()
		end
	end)

	-- Toggle with RightCtrl
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.RightControl then
			if self._open then
				self:Close()
			else
				self:Open()
			end
		end
	end)

	return self
end

function ShadowHub:_runLoading(title)
	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(3, 3, 6)
	overlay.BorderSizePixel = 0
	overlay.ZIndex = 500
	overlay.Parent = self._gui

	local titleText = Instance.new("TextLabel", overlay)
	titleText.Size = UDim2.new(0.8, 0, 0, 36)
	titleText.Position = UDim2.new(0.1, 0, 0.34, 0)
	titleText.BackgroundTransparency = 1
	titleText.Text = string.upper(title)
	titleText.TextColor3 = Theme.Accent
	titleText.TextStrokeTransparency = 0
	titleText.Font = Enum.Font.GothamBlack
	titleText.TextSize = 32
	titleText.ZIndex = 501

	local subText = Instance.new("TextLabel", overlay)
	subText.Size = UDim2.new(0.8, 0, 0, 18)
	subText.Position = UDim2.new(0.1, 0, 0.42, 0)
	subText.BackgroundTransparency = 1
	subText.Text = "Nao tem escapatoria \226\151\128\226\151\128"
	subText.TextColor3 = Theme.Text
	subText.TextStrokeTransparency = 0
	subText.Font = Enum.Font.GothamMedium
	subText.TextSize = 13
	subText.ZIndex = 501

	local barBG = Instance.new("Frame", overlay)
	barBG.Size = UDim2.new(0.45, 0, 0, 4)
	barBG.Position = UDim2.new(0.275, 0, 0.54, 0)
	barBG.BackgroundColor3 = Theme.Panel
	barBG.BorderSizePixel = 0
	barBG.ZIndex = 501
	Instance.new("UICorner", barBG).CornerRadius = UDim.new(0, 2)

	local barFill = Instance.new("Frame", barBG)
	barFill.Size = UDim2.new(0, 0, 1, 0)
	barFill.BackgroundColor3 = Theme.Accent
	barFill.BorderSizePixel = 0
	barFill.ZIndex = 502
	Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 2)

	local pctText = Instance.new("TextLabel", overlay)
	pctText.Size = UDim2.new(0.45, 0, 0, 14)
	pctText.Position = UDim2.new(0.275, 0, 0.59, 0)
	pctText.BackgroundTransparency = 1
	pctText.Text = "0%"
	pctText.TextColor3 = Theme.Accent
	pctText.TextStrokeTransparency = 0
	pctText.Font = Enum.Font.GothamBold
	pctText.TextSize = 10
	pctText.ZIndex = 501

	TweenService:Create(barFill, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()

	for i = 1, 20 do
		task.wait(1.5 / 20)
		pctText.Text = math.floor(i * 5) .. "%"
	end

	task.wait(0.2)

	-- Fade out
	for _, v in ipairs(overlay:GetDescendants()) do
		if v:IsA("TextLabel") then
			TweenService:Create(v, TweenInfo.new(0.4), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
		elseif v:IsA("Frame") then
			TweenService:Create(v, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
		end
	end
	TweenService:Create(overlay, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
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

	-- Use UserInputService for release (works even if mouse leaves the topbar)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			hasDragged = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			if delta.Magnitude > 8 then
				hasDragged = true
			end
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

	-- Expose for sections/toggles to check
	self.IsDragging = function()
		return hasDragged
	end
end

function ShadowHub:Open()
	self._open = true
	self._main.Visible = true
	self._main.Size = UDim2.new(0, 300, 0, 0)
	TweenService:Create(self._main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 300, 0, 420)
	}):Play()
end

function ShadowHub:Close()
	self._open = false
	local t = TweenService:Create(self._main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 300, 0, 0)
	})
	t:Play()
	t.Completed:Connect(function()
		if not self._open then
			self._main.Visible = false
		end
	end)
end

function ShadowHub:Section(name)
	self._n += 1
	self._sections[name] = self._sections[name] or false

	local header = Instance.new("TextButton")
	header.Size = UDim2.new(1, 0, 0, 30)
	header.BackgroundColor3 = Theme.Card
	header.BorderSizePixel = 0
	header.LayoutOrder = self._n
	header.AutoButtonColor = false
	header.ZIndex = 102
	header.Parent = self._content
	Instance.new("UICorner", header).CornerRadius = UDim.new(0, 6)

	local accentDot = Instance.new("Frame", header)
	accentDot.Size = UDim2.new(0, 3, 0, 14)
	accentDot.Position = UDim2.new(0, 8, 0.5, -7)
	accentDot.BackgroundColor3 = Theme.Accent
	accentDot.BorderSizePixel = 0
	Instance.new("UICorner", accentDot).CornerRadius = UDim.new(0, 2)

	local arrow = Instance.new("TextLabel", header)
	arrow.Size = UDim2.new(0, 16, 1, 0)
	arrow.Position = UDim2.new(0, 18, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text = self._sections[name] and "\226\150\160" or "\226\150\170"
	arrow.TextColor3 = Theme.Accent
	arrow.Font = Enum.Font.GothamBold
	arrow.TextSize = 9
	arrow.ZIndex = 103

	local label = Instance.new("TextLabel", header)
	label.Size = UDim2.new(1, -40, 1, 0)
	label.Position = UDim2.new(0, 34, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = string.upper(name)
	label.TextColor3 = Theme.Accent
	label.Font = Enum.Font.GothamBold
	label.TextSize = 9
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 103

	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 0)
	container.BackgroundTransparency = 1
	container.ClipsDescendants = true
	container.LayoutOrder = self._n + 0.5
	container.ZIndex = 102
	container.Parent = self._content
	local containerLayout = Instance.new("UIListLayout", container)
	containerLayout.Padding = UDim.new(0, 3)
	containerLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local sectionData = {_c = container, _name = name}

	local function Refresh()
		local lay = container:FindFirstChildOfClass("UIListLayout")
		if lay then
			-- Force layout recalc
			local absH = lay.AbsoluteContentSize.Y
		end
		task.wait()
		local lay2 = container:FindFirstChildOfClass("UIListLayout")
		local th = self._sections[name] and (lay2 and lay2.AbsoluteContentSize.Y or 0) or 0
		arrow.Text = self._sections[name] and "\226\150\160" or "\226\150\170"
		TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 0, th)
		}):Play()
	end

	header.MouseButton1Click:Connect(function()
		if self.IsDragging() then return end
		self._sections[name] = not self._sections[name]
		Refresh()
	end)

	-- Hover effect
	header.MouseEnter:Connect(function()
		if not self._sections[name] then
			TweenService:Create(header, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Hover}):Play()
		end
	end)
	header.MouseLeave:Connect(function()
		TweenService:Create(header, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Card}):Play()
	end)

	Refresh()
	return sectionData
end

function ShadowHub:Toggle(sec, name, def, cb)
	self._n += 1
	local on = def

	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 28)
	card.BackgroundColor3 = Theme.Card
	card.BorderSizePixel = 0
	card.LayoutOrder = self._n
	card.ZIndex = 102
	card.Parent = sec._c
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 5)

	local accentBar = Instance.new("Frame", card)
	accentBar.Size = UDim2.new(0, 2, 0, 10)
	accentBar.Position = UDim2.new(0, 6, 0.5, -5)
	accentBar.BackgroundColor3 = Theme.Accent
	accentBar.BackgroundTransparency = on and 0 or 0.7
	accentBar.BorderSizePixel = 0
	Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 1)

	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(1, -46, 1, 0)
	lbl.Position = UDim2.new(0, 16, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = Theme.Text
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 9
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 103

	-- Toggle track
	local track = Instance.new("Frame", card)
	track.Size = UDim2.new(0, 30, 0, 14)
	track.Position = UDim2.new(1, -38, 0.5, -7)
	track.BackgroundColor3 = Theme.Panel
	track.BorderSizePixel = 0
	track.ZIndex = 103
	Instance.new("UICorner", track).CornerRadius = UDim.new(0, 7)

	local knob = Instance.new("Frame", track)
	knob.Size = UDim2.new(0, 10, 0, 10)
	knob.Position = UDim2.new(0, 2, 0, 2)
	knob.BackgroundColor3 = Theme.Sub
	knob.BorderSizePixel = 0
	knob.ZIndex = 104
	Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 5)

	local function Refresh()
		TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = on and UDim2.new(1, -12, 0, 2) or UDim2.new(0, 2, 0, 2)
		}):Play()
		TweenService:Create(track, TweenInfo.new(0.2), {
			BackgroundColor3 = on and Theme.Accent or Theme.Panel
		}):Play()
		knob.BackgroundColor3 = on and Color3.new(1, 1, 1) or Theme.Sub
		accentBar.BackgroundTransparency = on and 0 or 0.7
	end

	-- Use MouseButton1Click on a transparent button overlay for reliable click
	local clickBtn = Instance.new("TextButton", card)
	clickBtn.Size = UDim2.new(1, 0, 1, 0)
	clickBtn.BackgroundTransparency = 1
	clickBtn.Text = ""
	clickBtn.ZIndex = 105
	clickBtn.AutoButtonColor = false

	clickBtn.MouseButton1Click:Connect(function()
		if self.IsDragging() then return end
		on = not on
		cb(on)
		Refresh()
	end)

	-- Hover
	card.MouseEnter:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Hover}):Play()
	end)
	card.MouseLeave:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Card}):Play()
	end)

	Refresh()
end

function ShadowHub:Slider(sec, name, mn, mx, def, cb)
	self._n += 1
	local V = def

	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 38)
	card.BackgroundColor3 = Theme.Card
	card.BorderSizePixel = 0
	card.LayoutOrder = self._n
	card.ZIndex = 102
	card.Parent = sec._c
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 5)

	local accentBar = Instance.new("Frame", card)
	accentBar.Size = UDim2.new(0, 2, 0, 10)
	accentBar.Position = UDim2.new(0, 6, 0, 6)
	accentBar.BackgroundColor3 = Theme.Accent
	accentBar.BorderSizePixel = 0
	Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 1)

	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(0.55, 0, 0, 12)
	lbl.Position = UDim2.new(0, 16, 0, 5)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = Theme.Text
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 9
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 103

	local valLabel = Instance.new("TextLabel", card)
	valLabel.Size = UDim2.new(0.3, 0, 0, 12)
	valLabel.Position = UDim2.new(1, -36, 0, 5)
	valLabel.BackgroundTransparency = 1
	valLabel.Text = tostring(math.floor(V * 10) / 10)
	valLabel.TextColor3 = Theme.Accent
	valLabel.Font = Enum.Font.GothamBold
	valLabel.TextSize = 9
	valLabel.TextXAlignment = Enum.TextXAlignment.Right
	valLabel.ZIndex = 103

	local track = Instance.new("Frame", card)
	track.Size = UDim2.new(1, -22, 0, 3)
	track.Position = UDim2.new(0, 11, 0, 24)
	track.BackgroundColor3 = Theme.Panel
	track.BorderSizePixel = 0
	track.ZIndex = 103
	Instance.new("UICorner", track).CornerRadius = UDim.new(0, 2)

	local fill = Instance.new("Frame", track)
	fill.Size = UDim2.new((V - mn) / (mx - mn), 0, 1, 0)
	fill.BackgroundColor3 = Theme.Accent
	fill.BorderSizePixel = 0
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)

	local knob = Instance.new("Frame", track)
	knob.Size = UDim2.new(0, 9, 0, 9)
	knob.Position = UDim2.new((V - mn) / (mx - mn), -5, 0.5, -5)
	knob.BackgroundColor3 = Color3.new(1, 1, 1)
	knob.BorderSizePixel = 0
	knob.ZIndex = 105
	Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 5)

	local sliding = false

	local function UpdateSlider(x)
		local p = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		V = mn + p * (mx - mn)
		fill.Size = UDim2.new(p, 0, 1, 0)
		knob.Position = UDim2.new(p, -5, 0.5, -5)
		valLabel.Text = tostring(math.floor(V * 10) / 10)
		cb(V)
	end

	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			UpdateSlider(input.Position.X)
		end
	end)
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
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
		end
	end)

	-- Hover
	card.MouseEnter:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Hover}):Play()
	end)
	card.MouseLeave:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Card}):Play()
	end)
end

function ShadowHub:Button(sec, name, cb)
	self._n += 1

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 28)
	btn.BackgroundColor3 = Theme.Accent
	btn.BorderSizePixel = 0
	btn.Text = string.upper(name)
	btn.TextColor3 = Color3.new(0, 0, 0)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 9
	btn.AutoButtonColor = false
	btn.LayoutOrder = self._n
	btn.ZIndex = 102
	btn.Parent = sec._c
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

	btn.MouseButton1Click:Connect(function()
		if self.IsDragging() then return end
		-- Press effect
		TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.AccentDim}):Play()
		task.delay(0.1, function()
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Accent}):Play()
		end)
		cb()
	end)

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(200, 20, 255)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Accent}):Play()
	end)
end

function ShadowHub:Label(sec, text)
	self._n += 1
	local l = Instance.new("TextLabel", sec._c)
	l.Size = UDim2.new(1, 0, 0, 12)
	l.BackgroundTransparency = 1
	l.Text = "  " .. text
	l.TextColor3 = Theme.Sub
	l.Font = Enum.Font.GothamMedium
	l.TextSize = 7
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.LayoutOrder = self._n
	l.ZIndex = 102
end

function ShadowHub:StatusBar(text)
	self._n += 1
	local l = Instance.new("TextLabel", self._content)
	l.Size = UDim2.new(1, 0, 0, 24)
	l.BackgroundColor3 = Theme.Card
	l.BorderSizePixel = 0
	l.Text = "  " .. text
	l.TextColor3 = Theme.Text
	l.Font = Enum.Font.GothamMedium
	l.TextSize = 8
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.LayoutOrder = self._n
	l.ZIndex = 102
	Instance.new("UICorner", l).CornerRadius = UDim.new(0, 5)

	return {
		SetText = function(_, t)
			l.Text = "  " .. t
		end
	}
end

return ShadowHub

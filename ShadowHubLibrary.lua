--!strict
-- Shadow Hub UI Library v3.0 - Clean & Working

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ShadowHub = {}
ShadowHub.__index = ShadowHub

-- Theme
local Theme = {
	Background = Color3.fromRGB(12, 12, 22),
	Panel = Color3.fromRGB(20, 20, 35),
	Button = Color3.fromRGB(30, 30, 50),
	ButtonHover = Color3.fromRGB(40, 40, 65),
	Accent = Color3.fromRGB(180, 0, 255),
	AccentDark = Color3.fromRGB(120, 0, 180),
	Text = Color3.fromRGB(245, 240, 255),
	Sub = Color3.fromRGB(140, 135, 165),
	Red = Color3.fromRGB(255, 50, 50),
	Green = Color3.fromRGB(50, 255, 100),
	Yellow = Color3.fromRGB(255, 200, 50),
}
ShadowHub.Theme = Theme

-- Notification system
local NotifContainer = nil

local function PushNotif(title, text, type_, duration)
	if not NotifContainer then return end
	type_ = type_ or "info"
	duration = duration or 3
	local cols = {
		info = Theme.Accent, success = Theme.Green,
		warning = Theme.Yellow, error = Theme.Red,
		kill = Color3.fromRGB(255, 80, 80), streak = Theme.Yellow,
	}
	local col = cols[type_] or Theme.Accent

	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, 48)
	f.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	f.BorderSizePixel = 0
	f.ClipsDescendants = true
	f.LayoutOrder = -tick()
	f.Parent = NotifContainer
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

	Instance.new("Frame", f).Size = UDim2.new(0, 3, 1, 0)
	Instance.new("Frame", f).BackgroundColor3 = col
	Instance.new("Frame", f).Size = UDim2.new(0, 3, 1, 0)
	f:ClearAllChildren()
	local bar = Instance.new("Frame", f)
	bar.Size = UDim2.new(0, 3, 1, 0)
	bar.BackgroundColor3 = col
	bar.BorderSizePixel = 0

	local tl = Instance.new("TextLabel", f)
	tl.Size = UDim2.new(1, -16, 0, 14)
	tl.Position = UDim2.new(0, 12, 0, 6)
	tl.BackgroundTransparency = 1
	tl.Text = string.upper(title)
	tl.TextColor3 = col
	tl.Font = Enum.Font.GothamBold
	tl.TextSize = 10
	tl.TextXAlignment = Enum.TextXAlignment.Left

	local tl2 = Instance.new("TextLabel", f)
	tl2.Size = UDim2.new(1, -16, 0, 20)
	tl2.Position = UDim2.new(0, 12, 0, 22)
	tl2.BackgroundTransparency = 1
	tl2.Text = text
	tl2.TextColor3 = Theme.Text
	tl2.Font = Enum.Font.Gotham
	tl2.TextSize = 9
	tl2.TextXAlignment = Enum.TextXAlignment.Left
	tl2.TextWrapped = true

	f.Size = UDim2.new(1, 0, 0, 0)
	TweenService:Create(f, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 48)}):Play()

	task.delay(duration, function()
		TweenService:Create(f, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
		task.wait(0.2)
		pcall(function() f:Destroy() end)
	end)
end

function ShadowHub:Notify(title, text, type_, duration)
	PushNotif(title, text, type_, duration)
end

function ShadowHub:GetGui() return self._gui end
function ShadowHub:IsOpen() return self._open end
function ShadowHub:IsDragging() return self._dragging or false end

function ShadowHub:CreateWindow(title, options)
	options = options or {}
	local self = setmetatable({}, ShadowHub)
	self._open = false
	self._dragging = false
	self._toggleN = 0
	self._openSections = {}

	-- ScreenGui
	self._gui = Instance.new("ScreenGui")
	self._gui.Name = options.Name or "ShadowHub"
	self._gui.ResetOnSpawn = false
	self._gui.IgnoreGuiInset = true
	self._gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self._gui.DisplayOrder = 999
	self._gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	-- Notification container
	NotifContainer = Instance.new("Frame")
	NotifContainer.Size = UDim2.new(0, 300, 1, 0)
	NotifContainer.Position = UDim2.new(1, -315, 0, 10)
	NotifContainer.BackgroundTransparency = 1
	NotifContainer.BorderSizePixel = 0
	NotifContainer.ZIndex = 200
	NotifContainer.Parent = self._gui
	Instance.new("UIListLayout", NotifContainer).Padding = UDim.new(0, 5)
	Instance.new("UIListLayout", NotifContainer).SortOrder = Enum.SortOrder.LayoutOrder
	Instance.new("UIListLayout", NotifContainer).VerticalAlignment = Enum.VerticalAlignment.Top

	-- Loading screen
	self:_loading(title)

	-- Icon
	self._icon = Instance.new("TextButton")
	self._icon.Size = UDim2.fromOffset(50, 50)
	self._icon.Position = UDim2.new(0, 14, 0.5, -25)
	self._icon.BackgroundColor3 = Theme.Panel
	self._icon.BorderSizePixel = 0
	self._icon.Text = "SH"
	self._icon.TextColor3 = Theme.Accent
	self._icon.Font = Enum.Font.GothamBlack
	self._icon.TextSize = 15
	self._icon.AutoButtonColor = false
	self._icon.ZIndex = 100
	self._icon.Parent = self._gui
	Instance.new("UICorner", self._icon).CornerRadius = UDim.new(0, 25)

	-- Main
	self._main = Instance.new("Frame")
	self._main.Size = UDim2.new(0, 320, 0, 0)
	self._main.Position = UDim2.new(0, 14, 0.5, 0)
	self._main.AnchorPoint = Vector2.new(0, 0.5)
	self._main.BackgroundColor3 = Theme.Background
	self._main.BorderSizePixel = 0
	self._main.ClipsDescendants = true
	self._main.Visible = false
	self._main.Parent = self._gui
	Instance.new("UICorner", self._main).CornerRadius = UDim.new(0, 10)
	Instance.new("UIStroke", self._main).Color = Theme.Accent
	Instance.new("UIStroke", self._main).Thickness = 1.5
	Instance.new("UIStroke", self._main).Transparency = 0.5

	-- TopBar
	self._topbar = Instance.new("Frame")
	self._topbar.Size = UDim2.new(1, 0, 0, 38)
	self._topbar.BackgroundColor3 = Theme.Panel
	self._topbar.BorderSizePixel = 0
	self._topbar.Parent = self._main
	Instance.new("UICorner", self._topbar).CornerRadius = UDim.new(0, 10)

	local titleLbl = Instance.new("TextLabel", self._topbar)
	titleLbl.Size = UDim2.new(1, -44, 1, 0)
	titleLbl.Position = UDim2.fromOffset(10, 0)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = string.upper(title)
	titleLbl.TextColor3 = Theme.Accent
	titleLbl.Font = Enum.Font.GothamBlack
	titleLbl.TextSize = 12
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left

	local closeBtn = Instance.new("TextButton", self._topbar)
	closeBtn.Size = UDim2.fromOffset(24, 24)
	closeBtn.Position = UDim2.new(1, -32, 0, 7)
	closeBtn.BackgroundColor3 = Theme.Button
	closeBtn.BorderSizePixel = 0
	closeBtn.Text = "x"
	closeBtn.TextColor3 = Theme.Sub
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 12
	closeBtn.AutoButtonColor = false
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)
	closeBtn.MouseButton1Click:Connect(function() self:Close() end)

	-- Content
	self._content = Instance.new("ScrollingFrame")
	self._content.Size = UDim2.new(1, -12, 1, -46)
	self._content.Position = UDim2.new(0, 6, 0, 42)
	self._content.BackgroundTransparency = 1
	self._content.BorderSizePixel = 0
	self._content.ScrollBarThickness = 2
	self._content.ScrollBarImageColor3 = Theme.Accent
	self._content.CanvasSize = UDim2.new(0, 0, 0, 0)
	self._content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self._content.Parent = self._main
	Instance.new("UIListLayout", self._content).Padding = UDim.new(0, 3)
	Instance.new("UIListLayout", self._content).SortOrder = Enum.SortOrder.LayoutOrder

	-- Drag
	self:_drag()

	-- Toggle
	self._icon.MouseButton1Click:Connect(function()
		if self._open then self:Close() else self:Open() end
	end)
	UserInputService.InputBegan:Connect(function(i, p)
		if p then return end
		if i.KeyCode == Enum.KeyCode.RightControl then
			if self._open then self:Close() else self:Open() end
		end
	end)

	return self
end

function ShadowHub:_loading(title)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 1, 0)
	f.BackgroundColor3 = Color3.fromRGB(3, 3, 8)
	f.BorderSizePixel = 0
	f.ZIndex = 1000
	f.Parent = self._gui

	local tl = Instance.new("TextLabel", f)
	tl.Size = UDim2.new(0.8, 0, 0, 40)
	tl.Position = UDim2.new(0.1, 0, 0.35, 0)
	tl.BackgroundTransparency = 1
	tl.Text = string.upper(title)
	tl.TextColor3 = Theme.Accent
	tl.TextStrokeTransparency = 0
	tl.Font = Enum.Font.GothamBlack
	tl.TextSize = 34
	tl.ZIndex = 1001

	local tl2 = Instance.new("TextLabel", f)
	tl2.Size = UDim2.new(0.8, 0, 0, 20)
	tl2.Position = UDim2.new(0.1, 0, 0.43, 0)
	tl2.BackgroundTransparency = 1
	tl2.Text = "Nao tem escapatoria\226\128\160\226\151\128\226\151\128"
	tl2.TextColor3 = Theme.Text
	tl2.TextStrokeTransparency = 0
	tl2.Font = Enum.Font.GothamMedium
	tl2.TextSize = 14
	tl2.ZIndex = 1001

	local barBG = Instance.new("Frame", f)
	barBG.Size = UDim2.new(0.5, 0, 0, 5)
	barBG.Position = UDim2.new(0.25, 0, 0.55, 0)
	barBG.BackgroundColor3 = Theme.Panel
	barBG.BorderSizePixel = 0
	barBG.ZIndex = 1001
	Instance.new("UICorner", barBG).CornerRadius = UDim.new(0, 3)

	local barFill = Instance.new("Frame", barBG)
	barFill.Size = UDim2.new(0, 0, 1, 0)
	barFill.BackgroundColor3 = Theme.Accent
	barFill.BorderSizePixel = 0
	barFill.ZIndex = 1002
	Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 3)

	local pct = Instance.new("TextLabel", f)
	pct.Size = UDim2.new(0.5, 0, 0, 16)
	pct.Position = UDim2.new(0.25, 0, 0.6, 0)
	pct.BackgroundTransparency = 1
	pct.Text = "0%"
	pct.TextColor3 = Theme.Accent
	pct.TextStrokeTransparency = 0
	pct.Font = Enum.Font.GothamBold
	pct.TextSize = 11
	pct.ZIndex = 1001

	TweenService:Create(barFill, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
	for i = 1, 20 do
		task.wait(1.5 / 20)
		pct.Text = math.floor(i * 5) .. "%"
	end
	task.wait(0.2)

	for _, v in ipairs(f:GetDescendants()) do
		if v:IsA("TextLabel") then
			TweenService:Create(v, TweenInfo.new(0.4), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
		elseif v:IsA("Frame") then
			TweenService:Create(v, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
		end
	end
	TweenService:Create(f, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
	task.wait(0.5)
	pcall(function() f:Destroy() end)
end

function ShadowHub:_drag()
	local dragging, dragStart, startPos, offset
	local THRESHOLD = 8

	self._topbar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = i.Position
			startPos = self._main.Position
			offset = Vector2.new(0, 0)
			self._dragging = false
		end
	end)
	self._topbar.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			self._dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			offset = i.Position - dragStart
			if offset.Magnitude > THRESHOLD then self._dragging = true end
			if self._dragging then
				self._main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + offset.X, startPos.Y.Scale, startPos.Y.Offset + offset.Y)
			end
		end
	end)
end

function ShadowHub:Open()
	self._open = true
	self._main.Visible = true
	self._main.Size = UDim2.new(0, 320, 0, 0)
	TweenService:Create(self._main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 320, 0, 420)}):Play()
end

function ShadowHub:Close()
	self._open = false
	local t = TweenService:Create(self._main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 320, 0, 0)})
	t:Play()
	t.Completed:Connect(function() if not self._open then self._main.Visible = false end end)
end

function ShadowHub:Section(name)
	self._toggleN += 1
	self._openSections[name] = self._openSections[name] or false

	local header = Instance.new("TextButton")
	header.Size = UDim2.new(1, 0, 0, 32)
	header.BackgroundColor3 = Theme.Button
	header.BorderSizePixel = 0
	header.LayoutOrder = self._toggleN
	header.AutoButtonColor = false
	header.Parent = self._content
	Instance.new("UICorner", header).CornerRadius = UDim.new(0, 5)

	local arrow = Instance.new("TextLabel", header)
	arrow.Size = UDim2.new(0, 18, 1, 0)
	arrow.Position = UDim2.fromOffset(6, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text = self._openSections[name] and "\226\150\160" or "\226\150\170"
	arrow.TextColor3 = Theme.Accent
	arrow.Font = Enum.Font.GothamBold
	arrow.TextSize = 9

	local lbl = Instance.new("TextLabel", header)
	lbl.Size = UDim2.new(1, -30, 1, 0)
	lbl.Position = UDim2.fromOffset(24, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = string.upper(name)
	lbl.TextColor3 = Theme.Accent
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 9
	lbl.TextXAlignment = Enum.TextXAlignment.Left

	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 0)
	container.BackgroundTransparency = 1
	container.ClipsDescendants = true
	container.LayoutOrder = self._toggleN + 0.5
	container.Parent = self._content
	Instance.new("UIListLayout", container).Padding = UDim.new(0, 3)
	Instance.new("UIListLayout", container).SortOrder = Enum.SortOrder.LayoutOrder

	local section = {_c = container}

	local function Refresh()
		local layout = container:FindFirstChildOfClass("UIListLayout")
		if layout then layout:ApplyLayout() end
		task.wait()
		local h = self._openSections[name] and (layout and layout.AbsoluteContentSize.Y or 0) or 0
		arrow.Text = self._openSections[name] and "\226\150\160" or "\226\150\170"
		TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, h)}):Play()
	end

	header.MouseButton1Click:Connect(function()
		if self._dragging then return end
		self._openSections[name] = not self._openSections[name]
		Refresh()
	end)

	Refresh()
	return section
end

function ShadowHub:Toggle(section, name, default, cb)
	self._toggleN += 1
	local on = default

	local h = Instance.new("Frame")
	h.Size = UDim2.new(1, 0, 0, 30)
	h.BackgroundColor3 = Theme.Button
	h.BorderSizePixel = 0
	h.LayoutOrder = self._toggleN
	h.Parent = section._c
	Instance.new("UICorner", h).CornerRadius = UDim.new(0, 5)

	local lbl = Instance.new("TextLabel", h)
	lbl.Size = UDim2.new(1, -48, 1, 0)
	lbl.Position = UDim2.fromOffset(10, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = Theme.Text
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 10
	lbl.TextXAlignment = Enum.TextXAlignment.Left

	local bg = Instance.new("Frame", h)
	bg.Size = UDim2.fromOffset(32, 16)
	bg.Position = UDim2.new(1, -42, 0.5, -8)
	bg.BackgroundColor3 = Theme.Panel
	bg.BorderSizePixel = 0
	Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)

	local dot = Instance.new("Frame", bg)
	dot.Size = UDim2.fromOffset(10, 10)
	dot.Position = UDim2.fromOffset(3, 3)
	dot.BackgroundColor3 = Theme.Sub
	dot.BorderSizePixel = 0
	Instance.new("UICorner", dot).CornerRadius = UDim.new(0, 5)

	local function Ref()
		dot.Position = on and UDim2.fromOffset(19, 3) or UDim2.fromOffset(3, 3)
		bg.BackgroundColor3 = on and Theme.Accent or Theme.Panel
		dot.BackgroundColor3 = on and Color3.new(1, 1, 1) or Theme.Sub
	end

	h.InputBegan:Connect(function(i)
		if self._dragging then return end
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			on = not on
			cb(on)
			Ref()
		end
	end)

	Ref()
end

function ShadowHub:Slider(section, name, min, max, def, cb)
	self._toggleN += 1
	local V = def

	local h = Instance.new("Frame")
	h.Size = UDim2.new(1, 0, 0, 40)
	h.BackgroundColor3 = Theme.Button
	h.BorderSizePixel = 0
	h.LayoutOrder = self._toggleN
	h.Parent = section._c
	Instance.new("UICorner", h).CornerRadius = UDim.new(0, 5)

	local lbl = Instance.new("TextLabel", h)
	lbl.Size = UDim2.new(0.6, 0, 0, 14)
	lbl.Position = UDim2.fromOffset(10, 3)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = Theme.Text
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 9
	lbl.TextXAlignment = Enum.TextXAlignment.Left

	local vl = Instance.new("TextLabel", h)
	vl.Size = UDim2.new(0.3, 0, 0, 14)
	vl.Position = UDim2.new(1, -38, 3, 0)
	vl.BackgroundTransparency = 1
	vl.Text = tostring(math.floor(V * 10) / 10)
	vl.TextColor3 = Theme.Accent
	vl.Font = Enum.Font.GothamBold
	vl.TextSize = 9
	vl.TextXAlignment = Enum.TextXAlignment.Right

	local trk = Instance.new("Frame", h)
	trk.Size = UDim2.new(1, -20, 0, 4)
	trk.Position = UDim2.fromOffset(10, 24)
	trk.BackgroundColor3 = Theme.Panel
	trk.BorderSizePixel = 0
	Instance.new("UICorner", trk).CornerRadius = UDim.new(0, 2)

	local fill = Instance.new("Frame", trk)
	fill.Size = UDim2.new((V - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Theme.Accent
	fill.BorderSizePixel = 0
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)

	local kn = Instance.new("Frame", trk)
	kn.Size = UDim2.fromOffset(10, 10)
	kn.Position = UDim2.new((V - min) / (max - min), -5, 0.5, -5)
	kn.BackgroundColor3 = Color3.new(1, 1, 1)
	kn.BorderSizePixel = 0
	kn.ZIndex = 5
	Instance.new("UICorner", kn).CornerRadius = UDim.new(0, 5)

	local sliding = false
	local function Upd(x)
		local p = math.clamp((x - trk.AbsolutePosition.X) / trk.AbsoluteSize.X, 0, 1)
		V = min + p * (max - min)
		fill.Size = UDim2.new(p, 0, 1, 0)
		kn.Position = UDim2.new(p, -5, 0.5, -5)
		vl.Text = tostring(math.floor(V * 10) / 10)
		cb(V)
	end

	kn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = true Upd(i.Position.X) end end)
	trk.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = true Upd(i.Position.X) end end)
	UserInputService.InputChanged:Connect(function(i) if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Upd(i.Position.X) end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end end)
end

function ShadowHub:Button(section, name, cb)
	self._toggleN += 1
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.BackgroundColor3 = Theme.Accent
	btn.BorderSizePixel = 0
	btn.Text = string.upper(name)
	btn.TextColor3 = Color3.new(0, 0, 0)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 10
	btn.AutoButtonColor = false
	btn.LayoutOrder = self._toggleN
	btn.Parent = section._c
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

	btn.MouseButton1Click:Connect(function()
		if self._dragging then return end
		cb()
	end)
end

function ShadowHub:Label(section, text)
	self._toggleN += 1
	local l = Instance.new("TextLabel", section._c)
	l.Size = UDim2.new(1, 0, 0, 14)
	l.BackgroundTransparency = 1
	l.Text = "  " .. text
	l.TextColor3 = Theme.Sub
	l.Font = Enum.Font.GothamMedium
	l.TextSize = 8
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.LayoutOrder = self._toggleN
end

function ShadowHub:StatusBar(text)
	self._toggleN += 1
	local l = Instance.new("TextLabel", self._content)
	l.Size = UDim2.new(1, 0, 0, 26)
	l.BackgroundColor3 = Theme.Button
	l.BorderSizePixel = 0
	l.Text = "  " .. text
	l.TextColor3 = Theme.Text
	l.Font = Enum.Font.GothamMedium
	l.TextSize = 9
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.LayoutOrder = self._toggleN
	Instance.new("UICorner", l).CornerRadius = UDim.new(0, 5)
	return {SetText = function(_, t) l.Text = "  " .. t end}
end

return ShadowHub

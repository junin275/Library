--!strict
-- Shadow Hub UI Library v1.0
-- Reusable Roblox UI Library with sections, toggles, sliders, buttons, color pickers

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
	Accent = Color3.fromRGB(180, 0, 255),
	Text = Color3.fromRGB(245, 240, 255),
	Sub = Color3.fromRGB(140, 135, 165),
	Red = Color3.fromRGB(255, 50, 50),
	Green = Color3.fromRGB(50, 255, 100),
	Yellow = Color3.fromRGB(255, 200, 50),
}

ShadowHub.Theme = Theme

-- Utility
local function Make(class: string, props: {[string]: any}, parent: Instance?)
	local o = Instance.new(class)
	for k, v in pairs(props) do
		pcall(function() o[k] = v end)
	end
	if parent then o.Parent = parent end
	return o
end

local function Tween(obj, info, props)
	TweenService:Create(obj, info, props):Play()
end

-- Create Window
function ShadowHub:CreateWindow(title: string, options: {[string]: any}?)
	options = options or {}
	local self = setmetatable({}, ShadowHub)

	-- State
	self._open = false
	self._sections = {}
	self._connections = {}
	self._toggleCount = 0
	self._openSections = {}

	-- ScreenGui
	self._gui = Make("ScreenGui", {
		Name = options.Name or "ShadowHub",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
		Parent = LocalPlayer:WaitForChild("PlayerGui"),
	})

	-- Loading Screen
	self:_createLoadingScreen(title)

	-- Icon
	self._icon = Make("TextButton", {
		Size = UDim2.fromOffset(52, 52),
		Position = UDim2.new(0, 16, 0.5, -26),
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Text = options.IconText or "SH",
		TextColor3 = Theme.Accent,
		Font = Enum.Font.GothamBlack,
		TextSize = 16,
		AutoButtonColor = false,
		ZIndex = 100,
		Parent = self._gui,
	})
	Make("UICorner", {CornerRadius = UDim.new(0, 26)}, self._icon)
	Make("UIStroke", {Color = Theme.Accent, Thickness = 1.5, Transparency = 0.4, Parent = self._icon})

	-- Icon hover
	self._icon.MouseEnter:Connect(function()
		Tween(self._icon, TweenInfo.new(0.2), {Size = UDim2.fromOffset(58, 58), BackgroundColor3 = Theme.Accent})
		Tween(self._icon, TweenInfo.new(0.2), {TextColor3 = Color3.new(0, 0, 0)})
	end)
	self._icon.MouseLeave:Connect(function()
		Tween(self._icon, TweenInfo.new(0.2), {Size = UDim2.fromOffset(52, 52), BackgroundColor3 = Theme.Panel})
		Tween(self._icon, TweenInfo.new(0.2), {TextColor3 = Theme.Accent})
	end)

	-- Main Frame
	self._main = Make("Frame", {
		Size = UDim2.fromOffset(340, 0),
		Position = UDim2.new(0, 16, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = false,
		Parent = self._gui,
	})
	Make("UICorner", {CornerRadius = UDim.new(0, 12)}, self._main)
	Make("UIStroke", {Color = Theme.Accent, Thickness = 1.5, Transparency = 0.4, Parent = self._main})

	-- TopBar
	self._topbar = Make("Frame", {
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = self._main,
	})
	Make("UICorner", {CornerRadius = UDim.new(0, 12)}, self._topbar)

	Make("TextLabel", {
		Size = UDim2.new(1, -50, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		BackgroundTransparency = 1,
		Text = string.upper(title),
		TextColor3 = Theme.Accent,
		Font = Enum.Font.GothamBlack,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self._topbar,
	})

	local closeBtn = Make("TextButton", {
		Size = UDim2.fromOffset(26, 26),
		Position = UDim2.new(1, -34, 0, 8),
		BackgroundColor3 = Theme.Button,
		BorderSizePixel = 0,
		Text = "x",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		AutoButtonColor = false,
		Parent = self._topbar,
	})
	Make("UICorner", {CornerRadius = UDim.new(0, 6)}, closeBtn)
	closeBtn.MouseButton1Click:Connect(function() self:Close() end)

	-- Content
	self._content = Make("ScrollingFrame", {
		Position = UDim2.fromOffset(8, 50),
		Size = UDim2.new(1, -16, 1, -58),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = self._main,
	})
	Make("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, self._content)

	-- Drag
	self:_setupDrag()

	-- Toggle
	self._icon.MouseButton1Click:Connect(function()
		if self._open then self:Close() else self:Open() end
	end)
	UserInputService.InputBegan:Connect(function(i, proc)
		if proc then return end
		if i.KeyCode == Enum.KeyCode.RightControl then
			if self._open then self:Close() else self:Open() end
		end
	end)

	-- Icon pulse
	task.spawn(function()
		while true do
			if not self._open then
				Tween(self._icon, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.3})
				task.wait(1.2)
				Tween(self._icon, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0})
				task.wait(1.2)
			else
				task.wait(0.5)
			end
		end
	end)

	return self
end

-- Loading Screen
function ShadowHub:_createLoadingScreen(title: string)
	local loadScreen = Make("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(5, 5, 10),
		BorderSizePixel = 0,
		ZIndex = 1000,
		Parent = self._gui,
	})

	Make("TextLabel", {
		Size = UDim2.new(0.8, 0, 0, 40),
		Position = UDim2.new(0.1, 0, 0.35, 0),
		BackgroundTransparency = 1,
		Text = string.upper(title),
		TextColor3 = Theme.Accent,
		TextStrokeTransparency = 0,
		TextStrokeColor3 = Color3.fromRGB(50, 0, 80),
		Font = Enum.Font.GothamBlack,
		TextSize = 36,
		ZIndex = 1001,
		Parent = loadScreen,
	})

	Make("TextLabel", {
		Size = UDim2.new(0.8, 0, 0, 24),
		Position = UDim2.new(0.1, 0, 0.44, 0),
		BackgroundTransparency = 1,
		Text = "Nao tem escapatoria\226\128\160\226\151\128\226\151\128",
		TextColor3 = Theme.Text,
		TextStrokeTransparency = 0,
		Font = Enum.Font.GothamMedium,
		TextSize = 16,
		ZIndex = 1001,
		Parent = loadScreen,
	})

	local barBG = Make("Frame", {
		Size = UDim2.new(0.5, 0, 0, 6),
		Position = UDim2.new(0.25, 0, 0.56, 0),
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		ZIndex = 1001,
		Parent = loadScreen,
	})
	Make("UICorner", {CornerRadius = UDim.new(0, 3)}, barBG)

	local barFill = Make("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		ZIndex = 1002,
		Parent = barBG,
	})
	Make("UICorner", {CornerRadius = UDim.new(0, 3)}, barFill)

	local barGlow = Make("UIStroke", {Color = Theme.Accent, Thickness = 4, Transparency = 0.5, Parent = barFill})

	local percentLabel = Make("TextLabel", {
		Size = UDim2.new(0.5, 0, 0, 18),
		Position = UDim2.new(0.25, 0, 0.6, 0),
		BackgroundTransparency = 1,
		Text = "0%",
		TextColor3 = Theme.Accent,
		TextStrokeTransparency = 0,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		ZIndex = 1001,
		Parent = loadScreen,
	})

	Make("TextLabel", {
		Size = UDim2.new(0.8, 0, 0, 14),
		Position = UDim2.new(0.1, 0, 0.66, 0),
		BackgroundTransparency = 1,
		Text = "carregando...",
		TextColor3 = Theme.Sub,
		TextStrokeTransparency = 0,
		Font = Enum.Font.Gotham,
		TextSize = 10,
		ZIndex = 1001,
		Parent = loadScreen,
	})

	-- Animate
	local duration = 1.8
	TweenService:Create(barFill, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()

	for i = 1, 20 do
		task.wait(duration / 20)
		percentLabel.Text = math.floor(i * 5) .. "%"
	end

	barGlow.Thickness = 8
	barGlow.Transparency = 0
	task.wait(0.15)

	TweenService:Create(loadScreen, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
	for _, child in ipairs(loadScreen:GetDescendants()) do
		if child:IsA("TextLabel") then
			TweenService:Create(child, TweenInfo.new(0.4), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
		elseif child:IsA("Frame") then
			TweenService:Create(child, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
		end
	end

	task.wait(0.5)
	pcall(function() loadScreen:Destroy() end)
end

-- Drag Setup
function ShadowHub:_setupDrag()
	local dragging, dragStart, startPos, dragOffset, isDragging
	local DRAG_THRESHOLD = 8

	self._isDragging = function() return isDragging end

	self._topbar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = i.Position
			startPos = self._main.Position
			dragOffset = Vector2.new(0, 0)
			isDragging = false
		end
	end)

	self._topbar.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			isDragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			dragOffset = i.Position - dragStart
			if dragOffset.Magnitude > DRAG_THRESHOLD then
				isDragging = true
			end
			if isDragging then
				self._main.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + dragOffset.X,
					startPos.Y.Scale, startPos.Y.Offset + dragOffset.Y
				)
			end
		end
	end)
end

-- Open/Close
function ShadowHub:Open()
	self._open = true
	self._main.Visible = true
	self._main.Position = UDim2.new(0, 16, 0.5, 0)
	self._main.Size = UDim2.fromOffset(340, 0)
	Tween(self._main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(340, 440)})
end

function ShadowHub:Close()
	self._open = false
	local tw = Tween(self._main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.fromOffset(340, 0)})
	tw.Completed:Once(function()
		if not self._open then self._main.Visible = false end
	end)
end

function ShadowHub:IsOpen()
	return self._open
end

function ShadowHub:IsDragging()
	return self._isDragging and self._isDragging() or false
end

function ShadowHub:GetGui()
	return self._gui
end

-- Section
function ShadowHub:Section(name: string)
	self._toggleCount += 1
	self._openSections[name] = self._openSections[name] or false

	local header = Make("TextButton", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = Theme.Button,
		BorderSizePixel = 0,
		LayoutOrder = self._toggleCount,
		AutoButtonColor = false,
		Parent = self._content,
	})
	Make("UICorner", {CornerRadius = UDim.new(0, 6)}, header)

	local arrow = Make("TextLabel", {
		Size = UDim2.new(0, 20, 1, 0),
		Position = UDim2.fromOffset(8, 0),
		BackgroundTransparency = 1,
		Text = self._openSections[name] and "\226\150\160" or "\226\150\170",
		TextColor3 = Theme.Accent,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		Parent = header,
	})

	Make("TextLabel", {
		Size = UDim2.new(1, -36, 1, 0),
		Position = UDim2.fromOffset(28, 0),
		BackgroundTransparency = 1,
		Text = string.upper(name),
		TextColor3 = Theme.Accent,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})

	local container = Make("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		LayoutOrder = self._toggleCount + 0.5,
		Parent = self._content,
	})
	local layout = Make("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, container)

	local section = {_container = container, _layout = layout, _items = {}}
	table.insert(self._sections, section)

	local function Refresh(animate: boolean)
		layout:ApplyLayout()
		task.wait()
		local targetH = self._openSections[name] and layout.AbsoluteContentSize.Y or 0
		arrow.Text = self._openSections[name] and "\226\150\160" or "\226\150\170"
		if animate then
			Tween(container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, targetH)})
		else
			container.Size = UDim2.new(1, 0, 0, targetH)
		end
	end

	header.MouseButton1Click:Connect(function()
		self._openSections[name] = not self._openSections[name]
		Refresh(true)
	end)

	Refresh(false)
	return section
end

-- Toggle
function ShadowHub:Toggle(section, name: string, default: boolean, callback: (boolean) -> ())
	self._toggleCount += 1
	local h = Make("Frame", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = Theme.Button,
		BorderSizePixel = 0,
		LayoutOrder = self._toggleCount,
		Parent = section._container,
	})
	Make("UICorner", {CornerRadius = UDim.new(0, 5)}, h)

	local on = default

	Make("TextLabel", {
		Size = UDim2.new(1, -50, 1, 0),
		Position = UDim2.fromOffset(10, 0),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamMedium,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = h,
	})

	local bg = Make("Frame", {
		Size = UDim2.fromOffset(34, 18),
		Position = UDim2.new(1, -44, 0.5, -9),
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Parent = h,
	})
	Make("UICorner", {CornerRadius = UDim.new(0, 9)}, bg)

	local dot = Make("Frame", {
		Size = UDim2.fromOffset(12, 12),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = Theme.Sub,
		BorderSizePixel = 0,
		Parent = bg,
	})
	Make("UICorner", {CornerRadius = UDim.new(0, 6)}, dot)

	local function Ref(anim: boolean)
		local pos = on and UDim2.fromOffset(19, 3) or UDim2.fromOffset(3, 3)
		local col = on and Theme.Accent or Theme.Panel
		local dotCol = on and Color3.new(1, 1, 1) or Theme.Sub
		if anim then
			Tween(bg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = col})
			Tween(dot, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = pos, BackgroundColor3 = dotCol})
			Tween(h, TweenInfo.new(0.08), {Size = UDim2.new(1, -2, 0, 30)})
			task.delay(0.08, function()
				Tween(h, TweenInfo.new(0.12, Enum.EasingStyle.Back), {Size = UDim2.new(1, 0, 0, 32)})
			end)
		else
			bg.BackgroundColor3 = col
			dot.Position = pos
			dot.BackgroundColor3 = dotCol
		end
	end

	h.InputBegan:Connect(function(i)
		if self:IsDragging() then return end
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			on = not on
			callback(on)
			Ref(true)
		end
	end)

	Ref(false)

	return {
		Get = function() return on end,
		Set = function(v: boolean)
			on = v
			callback(on)
			Ref(true)
		end,
	}
end

-- Slider
function ShadowHub:Slider(section, name: string, min: number, max: number, default: number, callback: (number) -> ())
	self._toggleCount += 1
	local h = Make("Frame", {
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = Theme.Button,
		BorderSizePixel = 0,
		LayoutOrder = self._toggleCount,
		Parent = section._container,
	})
	Make("UICorner", {CornerRadius = UDim.new(0, 5)}, h)

	local V = default

	Make("TextLabel", {
		Size = UDim2.new(0.6, 0, 0, 16),
		Position = UDim2.fromOffset(10, 3),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamMedium,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = h,
	})

	local VL = Make("TextLabel", {
		Size = UDim2.new(0.35, 0, 0, 16),
		Position = UDim2.new(1, -42, 3, 0),
		BackgroundTransparency = 1,
		Text = tostring(math.floor(V * 10) / 10),
		TextColor3 = Theme.Accent,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = h,
	})

	local Trk = Make("Frame", {
		Size = UDim2.new(1, -20, 0, 4),
		Position = UDim2.fromOffset(10, 26),
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Parent = h,
	})
	Make("UICorner", {CornerRadius = UDim.new(0, 2)}, Trk)

	local Fl = Make("Frame", {
		Size = UDim2.new((V - min) / (max - min), 0, 1, 0),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Parent = Trk,
	})
	Make("UICorner", {CornerRadius = UDim.new(0, 2)}, Fl)

	local Kn = Make("Frame", {
		Size = UDim2.fromOffset(10, 10),
		Position = UDim2.new((V - min) / (max - min), -5, 0.5, -5),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = Trk,
	})
	Make("UICorner", {CornerRadius = UDim.new(0, 5)}, Kn)
	local KnStroke = Make("UIStroke", {Color = Theme.Accent, Thickness = 1.5, Parent = Kn})

	local sliding = false

	local function Update(x: number)
		local p = math.clamp((x - Trk.AbsolutePosition.X) / Trk.AbsoluteSize.X, 0, 1)
		V = min + p * (max - min)
		Fl.Size = UDim2.new(p, 0, 1, 0)
		Tween(Kn, TweenInfo.new(0.08), {Position = UDim2.new(p, -5, 0.5, -5)})
		VL.Text = tostring(math.floor(V * 10) / 10)
		callback(V)
	end

	Kn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			KnStroke.Thickness = 3
			Update(i.Position.X)
		end
	end)
	Trk.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			Update(i.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			Update(i.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sliding = false
			KnStroke.Thickness = 1.5
		end
	end)

	return {
		Get = function() return V end,
		Set = function(v: number)
			V = math.clamp(v, min, max)
			local p = (V - min) / (max - min)
			Fl.Size = UDim2.new(p, 0, 1, 0)
			Kn.Position = UDim2.new(p, -5, 0.5, -5)
			VL.Text = tostring(math.floor(V * 10) / 10)
			callback(V)
		end,
	}
end

-- Button
function ShadowHub:Button(section, name: string, callback: () -> ())
	self._toggleCount += 1
	local btn = Make("TextButton", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Text = string.upper(name),
		TextColor3 = Color3.new(0, 0, 0),
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		AutoButtonColor = false,
		LayoutOrder = self._toggleCount,
		Parent = section._container,
	})
	Make("UICorner", {CornerRadius = UDim.new(0, 5)}, btn)

	btn.MouseButton1Click:Connect(function()
		if self:IsDragging() then return end
		Tween(btn, TweenInfo.new(0.06), {Size = UDim2.new(1, -4, 0, 30)})
		task.delay(0.06, function()
			Tween(btn, TweenInfo.new(0.12, Enum.EasingStyle.Back), {Size = UDim2.new(1, 0, 0, 32)})
		end)
		callback()
	end)
end

-- Label
function ShadowHub:Label(section, text: string)
	self._toggleCount += 1
	Make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Text = "  " .. text,
		TextColor3 = Theme.Sub,
		Font = Enum.Font.GothamMedium,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = self._toggleCount,
		Parent = section._container,
	})
end

-- Color Picker Row
function ShadowHub:ColorRow(section, name: string, default: Color3, callback: (Color3) -> ())
	self._toggleCount += 1
	local h = Make("Frame", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = Theme.Button,
		BorderSizePixel = 0,
		LayoutOrder = self._toggleCount,
		Parent = section._container,
	})
	Make("UICorner", {CornerRadius = UDim.new(0, 5)}, h)

	Make("TextLabel", {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.fromOffset(10, 0),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamMedium,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = h,
	})

	local colors = {
		{Color3.fromRGB(255, 255, 255), "Branco"},
		{Color3.fromRGB(255, 0, 0), "Vermelho"},
		{Color3.fromRGB(0, 255, 0), "Verde"},
		{Color3.fromRGB(0, 150, 255), "Azul"},
		{Color3.fromRGB(255, 0, 255), "Rosa"},
		{Color3.fromRGB(255, 200, 0), "Amarelo"},
		{Color3.fromRGB(0, 255, 255), "Ciano"},
	}

	local current = default
	for i, c in ipairs(colors) do
		local btn = Make("TextButton", {
			Size = UDim2.fromOffset(18, 18),
			Position = UDim2.new(0.5, (i - 1) * 22 - #colors * 11, 0.5, -9),
			BackgroundColor3 = c[1],
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Parent = h,
		})
		Make("UICorner", {CornerRadius = UDim.new(0, 4)}, btn)
		if c[1] == default then
			Make("UIStroke", {Color = Color3.new(1, 1, 1), Thickness = 2, Parent = btn})
		end
		btn.MouseButton1Click:Connect(function()
			if self:IsDragging() then return end
			current = c[1]
			callback(c[1])
			for _, ch in ipairs(h:GetChildren()) do
				if ch:IsA("UIStroke") then ch:Destroy() end
			end
			Make("UIStroke", {Color = Color3.new(1, 1, 1), Thickness = 2, Parent = btn})
		end)
	end
end

-- Status Bar (footer)
function ShadowHub:StatusBar(text: string)
	self._toggleCount += 1
	local label = Make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = Theme.Button,
		BorderSizePixel = 0,
		Text = "  " .. text,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamMedium,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = self._toggleCount,
		Parent = self._content,
	})
	Make("UICorner", {CornerRadius = UDim.new(0, 6)}, label)
	return {
		SetText = function(_, t: string) label.Text = "  " .. t end,
	}
end

-- Destroy
function ShadowHub:Destroy()
	for _, conn in ipairs(self._connections) do
		pcall(function() conn:Disconnect() end)
	end
	pcall(function() self._gui:Destroy() end)
end

return ShadowHub

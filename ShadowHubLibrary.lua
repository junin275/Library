--!strict
-- Shadow Hub UI Library v4.0 - Notification-style design
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
	Accent = Color3.fromRGB(180, 0, 255),
	AccentDim = Color3.fromRGB(100, 0, 160),
	Text = Color3.fromRGB(235, 230, 250),
	Sub = Color3.fromRGB(120, 115, 145),
	Green = Color3.fromRGB(50, 255, 100),
	Red = Color3.fromRGB(255, 50, 50),
	Yellow = Color3.fromRGB(255, 200, 50),
}
ShadowHub.Theme = Theme

-- Notif container
local NotifFolder = nil

local function Notif(title, text, type_, dur)
	if not NotifFolder then return end
	dur = dur or 3
	local cols = {info=Theme.Accent, success=Theme.Green, warning=Theme.Yellow, error=Theme.Red, kill=Color3.fromRGB(255,80,80), streak=Theme.Yellow}
	local col = cols[type_] or Theme.Accent

	local f = Instance.new("Frame")
	f.Size = UDim2.new(1,0,0,0)
	f.BackgroundColor3 = Color3.fromRGB(12,12,22)
	f.BorderSizePixel = 0
	f.ClipsDescendants = true
	f.LayoutOrder = -tick()
	f.Parent = NotifFolder
	Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)

	local bar = Instance.new("Frame", f)
	bar.Size = UDim2.new(0,3,1,0)
	bar.BackgroundColor3 = col
	bar.BorderSizePixel = 0

	local t1 = Instance.new("TextLabel", f)
	t1.Size = UDim2.new(1,-14,0,13)
	t1.Position = UDim2.new(0,12,0,7)
	t1.BackgroundTransparency = 1
	t1.Text = string.upper(title)
	t1.TextColor3 = col
	t1.Font = Enum.Font.GothamBold
	t1.TextSize = 10
	t1.TextXAlignment = Enum.TextXAlignment.Left

	local t2 = Instance.new("TextLabel", f)
	t2.Size = UDim2.new(1,-14,0,28)
	t2.Position = UDim2.new(0,12,0,23)
	t2.BackgroundTransparency = 1
	t2.Text = text
	t2.TextColor3 = Theme.Text
	t2.Font = Enum.Font.Gotham
	t2.TextSize = 9
	t2.TextXAlignment = Enum.TextXAlignment.Left
	t2.TextWrapped = true

	-- Progress
	local prog = Instance.new("Frame", f)
	prog.Size = UDim2.new(1,0,0,2)
	prog.Position = UDim2.new(0,0,1,-2)
	prog.BackgroundColor3 = col
	prog.BackgroundTransparency = 0.4
	prog.BorderSizePixel = 0

	TweenService:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,55)}):Play()
	TweenService:Create(prog, TweenInfo.new(dur, Enum.EasingStyle.Linear), {Size = UDim2.new(0,0,0,2)}):Play()

	task.delay(dur, function()
		TweenService:Create(f, TweenInfo.new(0.25), {Size = UDim2.new(1,0,0,0)}):Play()
		task.wait(0.25)
		pcall(function() f:Destroy() end)
	end)
end

function ShadowHub:Notify(t, x, y, d) Notif(t, x, y, d) end
function ShadowHub:GetGui() return self._gui end
function ShadowHub:IsOpen() return self._open end
function ShadowHub:IsDragging() return self._drag or false end

function ShadowHub:CreateWindow(title, opts)
	opts = opts or {}
	local self = setmetatable({}, ShadowHub)
	self._open = false
	self._drag = false
	self._n = 0
	self._sections = {}

	-- Gui
	self._gui = Instance.new("ScreenGui")
	self._gui.Name = opts.Name or "ShadowHub"
	self._gui.ResetOnSpawn = false
	self._gui.IgnoreGuiInset = true
	self._gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self._gui.DisplayOrder = 999
	self._gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	-- Notif folder
	NotifFolder = Instance.new("Frame")
	NotifFolder.Size = UDim2.new(0,280,1,0)
	NotifFolder.Position = UDim2.new(1,-295,0,10)
	NotifFolder.BackgroundTransparency = 1
	NotifFolder.BorderSizePixel = 0
	NotifFolder.ZIndex = 200
	NotifFolder.Parent = self._gui
	local nl = Instance.new("UIListLayout", NotifFolder)
	nl.Padding = UDim.new(0,5)
	nl.SortOrder = Enum.SortOrder.LayoutOrder
	nl.VerticalAlignment = Enum.VerticalAlignment.Top

	-- Loading
	self:_load(title)

	-- Icon
	self._icon = Instance.new("TextButton")
	self._icon.Size = UDim2.new(0,46,0,46)
	self._icon.Position = UDim2.new(0,12,0.5,-23)
	self._icon.BackgroundColor3 = Theme.Panel
	self._icon.BorderSizePixel = 0
	self._icon.Text = "SH"
	self._icon.TextColor3 = Theme.Accent
	self._icon.Font = Enum.Font.GothamBlack
	self._icon.TextSize = 14
	self._icon.AutoButtonColor = false
	self._icon.ZIndex = 100
	self._icon.Parent = self._gui
	Instance.new("UICorner", self._icon).CornerRadius = UDim.new(0,23)
	local is = Instance.new("UIStroke", self._icon)
	is.Color = Theme.Accent
	is.Thickness = 1.5
	is.Transparency = 0.5

	-- Main
	self._main = Instance.new("Frame")
	self._main.Size = UDim2.new(0,300,0,0)
	self._main.Position = UDim2.new(0,12,0.5,0)
	self._main.AnchorPoint = Vector2.new(0,0.5)
	self._main.BackgroundColor3 = Theme.BG
	self._main.BorderSizePixel = 0
	self._main.ClipsDescendants = true
	self._main.Visible = false
	self._main.Parent = self._gui
	Instance.new("UICorner", self._main).CornerRadius = UDim.new(0,10)
	Instance.new("UIStroke", self._main).Color = Theme.Accent
	Instance.new("UIStroke", self._main).Thickness = 1.5
	Instance.new("UIStroke", self._main).Transparency = 0.6

	-- TopBar
	self._tb = Instance.new("Frame")
	self._tb.Size = UDim2.new(1,0,0,36)
	self._tb.BackgroundColor3 = Theme.Panel
	self._tb.BorderSizePixel = 0
	self._tb.Parent = self._main
	Instance.new("UICorner", self._tb).CornerRadius = UDim.new(0,10)

	-- Accent line under topbar
	local al = Instance.new("Frame", self._tb)
	al.Size = UDim2.new(1,0,0,1)
	al.Position = UDim2.new(0,0,1,-1)
	al.BackgroundColor3 = Theme.Accent
	al.BackgroundTransparency = 0.6
	al.BorderSizePixel = 0

	local tl = Instance.new("TextLabel", self._tb)
	tl.Size = UDim2.new(1,-40,1,0)
	tl.Position = UDim2.new(0,10,0,0)
	tl.BackgroundTransparency = 1
	tl.Text = string.upper(title)
	tl.TextColor3 = Theme.Accent
	tl.Font = Enum.Font.GothamBlack
	tl.TextSize = 11
	tl.TextXAlignment = Enum.TextXAlignment.Left

	local cb = Instance.new("TextButton", self._tb)
	cb.Size = UDim2.new(0,22,0,22)
	cb.Position = UDim2.new(1,-30,0,7)
	cb.BackgroundColor3 = Theme.Card
	cb.BorderSizePixel = 0
	cb.Text = "x"
	cb.TextColor3 = Theme.Sub
	cb.Font = Enum.Font.GothamBold
	cb.TextSize = 11
	cb.AutoButtonColor = false
	Instance.new("UICorner", cb).CornerRadius = UDim.new(0,5)
	cb.MouseButton1Click:Connect(function() self:Close() end)

	-- Content
	self._ct = Instance.new("ScrollingFrame")
	self._ct.Size = UDim2.new(1,-10,1,-44)
	self._ct.Position = UDim2.new(0,5,0,40)
	self._ct.BackgroundTransparency = 1
	self._ct.BorderSizePixel = 0
	self._ct.ScrollBarThickness = 2
	self._ct.ScrollBarImageColor3 = Theme.Accent
	self._ct.CanvasSize = UDim2.new(0,0,0,0)
	self._ct.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self._ct.Parent = self._main
	Instance.new("UIListLayout", self._ct).Padding = UDim.new(0,3)
	Instance.new("UIListLayout", self._ct).SortOrder = Enum.SortOrder.LayoutOrder

	-- Drag
	self:_drag()

	self._icon.MouseButton1Click:Connect(function()
		if self._open then self:Close() else self:Open() end
	end)
	UserInputService.InputBegan:Connect(function(i,p)
		if p then return end
		if i.KeyCode == Enum.KeyCode.RightControl then
			if self._open then self:Close() else self:Open() end
		end
	end)

	return self
end

function ShadowHub:_load(title)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1,0,1,0)
	f.BackgroundColor3 = Color3.fromRGB(3,3,6)
	f.BorderSizePixel = 0
	f.ZIndex = 1000
	f.Parent = self._gui

	local t1 = Instance.new("TextLabel", f)
	t1.Size = UDim2.new(0.8,0,0,36)
	t1.Position = UDim2.new(0.1,0,0.34,0)
	t1.BackgroundTransparency = 1
	t1.Text = string.upper(title)
	t1.TextColor3 = Theme.Accent
	t1.TextStrokeTransparency = 0
	t1.Font = Enum.Font.GothamBlack
	t1.TextSize = 32
	t1.ZIndex = 1001

	local t2 = Instance.new("TextLabel", f)
	t2.Size = UDim2.new(0.8,0,0,18)
	t2.Position = UDim2.new(0.1,0,0.42,0)
	t2.BackgroundTransparency = 1
	t2.Text = "Nao tem escapatoria\226\128\160\226\151\128\226\151\128"
	t2.TextColor3 = Theme.Text
	t2.TextStrokeTransparency = 0
	t2.Font = Enum.Font.GothamMedium
	t2.TextSize = 13
	t2.ZIndex = 1001

	local bg = Instance.new("Frame", f)
	bg.Size = UDim2.new(0.45,0,0,4)
	bg.Position = UDim2.new(0.275,0,0.54,0)
	bg.BackgroundColor3 = Theme.Panel
	bg.BorderSizePixel = 0
	bg.ZIndex = 1001
	Instance.new("UICorner", bg).CornerRadius = UDim.new(0,2)

	local bf = Instance.new("Frame", bg)
	bf.Size = UDim2.new(0,0,1,0)
	bf.BackgroundColor3 = Theme.Accent
	bf.BorderSizePixel = 0
	bf.ZIndex = 1002
	Instance.new("UICorner", bf).CornerRadius = UDim.new(0,2)

	local pct = Instance.new("TextLabel", f)
	pct.Size = UDim2.new(0.45,0,0,14)
	pct.Position = UDim2.new(0.275,0,0.59,0)
	pct.BackgroundTransparency = 1
	pct.Text = "0%"
	pct.TextColor3 = Theme.Accent
	pct.TextStrokeTransparency = 0
	pct.Font = Enum.Font.GothamBold
	pct.TextSize = 10
	pct.ZIndex = 1001

	TweenService:Create(bf, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,1,0)}):Play()
	for i=1,20 do task.wait(1.5/20) pct.Text = math.floor(i*5).."%" end
	task.wait(0.2)
	for _,v in ipairs(f:GetDescendants()) do
		if v:IsA("TextLabel") then TweenService:Create(v, TweenInfo.new(0.4), {TextTransparency=1, TextStrokeTransparency=1}):Play()
		elseif v:IsA("Frame") then TweenService:Create(v, TweenInfo.new(0.4), {BackgroundTransparency=1}):Play() end
	end
	TweenService:Create(f, TweenInfo.new(0.4), {BackgroundTransparency=1}):Play()
	task.wait(0.5)
	pcall(function() f:Destroy() end)
end

function ShadowHub:_drag()
	local dragging, ds, so, off
	self._topbar = self._tb

	self._tb.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			dragging=true ds=i.Position so=self._main.Position off=Vector2.new(0,0) self._drag=false
		end
	end)
	self._tb.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			dragging=false self._drag=false
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
			off=i.Position-ds
			if off.Magnitude>8 then self._drag=true end
			if self._drag then
				self._main.Position = UDim2.new(so.X.Scale, so.X.Offset+off.X, so.Y.Scale, so.Y.Offset+off.Y)
			end
		end
	end)
end

function ShadowHub:Open()
	self._open=true self._main.Visible=true self._main.Size=UDim2.new(0,300,0,0)
	TweenService:Create(self._main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.new(0,300,0,400)}):Play()
end

function ShadowHub:Close()
	self._open=false
	local t=TweenService:Create(self._main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size=UDim2.new(0,300,0,0)})
	t:Play() t.Completed:Connect(function() if not self._open then self._main.Visible=false end end)
end

function ShadowHub:Section(name)
	self._n+=1 self._sections[name]=self._sections[name] or false

	-- Section header (notification style card)
	local h = Instance.new("TextButton")
	h.Size = UDim2.new(1,0,0,30)
	h.BackgroundColor3 = Theme.Card
	h.BorderSizePixel = 0
	h.LayoutOrder = self._n
	h.AutoButtonColor = false
	h.Parent = self._ct
	Instance.new("UICorner", h).CornerRadius = UDim.new(0,6)

	-- Accent dot
	local dot = Instance.new("Frame", h)
	dot.Size = UDim2.new(0,3,0,14)
	dot.Position = UDim2.new(0,8,0.5,-7)
	dot.BackgroundColor3 = Theme.Accent
	dot.BorderSizePixel = 0
	Instance.new("UICorner", dot).CornerRadius = UDim.new(0,2)

	local arrow = Instance.new("TextLabel", h)
	arrow.Size = UDim2.new(0,16,1,0)
	arrow.Position = UDim2.new(0,18,0,0)
	arrow.BackgroundTransparency = 1
	arrow.Text = self._sections[name] and "\226\150\160" or "\226\150\170"
	arrow.TextColor3 = Theme.Accent
	arrow.Font = Enum.Font.GothamBold
	arrow.TextSize = 9

	local lbl = Instance.new("TextLabel", h)
	lbl.Size = UDim2.new(1,-40,1,0)
	lbl.Position = UDim2.new(0,34,0,0)
	lbl.BackgroundTransparency = 1
	lbl.Text = string.upper(name)
	lbl.TextColor3 = Theme.Accent
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 9
	lbl.TextXAlignment = Enum.TextXAlignment.Left

	local ct = Instance.new("Frame")
	ct.Size = UDim2.new(1,0,0,0)
	ct.BackgroundTransparency = 1
	ct.ClipsDescendants = true
	ct.LayoutOrder = self._n+0.5
	ct.Parent = self._ct
	Instance.new("UIListLayout", ct).Padding = UDim.new(0,3)
	Instance.new("UIListLayout", ct).SortOrder = Enum.SortOrder.LayoutOrder

	local sec = {_c=ct}

	local function Refresh()
		local lay = ct:FindFirstChildOfClass("UIListLayout")
		if lay then lay:ApplyLayout() end
		task.wait()
		local th = self._sections[name] and (lay and lay.AbsoluteContentSize.Y or 0) or 0
		arrow.Text = self._sections[name] and "\226\150\160" or "\226\150\170"
		TweenService:Create(ct, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size=UDim2.new(1,0,0,th)}):Play()
	end

	h.MouseButton1Click:Connect(function()
		if self._drag then return end
		self._sections[name] = not self._sections[name]
		Refresh()
	end)

	Refresh()
	return sec
end

function ShadowHub:Toggle(sec, name, def, cb)
	self._n+=1
	local on = def

	local h = Instance.new("Frame")
	h.Size = UDim2.new(1,0,0,28)
	h.BackgroundColor3 = Theme.Card
	h.BorderSizePixel = 0
	h.LayoutOrder = self._n
	h.Parent = sec._c
	Instance.new("UICorner", h).CornerRadius = UDim.new(0,5)

	-- Small accent dot
	local ad = Instance.new("Frame", h)
	ad.Size = UDim2.new(0,2,0,10)
	ad.Position = UDim2.new(0,6,0.5,-5)
	ad.BackgroundColor3 = Theme.Accent
	ad.BackgroundTransparency = on and 0 or 0.7
	ad.BorderSizePixel = 0
	Instance.new("UICorner", ad).CornerRadius = UDim.new(0,1)

	local lbl = Instance.new("TextLabel", h)
	lbl.Size = UDim2.new(1,-46,1,0)
	lbl.Position = UDim2.new(0,16,0,0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = Theme.Text
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 9
	lbl.TextXAlignment = Enum.TextXAlignment.Left

	-- Toggle track
	local bg = Instance.new("Frame", h)
	bg.Size = UDim2.new(0,30,0,14)
	bg.Position = UDim2.new(1,-38,0.5,-7)
	bg.BackgroundColor3 = Theme.Panel
	bg.BorderSizePixel = 0
	Instance.new("UICorner", bg).CornerRadius = UDim.new(0,7)

	local kn = Instance.new("Frame", bg)
	kn.Size = UDim2.new(0,10,0,10)
	kn.Position = UDim2.new(0,2,0,2)
	kn.BackgroundColor3 = Theme.Sub
	kn.BorderSizePixel = 0
	Instance.new("UICorner", kn).CornerRadius = UDim.new(0,5)

	local function Ref()
		kn.Position = on and UDim2.new(1,-12,0,2) or UDim2.new(0,2,0,2)
		bg.BackgroundColor3 = on and Theme.Accent or Theme.Panel
		kn.BackgroundColor3 = on and Color3.new(1,1,1) or Theme.Sub
		ad.BackgroundTransparency = on and 0 or 0.7
	end

	h.InputBegan:Connect(function(i)
		if self._drag then return end
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			on=not on cb(on) Ref()
		end
	end)

	Ref()
end

function ShadowHub:Slider(sec, name, mn, mx, def, cb)
	self._n+=1
	local V = def

	local h = Instance.new("Frame")
	h.Size = UDim2.new(1,0,0,38)
	h.BackgroundColor3 = Theme.Card
	h.BorderSizePixel = 0
	h.LayoutOrder = self._n
	h.Parent = sec._c
	Instance.new("UICorner", h).CornerRadius = UDim.new(0,5)

	local ad = Instance.new("Frame", h)
	ad.Size = UDim2.new(0,2,0,10)
	ad.Position = UDim2.new(0,6,0,6)
	ad.BackgroundColor3 = Theme.Accent
	ad.BorderSizePixel = 0
	Instance.new("UICorner", ad).CornerRadius = UDim.new(0,1)

	local lbl = Instance.new("TextLabel", h)
	lbl.Size = UDim2.new(0.55,0,0,12)
	lbl.Position = UDim2.new(0,16,0,5)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = Theme.Text
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 9
	lbl.TextXAlignment = Enum.TextXAlignment.Left

	local vl = Instance.new("TextLabel", h)
	vl.Size = UDim2.new(0.3,0,0,12)
	vl.Position = UDim2.new(1,-36,5,0)
	vl.BackgroundTransparency = 1
	vl.Text = tostring(math.floor(V*10)/10)
	vl.TextColor3 = Theme.Accent
	vl.Font = Enum.Font.GothamBold
	vl.TextSize = 9
	vl.TextXAlignment = Enum.TextXAlignment.Right

	local trk = Instance.new("Frame", h)
	trk.Size = UDim2.new(1,-22,0,3)
	trk.Position = UDim2.new(0,11,0,24)
	trk.BackgroundColor3 = Theme.Panel
	trk.BorderSizePixel = 0
	Instance.new("UICorner", trk).CornerRadius = UDim.new(0,2)

	local fl = Instance.new("Frame", trk)
	fl.Size = UDim2.new((V-mn)/(mx-mn),0,1,0)
	fl.BackgroundColor3 = Theme.Accent
	fl.BorderSizePixel = 0
	Instance.new("UICorner", fl).CornerRadius = UDim.new(0,2)

	local kn = Instance.new("Frame", trk)
	kn.Size = UDim2.new(0,9,0,9)
	kn.Position = UDim2.new((V-mn)/(mx-mn),-5,0.5,-5)
	kn.BackgroundColor3 = Color3.new(1,1,1)
	kn.BorderSizePixel = 0
	kn.ZIndex = 5
	Instance.new("UICorner", kn).CornerRadius = UDim.new(0,5)

	local sliding = false
	local function Upd(x)
		local p = math.clamp((x-trk.AbsolutePosition.X)/trk.AbsoluteSize.X,0,1)
		V=mn+p*(mx-mn) fl.Size=UDim2.new(p,0,1,0)
		kn.Position=UDim2.new(p,-5,0.5,-5)
		vl.Text=tostring(math.floor(V*10)/10) cb(V)
	end

	kn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=true Upd(i.Position.X) end end)
	trk.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=true Upd(i.Position.X) end end)
	UserInputService.InputChanged:Connect(function(i) if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then Upd(i.Position.X) end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=false end end)
end

function ShadowHub:Button(sec, name, cb)
	self._n+=1
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,0,0,28)
	b.BackgroundColor3 = Theme.Accent
	b.BorderSizePixel = 0
	b.Text = string.upper(name)
	b.TextColor3 = Color3.new(0,0,0)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 9
	b.AutoButtonColor = false
	b.LayoutOrder = self._n
	b.Parent = sec._c
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,5)
	b.MouseButton1Click:Connect(function() if self._drag then return end cb() end)
end

function ShadowHub:Label(sec, text)
	self._n+=1
	local l = Instance.new("TextLabel", sec._c)
	l.Size = UDim2.new(1,0,0,12)
	l.BackgroundTransparency = 1
	l.Text = "  "..text
	l.TextColor3 = Theme.Sub
	l.Font = Enum.Font.GothamMedium
	l.TextSize = 7
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.LayoutOrder = self._n
end

function ShadowHub:StatusBar(text)
	self._n+=1
	local l = Instance.new("TextLabel", self._ct)
	l.Size = UDim2.new(1,0,0,24)
	l.BackgroundColor3 = Theme.Card
	l.BorderSizePixel = 0
	l.Text = "  "..text
	l.TextColor3 = Theme.Text
	l.Font = Enum.Font.GothamMedium
	l.TextSize = 8
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.LayoutOrder = self._n
	Instance.new("UICorner", l).CornerRadius = UDim.new(0,5)
	return {SetText=function(_,t) l.Text="  "..t end}
end

return ShadowHub

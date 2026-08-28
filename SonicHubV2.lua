-- Shadow Hub V2 - Premium Glassmorphism Edition
-- By @junin275

local ShadowHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/junin275/Library/main/ShadowHubLibrary.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- CONFIG
local Config = {
	ESP = true, ESPTracer = true, ESPDot = true,
	AimAssist = false, TargetLock = false, WallCheck = true,
	FFAMode = true, MaxDistance = 2000, TargetPart = "HumanoidRootPart",
	AutoHeadshot = false, KillNotify = true, MiniGPS = false,
	Noclip = false, Fullbright = false, SpeedBoost = false,
	SpinBot = false, SpinSpeed = 30, SpinAngle = 0,
	FOV = 70, HitSound = true, AimSmooth = 0.15,
}

local State = {
	ESP = {}, Target = nil, Kills = 0, Streak = 0,
	LastHP = {},
}

-- PREMIUM COLOR PALETTE
local C = {
	Enemy = Color3.fromRGB(255, 65, 85),
	EnemyBright = Color3.fromRGB(255, 115, 130),
	EnemyDark = Color3.fromRGB(180, 35, 45),
	Ally = Color3.fromRGB(56, 200, 255),
	AllyBright = Color3.fromRGB(100, 220, 255),
	AllyDark = Color3.fromRGB(30, 120, 180),
	Accent = Color3.fromRGB(168, 85, 247),
	AccentBright = Color3.fromRGB(196, 140, 255),
	Green = Color3.fromRGB(60, 255, 130),
	Yellow = Color3.fromRGB(255, 210, 70),
	Red = Color3.fromRGB(255, 70, 85),
	Dark = Color3.fromRGB(14, 12, 24),
	Dark2 = Color3.fromRGB(20, 18, 36),
	Dark3 = Color3.fromRGB(28, 26, 48),
	Text = Color3.fromRGB(238, 236, 252),
	TextDim = Color3.fromRGB(138, 132, 168),
	Glass = Color3.fromRGB(28, 26, 48),
}

local function IsColorClose(a, b, tol)
	tol = tol or 0.15
	return math.abs(a.R - b.R) < tol and math.abs(a.G - b.G) < tol and math.abs(a.B - b.B) < tol
end

local function IsEnemy(player)
	if Config.FFAMode then return true end
	if player == LocalPlayer then return false end
	local char = player.Character
	if not char then return false end
	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("Highlight") and v.OutlineColor then
			if IsColorClose(v.OutlineColor, Color3.fromRGB(255, 0, 0), 0.3) then return true end
			if IsColorClose(v.OutlineColor, Color3.fromRGB(0, 255, 100), 0.3) then return false end
		end
	end
	return false
end

local function GetDistance(player)
	local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local tRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if myRoot and tRoot then return (myRoot.Position - tRoot.Position).Magnitude end
	return 9999
end

local function HasLineOfSight(target)
	local myChar = LocalPlayer.Character
	local tChar = target.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
	if not myRoot or not tRoot then return false end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {myChar, tChar}
	local result = Workspace:Raycast(myRoot.Position, (tRoot.Position - myRoot.Position), params)
	return result == nil
end

local function IsValidTarget(target)
	if not target then return false end
	local char = target.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	return hum and root and hum.Health > 0
end

-- AIMBOT
local function FindTarget()
	local best, bestDist = nil, math.huge
	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and IsEnemy(p) then
			local char = p.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if hum and root and hum.Health > 0 then
				local dist = (myRoot.Position - root.Position).Magnitude
				if dist < bestDist and dist <= Config.MaxDistance then
					if not Config.WallCheck or HasLineOfSight(p) then
						bestDist = dist
						best = p
					end
				end
			end
		end
	end
	return best
end

local function AimAtTarget(target)
	if not Config.AimAssist then return end
	if not target or not IsValidTarget(target) then return end
	local partName = Config.AutoHeadshot and "Head" or Config.TargetPart
	local part = target.Character:FindFirstChild(partName)
	if not part then return end
	Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), Config.AimSmooth)
end

-- PREMIUM ESP SYSTEM
local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "ShadowESP"
ESPGui.ResetOnSpawn = false
ESPGui.IgnoreGuiInset = true
ESPGui.DisplayOrder = 998
ESPGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function RemoveESP(player)
	local data = State.ESP[player]
	if data then
		pcall(function() data.Frame:Destroy() end)
		pcall(function() data.Highlight:Destroy() end)
		pcall(function() data.Tracer:Destroy() end)
		pcall(function() data.Dot:Destroy() end)
		pcall(function() data.DotGlow:Destroy() end)
		pcall(function() data.Glow:Destroy() end)
		State.ESP[player] = nil
	end
end

local function HideESP(player)
	local data = State.ESP[player]
	if data then
		pcall(function()
			data.Frame.Enabled = false
			data.Highlight.Enabled = false
			data.Tracer.Visible = false
			data.Dot.Visible = false
			data.Glow.Enabled = false
		end)
	end
end

local function ShowESP(player)
	local data = State.ESP[player]
	if data then
		pcall(function()
			data.Frame.Enabled = true
			data.Highlight.Enabled = true
			data.Glow.Enabled = true
		end)
	end
end

-- Helper: create a corner
local function Corner(parent, r)
	local c = Instance.new("UICorner", parent)
	c.CornerRadius = UDim.new(0, r or 6)
	return c
end

-- Helper: create a stroke
local function Strk(parent, col, thick, trans)
	local s = Instance.new("UIStroke", parent)
	s.Color = col
	s.Thickness = thick or 1
	s.Transparency = trans or 0.5
	return s
end

-- Helper: gradient
local function Grad(parent, colorSeq, rot)
	local g = Instance.new("UIGradient", parent)
	g.Color = colorSeq
	g.Rotation = rot or 0
	return g
end

local function CreateESP(player)
	if player == LocalPlayer then return end
	if State.ESP[player] then return end
	local char = player.Character
	if not char then return end
	local head = char:FindFirstChild("Head")
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not head or not root or not hum then return end

	local isEnemy = IsEnemy(player)
	local c = isEnemy and C.Enemy or C.Ally
	local cB = isEnemy and C.EnemyBright or C.AllyBright
	local cD = isEnemy and C.EnemyDark or C.AllyDark

	-- BillboardGui
	local bb = Instance.new("BillboardGui")
	bb.Name = "ShadowESP_" .. player.Name
	bb.Adornee = head
	bb.Size = UDim2.new(0, 200, 0, 72)
	bb.StudsOffset = Vector3.new(0, 3.5, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = Config.MaxDistance
	bb.Parent = ESPGui

	-- Outer glow
	local glow = Instance.new("Frame", bb)
	glow.Name = "Glow"
	glow.Size = UDim2.new(1, 12, 1, 12)
	glow.Position = UDim2.new(0, -6, 0, -6)
	glow.BackgroundColor3 = c
	glow.BackgroundTransparency = 0.88
	glow.BorderSizePixel = 0
	glow.ZIndex = 0
	Corner(glow, 14)

	-- Main glass card
	local card = Instance.new("Frame", bb)
	card.Name = "Card"
	card.Size = UDim2.new(1, 0, 1, 0)
	card.BackgroundColor3 = C.Dark
	card.BackgroundTransparency = 0.45
	card.BorderSizePixel = 0
	card.ZIndex = 2
	Corner(card, 12)
	Strk(card, c, 1.5, 0.35)

	-- Glass highlight top
	local glassTop = Instance.new("Frame", card)
	glassTop.Size = UDim2.new(1, 0, 0.45, 0)
	glassTop.BackgroundColor3 = Color3.new(1, 1, 1)
	glassTop.BackgroundTransparency = 0.9
	glassTop.BorderSizePixel = 0
	glassTop.ZIndex = 3
	Corner(glassTop, 12)
	Grad(glassTop, ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
	}), 90)

	-- Left accent bar
	local bar = Instance.new("Frame", card)
	bar.Name = "Bar"
	bar.Size = UDim2.new(0, 4, 0.7, 0)
	bar.Position = UDim2.new(0, 8, 0.15, 0)
	bar.BackgroundColor3 = c
	bar.BorderSizePixel = 0
	bar.ZIndex = 4
	Corner(bar, 2)

	-- Team badge
	local badge = Instance.new("Frame", card)
	badge.Size = UDim2.new(0, 48, 0, 14)
	badge.Position = UDim2.new(1, -56, 0, 5)
	badge.BackgroundColor3 = cD
	badge.BackgroundTransparency = 0.25
	badge.BorderSizePixel = 0
	badge.ZIndex = 4
	Corner(badge, 7)
	Strk(badge, c, 1, 0.4)

	local badgeText = Instance.new("TextLabel", badge)
	badgeText.Size = UDim2.new(1, 0, 1, 0)
	badgeText.BackgroundTransparency = 1
	badgeText.Text = isEnemy and "ENEMY" or "ALLY"
	badgeText.TextColor3 = cB
	badgeText.Font = Enum.Font.GothamBlack
	badgeText.TextSize = 8
	badgeText.ZIndex = 5

	-- Name
	local nameLabel = Instance.new("TextLabel", card)
	nameLabel.Name = "Name"
	nameLabel.Size = UDim2.new(1, -70, 0, 18)
	nameLabel.Position = UDim2.new(0, 18, 0, 6)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = player.DisplayName
	nameLabel.TextColor3 = C.Text
	nameLabel.TextStrokeTransparency = 0.3
	nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 14
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.ZIndex = 4

	-- Distance
	local distLabel = Instance.new("TextLabel", card)
	distLabel.Name = "Dist"
	distLabel.Size = UDim2.new(0, 55, 0, 13)
	distLabel.Position = UDim2.new(1, -60, 0, 22)
	distLabel.BackgroundTransparency = 1
	distLabel.Text = "0m"
	distLabel.TextColor3 = C.TextDim
	distLabel.TextStrokeTransparency = 0.3
	distLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	distLabel.Font = Enum.Font.GothamBold
	distLabel.TextSize = 11
	distLabel.TextXAlignment = Enum.TextXAlignment.Right
	distLabel.ZIndex = 4

	-- HP background (glass)
	local hpBG = Instance.new("Frame", card)
	hpBG.Size = UDim2.new(0.82, 0, 0, 8)
	hpBG.Position = UDim2.new(0.09, 0, 0, 32)
	hpBG.BackgroundColor3 = C.Dark3
	hpBG.BackgroundTransparency = 0.3
	hpBG.BorderSizePixel = 0
	hpBG.ZIndex = 4
	Corner(hpBG, 4)
	Strk(hpBG, Color3.fromRGB(255, 255, 255), 0.5, 0.85)

	-- HP fill with gradient
	local hpFill = Instance.new("Frame", hpBG)
	hpFill.Name = "Fill"
	hpFill.Size = UDim2.new(1, 0, 1, 0)
	hpFill.BackgroundColor3 = C.Green
	hpFill.BorderSizePixel = 0
	hpFill.ZIndex = 5
	Corner(hpFill, 4)
	Grad(hpFill, ColorSequence.new({
		ColorSequenceKeypoint.new(0, C.Green),
		ColorSequenceKeypoint.new(0.5, C.Yellow),
		ColorSequenceKeypoint.new(1, C.Red),
	}), 0)

	-- HP shine
	local hpShine = Instance.new("Frame", hpFill)
	hpShine.Size = UDim2.new(1, 0, 0.4, 0)
	hpShine.Position = UDim2.new(0, 0, 0, 0)
	hpShine.BackgroundColor3 = Color3.new(1, 1, 1)
	hpShine.BackgroundTransparency = 0.75
	hpShine.BorderSizePixel = 0
	hpShine.ZIndex = 6
	Corner(hpShine, 4)

	-- HP text
	local hpLabel = Instance.new("TextLabel", card)
	hpLabel.Name = "HP"
	hpLabel.Size = UDim2.new(0.82, 0, 0, 10)
	hpLabel.Position = UDim2.new(0.09, 0, 0, 42)
	hpLabel.BackgroundTransparency = 1
	hpLabel.Text = "100 HP"
	hpLabel.TextColor3 = C.TextDim
	hpLabel.TextStrokeTransparency = 0.3
	hpLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	hpLabel.Font = Enum.Font.Gotham
	hpLabel.TextSize = 9
	hpLabel.TextXAlignment = Enum.TextXAlignment.Left
	hpLabel.ZIndex = 4

	-- Status label
	local statusLabel = Instance.new("TextLabel", card)
	statusLabel.Name = "Status"
	statusLabel.Size = UDim2.new(0.82, 0, 0, 9)
	statusLabel.Position = UDim2.new(0.09, 0, 0, 54)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = ""
	statusLabel.TextColor3 = cB
	statusLabel.TextStrokeTransparency = 0.3
	statusLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	statusLabel.Font = Enum.Font.GothamBold
	statusLabel.TextSize = 8
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.ZIndex = 4

	-- Highlight (world)
	local hl = Instance.new("Highlight")
	hl.Name = "ShadowHighlight"
	hl.Adornee = char
	hl.FillColor = c
	hl.FillTransparency = 0.72
	hl.OutlineColor = cB
	hl.OutlineTransparency = 0.1
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = ESPGui

	-- Tracer (line from center-bottom)
	local tracer = Instance.new("Frame", ESPGui)
	tracer.Name = "Tracer"
	tracer.AnchorPoint = Vector2.new(0.5, 0.5)
	tracer.BackgroundColor3 = c
	tracer.BackgroundTransparency = 0.35
	tracer.BorderSizePixel = 0
	tracer.Visible = false
	tracer.ZIndex = 10
	Corner(tracer, 1)
	Grad(tracer, ColorSequence.new({
		ColorSequenceKeypoint.new(0, c),
		ColorSequenceKeypoint.new(1, cB),
	}), 90)

	-- Dot (head position)
	local dot = Instance.new("Frame", ESPGui)
	dot.Name = "Dot"
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Size = UDim2.fromOffset(8, 8)
	dot.BackgroundColor3 = cB
	dot.BorderSizePixel = 0
	dot.Visible = false
	dot.ZIndex = 12
	Corner(dot, 100)

	-- Dot glow
	local dotGlow = Instance.new("Frame", ESPGui)
	dotGlow.Name = "DotGlow"
	dotGlow.AnchorPoint = Vector2.new(0.5, 0.5)
	dotGlow.Size = UDim2.fromOffset(16, 16)
	dotGlow.BackgroundColor3 = c
	dotGlow.BackgroundTransparency = 0.65
	dotGlow.BorderSizePixel = 0
	dotGlow.Visible = false
	dotGlow.ZIndex = 11
	Corner(dotGlow, 100)

	State.ESP[player] = {
		Frame = bb, Highlight = hl, Tracer = tracer, Dot = dot, Glow = glow, DotGlow = dotGlow,
		NameLabel = nameLabel, DistLabel = distLabel, HPLabel = hpLabel,
		HPFill = hpFill, StatusLabel = statusLabel, Badge = badge, BadgeText = badgeText,
		Bar = bar, EspColor = c, EspColorBright = cB, EspColorDark = cD, IsEnemy = isEnemy,
	}
end

local function UpdateESP(player)
	if player == LocalPlayer then return end
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not char or not hum or not root or hum.Health <= 0 then RemoveESP(player) return end
	local dist = GetDistance(player)
	if dist > Config.MaxDistance then HideESP(player) return end

	local data = State.ESP[player]
	local isEnemy = IsEnemy(player)
	if data and data.IsEnemy ~= isEnemy then RemoveESP(player) data = nil end
	if not data then CreateESP(player) data = State.ESP[player] end
	if not data then return end
	ShowESP(player)

	local c = data.EspColor
	local cB = data.EspColorBright
	local cD = data.EspColorDark

	pcall(function()
		data.Highlight.Adornee = char
		data.Highlight.FillColor = c
		data.Highlight.OutlineColor = cB
		data.Bar.BackgroundColor3 = c
		data.Badge.BackgroundColor3 = cD
		data.BadgeText.TextColor3 = cB
		data.BadgeText.Text = isEnemy and "ENEMY" or "ALLY"
		data.Tracer.BackgroundColor3 = c
		data.Dot.BackgroundColor3 = cB
		data.DotGlow.BackgroundColor3 = c
		data.Glow.BackgroundColor3 = c
	end)

	local hpPct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
	pcall(function()
		data.DistLabel.Text = math.floor(dist) .. "m"
		data.HPLabel.Text = math.floor(hum.Health) .. " HP"
		if hpPct > 0.6 then data.HPFill.BackgroundColor3 = C.Green
		elseif hpPct > 0.3 then data.HPFill.BackgroundColor3 = C.Yellow
		else data.HPFill.BackgroundColor3 = C.Red end
		data.HPFill.Size = UDim2.new(hpPct, 0, 1, 0)
		if hpPct <= 0 then data.StatusLabel.Text = "ELIMINATED"
		elseif hpPct < 0.3 then data.StatusLabel.Text = "CRITICAL"
		else data.StatusLabel.Text = "" end
	end)

	pcall(function()
		local sp, onScreen = Camera:WorldToViewportPoint(root.Position)
		if onScreen and sp.Z > 0 then
			local sc = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
			local sp2 = Vector2.new(sp.X, sp.Y)
			local diff = sp2 - sc
			data.Tracer.Position = UDim2.fromOffset((sc.X + sp2.X) / 2, (sc.Y + sp2.Y) / 2)
			data.Tracer.Size = UDim2.fromOffset(2, diff.Magnitude)
			data.Tracer.Rotation = math.deg(math.atan2(diff.Y, diff.X)) + 90
			data.Tracer.Visible = Config.ESPTracer
			data.Dot.Position = UDim2.fromOffset(sp.X, sp.Y)
			data.Dot.Visible = Config.ESPDot
			data.DotGlow.Position = UDim2.fromOffset(sp.X, sp.Y)
			data.DotGlow.Visible = Config.ESPDot
		else
			data.Tracer.Visible = false
			data.Dot.Visible = false
			data.DotGlow.Visible = false
		end
	end)
end

local function UpdateAllESP()
	if not Config.ESP then for p in pairs(State.ESP) do RemoveESP(p) end return end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then UpdateESP(p) end
	end
end

-- PREMIUM GPS
local GPSFrame = Instance.new("Frame")
GPSFrame.Size = UDim2.new(0, 160, 0, 90)
GPSFrame.Position = UDim2.new(1, -175, 0, 15)
GPSFrame.BackgroundColor3 = C.Dark
GPSFrame.BackgroundTransparency = 0.3
GPSFrame.BorderSizePixel = 0
GPSFrame.Visible = false
GPSFrame.ZIndex = 999
GPSFrame.Parent = ESPGui
Corner(GPSFrame, 14)
Strk(GPSFrame, C.Accent, 1.5, 0.3)

local gpsGlass = Instance.new("Frame", GPSFrame)
gpsGlass.Size = UDim2.new(1, 0, 0.45, 0)
gpsGlass.BackgroundColor3 = Color3.new(1, 1, 1)
gpsGlass.BackgroundTransparency = 0.92
gpsGlass.BorderSizePixel = 0
Corner(gpsGlass, 14)

local GPSArrow = Instance.new("TextLabel", GPSFrame)
GPSArrow.Size = UDim2.new(1, 0, 0, 32)
GPSArrow.Position = UDim2.new(0, 0, 0, 6)
GPSArrow.BackgroundTransparency = 1
GPSArrow.Text = "▲"
GPSArrow.TextColor3 = C.Green
GPSArrow.TextStrokeTransparency = 0.3
GPSArrow.TextStrokeColor3 = Color3.new(0, 0, 0)
GPSArrow.Font = Enum.Font.GothamBlack
GPSArrow.TextSize = 26
GPSArrow.ZIndex = 1000

local GPSDist = Instance.new("TextLabel", GPSFrame)
GPSDist.Size = UDim2.new(1, 0, 0, 18)
GPSDist.Position = UDim2.new(0, 0, 0, 38)
GPSDist.BackgroundTransparency = 1
GPSDist.Text = "--"
GPSDist.TextColor3 = C.AccentBright
GPSDist.TextStrokeTransparency = 0.3
GPSDist.TextStrokeColor3 = Color3.new(0, 0, 0)
GPSDist.Font = Enum.Font.GothamBold
GPSDist.TextSize = 13
GPSDist.ZIndex = 1000

local GPSName = Instance.new("TextLabel", GPSFrame)
GPSName.Size = UDim2.new(1, -10, 0, 14)
GPSName.Position = UDim2.new(0, 5, 0, 62)
GPSName.BackgroundTransparency = 1
GPSName.Text = "procurando..."
GPSName.TextColor3 = C.TextDim
GPSName.TextStrokeTransparency = 0.3
GPSName.TextStrokeColor3 = Color3.new(0, 0, 0)
GPSName.Font = Enum.Font.Gotham
GPSName.TextSize = 9
GPSName.TextTruncate = Enum.TextTruncate.AtEnd
GPSName.ZIndex = 1000

-- EXPLOITS
RunService.Stepped:Connect(function()
	if Config.Noclip then
		local char = LocalPlayer.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = false end
			end
		end
	end
end)

local function SetFullbright(on)
	Config.Fullbright = on
	if on then
		Lighting.Brightness = 2
		Lighting.Ambient = Color3.fromRGB(178, 178, 178)
		Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
		Lighting.FogEnd = 100000
	else
		Lighting.Brightness = 1
		Lighting.Ambient = Color3.fromRGB(70, 70, 70)
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
		Lighting.FogEnd = 100000
	end
end

local function SetSpeed(on)
	Config.SpeedBoost = on
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = on and 32 or 16 end
end

local function TeleportToEnemy()
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local best, bestDist
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and IsEnemy(p) then
			local tRoot = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
			local tHum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
			if tRoot and tHum and tHum.Health > 0 then
				local d = (root.Position - tRoot.Position).Magnitude
				if d < Config.MaxDistance and (not bestDist or d < bestDist) then
					best = p
					bestDist = d
				end
			end
		end
	end
	if best and best.Character and best.Character:FindFirstChild("HumanoidRootPart") then
		root.CFrame = best.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -4)
		ShadowHub:Notify("Teleport", best.DisplayName, "success", 2)
	end
end

-- PLAYER MONITOR
local function MonitorPlayer(player)
	if player == LocalPlayer then return end
	State.LastHP[player] = 100
	local function onCharacter(char)
		local hum = char:WaitForChild("Humanoid", 10)
		if not hum then return end
		State.LastHP[player] = hum.Health
		hum.HealthChanged:Connect(function(newHP)
			local oldHP = State.LastHP[player] or newHP
			State.LastHP[player] = newHP
			if oldHP > 0 and newHP <= 0 then
				task.delay(0.1, function() RemoveESP(player) end)
				local dist = GetDistance(player)
				if State.Target == player or dist < 80 then
					State.Kills += 1
					State.Streak += 1
					if Config.HitSound then
						pcall(function()
							local s = Instance.new("Sound")
							s.SoundId = "rbxassetid://5765660795"
							s.Volume = 0.5
							s.Parent = Camera
							s:Play()
							game:GetService("Debris"):AddItem(s, 2)
						end)
					end
					if Config.KillNotify then ShadowHub:Notify("Kill", player.DisplayName, "kill", 3) end
					if State.Target == player then State.Target = nil end
					if State.Streak == 3 then ShadowHub:Notify("Streak!", "3x", "streak", 3) end
					if State.Streak == 5 then ShadowHub:Notify("Streak!", "5x", "streak", 3) end
					if State.Streak == 10 then ShadowHub:Notify("Unstoppable!", "10x", "streak", 4) end
				end
			end
		end)
	end
	if player.Character then task.spawn(onCharacter, player.Character) end
	player.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		onCharacter(char)
		task.wait(0.3)
		RemoveESP(player)
	end)
end

for _, p in ipairs(Players:GetPlayers()) do MonitorPlayer(p) end
Players.PlayerAdded:Connect(MonitorPlayer)

LocalPlayer.CharacterAdded:Connect(function(char)
	State.Streak = 0
	local hum = char:WaitForChild("Humanoid", 10)
	if hum then hum.Died:Connect(function() State.Streak = 0 end) end
	if Config.SpeedBoost then
		local h = char:WaitForChild("Humanoid", 5)
		if h then h.WalkSpeed = 32 end
	end
end)

Players.PlayerRemoving:Connect(function(p)
	RemoveESP(p)
	if State.Target == p then State.Target = nil end
	State.LastHP[p] = nil
end)

-- BUILD MENU
local menu = ShadowHub:CreateWindow("Shadow Hub V2")

local s1 = menu:Section("COMBATE")
menu:Toggle(s1, "ESP", true, function(v)
	Config.ESP = v
	if not v then for p in pairs(State.ESP) do RemoveESP(p) end end
end)
menu:Toggle(s1, "  Tracer", true, function(v) Config.ESPTracer = v end)
menu:Toggle(s1, "  Dot", true, function(v) Config.ESPDot = v end)
menu:Toggle(s1, "Aimbot", false, function(v) Config.AimAssist = v end)
menu:Label(s1, "Sempre ativo quando ligado")
menu:Toggle(s1, "Target Lock", false, function(v)
	Config.TargetLock = v
	if v then State.Target = FindTarget() else State.Target = nil end
end)
menu:Toggle(s1, "Wall Check", true, function(v) Config.WallCheck = v end)
menu:Label(s1, "Nao mira atraves de parede")
menu:Toggle(s1, "Auto Headshot", false, function(v) Config.AutoHeadshot = v end)
menu:Slider(s1, "Smoothness", 1, 50, 15, function(v) Config.AimSmooth = v / 100 end)
menu:Label(s1, "Mais alto = mais grude")
menu:Slider(s1, "Distance", 50, 5000, 2000, function(v) Config.MaxDistance = v end)

local s3 = menu:Section("UTIL")
menu:Toggle(s3, "GPS", false, function(v) Config.MiniGPS = v GPSFrame.Visible = v end)
menu:Toggle(s3, "Kill Notif", true, function(v) Config.KillNotify = v end)
menu:Toggle(s3, "Hit Sound", true, function(v) Config.HitSound = v end)
menu:Toggle(s3, "FFA Mode", true, function(v) Config.FFAMode = v end)
menu:Toggle(s3, "Stealth Mode", false, function(v) menu:SetStealthMode(v) end)
menu:Label(s3, "Icone invisivel mas clicavel/arrastavel")
menu:Button(s3, "Teleport", TeleportToEnemy)

local s4 = menu:Section("EXPLOITS")
menu:Toggle(s4, "Noclip", false, function(v) Config.Noclip = v end)
menu:Toggle(s4, "Fullbright", false, function(v) SetFullbright(v) end)
menu:Toggle(s4, "Speed", false, function(v) SetSpeed(v) end)
menu:Toggle(s4, "Spin Bot", false, function(v) Config.SpinBot = v State.SpinAngle = 0 end)
menu:Slider(s4, "Spin", 5, 120, 30, function(v) Config.SpinSpeed = v end)
menu:Slider(s4, "FOV", 30, 120, 70, function(v) Config.FOV = v Camera.FieldOfView = v end)

local status = menu:StatusBar("K: 0 | S: 0")

-- MAIN LOOP
RunService.RenderStepped:Connect(function(dt)
	UpdateAllESP()

	if Config.AimAssist then
		local target = FindTarget()
		if Config.TargetLock then
			if not IsValidTarget(State.Target) then State.Target = target end
		else
			State.Target = target
		end
		AimAtTarget(State.Target)
	else
		State.Target = nil
	end

	if Config.SpinBot then
		local char = LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if root then
			State.SpinAngle += Config.SpinSpeed * dt
			root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(State.SpinAngle), 0)
		end
	end

	if Config.MiniGPS then
		GPSFrame.Visible = true
		local myChar = LocalPlayer.Character
		local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
		local gpsTarget = State.Target or FindTarget()
		if gpsTarget and myRoot then
			local tRoot = gpsTarget.Character and gpsTarget.Character:FindFirstChild("HumanoidRootPart")
			if tRoot then
				local dist = (myRoot.Position - tRoot.Position).Magnitude
				local dir = (tRoot.Position - myRoot.Position).Unit
				local look = myRoot.CFrame.LookVector
				local angle = math.atan2(dir.X * look.Z - dir.Z * look.X, dir.X * look.X + dir.Z * look.Z)
				GPSArrow.Rotation = -math.deg(angle)
				GPSDist.Text = math.floor(dist) .. "m"
				GPSName.Text = gpsTarget.DisplayName
			end
		end
	else
		GPSFrame.Visible = false
	end

	pcall(function() Camera.FieldOfView = Config.FOV end)
	status:SetText("K: " .. State.Kills .. " | S: " .. State.Streak)
end)

StarterGui:SetCore("SendNotification", {
	Title = "Shadow Hub",
	Text = "Pronto! RightCtrl para abrir",
	Duration = 3,
})
print("[Shadow Hub V2] Ready!")
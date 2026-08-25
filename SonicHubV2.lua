-- Shadow Hub V2 - Main Script
-- Requires ShadowHubLibrary.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Load Library
local ShadowHub = require(game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ShadowHubLibrary"))
-- Or if in workspace: local ShadowHub = require(script:WaitForChild("ShadowHubLibrary"))

-- Config
local Config = {
	ESP = false, AimAssist = false, TargetLock = false,
	WallCheck = true, FFAMode = false, AimSmoothness = 0.08,
	MaxDistance = 500, TargetPart = "Head", KillNotify = true,
	MiniGPS = false, Crosshair = false, CrossStyle = "Cross",
	CrossSize = 4, CrossGap = 3, CrossColor = Color3.fromRGB(255, 255, 255),
	Noclip = false, Fullbright = false, FOV = 70,
	SpeedBoost = false, SpinBot = false, SpinSpeed = 30,
	HitSound = true, ESPBox = true, ESPTracer = true,
	ESPDot = true, AutoHeadshot = false,
}

local State = {
	Target = nil, ESP = {}, Kills = 0, LastHP = {},
	Streak = 0, NoclipParts = {}, SpinAngle = 0,
}

local Theme = ShadowHub.Theme
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ShadowESP"
ESPFolder.Parent = ShadowHub:GetGui()

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function IsColorClose(a, b, tol)
	tol = tol or 0.25
	return math.abs(a.R - b.R) < tol and math.abs(a.G - b.G) < tol and math.abs(a.B - b.B) < tol
end

local function GetDistance(player)
	local char = LocalPlayer.Character
	local myRoot = char and char:FindFirstChild("HumanoidRootPart")
	local tChar = player.Character
	local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
	if myRoot and tRoot then return (myRoot.Position - tRoot.Position).Magnitude end
	return 9999
end

local function IsEnemy(player)
	if Config.FFAMode then return true end
	if player == LocalPlayer then return false end
	local char = player.Character
	if not char then return false end

	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("Highlight") and v.OutlineColor then
			if IsColorClose(v.OutlineColor, Color3.fromRGB(255, 0, 0)) then return true end
			if IsColorClose(v.OutlineColor, Color3.fromRGB(0, 255, 100)) then return false end
		end
	end
	return false
end

local function HasLineOfSight(target)
	local char = target.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not root or not myRoot then return false end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {LocalPlayer.Character, target.Character}
	local result = Workspace:Raycast(myRoot.Position, (root.Position - myRoot.Position), params)
	return result == nil
end

local function FindTarget()
	local best, bestScore
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and IsEnemy(p) then
			local char = p.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if hum and root and hum.Health > 0 then
				local dist = GetDistance(p)
				if dist <= Config.MaxDistance then
					local onScreen = Camera:WorldToViewportPoint(root.Position)
					local score = (1 / math.max(dist, 1)) * (onScreen and 1 or 0.3) * (hum.Health / hum.MaxHealth)
					if not bestScore or score > bestScore then
						best = p bestScore = score
					end
				end
			end
		end
	end
	return best
end

local function IsValidTarget(target)
	if not target then return false end
	local char = target.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	return hum and root and hum.Health > 0 and IsEnemy(target)
end

local function AimAtTarget(target)
	if not target or not IsValidTarget(target) then return end
	if Config.WallCheck and not HasLineOfSight(target) then return end
	local partName = Config.AutoHeadshot and "Head" or Config.TargetPart
	local part = target.Character:FindFirstChild(partName)
	if not part then return end
	Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, part.Position), Config.AimSmoothness)
end

-- ============================================
-- NOTIFICATIONS
-- ============================================

local KillFrame = Instance.new("Frame")
KillFrame.Size = UDim2.new(0.6, 0, 0, 80)
KillFrame.Position = UDim2.new(0.2, 0, 0, 6)
KillFrame.BackgroundTransparency = 1
KillFrame.Parent = ShadowHub:GetGui()
Instance.new("UIListLayout", KillFrame).Padding = UDim.new(0, 4)
Instance.new("UIListLayout", KillFrame).SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIListLayout", KillFrame).VerticalAlignment = Enum.VerticalAlignment.Top

local function ShowKillNotification(targetName, isStreak)
	if not Config.KillNotify then return end
	local streakText = ""
	local color = Color3.fromRGB(255, 70, 70)
	local bgColor = Color3.fromRGB(25, 5, 5)
	if isStreak and State.Streak >= 3 then
		streakText = " [" .. State.Streak .. "x STREAK!]"
		color = Theme.Yellow bgColor = Color3.fromRGB(30, 25, 5)
	end

	if Config.HitSound then
		pcall(function()
			local sound = Instance.new("Sound")
			sound.SoundId = State.Streak >= 5 and "rbxassetid://642890855" or "rbxassetid://5765660795"
			sound.Volume = State.Streak >= 5 and 0.8 or 0.5
			sound.PlaybackSpeed = State.Streak >= 10 and 1.5 or 1
			sound.Parent = Camera
			sound:Play()
			game:GetService("Debris"):AddItem(sound, 2)
		end)
	end

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.8, 0, 0, 0)
	label.BackgroundColor3 = bgColor
	label.BackgroundTransparency = 0.05
	label.BorderSizePixel = 0
	label.Text = "KILL: " .. string.upper(targetName) .. streakText
	label.TextColor3 = color
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.fromRGB(80, 0, 0)
	label.Font = Enum.Font.GothamBlack
	label.TextSize = 15
	label.LayoutOrder = -tick()
	label.Parent = KillFrame
	Instance.new("UICorner", label).CornerRadius = UDim.new(0, 6)

	TweenService:Create(label, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0.8, 0, 0, 34)}):Play()
	task.delay(3.5, function()
		TweenService:Create(label, TweenInfo.new(0.5), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
		task.wait(0.5) pcall(function() label:Destroy() end)
	end)
end

local function ShowNotification(text, color)
	color = color or Theme.Accent
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 0, 0)
	label.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	label.BackgroundTransparency = 0.1
	label.BorderSizePixel = 0
	label.Text = text
	label.TextColor3 = color
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.GothamBold
	label.TextSize = 12
	label.LayoutOrder = -tick() - 1
	label.Parent = KillFrame
	Instance.new("UICorner", label).CornerRadius = UDim.new(0, 5)

	TweenService:Create(label, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0.6, 0, 0, 28)}):Play()
	task.delay(2.5, function()
		TweenService:Create(label, TweenInfo.new(0.4), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
		task.wait(0.4) pcall(function() label:Destroy() end)
	end)
end

-- ============================================
-- ESP SYSTEM
-- ============================================

local function RemoveESP(player)
	local data = State.ESP[player]
	if data then
		for _, obj in pairs(data) do
			if typeof(obj) == "Instance" then pcall(function() obj:Destroy() end) end
		end
	end
	State.ESP[player] = nil
end

local function CreateESP(player)
	if player == LocalPlayer then return end
	if State.ESP[player] then return end
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end

	local data = {}
	data.Highlight = Instance.new("Highlight")
	data.Highlight.Adornee = char
	data.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	data.Highlight.FillTransparency = 0.85
	data.Highlight.OutlineTransparency = 0
	data.Highlight.FillColor = Color3.fromRGB(255, 0, 0)
	data.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	data.Highlight.Parent = ESPFolder

	data.Billboard = Instance.new("BillboardGui")
	data.Billboard.Adornee = root
	data.Billboard.Size = UDim2.fromOffset(100, 50)
	data.Billboard.StudsOffset = Vector3.new(3, 0.5, 0)
	data.Billboard.AlwaysOnTop = true
	data.Billboard.MaxDistance = Config.MaxDistance
	data.Billboard.Parent = ESPFolder

	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 1, 0)
	card.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
	card.BackgroundTransparency = 0.88
	card.BorderSizePixel = 0
	card.Parent = data.Billboard
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 5)
	local stroke = Instance.new("UIStroke", card)
	stroke.Color = Color3.fromRGB(255, 0, 0)
	stroke.Thickness = 1
	stroke.Transparency = 0.7

	data.NameLabel = Instance.new("TextLabel")
	data.NameLabel.Size = UDim2.new(1, -8, 0, 14)
	data.NameLabel.Position = UDim2.fromOffset(4, 2)
	data.NameLabel.BackgroundTransparency = 1
	data.NameLabel.Text = player.DisplayName
	data.NameLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
	data.NameLabel.TextStrokeTransparency = 0
	data.NameLabel.Font = Enum.Font.GothamBold
	data.NameLabel.TextSize = 10
	data.NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	data.NameLabel.Parent = card

	data.InfoLabel = Instance.new("TextLabel")
	data.InfoLabel.Size = UDim2.new(1, -8, 0, 11)
	data.InfoLabel.Position = UDim2.fromOffset(4, 16)
	data.InfoLabel.BackgroundTransparency = 1
	data.InfoLabel.Text = "0m | 100hp"
	data.InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
	data.InfoLabel.TextStrokeTransparency = 0
	data.InfoLabel.Font = Enum.Font.Gotham
	data.InfoLabel.TextSize = 8
	data.InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
	data.InfoLabel.Parent = card

	local hpBG = Instance.new("Frame")
	hpBG.Size = UDim2.new(1, -8, 0, 4)
	hpBG.Position = UDim2.fromOffset(4, 29)
	hpBG.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	hpBG.BackgroundTransparency = 0.5
	hpBG.BorderSizePixel = 0
	hpBG.Parent = card
	Instance.new("UICorner", hpBG).CornerRadius = UDim.new(0, 2)

	data.HPBar = Instance.new("Frame")
	data.HPBar.Size = UDim2.new(1, 0, 1, 0)
	data.HPBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	data.HPBar.BorderSizePixel = 0
	data.HPBar.Parent = hpBG
	Instance.new("UICorner", data.HPBar).CornerRadius = UDim.new(0, 2)

	data.StatusLabel = Instance.new("TextLabel")
	data.StatusLabel.Size = UDim2.new(1, -8, 0, 9)
	data.StatusLabel.Position = UDim2.fromOffset(4, 35)
	data.StatusLabel.BackgroundTransparency = 1
	data.StatusLabel.Text = ""
	data.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	data.StatusLabel.TextStrokeTransparency = 0
	data.StatusLabel.Font = Enum.Font.GothamBold
	data.StatusLabel.TextSize = 7
	data.StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
	data.StatusLabel.Parent = card

	data.Box = Instance.new("BoxHandleAdornment")
	data.Box.Adornee = root
	data.Box.Size = Vector3.new(3, 5, 2)
	data.Box.Color3 = Color3.fromRGB(255, 0, 0)
	data.Box.Transparency = 0.55
	data.Box.AlwaysOnTop = true
	data.Box.ZIndex = 5
	data.Box.Parent = ESPFolder

	data.Tracer = Instance.new("Frame")
	data.Tracer.AnchorPoint = Vector2.new(0.5, 0.5)
	data.Tracer.BorderSizePixel = 0
	data.Tracer.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	data.Tracer.BackgroundTransparency = 0.15
	data.Tracer.Visible = false
	data.Tracer.Parent = ESPFolder

	data.Dot = Instance.new("Frame")
	data.Dot.AnchorPoint = Vector2.new(0.5, 0.5)
	data.Dot.Size = UDim2.fromOffset(6, 6)
	data.Dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	data.Dot.BorderSizePixel = 0
	data.Dot.Visible = false
	data.Dot.Parent = ESPFolder
	Instance.new("UICorner", data.Dot).CornerRadius = UDim.new(1, 0)

	State.ESP[player] = data
end

local function HideAll(data)
	if not data then return end
	pcall(function()
		if data.Billboard then data.Billboard.Enabled = false end
		if data.Highlight then data.Highlight.Enabled = false end
		if data.Box then data.Box.Visible = false end
		if data.Tracer then data.Tracer.Visible = false end
		if data.Dot then data.Dot.Visible = false end
	end)
end

local function UpdateSingleESP(player)
	if player == LocalPlayer then return end
	local data = State.ESP[player]
	if not data then CreateESP(player) data = State.ESP[player] end
	if not data then return end
	if not Config.ESP then HideAll(data) return end

	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not char or not hum or not root or hum.Health <= 0 then RemoveESP(player) return end
	if not IsEnemy(player) then HideAll(data) return end
	local dist = GetDistance(player)
	if dist > Config.MaxDistance then HideAll(data) return end

	if data.Billboard then data.Billboard.Enabled = true end
	if data.Highlight then data.Highlight.Enabled = true data.Highlight.Adornee = char end
	if data.Box then data.Box.Visible = Config.ESPBox data.Box.Adornee = root end

	local hpPct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
	if data.InfoLabel then
		data.InfoLabel.Text = math.floor(dist) .. "m | " .. math.floor(hum.Health) .. "hp"
		if hpPct > 0.6 then data.InfoLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
		elseif hpPct > 0.3 then data.InfoLabel.TextColor3 = Theme.Yellow
		else data.InfoLabel.TextColor3 = Theme.Red end
	end
	if data.HPBar then
		TweenService:Create(data.HPBar, TweenInfo.new(0.12), {Size = UDim2.new(hpPct, 0, 1, 0)}):Play()
		if hpPct > 0.6 then data.HPBar.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
		elseif hpPct > 0.3 then data.HPBar.BackgroundColor3 = Theme.Yellow
		else data.HPBar.BackgroundColor3 = Theme.Red end
	end
	if data.StatusLabel then
		if hpPct <= 0 then data.StatusLabel.Text = "MORTO" data.StatusLabel.TextColor3 = Theme.Red
		elseif hpPct < 0.3 then data.StatusLabel.Text = "LOW HP" data.StatusLabel.TextColor3 = Theme.Yellow
		else data.StatusLabel.Text = "" end
	end

	local sp, onScreen = Camera:WorldToViewportPoint(root.Position)
	if onScreen then
		local s = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
		local e = Vector2.new(sp.X, sp.Y)
		local d = e - s
		if data.Tracer then
			data.Tracer.Position = UDim2.fromOffset((s.X + e.X) / 2, (s.Y + e.Y) / 2)
			data.Tracer.Size = UDim2.fromOffset(2, d.Magnitude)
			data.Tracer.Rotation = math.deg(math.atan2(d.Y, d.X)) + 90
			data.Tracer.Visible = Config.ESPTracer
		end
		if data.Dot then
			data.Dot.Position = UDim2.fromOffset(sp.X, sp.Y)
			data.Dot.Visible = Config.ESPDot
		end
	else
		if data.Tracer then data.Tracer.Visible = false end
		if data.Dot then data.Dot.Visible = false end
	end
end

local function UpdateAllESP()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			if Config.ESP then UpdateSingleESP(p)
			elseif State.ESP[p] then RemoveESP(p) end
		end
	end
end

-- ============================================
-- CROSSHAIR
-- ============================================

local CrosshairFrame = Instance.new("Frame")
CrosshairFrame.Size = UDim2.new(0, 30, 0, 30)
CrosshairFrame.Position = UDim2.new(0.5, -15, 0.5, -15)
CrosshairFrame.BackgroundTransparency = 1
CrosshairFrame.Visible = false
CrosshairFrame.Parent = ShadowHub:GetGui()

local CrossTop = Instance.new("Frame")
CrossTop.Size = UDim2.new(0, 2, 0, 10)
CrossTop.Position = UDim2.new(0.5, -1, 0, 0)
CrossTop.BackgroundColor3 = Config.CrossColor
CrossTop.BorderSizePixel = 0
CrossTop.Parent = CrosshairFrame

local CrossBot = Instance.new("Frame")
CrossBot.Size = UDim2.new(0, 2, 0, 10)
CrossBot.Position = UDim2.new(0.5, -1, 1, -10)
CrossBot.BackgroundColor3 = Config.CrossColor
CrossBot.BorderSizePixel = 0
CrossBot.Parent = CrosshairFrame

local CrossLeft = Instance.new("Frame")
CrossLeft.Size = UDim2.new(0, 10, 0, 2)
CrossLeft.Position = UDim2.new(0, 0, 0.5, -1)
CrossLeft.BackgroundColor3 = Config.CrossColor
CrossLeft.BorderSizePixel = 0
CrossLeft.Parent = CrosshairFrame

local CrossRight = Instance.new("Frame")
CrossRight.Size = UDim2.new(0, 10, 0, 2)
CrossRight.Position = UDim2.new(1, -10, 0.5, -1)
CrossRight.BackgroundColor3 = Config.CrossColor
CrossRight.BorderSizePixel = 0
CrossRight.Parent = CrosshairFrame

local CrossDot = Instance.new("Frame")
CrossDot.Size = UDim2.fromOffset(4, 4)
CrossDot.Position = UDim2.new(0.5, -2, 0.5, -2)
CrossDot.BackgroundColor3 = Config.CrossColor
CrossDot.BorderSizePixel = 0
CrossDot.Parent = CrosshairFrame
Instance.new("UICorner", CrossDot).CornerRadius = UDim.new(1, 0)

local CrossCircle = Instance.new("Frame")
CrossCircle.Size = UDim2.fromOffset(20, 20)
CrossCircle.Position = UDim2.new(0.5, -10, 0.5, -10)
CrossCircle.BackgroundTransparency = 1
CrossCircle.BorderSizePixel = 0
CrossCircle.Parent = CrosshairFrame
local CrossCircleStroke = Instance.new("UIStroke")
CrossCircleStroke.Color = Config.CrossColor
CrossCircleStroke.Thickness = 1.5
CrossCircleStroke.Parent = CrossCircle

local CrossGlow = Instance.new("Frame")
CrossGlow.Size = UDim2.fromOffset(6, 6)
CrossGlow.Position = UDim2.new(0.5, -3, 0.5, -3)
CrossGlow.BackgroundColor3 = Config.CrossColor
CrossGlow.BackgroundTransparency = 0.6
CrossGlow.BorderSizePixel = 0
CrossGlow.ZIndex = -1
CrossGlow.Parent = CrosshairFrame
Instance.new("UICorner", CrossGlow).CornerRadius = UDim.new(1, 0)

local function UpdateCrosshairStyle()
	local s = Config.CrossSize
	local g = Config.CrossGap
	local c = Config.CrossColor

	CrossTop.Size = UDim2.new(0, 2, 0, s)
	CrossTop.Position = UDim2.new(0.5, -1, 0.5, -(s + g))
	CrossTop.BackgroundColor3 = c

	CrossBot.Size = UDim2.new(0, 2, 0, s)
	CrossBot.Position = UDim2.new(0.5, -1, 0.5, g)
	CrossBot.BackgroundColor3 = c

	CrossLeft.Size = UDim2.new(0, s, 0, 2)
	CrossLeft.Position = UDim2.new(0.5, -(s + g), 0.5, -1)
	CrossLeft.BackgroundColor3 = c

	CrossRight.Size = UDim2.new(0, s, 0, 2)
	CrossRight.Position = UDim2.new(0.5, g, 0.5, -1)
	CrossRight.BackgroundColor3 = c

	CrossDot.Size = UDim2.fromOffset(4, 4)
	CrossDot.BackgroundColor3 = c
	CrossCircleStroke.Color = c
	CrossGlow.BackgroundColor3 = c

	CrossTop.Visible = (Config.CrossStyle == "Cross")
	CrossBot.Visible = (Config.CrossStyle == "Cross")
	CrossLeft.Visible = (Config.CrossStyle == "Cross")
	CrossRight.Visible = (Config.CrossStyle == "Cross")
	CrossDot.Visible = (Config.CrossStyle == "Dot" or Config.CrossStyle == "Cross" or Config.CrossStyle == "Diamond")
	CrossCircle.Visible = (Config.CrossStyle == "Circle")
	CrossGlow.Visible = true

	if Config.CrossStyle == "Diamond" then
		CrossDot.Size = UDim2.fromOffset(8, 8)
		CrossDot.Rotation = 45
	else
		CrossDot.Rotation = 0
	end
end

-- ============================================
-- GPS
-- ============================================

local GPSFrame = Instance.new("Frame")
GPSFrame.Size = UDim2.fromOffset(160, 100)
GPSFrame.Position = UDim2.new(1, -175, 0, 15)
GPSFrame.BackgroundColor3 = Theme.Panel
GPSFrame.BackgroundTransparency = 0.85
GPSFrame.BorderSizePixel = 0
GPSFrame.Visible = false
GPSFrame.Parent = ShadowHub:GetGui()
Instance.new("UICorner", GPSFrame).CornerRadius = UDim.new(0, 70)
local gpsStroke = Instance.new("UIStroke")
gpsStroke.Color = Theme.Accent
gpsStroke.Thickness = 2
gpsStroke.Transparency = 0.5
gpsStroke.Parent = GPSFrame

local GPSArrow = Instance.new("TextLabel")
GPSArrow.Size = UDim2.fromOffset(40, 40)
GPSArrow.Position = UDim2.new(0.5, -20, 0.5, -30)
GPSArrow.BackgroundTransparency = 1
GPSArrow.Text = "\226\136\128"
GPSArrow.TextColor3 = Theme.Green
GPSArrow.TextStrokeTransparency = 0
GPSArrow.Font = Enum.Font.GothamBlack
GPSArrow.TextSize = 28
GPSArrow.Rotation = 0
GPSArrow.Parent = GPSFrame

local GPSDistance = Instance.new("TextLabel")
GPSDistance.Size = UDim2.new(1, 0, 0, 16)
GPSDistance.Position = UDim2.new(0, 0, 0.65, 0)
GPSDistance.BackgroundTransparency = 1
GPSDistance.Text = "--"
GPSDistance.TextColor3 = Theme.Accent
GPSDistance.TextStrokeTransparency = 0
GPSDistance.Font = Enum.Font.GothamBold
GPSDistance.TextSize = 12
GPSDistance.Parent = GPSFrame

local GPSStatus = Instance.new("TextLabel")
GPSStatus.Size = UDim2.new(1, 0, 0, 12)
GPSStatus.Position = UDim2.new(0, 0, 0.8, 0)
GPSStatus.BackgroundTransparency = 1
GPSStatus.Text = ""
GPSStatus.TextColor3 = Theme.Sub
GPSStatus.TextStrokeTransparency = 0
GPSStatus.Font = Enum.Font.Gotham
GPSStatus.TextSize = 8
GPSStatus.Parent = GPSFrame

local GPSName = Instance.new("TextLabel")
GPSName.Size = UDim2.new(1, 0, 0, 12)
GPSName.Position = UDim2.new(0, 0, 0.5, 0)
GPSName.BackgroundTransparency = 1
GPSName.Text = "procurando"
GPSName.TextColor3 = Theme.Text
GPSName.TextStrokeTransparency = 0
GPSName.Font = Enum.Font.GothamMedium
GPSName.TextSize = 9
GPSName.Parent = GPSFrame

-- ============================================
-- LOGIC FUNCTIONS
-- ============================================

local function SetNoclip(on)
	Config.Noclip = on
	if not on then
		for _, part in pairs(State.NoclipParts) do
			if part and part:IsA("BasePart") then part.CanCollide = true end
		end
		State.NoclipParts = {}
	end
end

RunService.Stepped:Connect(function()
	if Config.Noclip then
		local char = LocalPlayer.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
					table.insert(State.NoclipParts, part)
				end
			end
		end
	end
end)

local function SetFullbright(on)
	Config.Fullbright = on
	if on then
		State.OrigBrightness = Lighting.Brightness
		State.OrigAmbient = Lighting.Ambient
		State.OrigOutdoorAmbient = Lighting.OutdoorAmbient
		State.OrigFogEnd = Lighting.FogEnd
		Lighting.Brightness = 2
		Lighting.Ambient = Color3.fromRGB(178, 178, 178)
		Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
		Lighting.FogEnd = 100000
		for _, v in ipairs(Lighting:GetDescendants()) do
			if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
				v.Enabled = false
			end
		end
	else
		Lighting.Brightness = State.OrigBrightness or 1
		Lighting.Ambient = State.OrigAmbient or Color3.fromRGB(70, 70, 70)
		Lighting.OutdoorAmbient = State.OrigOutdoorAmbient or Color3.fromRGB(128, 128, 128)
		Lighting.FogEnd = State.OrigFogEnd or 100000
		for _, v in ipairs(Lighting:GetDescendants()) do
			if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
				v.Enabled = true
			end
		end
	end
end

local function SetFOV(val)
	Config.FOV = val
	Camera.FieldOfView = val
end

local function SetSpeed(on)
	Config.SpeedBoost = on
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = on and 32 or 16 end
end

local function TeleportToEnemy()
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local best, bestDist
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and IsEnemy(p) then
			local tChar = p.Character
			local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
			local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
			if tRoot and tHum and tHum.Health > 0 then
				local d = (root.Position - tRoot.Position).Magnitude
				if d < Config.MaxDistance and (not bestDist or d < bestDist) then
					best = p bestDist = d
				end
			end
		end
	end
	if best and best.Character and best.Character:FindFirstChild("HumanoidRootPart") then
		root.CFrame = best.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -4)
		ShowNotification("Teleport: " .. best.DisplayName, Theme.Accent)
	end
end

-- ============================================
-- PLAYER MONITOR
-- ============================================

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
				if IsEnemy(player) then
					local dist = GetDistance(player)
					local wasTarget = (State.Target == player)
					local wasClose = (dist < 80)
					if wasTarget or wasClose then
						State.Kills += 1
						State.Streak += 1
						ShowKillNotification(player.DisplayName, true)
						if State.Target == player then State.Target = nil end
						if State.Streak == 3 then ShowNotification("3x STREAK!", Theme.Yellow) end
						if State.Streak == 5 then ShowNotification("5x STREAK!", Color3.fromRGB(255, 100, 0)) end
						if State.Streak == 10 then ShowNotification("10x UNSTOPPABLE!", Color3.fromRGB(255, 0, 255)) end
					end
				end
			end
			if player == LocalPlayer and newHP > 0 and newHP < 30 and oldHP >= 30 then
				ShowNotification("HP BAIXO!", Theme.Red)
			end
		end)
	end

	if player.Character then task.spawn(onCharacter, player.Character) end
	player.CharacterAdded:Connect(function(char)
		task.wait(0.5) onCharacter(char)
		task.wait(0.3) RemoveESP(player)
		if Config.ESP then CreateESP(player) end
	end)
end

for _, p in ipairs(Players:GetPlayers()) do MonitorPlayer(p) end
Players.PlayerAdded:Connect(function(p) MonitorPlayer(p) end)

LocalPlayer.CharacterAdded:Connect(function(char)
	State.Streak = 0
	local hum = char:WaitForChild("Humanoid", 10)
	if hum then hum.Died:Connect(function() State.Streak = 0 ShowNotification("Voce morreu!", Theme.Red) end) end
	if Config.Noclip then SetNoclip(true) end
	if Config.SpeedBoost then
		local h = char:WaitForChild("Humanoid", 5)
		if h then h.WalkSpeed = 32 end
	end
end)

-- ============================================
-- BUILD MENU
-- ============================================

local menu = ShadowHub:CreateWindow("Shadow Hub")

-- COMBATE
local s1 = menu:Section("Combate")
menu:Toggle(s1, "ESP", false, function(v) Config.ESP = v if not v then for pp in pairs(State.ESP) do RemoveESP(pp) end end end)
menu:Toggle(s1, "  Box", true, function(v) Config.ESPBox = v end)
menu:Toggle(s1, "  Tracer", true, function(v) Config.ESPTracer = v end)
menu:Toggle(s1, "  Dot", true, function(v) Config.ESPDot = v end)
menu:Toggle(s1, "Aim Assist", false, function(v) Config.AimAssist = v end)
menu:Toggle(s1, "Target Lock", false, function(v) Config.TargetLock = v if v then State.Target = FindTarget() else State.Target = nil end end)
menu:Toggle(s1, "Auto Headshot", false, function(v) Config.AutoHeadshot = v end)
menu:Slider(s1, "Aim Smoothness", 0.01, 0.5, 0.08, function(v) Config.AimSmoothness = v end)
menu:Slider(s1, "Max Distance", 50, 2000, 500, function(v) Config.MaxDistance = v end)

-- CROSSHAIR
local s2 = menu:Section("Crosshair")
menu:Toggle(s2, "Crosshair", false, function(v) Config.Crosshair = v CrosshairFrame.Visible = v end)
menu:Label(s2, "Estilo")
do
	local styles = {"Cross", "Dot", "Circle", "Diamond"}
	local current = 1
	menu:Button(s2, "Estilo: Cross", function()
		current = current % #styles + 1
		Config.CrossStyle = styles[current]
		UpdateCrosshairStyle()
	end)
end
menu:Slider(s2, "Tamanho", 2, 15, 4, function(v) Config.CrossSize = v UpdateCrosshairStyle() end)
menu:Slider(s2, "Gap", 1, 15, 3, function(v) Config.CrossGap = v UpdateCrosshairStyle() end)
menu:ColorRow(s2, "Cor", Config.CrossColor, function(c) Config.CrossColor = c UpdateCrosshairStyle() end)

-- UTILIDADES
local s3 = menu:Section("Utilidades")
menu:Toggle(s3, "Mini GPS", false, function(v) Config.MiniGPS = v GPSFrame.Visible = v end)
menu:Toggle(s3, "Kill Notification", true, function(v) Config.KillNotify = v end)
menu:Toggle(s3, "Hit Sound", true, function(v) Config.HitSound = v end)
menu:Toggle(s3, "FFA Mode", false, function(v) Config.FFAMode = v end)
menu:Toggle(s3, "Wall Check", true, function(v) Config.WallCheck = v end)
menu:Button(s3, "Teleport to Enemy", TeleportToEnemy)

-- EXPLOITS
local s4 = menu:Section("Exploits")
menu:Toggle(s4, "Noclip", false, function(v) SetNoclip(v) end)
menu:Toggle(s4, "Fullbright", false, function(v) SetFullbright(v) end)
menu:Toggle(s4, "Speed Boost", false, function(v) SetSpeed(v) end)
menu:Toggle(s4, "Spin Bot", false, function(v) Config.SpinBot = v State.SpinAngle = 0 end)
menu:Slider(s4, "Spin Speed", 5, 120, 30, function(v) Config.SpinSpeed = v end)
menu:Slider(s4, "FOV", 30, 120, 70, function(v) SetFOV(v) end)

-- Status
local status = menu:StatusBar("Kills: 0 | Streak: 0")

-- ============================================
-- MAIN LOOP
-- ============================================

local glowT = 0

RunService.RenderStepped:Connect(function(dt)
	UpdateAllESP()

	-- Aim
	if Config.AimAssist then
		if Config.TargetLock then
			if not IsValidTarget(State.Target) then State.Target = FindTarget() end
		else
			State.Target = FindTarget()
		end
		AimAtTarget(State.Target)
	else
		State.Target = nil
	end

	-- Crosshair glow pulse
	if Config.Crosshair then
		glowT += dt * 3
		local pulse = math.sin(glowT) * 0.3 + 0.5
		CrossGlow.Transparency = 0.4 + pulse * 0.4
		CrossCircleStroke.Transparency = 0.1 + pulse * 0.3
	end

	-- Spin Bot
	if Config.SpinBot then
		local char = LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if root then
			State.SpinAngle += Config.SpinSpeed * dt
			root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(State.SpinAngle), 0)
		end
	end

	-- GPS
	if Config.MiniGPS then
		GPSFrame.Visible = true
		local myChar = LocalPlayer.Character
		local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
		local gpsTarget = State.Target or FindTarget()
		if gpsTarget and myRoot then
			local tRoot = gpsTarget.Character and gpsTarget.Character:FindFirstChild("HumanoidRootPart")
			local tHum = gpsTarget.Character and gpsTarget.Character:FindFirstChildOfClass("Humanoid")
			if tRoot and tHum and tHum.Health > 0 then
				local dist = (myRoot.Position - tRoot.Position).Magnitude
				local dir = (tRoot.Position - myRoot.Position).Unit
				local myLook = myRoot.CFrame.LookVector
				local angle = math.atan2(dir.X * myLook.Z - dir.Z * myLook.X, dir.X * myLook.X + dir.Z * myLook.Z)
				GPSArrow.Rotation = -math.deg(angle)
				GPSDistance.Text = math.floor(dist) .. "m"
				GPSName.Text = gpsTarget.DisplayName
				local hasWall = Config.WallCheck and not HasLineOfSight(gpsTarget)
				if hasWall then
					GPSStatus.Text = "paredes"
					GPSStatus.TextColor3 = Theme.Yellow
					GPSArrow.TextColor3 = Theme.Yellow
				else
					GPSStatus.Text = "rota limpa"
					GPSStatus.TextColor3 = Theme.Green
					GPSArrow.TextColor3 = Theme.Green
				end
				if dist > 200 then GPSDistance.TextColor3 = Theme.Sub
				elseif dist > 100 then GPSDistance.TextColor3 = Theme.Yellow
				else GPSDistance.TextColor3 = Theme.Green end
			else
				GPSName.Text = "..."
				GPSArrow.Rotation = 0
				GPSArrow.TextColor3 = Theme.Sub
				GPSDistance.Text = "--"
				GPSStatus.Text = "aguardando"
			end
		else
			GPSName.Text = "procurando"
			GPSArrow.Rotation = 0
			GPSArrow.TextColor3 = Theme.Sub
			GPSDistance.Text = "--"
			GPSStatus.Text = "nenhum alvo"
			GPSStatus.TextColor3 = Theme.Sub
		end
	else
		GPSFrame.Visible = false
	end

	-- FOV
	if Config.FOV ~= Camera.FieldOfView then Camera.FieldOfView = Config.FOV end

	status:SetText("Kills: " .. State.Kills .. " | Streak: " .. State.Streak .. (Config.FFAMode and " | FFA" or ""))
end)

-- Cleanup
Players.PlayerRemoving:Connect(function(p)
	RemoveESP(p)
	if State.Target == p then State.Target = nil end
	State.LastHP[p] = nil
end)

StarterGui:SetCore("SendNotification", {Title = "SHADOW HUB V2", Text = "Pronto! RightCtrl = menu", Duration = 3})
print("[SHADOW HUB V2] Pronto!")

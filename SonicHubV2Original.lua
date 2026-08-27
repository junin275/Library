-- Shadow Hub V2 - Premium Design Version
local ShadowHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/junin275/Library/main/ShadowHubLibrary.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

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

-- COLORS
local C = {
	Enemy = Color3.fromRGB(255, 45, 45),
	EnemyBright = Color3.fromRGB(255, 85, 85),
	EnemyDark = Color3.fromRGB(180, 25, 25),
	Ally = Color3.fromRGB(0, 170, 255),
	AllyBright = Color3.fromRGB(80, 200, 255),
	AllyDark = Color3.fromRGB(0, 100, 180),
	Accent = Color3.fromRGB(160, 80, 255),
	AccentBright = Color3.fromRGB(200, 140, 255),
	Green = Color3.fromRGB(50, 255, 120),
	Yellow = Color3.fromRGB(255, 220, 50),
	Red = Color3.fromRGB(255, 60, 60),
	Dark = Color3.fromRGB(12, 12, 20),
	Dark2 = Color3.fromRGB(20, 20, 32),
	Dark3 = Color3.fromRGB(30, 30, 48),
	Text = Color3.fromRGB(220, 220, 235),
	TextDim = Color3.fromRGB(140, 140, 160),
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

-- ESP PREMIUM
local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "E"
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
	bb.Name = "B"
	bb.Adornee = head
	bb.Size = UDim2.new(0, 180, 0, 65)
	bb.StudsOffset = Vector3.new(0, 3, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = Config.MaxDistance
	bb.Parent = ESPGui

	-- Glow (outer shadow)
	local glow = Instance.new("Frame", bb)
	glow.Name = "Glow"
	glow.Size = UDim2.new(1, 8, 1, 8)
	glow.Position = UDim2.new(0, -4, 0, -4)
	glow.BackgroundColor3 = c
	glow.BackgroundTransparency = 0.9
	glow.BorderSizePixel = 0
	glow.ZIndex = 0
	Instance.new("UICorner", glow).CornerRadius = UDim.new(0, 12)

	-- Main card
	local card = Instance.new("Frame", bb)
	card.Name = "Card"
	card.Size = UDim2.new(1, 0, 1, 0)
	card.BackgroundColor3 = C.Dark
	card.BackgroundTransparency = 0.55
	card.BorderSizePixel = 0
	card.ZIndex = 2
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
	Instance.new("UIStroke", card).Color = c
	Instance.new("UIStroke", card).Thickness = 1.5
	Instance.new("UIStroke", card).Transparency = 0.4

	-- Gradient overlay
	local grad = Instance.new("Frame", card)
	grad.Size = UDim2.new(1, 0, 0.5, 0)
	grad.BackgroundColor3 = Color3.new(1, 1, 1)
	grad.BackgroundTransparency = 0.92
	grad.BorderSizePixel = 0
	grad.ZIndex = 3

	-- Color bar (left accent)
	local bar = Instance.new("Frame", card)
	bar.Name = "Bar"
	bar.Size = UDim2.new(0, 4, 0.7, 0)
	bar.Position = UDim2.new(0, 6, 0.15, 0)
	bar.BackgroundColor3 = c
	bar.BorderSizePixel = 0
	bar.ZIndex = 4
	Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)

	-- Team badge
	local badge = Instance.new("Frame", card)
	badge.Size = UDim2.new(0, 44, 0, 13)
	badge.Position = UDim2.new(1, -50, 0, 5)
	badge.BackgroundColor3 = cD
	badge.BackgroundTransparency = 0.3
	badge.BorderSizePixel = 0
	badge.ZIndex = 4
	Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", badge).Color = c
	Instance.new("UIStroke", badge).Thickness = 1
	Instance.new("UIStroke", badge).Transparency = 0.5

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
	nameLabel.Size = UDim2.new(1, -60, 0, 16)
	nameLabel.Position = UDim2.new(0, 16, 0, 6)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = player.DisplayName
	nameLabel.TextColor3 = C.Text
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.ZIndex = 4

	-- Distance
	local distLabel = Instance.new("TextLabel", card)
	distLabel.Name = "Dist"
	distLabel.Size = UDim2.new(0, 50, 0, 12)
	distLabel.Position = UDim2.new(1, -55, 0, 20)
	distLabel.BackgroundTransparency = 1
	distLabel.Text = "0m"
	distLabel.TextColor3 = C.TextDim
	distLabel.TextStrokeTransparency = 0
	distLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	distLabel.Font = Enum.Font.GothamBold
	distLabel.TextSize = 10
	distLabel.TextXAlignment = Enum.TextXAlignment.Right
	distLabel.ZIndex = 4

	-- HP background
	local hpBG = Instance.new("Frame", card)
	hpBG.Size = UDim2.new(0.82, 0, 0, 7)
	hpBG.Position = UDim2.new(0.09, 0, 0, 28)
	hpBG.BackgroundColor3 = C.Dark3
	hpBG.BorderSizePixel = 0
	hpBG.ZIndex = 4
	Instance.new("UICorner", hpBG).CornerRadius = UDim.new(0, 4)

	-- HP fill
	local hpFill = Instance.new("Frame", hpBG)
	hpFill.Name = "Fill"
	hpFill.Size = UDim2.new(1, 0, 1, 0)
	hpFill.BackgroundColor3 = C.Green
	hpFill.BorderSizePixel = 0
	hpFill.ZIndex = 5
	Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0, 4)

	-- HP shine
	local hpShine = Instance.new("Frame", hpFill)
	hpShine.Size = UDim2.new(1, 0, 0.4, 0)
	hpShine.Position = UDim2.new(0, 0, 0, 0)
	hpShine.BackgroundColor3 = Color3.new(1, 1, 1)
	hpShine.BackgroundTransparency = 0.7
	hpShine.BorderSizePixel = 0
	hpShine.ZIndex = 6
	Instance.new("UICorner", hpShine).CornerRadius = UDim.new(0, 4)

	-- HP text
	local hpLabel = Instance.new("TextLabel", card)
	hpLabel.Name = "HP"
	hpLabel.Size = UDim2.new(0.82, 0, 0, 10)
	hpLabel.Position = UDim2.new(0.09, 0, 0, 37)
	hpLabel.BackgroundTransparency = 1
	hpLabel.Text = "100 HP"
	hpLabel.TextColor3 = C.TextDim
	hpLabel.TextStrokeTransparency = 0
	hpLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	hpLabel.Font = Enum.Font.Gotham
	hpLabel.TextSize = 9
	hpLabel.TextXAlignment = Enum.TextXAlignment.Left
	hpLabel.ZIndex = 4

	-- Status label
	local statusLabel = Instance.new("TextLabel", card)
	statusLabel.Name = "Status"
	statusLabel.Size = UDim2.new(0.82, 0, 0, 8)
	statusLabel.Position = UDim2.new(0.09, 0, 0, 48)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = ""
	statusLabel.TextColor3 = cB
	statusLabel.TextStrokeTransparency = 0
	statusLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	statusLabel.Font = Enum.Font.GothamBold
	statusLabel.TextSize = 8
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.ZIndex = 4

	-- Highlight
	local hl = Instance.new("Highlight")
	hl.Name = "H"
	hl.Adornee = char
	hl.FillColor = c
	hl.FillTransparency = 0.75
	hl.OutlineColor = cB
	hl.OutlineTransparency = 0.15
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = ESPGui

	-- Tracer
	local tracer = Instance.new("Frame", ESPGui)
	tracer.Name = "T"
	tracer.AnchorPoint = Vector2.new(0.5, 0.5)
	tracer.BackgroundColor3 = c
	tracer.BackgroundTransparency = 0.4
	tracer.BorderSizePixel = 0
	tracer.Visible = false

	-- Tracer gradient
	local tracerGrad = Instance.new("UIGradient", tracer)
	tracerGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(1, 0),
	})
	tracerGrad.Rotation = 90

	-- Dot
	local dot = Instance.new("Frame", ESPGui)
	dot.Name = "D"
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Size = UDim2.fromOffset(8, 8)
	dot.BackgroundColor3 = cB
	dot.BorderSizePixel = 0
	dot.Visible = false
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

	-- Dot glow
	local dotGlow = Instance.new("Frame", ESPGui)
	dotGlow.Name = "DG"
	dotGlow.AnchorPoint = Vector2.new(0.5, 0.5)
	dotGlow.Size = UDim2.fromOffset(14, 14)
	dotGlow.BackgroundColor3 = c
	dotGlow.BackgroundTransparency = 0.7
	dotGlow.BorderSizePixel = 0
	dotGlow.Visible = false
	Instance.new("UICorner", dotGlow).CornerRadius = UDim.new(1, 0)

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

-- GPS PREMIUM
local GPSFrame = Instance.new("Frame")
GPSFrame.Size = UDim2.new(0, 140, 0, 80)
GPSFrame.Position = UDim2.new(1, -155, 0, 15)
GPSFrame.BackgroundColor3 = C.Dark
GPSFrame.BackgroundTransparency = 0.2
GPSFrame.BorderSizePixel = 0
GPSFrame.Visible = false
GPSFrame.Parent = ESPGui
Instance.new("UICorner", GPSFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", GPSFrame).Color = C.Accent
Instance.new("UIStroke", GPSFrame).Thickness = 1.5
Instance.new("UIStroke", GPSFrame).Transparency = 0.3

-- GPS gradient
local gpsGrad = Instance.new("Frame", GPSFrame)
gpsGrad.Size = UDim2.new(1, 0, 0.4, 0)
gpsGrad.BackgroundColor3 = Color3.new(1, 1, 1)
gpsGrad.BackgroundTransparency = 0.92
gpsGrad.BorderSizePixel = 0

local GPSArrow = Instance.new("TextLabel", GPSFrame)
GPSArrow.Size = UDim2.new(1, 0, 0, 28)
GPSArrow.Position = UDim2.new(0, 0, 0, 6)
GPSArrow.BackgroundTransparency = 1
GPSArrow.Text = "\226\136\128"
GPSArrow.TextColor3 = C.Green
GPSArrow.TextStrokeTransparency = 0
GPSArrow.TextStrokeColor3 = Color3.new(0, 0, 0)
GPSArrow.Font = Enum.Font.GothamBlack
GPSArrow.TextSize = 22

local GPSDist = Instance.new("TextLabel", GPSFrame)
GPSDist.Size = UDim2.new(1, 0, 0, 16)
GPSDist.Position = UDim2.new(0, 0, 0, 36)
GPSDist.BackgroundTransparency = 1
GPSDist.Text = "--"
GPSDist.TextColor3 = C.AccentBright
GPSDist.TextStrokeTransparency = 0
GPSDist.TextStrokeColor3 = Color3.new(0, 0, 0)
GPSDist.Font = Enum.Font.GothamBold
GPSDist.TextSize = 12

local GPSName = Instance.new("TextLabel", GPSFrame)
GPSName.Size = UDim2.new(1, -10, 0, 14)
GPSName.Position = UDim2.new(0, 5, 0, 55)
GPSName.BackgroundTransparency = 1
GPSName.Text = "procurando..."
GPSName.TextColor3 = C.TextDim
GPSName.TextStrokeTransparency = 0
GPSName.TextStrokeColor3 = Color3.new(0, 0, 0)
GPSName.Font = Enum.Font.Gotham
GPSName.TextSize = 9
GPSName.TextTruncate = Enum.TextTruncate.AtEnd

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
local menu = ShadowHub:CreateWindow("SH")

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
	Title = "SH",
	Text = "Pronto!",
	Duration = 2,
})
print("[SH] Ready!")

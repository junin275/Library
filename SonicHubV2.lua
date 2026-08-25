-- Shadow Hub V2 - Main Script v3
local ShadowHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/junin275/Library/main/ShadowHubLibrary.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================
-- CONFIG
-- ============================================

local Config = {
	ESP = true,
	ESPBox = true,
	ESPTracer = true,
	ESPDot = true,
	ESPName = true,
	ESPDistance = true,
	ESPHealth = true,
	AimAssist = false,
	TargetLock = false,
	WallCheck = true,
	FFAMode = true,
	AimSmoothness = 3,
	MaxDistance = 2000,
	TargetPart = "Head",
	AutoHeadshot = false,
	KillNotify = true,
	MiniGPS = false,
	Crosshair = false,
	CrossStyle = "Cross",
	CrossSize = 4,
	CrossGap = 3,
	CrossColor = Color3.fromRGB(255, 255, 255),
	Noclip = false,
	Fullbright = false,
	SpeedBoost = false,
	SpinBot = false,
	SpinSpeed = 30,
	SpinAngle = 0,
	FOV = 70,
	HitSound = true,
}

local State = {
	ESP = {},
	Target = nil,
	Kills = 0,
	Streak = 0,
	LastHP = {},
}

-- ============================================
-- UTILITIES
-- ============================================

local function IsColorClose(a, b, tol)
	tol = tol or 0.15
	return math.abs(a.R - b.R) < tol and math.abs(a.G - b.G) < tol and math.abs(a.B - b.B) < tol
end

local function IsEnemy(player)
	if Config.FFAMode then return true end
	if player == LocalPlayer then return false end
	local char = player.Character
	if not char then return false end

	-- Highlights on character
	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("Highlight") and v.OutlineColor then
			if IsColorClose(v.OutlineColor, Color3.fromRGB(255, 0, 0), 0.3) then return true, Color3.fromRGB(255, 0, 0) end
			if IsColorClose(v.OutlineColor, Color3.fromRGB(0, 255, 100), 0.3) then return false, Color3.fromRGB(0, 255, 100) end
		end
	end
	-- Highlights in Workspace
	for _, v in ipairs(Workspace:GetDescendants()) do
		if v:IsA("Highlight") and v.Adornee and (v.Adornee == char or v.Adornee:IsDescendantOf(char)) and v.OutlineColor then
			if IsColorClose(v.OutlineColor, Color3.fromRGB(255, 0, 0), 0.3) then return true, Color3.fromRGB(255, 0, 0) end
			if IsColorClose(v.OutlineColor, Color3.fromRGB(0, 255, 100), 0.3) then return false, Color3.fromRGB(0, 255, 100) end
		end
	end
	return false, nil
end

local function GetDistance(player)
	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local tChar = player.Character
	local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
	if myRoot and tRoot then
		return (myRoot.Position - tRoot.Position).Magnitude
	end
	return 9999
end

local function HasLineOfSight(target)
	local tChar = target.Character
	local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not tRoot or not myRoot then return false end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {LocalPlayer.Character, target.Character}
	local result = Workspace:Raycast(myRoot.Position, (tRoot.Position - myRoot.Position), params)
	return result == nil
end

local function FindTarget()
	local best, bestScore = nil, 0
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and IsEnemy(p) then
			local char = p.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if hum and root and hum.Health > 0 then
				local dist = GetDistance(p)
				if dist <= Config.MaxDistance then
					local ok, vp = pcall(function()
						return Camera:WorldToViewportPoint(root.Position)
					end)
					if ok and vp and vp.Z > 0 then
						local score = (1 / math.max(dist, 1)) * 10
						if score > bestScore then
							best = p
							bestScore = score
						end
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
	return hum and root and hum.Health > 0
end

-- ============================================
-- AIMBOT (Camera CFrame style)
-- ============================================

local Aimbot = {
	Active = false,
	Smooth = 0.5,
}

-- Right mouse button = aim
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		Aimbot.Active = true
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		Aimbot.Active = false
	end
end)

local function AimAtTarget(target)
	if not target or not IsValidTarget(target) then return end
	if Config.WallCheck and not HasLineOfSight(target) then return end
	if not Aimbot.Active then return end

	local partName = Config.AutoHeadshot and "Head" or Config.TargetPart
	local part = target.Character:FindFirstChild(partName)
	if not part then return end

	local camPos = Camera.CFrame.Position
	local targetPos = part.Position

	-- Direct camera aim (like the reference script)
	Camera.CFrame = CFrame.new(camPos, targetPos)
end

-- ============================================
-- ESP - New Versatile Design
-- ============================================

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP_Folder"
ESPFolder.Parent = Camera

local ESP_COLORS = {
	Enemy = Color3.fromRGB(255, 50, 50),
	EnemyBright = Color3.fromRGB(255, 80, 80),
	EnemyDark = Color3.fromRGB(180, 30, 30),
	Ally = Color3.fromRGB(50, 180, 255),
	AllyBright = Color3.fromRGB(80, 200, 255),
	AllyDark = Color3.fromRGB(30, 120, 180),
	Neutral = Color3.fromRGB(200, 200, 200),
}

local function RemoveESP(player)
	local data = State.ESP[player]
	if data then
		pcall(function() data.Billboard:Destroy() end)
		pcall(function() data.Highlight:Destroy() end)
		pcall(function() data.Tracer:Destroy() end)
		pcall(function() data.Dot:Destroy() end)
		State.ESP[player] = nil
	end
end

local function HideESP(player)
	local data = State.ESP[player]
	if data then
		data.Billboard.Enabled = false
		data.Highlight.Enabled = false
		data.Tracer.Visible = false
		data.Dot.Visible = false
	end
end

local function ShowESP(player)
	local data = State.ESP[player]
	if data then
		data.Billboard.Enabled = true
		data.Highlight.Enabled = true
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

	local isEnemy, teamColor = IsEnemy(player)
	local c = isEnemy and ESP_COLORS.Enemy or (teamColor or ESP_COLORS.Ally)
	local cBright = isEnemy and ESP_COLORS.EnemyBright or ESP_COLORS.AllyBright
	local cDark = isEnemy and ESP_COLORS.EnemyDark or ESP_COLORS.AllyDark

	-- BillboardGui
	local bb = Instance.new("BillboardGui")
	bb.Name = "ESP_" .. player.Name
	bb.Adornee = head
	bb.Size = UDim2.new(0, 160, 0, 58)
	bb.StudsOffset = Vector3.new(0, 2.8, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = Config.MaxDistance
	bb.Parent = ESPFolder

	-- Background card (very transparent)
	local card = Instance.new("Frame", bb)
	card.Name = "Card"
	card.Size = UDim2.new(1, 0, 1, 0)
	card.BackgroundColor3 = Color3.fromRGB(5, 5, 12)
	card.BackgroundTransparency = 0.75
	card.BorderSizePixel = 0
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

	-- Left accent bar
	local accent = Instance.new("Frame", card)
	accent.Name = "Accent"
	accent.Size = UDim2.new(0, 3, 1, 0)
	accent.Position = UDim2.new(0, 0, 0, 0)
	accent.BackgroundColor3 = c
	accent.BorderSizePixel = 0

	-- Top accent line
	local topLine = Instance.new("Frame", card)
	topLine.Name = "TopLine"
	topLine.Size = UDim2.new(1, 0, 0, 1)
	topLine.Position = UDim2.new(0, 0, 0, 0)
	topLine.BackgroundColor3 = c
	topLine.BackgroundTransparency = 0.5
	topLine.BorderSizePixel = 0

	-- Team indicator pill
	local pill = Instance.new("Frame", card)
	pill.Name = "Pill"
	pill.Size = UDim2.new(0, 40, 0, 8)
	pill.Position = UDim2.new(1, -48, 0, 4)
	pill.BackgroundColor3 = cDark
	pill.BackgroundTransparency = 0.3
	pill.BorderSizePixel = 0
	Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

	local pillText = Instance.new("TextLabel", pill)
	pillText.Size = UDim2.new(1, 0, 1, 0)
	pillText.BackgroundTransparency = 1
	pillText.Text = isEnemy and "ENEMY" or "ALLY"
	pillText.TextColor3 = cBright
	pillText.Font = Enum.Font.GothamBlack
	pillText.TextSize = 6

	-- Name
	local nameLabel = Instance.new("TextLabel", card)
	nameLabel.Name = "Name"
	nameLabel.Size = UDim2.new(1, -56, 0, 14)
	nameLabel.Position = UDim2.new(0, 8, 0, 3)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = player.DisplayName
	nameLabel.TextColor3 = cBright
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 11
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd

	-- Distance
	local distLabel = Instance.new("TextLabel", card)
	distLabel.Name = "Dist"
	distLabel.Size = UDim2.new(0, 40, 0, 10)
	distLabel.Position = UDim2.new(1, -48, 0, 14)
	distLabel.BackgroundTransparency = 1
	distLabel.Text = "0m"
	distLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
	distLabel.TextStrokeTransparency = 0
	distLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	distLabel.Font = Enum.Font.GothamBold
	distLabel.TextSize = 8
	distLabel.TextXAlignment = Enum.TextXAlignment.Right

	-- HP text
	local hpLabel = Instance.new("TextLabel", card)
	hpLabel.Name = "HP"
	hpLabel.Size = UDim2.new(1, -16, 0, 10)
	hpLabel.Position = UDim2.new(0, 8, 0, 17)
	hpLabel.BackgroundTransparency = 1
	hpLabel.Text = "100 HP"
	hpLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
	hpLabel.TextStrokeTransparency = 0
	hpLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	hpLabel.Font = Enum.Font.Gotham
	hpLabel.TextSize = 8
	hpLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- HP Bar background
	local hpBG = Instance.new("Frame", card)
	hpBG.Name = "HPBG"
	hpBG.Size = UDim2.new(0.88, 0, 0, 5)
	hpBG.Position = UDim2.new(0.06, 0, 0, 30)
	hpBG.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	hpBG.BackgroundTransparency = 0.2
	hpBG.BorderSizePixel = 0
	Instance.new("UICorner", hpBG).CornerRadius = UDim.new(0, 3)

	-- HP Bar fill
	local hpFill = Instance.new("Frame", hpBG)
	hpFill.Name = "Fill"
	hpFill.Size = UDim2.new(1, 0, 1, 0)
	hpFill.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
	hpFill.BorderSizePixel = 0
	Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0, 3)

	-- HP Bar glow
	local hpGlow = Instance.new("Frame", hpBG)
	hpGlow.Name = "Glow"
	hpGlow.Size = UDim2.new(1, 0, 1, 0)
	hpGlow.BackgroundColor3 = c
	hpGlow.BackgroundTransparency = 0.75
	hpGlow.BorderSizePixel = 0
	Instance.new("UICorner", hpGlow).CornerRadius = UDim.new(0, 3)

	-- Weapon label (placeholder)
	local weaponLabel = Instance.new("TextLabel", card)
	weaponLabel.Name = "Weapon"
	weaponLabel.Size = UDim2.new(0.88, 0, 0, 8)
	weaponLabel.Position = UDim2.new(0.06, 0, 0, 38)
	weaponLabel.BackgroundTransparency = 1
	weaponLabel.Text = ""
	weaponLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
	weaponLabel.TextStrokeTransparency = 0
	weaponLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	weaponLabel.Font = Enum.Font.Gotham
	weaponLabel.TextSize = 7
	weaponLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- Status label
	local statusLabel = Instance.new("TextLabel", card)
	statusLabel.Name = "Status"
	statusLabel.Size = UDim2.new(0.88, 0, 0, 8)
	statusLabel.Position = UDim2.new(0.06, 0, 0, 47)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = ""
	statusLabel.TextColor3 = cBright
	statusLabel.TextStrokeTransparency = 0
	statusLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	statusLabel.Font = Enum.Font.GothamBold
	statusLabel.TextSize = 7
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- Corner accents (top-left, bottom-right)
	local cornerTL = Instance.new("Frame", card)
	cornerTL.Name = "CornerTL"
	cornerTL.Size = UDim2.new(0, 8, 0, 8)
	cornerTL.Position = UDim2.new(0, 0, 0, 0)
	cornerTL.BackgroundColor3 = c
	cornerTL.BorderSizePixel = 0
	cornerTL.ZIndex = 2
	Instance.new("UICorner", cornerTL).CornerRadius = UDim.new(0, 6)

	local cornerBR = Instance.new("Frame", card)
	cornerBR.Name = "CornerBR"
	cornerBR.Size = UDim2.new(0, 8, 0, 8)
	cornerBR.Position = UDim2.new(1, -8, 1, -8)
	cornerBR.BackgroundColor3 = c
	cornerBR.BorderSizePixel = 0
	cornerBR.ZIndex = 2
	Instance.new("UICorner", cornerBR).CornerRadius = UDim.new(0, 6)

	-- Highlight (box)
	local hl = Instance.new("Highlight")
	hl.Name = "ESP_HL_" .. player.Name
	hl.Adornee = char
	hl.FillColor = c
	hl.FillTransparency = 0.8
	hl.OutlineColor = cBright
	hl.OutlineTransparency = 0.1
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = ESPFolder

	-- Tracer
	local tracer = Instance.new("Frame", ESPFolder)
	tracer.Name = "TR_" .. player.Name
	tracer.AnchorPoint = Vector2.new(0.5, 0.5)
	tracer.BackgroundColor3 = c
	tracer.BackgroundTransparency = 0.3
	tracer.BorderSizePixel = 0
	tracer.Visible = false

	-- Dot
	local dot = Instance.new("Frame", ESPFolder)
	dot.Name = "DT_" .. player.Name
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Size = UDim2.fromOffset(6, 6)
	dot.BackgroundColor3 = cBright
	dot.BorderSizePixel = 0
	dot.Visible = false
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

	State.ESP[player] = {
		Billboard = bb,
		Highlight = hl,
		Tracer = tracer,
		Dot = dot,
		NameLabel = nameLabel,
		DistLabel = distLabel,
		HPLabel = hpLabel,
		HPFill = hpFill,
		StatusLabel = statusLabel,
		WeaponLabel = weaponLabel,
		Pill = pill,
		PillText = pillText,
		Accent = accent,
		TopLine = topLine,
		Card = card,
		EspColor = c,
		EspColorBright = cBright,
		EspColorDark = cDark,
		IsEnemy = isEnemy,
	}
end

local function UpdateESP(player)
	if player == LocalPlayer then return end

	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")

	if not char or not hum or not root or hum.Health <= 0 then
		RemoveESP(player)
		return
	end

	local dist = GetDistance(player)
	if dist > Config.MaxDistance then
		HideESP(player)
		return
	end

	-- Recreate if team changed
	local data = State.ESP[player]
	local isEnemy, teamColor = IsEnemy(player)
	local newColor = isEnemy and ESP_COLORS.Enemy or (teamColor or ESP_COLORS.Ally)

	if data and data.IsEnemy ~= isEnemy then
		RemoveESP(player)
		data = nil
	end

	if not data then
		CreateESP(player)
		data = State.ESP[player]
	end
	if not data then return end

	ShowESP(player)

	-- Update colors
	local c = data.EspColor
	local cBright = data.EspColorBright

	pcall(function()
		data.Highlight.Adornee = char
		data.Highlight.FillColor = c
		data.Highlight.OutlineColor = cBright
		data.Accent.BackgroundColor3 = c
		data.TopLine.BackgroundColor3 = c
		data.Pill.BackgroundColor3 = data.EspColorDark
		data.PillText.TextColor3 = cBright
		data.PillText.Text = isEnemy and "ENEMY" or "ALLY"
		data.Tracer.BackgroundColor3 = c
		data.Dot.BackgroundColor3 = cBright
	end)

	-- Update card info
	local hpPct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
	pcall(function()
		data.DistLabel.Text = math.floor(dist) .. "m"
		data.HPLabel.Text = math.floor(hum.Health) .. " HP"

		if hpPct > 0.6 then
			data.HPFill.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
		elseif hpPct > 0.3 then
			data.HPFill.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
		else
			data.HPFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		end
		data.HPFill.Size = UDim2.new(hpPct, 0, 1, 0)

		if hpPct <= 0 then
			data.StatusLabel.Text = "MORTO"
			data.StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
		elseif hpPct < 0.3 then
			data.StatusLabel.Text = "LOW HP"
			data.StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
		else
			data.StatusLabel.Text = ""
		end
	end)

	-- Tracer + Dot
	pcall(function()
		local sp, onScreen = Camera:WorldToViewportPoint(root.Position)
		if onScreen and sp.Z > 0 then
			local sc = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
			local sp2 = Vector2.new(sp.X, sp.Y)
			local diff = sp2 - sc
			data.Tracer.Position = UDim2.fromOffset((sc.X + sp2.X) / 2, (sc.Y + sp2.Y) / 2)
			data.Tracer.Size = UDim2.fromOffset(2, diff.Magnitude)
			data.Tracer.Rotation = math.deg(math.atan2(diff.Y, diff.X)) + 90
			data.Tracer.BackgroundColor3 = c
			data.Tracer.Visible = Config.ESPTracer
			data.Dot.Position = UDim2.fromOffset(sp.X, sp.Y)
			data.Dot.BackgroundColor3 = cBright
			data.Dot.Visible = Config.ESPDot
		else
			data.Tracer.Visible = false
			data.Dot.Visible = false
		end
	end)
end

local function UpdateAllESP()
	if not Config.ESP then
		for p in pairs(State.ESP) do RemoveESP(p) end
		return
	end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			UpdateESP(p)
		end
	end
end

-- ============================================
-- CROSSHAIR
-- ============================================

local CrosshairFrame = Instance.new("Frame")
CrosshairFrame.Size = UDim2.new(1, 0, 1, 0)
CrosshairFrame.BackgroundTransparency = 1
CrosshairFrame.BorderSizePixel = 0
CrosshairFrame.Visible = false
CrosshairFrame.Parent = ShadowHub:GetGui()

local function UpdateCrosshairStyle()
	for _, v in ipairs(CrosshairFrame:GetChildren()) do
		v:Destroy()
	end
	local c = Config.CrossColor

	if Config.CrossStyle == "Cross" then
		local sz = Config.CrossSize
		local gap = Config.CrossGap
		for _, data in ipairs({
			{UDim2.new(0.5, -gap - sz, 0.5, -1), UDim2.new(0, sz, 0, 2)},
			{UDim2.new(0.5, gap, 0.5, -1), UDim2.new(0, sz, 0, 2)},
			{UDim2.new(0.5, -1, 0.5, -gap - sz), UDim2.new(0, 2, 0, sz)},
			{UDim2.new(0.5, -1, 0.5, gap), UDim2.new(0, 2, 0, sz)},
		}) do
			local f = Instance.new("Frame", CrosshairFrame)
			f.Position = data[1]
			f.Size = data[2]
			f.BackgroundColor3 = c
			f.BorderSizePixel = 0
		end
	elseif Config.CrossStyle == "Dot" then
		local dot = Instance.new("Frame", CrosshairFrame)
		dot.Size = UDim2.new(0, 6, 0, 6)
		dot.Position = UDim2.new(0.5, -3, 0.5, -3)
		dot.BackgroundColor3 = c
		dot.BorderSizePixel = 0
		Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
	elseif Config.CrossStyle == "Circle" then
		local circle = Instance.new("Frame", CrosshairFrame)
		circle.Size = UDim2.new(0, 16, 0, 16)
		circle.Position = UDim2.new(0.5, -8, 0.5, -8)
		circle.BackgroundTransparency = 1
		circle.BorderSizePixel = 0
		local s = Instance.new("UIStroke", circle)
		s.Color = c
		s.Thickness = 1.5
	elseif Config.CrossStyle == "Diamond" then
		local d = Instance.new("Frame", CrosshairFrame)
		d.Size = UDim2.new(0, 8, 0, 8)
		d.Position = UDim2.new(0.5, -4, 0.5, -4)
		d.BackgroundColor3 = c
		d.BorderSizePixel = 0
		d.Rotation = 45
		Instance.new("UICorner", d).CornerRadius = UDim.new(0, 1)
	end
end

-- ============================================
-- GPS
-- ============================================

local GPSFrame = Instance.new("Frame")
GPSFrame.Size = UDim2.new(0, 150, 0, 90)
GPSFrame.Position = UDim2.new(1, -165, 0, 12)
GPSFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
GPSFrame.BackgroundTransparency = 0.15
GPSFrame.BorderSizePixel = 0
GPSFrame.Visible = false
GPSFrame.Parent = ShadowHub:GetGui()
Instance.new("UICorner", GPSFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", GPSFrame).Color = Color3.fromRGB(180, 0, 255)
Instance.new("UIStroke", GPSFrame).Thickness = 1.5
Instance.new("UIStroke", GPSFrame).Transparency = 0.5

local GPSArrow = Instance.new("TextLabel", GPSFrame)
GPSArrow.Size = UDim2.new(1, 0, 0, 30)
GPSArrow.Position = UDim2.new(0, 0, 0, 5)
GPSArrow.BackgroundTransparency = 1
GPSArrow.Text = "\226\136\128"
GPSArrow.TextColor3 = Color3.fromRGB(50, 255, 100)
GPSArrow.TextStrokeTransparency = 0
GPSArrow.Font = Enum.Font.GothamBlack
GPSArrow.TextSize = 24

local GPSDist = Instance.new("TextLabel", GPSFrame)
GPSDist.Size = UDim2.new(1, 0, 0, 14)
GPSDist.Position = UDim2.new(0, 0, 0, 38)
GPSDist.BackgroundTransparency = 1
GPSDist.Text = "--"
GPSDist.TextColor3 = Color3.fromRGB(180, 0, 255)
GPSDist.TextStrokeTransparency = 0
GPSDist.Font = Enum.Font.GothamBold
GPSDist.TextSize = 11

local GPSName = Instance.new("TextLabel", GPSFrame)
GPSName.Size = UDim2.new(1, 0, 0, 12)
GPSName.Position = UDim2.new(0, 0, 0, 54)
GPSName.BackgroundTransparency = 1
GPSName.Text = "procurando..."
GPSName.TextColor3 = Color3.fromRGB(200, 200, 210)
GPSName.TextStrokeTransparency = 0
GPSName.Font = Enum.Font.Gotham
GPSName.TextSize = 9

-- ============================================
-- EXPLOITS
-- ============================================

local function SetNoclip(on)
	Config.Noclip = on
end

RunService.Stepped:Connect(function()
	if Config.Noclip then
		local char = LocalPlayer.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
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
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = on and 32 or 16
	end
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
					ShadowHub:Notify("Kill", player.DisplayName, "kill", 3)
					if State.Target == player then State.Target = nil end
					if State.Streak == 3 then ShadowHub:Notify("Streak!", "3x STREAK!", "streak", 3) end
					if State.Streak == 5 then ShadowHub:Notify("Streak!", "5x STREAK!", "streak", 3) end
					if State.Streak == 10 then ShadowHub:Notify("Unstoppable!", "10x STREAK!", "streak", 4) end
				end
			end

			if player == LocalPlayer and newHP > 0 and newHP < 30 and oldHP >= 30 then
				ShadowHub:Notify("Alerta", "HP BAIXO!", "warning", 2)
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
	if hum then
		hum.Died:Connect(function()
			State.Streak = 0
			ShadowHub:Notify("Morte", "Voce morreu!", "error", 3)
		end)
	end
	if Config.Noclip then SetNoclip(true) end
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

-- ============================================
-- BUILD MENU
-- ============================================

local menu = ShadowHub:CreateWindow("Shadow Hub")

-- COMBATE
local s1 = menu:Section("Combate")
menu:Toggle(s1, "ESP", true, function(v)
	Config.ESP = v
	if not v then for p in pairs(State.ESP) do RemoveESP(p) end end
end)
menu:Toggle(s1, "  Box (Highlight)", true, function(v) Config.ESPBox = v end)
menu:Toggle(s1, "  Tracer", true, function(v) Config.ESPTracer = v end)
menu:Toggle(s1, "  Dot", true, function(v) Config.ESPDot = v end)
menu:Toggle(s1, "  Name", true, function(v) Config.ESPName = v end)
menu:Toggle(s1, "  Distance", true, function(v) Config.ESPDistance = v end)
menu:Toggle(s1, "  Health", true, function(v) Config.ESPHealth = v end)
menu:Toggle(s1, "Aim Assist", false, function(v) Config.AimAssist = v end)
menu:Label(s1, "Segure Botao Direito = Mirar")
menu:Toggle(s1, "Target Lock", false, function(v)
	Config.TargetLock = v
	if v then State.Target = FindTarget() else State.Target = nil end
end)
menu:Toggle(s1, "Auto Headshot", false, function(v) Config.AutoHeadshot = v end)
menu:Slider(s1, "Max Distance", 50, 5000, 2000, function(v) Config.MaxDistance = v end)

-- CROSSHAIR
local s2 = menu:Section("Crosshair")
menu:Toggle(s2, "Crosshair", false, function(v)
	Config.Crosshair = v
	CrosshairFrame.Visible = v
	UpdateCrosshairStyle()
end)
menu:Button(s2, "Estilo: " .. Config.CrossStyle, function()
	local styles = {"Cross", "Dot", "Circle", "Diamond"}
	local idx = table.find(styles, Config.CrossStyle) or 1
	idx = idx % #styles + 1
	Config.CrossStyle = styles[idx]
	UpdateCrosshairStyle()
	ShadowHub:Notify("Crosshair", "Estilo: " .. Config.CrossStyle, "info", 1.5)
end)
menu:Slider(s2, "Tamanho", 2, 15, 4, function(v) Config.CrossSize = v UpdateCrosshairStyle() end)
menu:Slider(s2, "Gap", 1, 15, 3, function(v) Config.CrossGap = v UpdateCrosshairStyle() end)

-- UTILIDADES
local s3 = menu:Section("Utilidades")
menu:Toggle(s3, "Mini GPS", false, function(v) Config.MiniGPS = v GPSFrame.Visible = v end)
menu:Toggle(s3, "Kill Notification", true, function(v) Config.KillNotify = v end)
menu:Toggle(s3, "Hit Sound", true, function(v) Config.HitSound = v end)
menu:Toggle(s3, "FFA Mode", true, function(v) Config.FFAMode = v end)
menu:Toggle(s3, "Wall Check", true, function(v) Config.WallCheck = v end)
menu:Button(s3, "Teleport to Enemy", TeleportToEnemy)

-- EXPLOITS
local s4 = menu:Section("Exploits")
menu:Toggle(s4, "Noclip", false, function(v) SetNoclip(v) end)
menu:Toggle(s4, "Fullbright", false, function(v) SetFullbright(v) end)
menu:Toggle(s4, "Speed Boost", false, function(v) SetSpeed(v) end)
menu:Toggle(s4, "Spin Bot", false, function(v) Config.SpinBot = v State.SpinAngle = 0 end)
menu:Slider(s4, "Spin Speed", 5, 120, 30, function(v) Config.SpinSpeed = v end)
menu:Slider(s4, "FOV", 30, 120, 70, function(v) Config.FOV = v Camera.FieldOfView = v end)

-- STATUS
local status = menu:StatusBar("Kills: 0 | Streak: 0")

-- ============================================
-- MAIN LOOP
-- ============================================

RunService.RenderStepped:Connect(function(dt)
	UpdateAllESP()

	if Config.AimAssist and Aimbot.Active then
		if Config.TargetLock then
			if not IsValidTarget(State.Target) then State.Target = FindTarget() end
		else
			State.Target = FindTarget()
		end
		AimAtTarget(State.Target)
	elseif not Config.TargetLock then
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
			local tHum = gpsTarget.Character and gpsTarget.Character:FindFirstChildOfClass("Humanoid")
			if tRoot and tHum and tHum.Health > 0 then
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

	status:SetText("Kills: " .. State.Kills .. " | Streak: " .. State.Streak)
end)

-- ============================================
-- DONE
-- ============================================

pcall(function()
	StarterGui:SetCore("SendNotification", {
		Title = "SHADOW HUB V2",
		Text = "Pronto! RightCtrl = menu",
		Duration = 3,
	})
end)
print("[SHADOW HUB V2] Pronto!")

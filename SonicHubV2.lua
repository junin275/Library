-- Shadow Hub V2 - Main Script v2
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
	AimAssist = false,
	TargetLock = false,
	WallCheck = true,
	FFAMode = true,
	AimSmoothness = 0.08,
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

	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("Highlight") and v.OutlineColor then
			if IsColorClose(v.OutlineColor, Color3.fromRGB(255, 0, 0), 0.3) then return true, Color3.fromRGB(255, 0, 0) end
			if IsColorClose(v.OutlineColor, Color3.fromRGB(0, 255, 100), 0.3) then return false, Color3.fromRGB(0, 255, 100) end
		end
	end

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
		if p ~= LocalPlayer then
			local isEnemy = IsEnemy(p)
			if isEnemy then
				local char = p.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				local root = char and char:FindFirstChild("HumanoidRootPart")
				if hum and root and hum.Health > 0 then
					local dist = GetDistance(p)
					if dist <= Config.MaxDistance then
						local sp, onScreen = pcall(function()
							return Camera:WorldToViewportPoint(root.Position)
						end)
						if sp and onScreen then
							local score = (1 / math.max(dist, 1)) * (onScreen and 10 or 1)
							if score > bestScore then
								best = p
								bestScore = score
							end
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

local function AimAtTarget(target)
	if not target or not IsValidTarget(target) then return end
	if Config.WallCheck and not HasLineOfSight(target) then return end

	local partName = Config.AutoHeadshot and "Head" or Config.TargetPart
	local part = target.Character:FindFirstChild(partName)
	if not part then return end

	local sp = pcall(function()
		return Camera:WorldToViewportPoint(part.Position)
	end)
	if not sp then return end

	local viewportPoint = Camera:WorldToViewportPoint(part.Position)
	local screenPos = Vector2.new(viewportPoint.X, viewportPoint.Y)
	local screenCenter = Camera.ViewportSize / 2
	local diff = screenPos - screenCenter
	local dist = diff.Magnitude

	if dist > 1 then
		local maxMove = 50
		local moveX = math.clamp(diff.X * Config.AimSmoothness, -maxMove, maxMove)
		local moveY = math.clamp(diff.Y * Config.AimSmoothness, -maxMove, maxMove)
		mousemoverel(moveX, moveY)
	end
end

-- ============================================
-- ESP
-- ============================================

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP_Folder"
ESPFolder.Parent = Camera

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
	local espColor = teamColor or (isEnemy and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 200, 255))

	-- BillboardGui
	local bb = Instance.new("BillboardGui")
	bb.Name = "ESP_" .. player.Name
	bb.Adornee = head
	bb.Size = UDim2.new(0, 140, 0, 55)
	bb.StudsOffset = Vector3.new(0, 2.8, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = Config.MaxDistance
	bb.Parent = ESPFolder

	-- Card (transparent background)
	local card = Instance.new("Frame", bb)
	card.Size = UDim2.new(1, 0, 1, 0)
	card.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
	card.BackgroundTransparency = 0.7
	card.BorderSizePixel = 0
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 5)

	-- Accent bar (left side)
	local accentBar = Instance.new("Frame", card)
	accentBar.Size = UDim2.new(0, 3, 1, 0)
	accentBar.BackgroundColor3 = espColor
	accentBar.BorderSizePixel = 0

	-- Name
	local nameLabel = Instance.new("TextLabel", card)
	nameLabel.Size = UDim2.new(1, -14, 0, 14)
	nameLabel.Position = UDim2.new(0, 10, 0, 3)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = player.DisplayName
	nameLabel.TextColor3 = espColor
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 11
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- Distance + HP
	local infoLabel = Instance.new("TextLabel", card)
	infoLabel.Size = UDim2.new(1, -14, 0, 11)
	infoLabel.Position = UDim2.new(0, 10, 0, 18)
	infoLabel.BackgroundTransparency = 1
	infoLabel.Text = "0m | 100HP"
	infoLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
	infoLabel.TextStrokeTransparency = 0
	infoLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	infoLabel.Font = Enum.Font.Gotham
	infoLabel.TextSize = 9
	infoLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- HP Bar background
	local hpBG = Instance.new("Frame", card)
	hpBG.Size = UDim2.new(0.85, 0, 0, 5)
	hpBG.Position = UDim2.new(0.075, 0, 0, 33)
	hpBG.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	hpBG.BorderSizePixel = 0
	Instance.new("UICorner", hpBG).CornerRadius = UDim.new(0, 3)

	-- HP Bar fill
	local hpFill = Instance.new("Frame", hpBG)
	hpFill.Size = UDim2.new(1, 0, 1, 0)
	hpFill.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
	hpFill.BorderSizePixel = 0
	Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0, 3)

	-- HP bar glow
	local hpGlow = Instance.new("Frame", hpBG)
	hpGlow.Size = UDim2.new(1, 0, 1, 0)
	hpGlow.BackgroundColor3 = espColor
	hpGlow.BackgroundTransparency = 0.7
	hpGlow.BorderSizePixel = 0
	Instance.new("UICorner", hpGlow).CornerRadius = UDim.new(0, 3)

	-- Status label
	local statusLabel = Instance.new("TextLabel", card)
	statusLabel.Size = UDim2.new(1, -14, 0, 8)
	statusLabel.Position = UDim2.new(0, 10, 0, 40)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = ""
	statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
	statusLabel.TextStrokeTransparency = 0
	statusLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	statusLabel.Font = Enum.Font.GothamBold
	statusLabel.TextSize = 7
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- Team dot
	local teamDot = Instance.new("Frame", card)
	teamDot.Size = UDim2.fromOffset(6, 6)
	teamDot.Position = UDim2.new(1, -12, 0, 5)
	teamDot.BackgroundColor3 = espColor
	teamDot.BorderSizePixel = 0
	Instance.new("UICorner", teamDot).CornerRadius = UDim.new(1, 0)

	-- Highlight (box)
	local hl = Instance.new("Highlight")
	hl.Name = "ESP_HL_" .. player.Name
	hl.Adornee = char
	hl.FillColor = espColor
	hl.FillTransparency = 0.75
	hl.OutlineColor = espColor
	hl.OutlineTransparency = 0.2
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = ESPFolder

	-- Tracer
	local tracer = Instance.new("Frame", ESPFolder)
	tracer.Name = "TR_" .. player.Name
	tracer.AnchorPoint = Vector2.new(0.5, 0.5)
	tracer.BackgroundColor3 = espColor
	tracer.BackgroundTransparency = 0.35
	tracer.BorderSizePixel = 0
	tracer.Visible = false

	-- Dot
	local dot = Instance.new("Frame", ESPFolder)
	dot.Name = "DT_" .. player.Name
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Size = UDim2.fromOffset(6, 6)
	dot.BackgroundColor3 = espColor
	dot.BorderSizePixel = 0
	dot.Visible = false
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

	State.ESP[player] = {
		Billboard = bb,
		Highlight = hl,
		Tracer = tracer,
		Dot = dot,
		NameLabel = nameLabel,
		InfoLabel = infoLabel,
		HPFill = hpFill,
		StatusLabel = statusLabel,
		TeamDot = teamDot,
		AccentBar = accentBar,
		EspColor = espColor,
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
	local isEnemy = IsEnemy(player)
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

	-- Update highlight
	pcall(function()
		data.Highlight.Adornee = char
		data.Highlight.FillColor = data.EspColor
		data.Highlight.OutlineColor = data.EspColor
	end)

	-- Update card
	local hpPct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
	pcall(function()
		data.InfoLabel.Text = math.floor(dist) .. "m | " .. math.floor(hum.Health) .. "HP"
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
		elseif hpPct < 0.3 then
			data.StatusLabel.Text = "LOW HP"
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
			data.Tracer.BackgroundColor3 = data.EspColor
			data.Tracer.Visible = Config.ESPTracer
			data.Dot.Position = UDim2.fromOffset(sp.X, sp.Y)
			data.Dot.BackgroundColor3 = data.EspColor
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
	end

	if Config.CrossStyle == "Dot" then
		local dot = Instance.new("Frame", CrosshairFrame)
		dot.Size = UDim2.new(0, 6, 0, 6)
		dot.Position = UDim2.new(0.5, -3, 0.5, -3)
		dot.BackgroundColor3 = c
		dot.BorderSizePixel = 0
		Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
	end

	if Config.CrossStyle == "Circle" then
		local circle = Instance.new("Frame", CrosshairFrame)
		circle.Size = UDim2.new(0, 16, 0, 16)
		circle.Position = UDim2.new(0.5, -8, 0.5, -8)
		circle.BackgroundTransparency = 1
		circle.BorderSizePixel = 0
		local s = Instance.new("UIStroke", circle)
		s.Color = c
		s.Thickness = 1.5
	end

	if Config.CrossStyle == "Diamond" then
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
		if p ~= LocalPlayer then
			local tChar = p.Character
			local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
			local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
			if tRoot and tHum and tHum.Health > 0 then
				local isEnemy = IsEnemy(p)
				if isEnemy then
					local d = (root.Position - tRoot.Position).Magnitude
					if d < Config.MaxDistance and (not bestDist or d < bestDist) then
						best = p
						bestDist = d
					end
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
					if State.Target == player then
						State.Target = nil
					end
					if State.Streak == 3 then
						ShadowHub:Notify("Streak!", "3x STREAK!", "streak", 3)
					end
					if State.Streak == 5 then
						ShadowHub:Notify("Streak!", "5x STREAK!", "streak", 3)
					end
					if State.Streak == 10 then
						ShadowHub:Notify("Unstoppable!", "10x STREAK!", "streak", 4)
					end
				end
			end

			if player == LocalPlayer and newHP > 0 and newHP < 30 and oldHP >= 30 then
				ShadowHub:Notify("Alerta", "HP BAIXO!", "warning", 2)
			end
		end)
	end

	if player.Character then
		task.spawn(onCharacter, player.Character)
	end
	player.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		onCharacter(char)
		task.wait(0.3)
		RemoveESP(player)
	end)
end

for _, p in ipairs(Players:GetPlayers()) do
	MonitorPlayer(p)
end
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
	if Config.Noclip then
		SetNoclip(true)
	end
	if Config.SpeedBoost then
		local h = char:WaitForChild("Humanoid", 5)
		if h then
			h.WalkSpeed = 32
		end
	end
end)

Players.PlayerRemoving:Connect(function(p)
	RemoveESP(p)
	if State.Target == p then
		State.Target = nil
	end
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
	if not v then
		for p in pairs(State.ESP) do RemoveESP(p) end
	end
end)
menu:Toggle(s1, "  Box (Highlight)", true, function(v) Config.ESPBox = v end)
menu:Toggle(s1, "  Tracer", true, function(v) Config.ESPTracer = v end)
menu:Toggle(s1, "  Dot", true, function(v) Config.ESPDot = v end)
menu:Toggle(s1, "Aim Assist", false, function(v) Config.AimAssist = v end)
menu:Toggle(s1, "Target Lock", false, function(v)
	Config.TargetLock = v
	if v then
		State.Target = FindTarget()
	else
		State.Target = nil
	end
end)
menu:Toggle(s1, "Auto Headshot", false, function(v) Config.AutoHeadshot = v end)
menu:Slider(s1, "Aim Smoothness", 0.01, 0.5, 0.08, function(v) Config.AimSmoothness = v end)
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
menu:Slider(s2, "Tamanho", 2, 15, 4, function(v)
	Config.CrossSize = v
	UpdateCrosshairStyle()
end)
menu:Slider(s2, "Gap", 1, 15, 3, function(v)
	Config.CrossGap = v
	UpdateCrosshairStyle()
end)

-- UTILIDADES
local s3 = menu:Section("Utilidades")
menu:Toggle(s3, "Mini GPS", false, function(v)
	Config.MiniGPS = v
	GPSFrame.Visible = v
end)
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
menu:Toggle(s4, "Spin Bot", false, function(v)
	Config.SpinBot = v
	State.SpinAngle = 0
end)
menu:Slider(s4, "Spin Speed", 5, 120, 30, function(v) Config.SpinSpeed = v end)
menu:Slider(s4, "FOV", 30, 120, 70, function(v)
	Config.FOV = v
	Camera.FieldOfView = v
end)

-- STATUS
local status = menu:StatusBar("Kills: 0 | Streak: 0")

-- ============================================
-- MAIN LOOP
-- ============================================

RunService.RenderStepped:Connect(function(dt)
	-- ESP
	UpdateAllESP()

	-- Aim
	if Config.AimAssist then
		if Config.TargetLock then
			if not IsValidTarget(State.Target) then
				State.Target = FindTarget()
			end
		else
			State.Target = FindTarget()
		end
		AimAtTarget(State.Target)
	else
		State.Target = nil
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

	-- FOV
	pcall(function() Camera.FieldOfView = Config.FOV end)

	-- Status
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

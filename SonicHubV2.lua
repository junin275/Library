-- Shadow Hub V2 - Drawing Anti-Capture Version
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
-- CHECK DRAWING API (nao aparece em gravacao)
-- ============================================

local HasDrawing = false
pcall(function()
	local test = Drawing.new("Line")
	test:Remove()
	HasDrawing = true
end)

-- ============================================
-- CONFIG
-- ============================================

local Config = {
	ESP = true,
	ESPTracer = true,
	ESPDot = true,
	AimAssist = false,
	TargetLock = false,
	WallCheck = true,
	FFAMode = true,
	MaxDistance = 2000,
	TargetPart = "HumanoidRootPart",
	AutoHeadshot = false,
	KillNotify = true,
	MiniGPS = false,
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
			if IsColorClose(v.OutlineColor, Color3.fromRGB(255, 0, 0), 0.3) then return true end
			if IsColorClose(v.OutlineColor, Color3.fromRGB(0, 255, 100), 0.3) then return false end
		end
	end
	for _, v in ipairs(Workspace:GetDescendants()) do
		if v:IsA("Highlight") and v.Adornee and (v.Adornee == char or v.Adornee:IsDescendantOf(char)) and v.OutlineColor then
			if IsColorClose(v.OutlineColor, Color3.fromRGB(255, 0, 0), 0.3) then return true end
			if IsColorClose(v.OutlineColor, Color3.fromRGB(0, 255, 100), 0.3) then return false end
		end
	end
	return false
end

local function GetDistance(player)
	local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local tRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if myRoot and tRoot then
		return (myRoot.Position - tRoot.Position).Magnitude
	end
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

local function FindTarget()
	local best, bestScore = nil, 0
	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and IsEnemy(p) then
			local char = p.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if hum and root and hum.Health > 0 then
				local dist = GetDistance(p)
				if dist <= Config.MaxDistance then
					local score = (1 / math.max(dist, 1)) * 10
					if score > bestScore then
						best = p
						bestScore = score
					end
				end
			end
		end
	end
	return best
end

-- ============================================
-- AIMBOT (Always Active - Camera CFrame)
-- ============================================

local function AimAtTarget(target)
	if not Config.AimAssist then return end
	if not target or not IsValidTarget(target) then return end
	if Config.WallCheck and not HasLineOfSight(target) then return end
	local partName = Config.AutoHeadshot and "Head" or Config.TargetPart
	local part = target.Character:FindFirstChild(partName)
	if not part then return end
	local camPos = Camera.CFrame.Position
	local targetPos = part.Position
	Camera.CFrame = CFrame.new(camPos, targetPos)
end

-- ============================================
-- DRAWING ESP (nao aparece em gravacao)
-- ============================================

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "M"
ESPFolder.Parent = Camera

local COLORS = {
	Enemy = {r=255, g=50, b=50},
	EnemyB = {r=255, g=80, b=80},
	Ally = {r=50, g=180, b=255},
	AllyB = {r=80, g=200, b=255},
}

local function GetColor(isEnemy)
	if isEnemy then
		return COLORS.Enemy, COLORS.EnemyB
	end
	return COLORS.Ally, COLORS.AllyB
end

local function RemoveESP(player)
	local data = State.ESP[player]
	if data then
		if HasDrawing then
			for _, obj in ipairs(data.Drawing or {}) do
				pcall(function() obj:Remove() end)
			end
		end
		pcall(function() data.Highlight:Destroy() end)
		State.ESP[player] = nil
	end
end

local function HideESP(player)
	local data = State.ESP[player]
	if not data then return end
	if HasDrawing then
		for _, obj in ipairs(data.Drawing or {}) do
			pcall(function() obj.Visible = false end)
		end
	end
	pcall(function()
		data.Highlight.Enabled = false
	end)
end

local function ShowESP(player)
	local data = State.ESP[player]
	if not data then return end
	if HasDrawing then
		for _, obj in ipairs(data.Drawing or {}) do
			pcall(function() obj.Visible = true end)
		end)
	end
	pcall(function()
		data.Highlight.Enabled = true
	end)
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
	local c, cB = GetColor(isEnemy)

	local drawingObjs = {}

	if HasDrawing then
		-- Tracer line (Drawing - NOT captured by recorders)
		local tracer = Drawing.new("Line")
		tracer.Color = Color3.fromRGB(c.r, c.g, c.b)
		tracer.Thickness = 1.5
		tracer.Transparency = 0.6
		tracer.Visible = false
		table.insert(drawingObjs, tracer)

		-- Box outline
		local boxOutline = Drawing.new("Quad")
		boxOutline.Color = Color3.fromRGB(0, 0, 0)
		boxOutline.Thickness = 3
		boxOutline.Transparency = 0.5
		boxOutline.Filled = false
		boxOutline.Visible = false
		table.insert(drawingObjs, boxOutline)

		-- Box
		local box = Drawing.new("Quad")
		box.Color = Color3.fromRGB(c.r, c.g, c.b)
		box.Thickness = 1
		box.Transparency = 0.8
		box.Filled = false
		box.Visible = false
		table.insert(drawingObjs, box)

		-- Name
		local name = Drawing.new("Text")
		name.Color = Color3.fromRGB(cB.r, cB.g, cB.b)
		name.Size = 13
		name.Center = true
		name.Outline = true
		name.OutlineColor = Color3.new(0, 0, 0)
		name.Visible = false
		table.insert(drawingObjs, name)

		-- Distance
		local dist = Drawing.new("Text")
		dist.Color = Color3.fromRGB(180, 180, 195)
		dist.Size = 11
		dist.Center = true
		dist.Outline = true
		dist.OutlineColor = Color3.new(0, 0, 0)
		dist.Visible = false
		table.insert(drawingObjs, dist)

		-- Health bar outline
		local hpOutline = Drawing.new("Line")
		hpOutline.Color = Color3.fromRGB(0, 0, 0)
		hpOutline.Thickness = 3
		hpOutline.Transparency = 0.5
		hpOutline.Visible = false
		table.insert(drawingObjs, hpOutline)

		-- Health bar
		local hpBar = Drawing.new("Line")
		hpBar.Color = Color3.fromRGB(50, 255, 100)
		hpBar.Thickness = 1
		hpBar.Transparency = 0.8
		hpBar.Visible = false
		table.insert(drawingObjs, hpBar)

		-- Dot
		local dot = Drawing.new("Circle")
		dot.Color = Color3.fromRGB(cB.r, cB.g, cB.b)
		dot.Radius = 4
		dot.Filled = true
		dot.Transparency = 0.8
		dot.Visible = false
		table.insert(drawingObjs, dot)
	end

	-- Highlight (this shows in game but not in recordings usually)
	local hl = Instance.new("Highlight")
	hl.Name = "H"
	hl.Adornee = char
	hl.FillColor = Color3.fromRGB(c.r, c.g, c.b)
	hl.FillTransparency = 0.8
	hl.OutlineColor = Color3.fromRGB(cB.r, cB.g, cB.b)
	hl.OutlineTransparency = 0.1
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = ESPFolder

	State.ESP[player] = {
		Highlight = hl,
		Drawing = drawingObjs,
		IsEnemy = isEnemy,
		C = c,
		CB = cB,
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

	local c = data.C
	local cB = data.CB

	pcall(function()
		data.Highlight.Adornee = char
		data.Highlight.FillColor = Color3.fromRGB(c.r, c.g, c.b)
		data.Highlight.OutlineColor = Color3.fromRGB(cB.r, cB.g, cB.b)
	end)

	if HasDrawing and #data.Drawing >= 8 then
		local drawing = data.Drawing
		local tracer = drawing[1]
		local boxOutline = drawing[2]
		local box = drawing[3]
		local nameLabel = drawing[4]
		local distLabel = drawing[5]
		local hpOutline = drawing[6]
		local hpBar = drawing[7]
		local dot = drawing[8]

		local ok, sp = pcall(function()
			return Camera:WorldToViewportPoint(root.Position)
		end)

		if ok and sp and sp.Z > 0 then
			local screenPos = Vector2.new(sp.X, sp.Y)
			local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
			local onScreen = sp.Z > 0

			-- Box (3D corners projected)
			local top = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
			local bottom = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0))
			local height = math.abs(top.Y - bottom.Y)
			local width = height * 0.55
			local topLeft = Vector2.new(screenPos.X - width / 2, top.Y)
			local topRight = Vector2.new(screenPos.X + width / 2, top.Y)
			local botLeft = Vector2.new(screenPos.X - width / 2, bottom.Y)
			local botRight = Vector2.new(screenPos.X + width / 2, bottom.Y)

			boxOutline.PointA = topLeft
			boxOutline.PointB = topRight
			boxOutline.PointC = botRight
			boxOutline.PointD = botLeft
			boxOutline.Visible = Config.ESPTracer

			box.PointA = topLeft
			box.PointB = topRight
			box.PointC = botRight
			box.PointD = botLeft
			box.Visible = Config.ESPTracer

			-- Tracer
			tracer.From = screenCenter
			tracer.To = screenPos
			tracer.Color = Color3.fromRGB(c.r, c.g, c.b)
			tracer.Visible = Config.ESPTracer

			-- Name
			nameLabel.Position = Vector2.new(screenPos.X, top.Y - 16)
			nameLabel.Text = player.DisplayName
			nameLabel.Color = Color3.fromRGB(cB.r, cB.g, cB.b)
			nameLabel.Visible = true

			-- Distance
			distLabel.Position = Vector2.new(screenPos.X, bottom.Y + 2)
			distLabel.Text = math.floor(dist) .. "m"
			distLabel.Visible = true

			-- HP bar
			local hpPct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
			local hpX = topLeft.X - 6
			local hpTop = topLeft.Y
			local hpBot = bottom.Y
			local hpLen = (hpBot - hpTop) * hpPct

			hpOutline.From = Vector2.new(hpX, hpTop)
			hpOutline.To = Vector2.new(hpX, hpBot)
			hpOutline.Visible = true

			hpBar.From = Vector2.new(hpX, hpBot - hpLen)
			hpBar.To = Vector2.new(hpX, hpBot)
			if hpPct > 0.6 then
				hpBar.Color = Color3.fromRGB(50, 255, 100)
			elseif hpPct > 0.3 then
				hpBar.Color = Color3.fromRGB(255, 200, 50)
			else
				hpBar.Color = Color3.fromRGB(255, 50, 50)
			end
			hpBar.Visible = true

			-- Dot
			dot.Position = screenPos
			dot.Visible = Config.ESPDot
		else
			tracer.Visible = false
			boxOutline.Visible = false
			box.Visible = false
			nameLabel.Visible = false
			distLabel.Visible = false
			hpOutline.Visible = false
			hpBar.Visible = false
			dot.Visible = false
		end
	end
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
-- GPS (Drawing)
-- ============================================

local GPSObjects = {}
if HasDrawing then
	local gpsBg = Drawing.new("Square")
	gpsBg.Size = Vector2.new(120, 70)
	gpsBg.Position = Vector2.new(Camera.ViewportSize.X - 135, 12)
	gpsBg.Color = Color3.fromRGB(15, 15, 25)
	gpsBg.Transparency = 0.85
	gpsBg.Filled = true
	gpsBg.Visible = false
	table.insert(GPSObjects, gpsBg)

	local gpsBorder = Drawing.new("Square")
	gpsBorder.Size = Vector2.new(120, 70)
	gpsBorder.Position = Vector2.new(Camera.ViewportSize.X - 135, 12)
	gpsBorder.Color = Color3.fromRGB(180, 0, 255)
	gpsBorder.Thickness = 1
	gpsBorder.Filled = false
	gpsBorder.Visible = false
	table.insert(GPSObjects, gpsBorder)

	local gpsArrow = Drawing.new("Text")
	gpsArrow.Text = "\226\136\128"
	gpsArrow.Color = Color3.fromRGB(50, 255, 100)
	gpsArrow.Size = 20
	gpsArrow.Center = true
	gpsArrow.Outline = true
	gpsArrow.Visible = false
	table.insert(GPSObjects, gpsArrow)

	local gpsDist = Drawing.new("Text")
	gpsDist.Text = "--"
	gpsDist.Color = Color3.fromRGB(180, 0, 255)
	gpsDist.Size = 11
	gpsDist.Center = true
	gpsDist.Outline = true
	gpsDist.Visible = false
	table.insert(GPSObjects, gpsDist)

	local gpsName = Drawing.new("Text")
	gpsName.Text = "procurando..."
	gpsName.Color = Color3.fromRGB(200, 200, 210)
	gpsName.Size = 9
	gpsName.Center = true
	gpsName.Outline = true
	gpsName.Visible = false
	table.insert(GPSObjects, gpsName)
end

-- ============================================
-- EXPLOITS
-- ============================================

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
	if hum then hum.WalkSpeed = on and 32 or 16 end
end

local function TeleportToEnemy()
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
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
		ShadowHub:Notify("TP", best.DisplayName, "success", 2)
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
					if State.Streak == 3 then ShadowHub:Notify("Streak!", "3x", "streak", 3) end
					if State.Streak == 5 then ShadowHub:Notify("Streak!", "5x", "streak", 3) end
					if State.Streak == 10 then ShadowHub:Notify("God!", "10x", "streak", 4) end
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

-- ============================================
-- BUILD MENU
-- ============================================

local menu = ShadowHub:CreateWindow("SH")

local s1 = menu:Section("COMBATE")
menu:Toggle(s1, "ESP", true, function(v)
	Config.ESP = v
	if not v then for p in pairs(State.ESP) do RemoveESP(p) end end
end)
menu:Toggle(s1, "Tracer", true, function(v) Config.ESPTracer = v end)
menu:Toggle(s1, "Dot", true, function(v) Config.ESPDot = v end)
menu:Toggle(s1, "Aimbot", false, function(v) Config.AimAssist = v end)
menu:Label(s1, "Sempre ativo quando ligado")
menu:Toggle(s1, "Target Lock", false, function(v)
	Config.TargetLock = v
	if v then State.Target = FindTarget() else State.Target = nil end
end)
menu:Toggle(s1, "Auto Headshot", false, function(v) Config.AutoHeadshot = v end)
menu:Slider(s1, "Distance", 50, 5000, 2000, function(v) Config.MaxDistance = v end)

local s3 = menu:Section("UTIL")
menu:Toggle(s3, "GPS", false, function(v) Config.MiniGPS = v end)
menu:Toggle(s3, "Kill Notif", true, function(v) Config.KillNotify = v end)
menu:Toggle(s3, "Hit Sound", true, function(v) Config.HitSound = v end)
menu:Toggle(s3, "FFA Mode", true, function(v) Config.FFAMode = v end)
menu:Toggle(s3, "Wall Check", true, function(v) Config.WallCheck = v end)
menu:Button(s3, "Teleport", TeleportToEnemy)

local s4 = menu:Section("EXPLOITS")
menu:Toggle(s4, "Noclip", false, function(v) Config.Noclip = v end)
menu:Toggle(s4, "Fullbright", false, function(v) SetFullbright(v) end)
menu:Toggle(s4, "Speed", false, function(v) SetSpeed(v) end)
menu:Toggle(s4, "Spin Bot", false, function(v) Config.SpinBot = v State.SpinAngle = 0 end)
menu:Slider(s4, "Spin", 5, 120, 30, function(v) Config.SpinSpeed = v end)
menu:Slider(s4, "FOV", 30, 120, 70, function(v) Config.FOV = v Camera.FieldOfView = v end)

local status = menu:StatusBar("K: 0 | S: 0")

-- ============================================
-- MAIN LOOP
-- ============================================

RunService.RenderStepped:Connect(function(dt)
	UpdateAllESP()

	if Config.AimAssist then
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

	if Config.MiniGPS and HasDrawing and #GPSObjects >= 5 then
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

				local posX = Camera.ViewportSize.X - 135
				GPSObjects[1].Position = Vector2.new(posX, 12)
				GPSObjects[1].Visible = true
				GPSObjects[2].Position = Vector2.new(posX, 12)
				GPSObjects[2].Visible = true
				GPSObjects[3].Position = Vector2.new(posX + 60, 20)
				GPSObjects[3].Rotation = -math.deg(angle)
				GPSObjects[3].Visible = true
				GPSObjects[4].Position = Vector2.new(posX + 60, 42)
				GPSObjects[4].Text = math.floor(dist) .. "m"
				GPSObjects[4].Visible = true
				GPSObjects[5].Position = Vector2.new(posX + 60, 56)
				GPSObjects[5].Text = gpsTarget.DisplayName
				GPSObjects[5].Visible = true
			end
		else
			for _, obj in ipairs(GPSObjects) do obj.Visible = false end
		end
	elseif not Config.MiniGPS then
		if HasDrawing then
			for _, obj in ipairs(GPSObjects) do obj.Visible = false end
		end
	end

	pcall(function() Camera.FieldOfView = Config.FOV end)
	status:SetText("K: " .. State.Kills .. " | S: " .. State.Streak)
end)

print("[SH] Drawing ESP Ready | HasDrawing: " .. tostring(HasDrawing))

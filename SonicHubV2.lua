-- Shadow Hub V2 - Mobile Fixed Version
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
	AimAssist = false,
	TargetLock = false,
	WallCheck = true,
	FFAMode = true,
	MaxDistance = 2000,
	TargetPart = "HumanoidRootPart",
	AutoHeadshot = false,
	KillNotify = true,
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
-- AIMBOT (Always Active)
-- ============================================

local function AimAtTarget(target)
	if not Config.AimAssist then return end
	if not target or not IsValidTarget(target) then return end
	local partName = Config.AutoHeadshot and "Head" or Config.TargetPart
	local part = target.Character:FindFirstChild(partName)
	if not part then return end
	Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
end

-- ============================================
-- ESP (Simple BillboardGui + Highlight)
-- ============================================

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
		State.ESP[player] = nil
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
	local c = isEnemy and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 180, 255)

	-- BillboardGui (always on screen)
	local bb = Instance.new("BillboardGui")
	bb.Name = "B"
	bb.Adornee = head
	bb.Size = UDim2.new(0, 150, 0, 45)
	bb.StudsOffset = Vector3.new(0, 2.5, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = Config.MaxDistance
	bb.Parent = ESPGui

	-- Background
	local bg = Instance.new("Frame", bb)
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	bg.BackgroundTransparency = 0.6
	bg.BorderSizePixel = 0
	Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 4)

	-- Color bar
	local bar = Instance.new("Frame", bg)
	bar.Size = UDim2.new(0, 3, 1, 0)
	bar.BackgroundColor3 = c
	bar.BorderSizePixel = 0

	-- Name
	local nameLabel = Instance.new("TextLabel", bg)
	nameLabel.Size = UDim2.new(1, -10, 0, 14)
	nameLabel.Position = UDim2.new(0, 8, 0, 2)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = player.DisplayName
	nameLabel.TextColor3 = c
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 11
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- Distance
	local distLabel = Instance.new("TextLabel", bg)
	distLabel.Size = UDim2.new(1, -10, 0, 10)
	distLabel.Position = UDim2.new(0, 8, 0, 16)
	distLabel.BackgroundTransparency = 1
	distLabel.Text = "0m"
	distLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
	distLabel.TextStrokeTransparency = 0
	distLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	distLabel.Font = Enum.Font.Gotham
	distLabel.TextSize = 9
	distLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- HP Bar
	local hpBG = Instance.new("Frame", bg)
	hpBG.Size = UDim2.new(0.9, 0, 0, 4)
	hpBG.Position = UDim2.new(0.05, 0, 0, 30)
	hpBG.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	hpBG.BorderSizePixel = 0
	Instance.new("UICorner", hpBG).CornerRadius = UDim.new(0, 2)

	local hpFill = Instance.new("Frame", hpBG)
	hpFill.Size = UDim2.new(1, 0, 1, 0)
	hpFill.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
	hpFill.BorderSizePixel = 0
	Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0, 2)

	-- Highlight
	local hl = Instance.new("Highlight")
	hl.Name = "H"
	hl.Adornee = char
	hl.FillColor = c
	hl.FillTransparency = 0.7
	hl.OutlineColor = Color3.new(1, 1, 1)
	hl.OutlineTransparency = 0
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = ESPGui

	State.ESP[player] = {
		Billboard = bb,
		Highlight = hl,
		NameLabel = nameLabel,
		DistLabel = distLabel,
		HPFill = hpFill,
		IsEnemy = isEnemy,
		Color = c,
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
		RemoveESP(player)
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

	-- Update
	pcall(function()
		data.NameLabel.Text = player.DisplayName
		data.DistLabel.Text = math.floor(dist) .. "m"
		local hpPct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
		data.HPFill.Size = UDim2.new(hpPct, 0, 1, 0)
		if hpPct > 0.6 then
			data.HPFill.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
		elseif hpPct > 0.3 then
			data.HPFill.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
		else
			data.HPFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		end
		data.Highlight.Adornee = char
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
	else
		Lighting.Brightness = 1
		Lighting.Ambient = Color3.fromRGB(70, 70, 70)
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
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
					if Config.KillNotify then
						ShadowHub:Notify("Kill", player.DisplayName, "kill", 3)
					end
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
menu:Toggle(s1, "Aimbot", false, function(v) Config.AimAssist = v end)
menu:Label(s1, "Sempre ativo quando ligado")
menu:Toggle(s1, "Target Lock", false, function(v)
	Config.TargetLock = v
	if v then State.Target = FindTarget() else State.Target = nil end
end)
menu:Toggle(s1, "Auto Headshot", false, function(v) Config.AutoHeadshot = v end)
menu:Slider(s1, "Distance", 50, 5000, 2000, function(v) Config.MaxDistance = v end)

local s3 = menu:Section("UTIL")
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

	pcall(function() Camera.FieldOfView = Config.FOV end)
	status:SetText("K: " .. State.Kills .. " | S: " .. State.Streak)
end)

StarterGui:SetCore("SendNotification", {
	Title = "SH",
	Text = "Pronto!",
	Duration = 2,
})
print("[SH] Ready!")

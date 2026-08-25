--// SONIC HUB - COLETOR DE DADOS
--// Mostra TUDO sobre times em tempo real
--// Abre o F9 pra ver o output E olha a janela na tela

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Output = {}
local function Log(text)
	table.insert(Output, text)
	print(text)
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DataCollector"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Panel = Instance.new("Frame")
Panel.Size = UDim2.fromOffset(600, 500)
Panel.Position = UDim2.new(0.5, -300, 0.5, -250)
Panel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
Panel.BorderSizePixel = 0
Panel.Parent = ScreenGui
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 10)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
TopBar.BorderSizePixel = 0
TopBar.Parent = Panel
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.fromOffset(12, 0)
Title.BackgroundTransparency = 1
Title.Text = "SONIC HUB - COLETOR DE DADOS"
Title.TextColor3 = Color3.fromRGB(180, 0, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.fromOffset(80, 28)
CopyBtn.Position = UDim2.new(1, -174, 0.5, -14)
CopyBtn.BackgroundColor3 = Color3.fromRGB(50, 220, 120)
CopyBtn.BorderSizePixel = 0
CopyBtn.Text = "COPIAR"
CopyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 10
CopyBtn.Parent = TopBar
Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 6)

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.fromOffset(80, 28)
RefreshBtn.Position = UDim2.new(1, -90, 0.5, -14)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
RefreshBtn.BorderSizePixel = 0
RefreshBtn.Text = "REFRESH"
RefreshBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.TextSize = 10
RefreshBtn.Parent = TopBar
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(28, 28)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "x"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.fromOffset(10, 45)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(180, 0, 255)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Panel

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 4)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Scroll

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 0, 0)
ContentFrame.BackgroundTransparency = 1
ContentFrame.AutomaticSize = Enum.AutomaticSize.Y
ContentFrame.Parent = Scroll

-- Função pra adicionar texto
local OrderCounter = 0
local function AddLine(text, color)
	table.insert(Output, text)
	OrderCounter = OrderCounter + 1
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 0)
	lbl.AutomaticSize = Enum.AutomaticSize.Y
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = color or Color3.fromRGB(200, 200, 210)
	lbl.Font = Enum.Font.RobotoMono
	lbl.TextSize = 10
	lbl.TextWrapped = true
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextYAlignment = Enum.TextYAlignment.Top
	lbl.LayoutOrder = OrderCounter
	lbl.Parent = ContentFrame
	return lbl
end

local function AddHeader(text)
	OrderCounter = OrderCounter + 1
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 22)
	lbl.BackgroundTransparency = 1
	lbl.Text = "  " .. text
	lbl.TextColor3 = Color3.fromRGB(180, 0, 255)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.LayoutOrder = OrderCounter
	lbl.Parent = ContentFrame
end

local function AddSeparator()
	OrderCounter = OrderCounter + 1
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, -20, 0, 1)
	f.Position = UDim2.fromOffset(10, 0)
	f.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
	f.BorderSizePixel = 0
	f.LayoutOrder = OrderCounter
	f.Parent = ContentFrame
end

-- FUNÇÃO PRINCIPAL DE COLETA
local function CollectData()
	-- Limpar output e GUI
	Output = {}
	for _, child in ipairs(ContentFrame:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
	OrderCounter = 0

	-- INFO LOCAL PLAYER
	AddHeader("SEU PLAYER")
	AddLine("Nome: " .. LocalPlayer.Name)
	AddLine("Display Name: " .. LocalPlayer.DisplayName)
	AddLine("UserId: " .. tostring(LocalPlayer.UserId))

	if LocalPlayer.Team then
		AddLine("Time: " .. LocalPlayer.Team.Name, Color3.fromRGB(0, 200, 255))
		AddLine("TeamColor: " .. tostring(LocalPlayer.Team.TeamColor), Color3.fromRGB(0, 200, 255))
		AddLine("TeamColor.Color: " .. tostring(LocalPlayer.Team.TeamColor.Color), Color3.fromRGB(0, 200, 255))
	else
		AddLine("Time: NENHUM", Color3.fromRGB(255, 100, 100))
	end

	-- Character info
	local myChar = LocalPlayer.Character
	if myChar then
		AddLine("Character: " .. myChar.Name)
		local myShirt = myChar:FindFirstChildOfClass("Shirt")
		local myPants = myChar:FindFirstChildOfClass("Pants")
		local myBC = myChar:FindFirstChildOfClass("BodyColors")
		if myShirt then AddLine("Shirt: " .. tostring(myShirt.ShirtTemplate)) end
		if myPants then AddLine("Pants: " .. tostring(myPants.PantsTemplate)) end
		if myBC then
			AddLine("TorsoColor: " .. tostring(myBC.TorsoColor3))
		end
		for _, part in ipairs(myChar:GetChildren()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				AddLine("  " .. part.Name .. " Color: " .. tostring(part.Color))
			end
		end
	end

	AddSeparator()

	-- TODOS OS JOGADORES
	AddHeader("TODOS OS JOGADORES (" .. #Players:GetPlayers() .. ")")

	for _, player in ipairs(Players:GetPlayers()) do
		AddSeparator()
		AddHeader(player.Name .. " (ID: " .. player.UserId .. ")")

		if player.Team then
			AddLine("  Time: " .. player.Team.Name, Color3.fromRGB(0, 200, 255))
			AddLine("  TeamColor: " .. tostring(player.Team.TeamColor), Color3.fromRGB(0, 200, 255))
			AddLine("  TeamColor.Color: " .. tostring(player.Team.TeamColor.Color), Color3.fromRGB(0, 200, 255))

			-- Comparar com meu time
			if LocalPlayer.Team then
				if player.Team == LocalPlayer.Team then
					AddLine("  >> MESMO TIME QUE VOCE", Color3.fromRGB(0, 255, 100))
				else
					AddLine("  >> TIME DIFERENTE (INIMIGO)", Color3.fromRGB(255, 60, 60))
				end
			end
		else
			AddLine("  Time: NENHUM", Color3.fromRGB(255, 100, 100))
		end

		local char = player.Character
		if char then
			AddLine("  Character: " .. char.Name)
			local shirt = char:FindFirstChildOfClass("Shirt")
			local pants = char:FindFirstChildOfClass("Pants")
			local bc = char:FindFirstChildOfClass("BodyColors")
			if shirt then AddLine("  Shirt: " .. tostring(shirt.ShirtTemplate)) end
			if pants then AddLine("  Pants: " .. tostring(pants.PantsTemplate)) end
			if bc then AddLine("  TorsoColor: " .. tostring(bc.TorsoColor3)) end

			for _, part in ipairs(char:GetChildren()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					AddLine("    " .. part.Name .. " Color: " .. tostring(part.Color))
				end
			end

			-- Highlights
			local hlCount = 0
			for _, obj in ipairs(char:GetDescendants()) do
				if obj:IsA("Highlight") then
					hlCount = hlCount + 1
					AddLine("  [HL] " .. obj.Name .. " Fill: " .. tostring(obj.FillColor) .. " Out: " .. tostring(obj.OutlineColor))
				end
			end

			-- BillboardGuis
			for _, obj in ipairs(char:GetDescendants()) do
				if obj:IsA("BillboardGui") then
					for _, child in ipairs(obj:GetDescendants()) do
						if child:IsA("TextLabel") then
							AddLine("  [BB] '" .. child.Text .. "' Cor: " .. tostring(child.TextColor3))
						end
					end
				end
			end
		else
			AddLine("  SEM CHARACTER", Color3.fromRGB(255, 100, 100))
		end
	end

	AddSeparator()

	-- TIMES DO JOGO
	AddHeader("TIMES DO JOGO")
	for _, team in ipairs(game:GetService("Teams"):GetTeams()) do
		AddLine("Time: " .. team.Name)
		AddLine("  TeamColor: " .. tostring(team.TeamColor))
		AddLine("  AutoAssignable: " .. tostring(team.AutoAssignable))
		local players = team:GetPlayers()
		AddLine("  Jogadores: " .. #players)
		for _, p in ipairs(players) do
			AddLine("    - " .. p.Name)
		end
	end

	-- LISTA DE TODAS AS CORES
	AddSeparator()
	AddHeader("TODAS AS CORES DETECTADAS")
	local colors = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Team and player.Team.TeamColor then
			local c = player.Team.TeamColor
			if not colors[tostring(c)] then
				colors[tostring(c)] = {name = c.Name, color = c.Color, players = {}}
			end
			table.insert(colors[tostring(c)].players, player.Name)
		end
	end
	for k, v in pairs(colors) do
		AddLine(v.name .. " = " .. tostring(v.color) .. " [" .. table.concat(v.players, ", ") .. "]")
	end
end

-- Função pra copiar
local function CopyToClipboard()
	local FullText = table.concat(Output, "\n")
	pcall(function()
		if setclipboard then
			setclipboard(FullText)
		elseif syn and syn.write_clipboard then
			syn.write_clipboard(FullText)
		end
	end)
	CopyBtn.Text = "COPIADO!"
	CopyBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 180)
	task.delay(2, function()
		CopyBtn.Text = "COPIAR"
		CopyBtn.BackgroundColor3 = Color3.fromRGB(50, 220, 120)
	end)
end

-- Botões
CopyBtn.MouseButton1Click:Connect(CopyToClipboard)
RefreshBtn.MouseButton1Click:Connect(CollectData)
CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- CollectData na primeira vez
task.wait(1)
CollectData()

-- Auto-refresh a cada 2 segundos
task.spawn(function()
	while ScreenGui and ScreenGui.Parent do
		task.wait(2)
		pcall(CollectData)
	end
end)

print("COLETOR DE DADOS PRONTO!")
print("Olhe a janela na tela e copie os dados aqui")

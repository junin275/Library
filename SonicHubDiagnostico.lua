--// SONIC HUB - DIAGNÓSTICO COM BOTÃO DE COPIAR
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")

local Output = {}
local function Log(text)
	table.insert(Output, text)
end

local function LogLine()
	Log(string.rep("=", 60))
end

local function LogDash()
	Log(string.rep("-", 60))
end

LogLine()
Log("SONIC HUB - DIAGNÓSTICO COMPLETO")
LogLine()

-- 1. INFO DO LOCAL PLAYER
Log("")
Log("[JOGADOR LOCAL]")
Log("Nome: " .. LocalPlayer.Name)
Log("UserId: " .. LocalPlayer.UserId)

if LocalPlayer.Team then
	Log("Time: " .. LocalPlayer.Team.Name)
	Log("Cor do Time: " .. tostring(LocalPlayer.Team.TeamColor))
else
	Log("Time: NENHUM")
end

local myChar = LocalPlayer.Character
if myChar then
	Log("")
	Log("[SEU CHARACTER]")
	local myShirt = myChar:FindFirstChildOfClass("Shirt")
	local myPants = myChar:FindFirstChildOfClass("Pants")
	local myBodyColors = myChar:FindFirstChildOfClass("BodyColors")

	if myShirt then Log("Shirt: " .. myShirt.ShirtTemplate) end
	if myPants then Log("Pants: " .. myPants.PantsTemplate) end
	if myBodyColors then
		Log("Torso Color: " .. tostring(myBodyColors.TorsoColor3))
		Log("Head Color: " .. tostring(myBodyColors.HeadColor3))
	end

	for _, part in ipairs(myChar:GetChildren()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			Log("Part: " .. part.Name .. " | Color: " .. tostring(part.Color)
				.. " | Material: " .. tostring(part.Material))
		end
	end
end

-- 2. TODOS OS JOGADORES
Log("")
LogDash()
Log("TODOS OS JOGADORES (" .. #Players:GetPlayers() .. " jogadores)")
LogDash()

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		Log("")
		Log("--- " .. player.Name .. " (ID: " .. player.UserId .. ") ---")

		if player.Team then
			Log("  Time: " .. player.Team.Name)
			Log("  Cor Time: " .. tostring(player.Team.TeamColor))
		else
			Log("  Time: NENHUM")
		end

		local char = player.Character
		if char then
			local shirt = char:FindFirstChildOfClass("Shirt")
			local pants = char:FindFirstChildOfClass("Pants")
			local bodyColors = char:FindFirstChildOfClass("BodyColors")

			if shirt then Log("  Shirt: " .. shirt.ShirtTemplate) end
			if pants then Log("  Pants: " .. pants.PantsTemplate) end
			if bodyColors then
				Log("  Torso Color: " .. tostring(bodyColors.TorsoColor3))
				Log("  Head Color: " .. tostring(bodyColors.HeadColor3))
			end

			for _, part in ipairs(char:GetChildren()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					Log("  Part: " .. part.Name .. " | Color: " .. tostring(part.Color))
				end
			end

			-- HIGHLIGHTS
			Log("  [HIGHLIGHTS]")
			local hlCount = 0
			for _, obj in ipairs(char:GetDescendants()) do
				if obj:IsA("Highlight") then
					hlCount = hlCount + 1
					Log("    Highlight #" .. hlCount)
					Log("      Name: " .. obj.Name)
					Log("      FillColor: " .. tostring(obj.FillColor))
					Log("      OutlineColor: " .. tostring(obj.OutlineColor))
					Log("      FillTransparency: " .. tostring(obj.FillTransparency))
					Log("      Parent: " .. tostring(obj.Parent:GetFullName()))
				end
			end

			for _, obj in ipairs(Workspace:GetDescendants()) do
				if obj:IsA("Highlight") and obj.Adornee then
					if obj.Adornee == char or obj.Adornee:IsDescendantOf(char) then
						hlCount = hlCount + 1
						Log("    Highlight (Workspace) #" .. hlCount)
						Log("      Name: " .. obj.Name)
						Log("      FillColor: " .. tostring(obj.FillColor))
						Log("      OutlineColor: " .. tostring(obj.OutlineColor))
						Log("      Parent: " .. tostring(obj.Parent:GetFullName()))
					end
				end
			end

			if hlCount == 0 then
				Log("    NENHUM Highlight encontrado")
			end

			-- BILLBOARDS NO CHARACTER
			Log("  [BILLBOARDS no Character]")
			local bbCount = 0
			for _, obj in ipairs(char:GetDescendants()) do
				if obj:IsA("BillboardGui") then
					bbCount = bbCount + 1
					Log("    Billboard #" .. bbCount)
					Log("      Name: " .. obj.Name)
					for _, child in ipairs(obj:GetDescendants()) do
						if child:IsA("TextLabel") then
							Log("      TextLabel: '" .. child.Text .. "'")
							Log("        TextColor3: " .. tostring(child.TextColor3))
						elseif child:IsA("ImageLabel") then
							Log("      ImageLabel: " .. tostring(child.Image))
							Log("        ImageColor3: " .. tostring(child.ImageColor3))
						end
					end
				end
			end
			if bbCount == 0 then Log("    NENHUM Billboard no character") end

			-- BILLBOARDS NO PLAYERGUI
			Log("  [BILLBOARDS no PlayerGui]")
			local guiBBCount = 0
			for _, gui in ipairs(PlayerGui:GetDescendants()) do
				if gui:IsA("BillboardGui") and gui.Adornee then
					local adornee = gui.Adornee
					if adornee == char or (adornee:IsDescendantOf and adornee:IsDescendantOf(char)) then
						guiBBCount = guiBBCount + 1
						Log("    Billboard (GUI) #" .. guiBBCount)
						Log("      Name: " .. gui.Name)
						Log("      Parent: " .. tostring(gui.Parent:GetFullName()))
						for _, child in ipairs(gui:GetDescendants()) do
							if child:IsA("TextLabel") then
								Log("      TextLabel: '" .. child.Text .. "'")
								Log("        TextColor3: " .. tostring(child.TextColor3))
								Log("        TextStrokeColor3: " .. tostring(child.TextStrokeColor3))
							elseif child:IsA("ImageLabel") then
								Log("      ImageLabel: " .. tostring(child.Image))
								Log("        ImageColor3: " .. tostring(child.ImageColor3))
							elseif child:IsA("Frame") then
								Log("      Frame: " .. child.Name)
								Log("        BackgroundColor3: " .. tostring(child.BackgroundColor3))
							end
						end
					end
				end
			end
			if guiBBCount == 0 then Log("    NENHUM Billboard no PlayerGui") end

			-- SURFACE GUI
			Log("  [SURFACE GUI]")
			local sgCount = 0
			for _, obj in ipairs(char:GetDescendants()) do
				if obj:IsA("SurfaceGui") then
					sgCount = sgCount + 1
					Log("    SurfaceGui #" .. sgCount)
					Log("      Name: " .. obj.Name)
					for _, child in ipairs(obj:GetDescendants()) do
						if child:IsA("TextLabel") then
							Log("      TextLabel: '" .. child.Text .. "' Cor: " .. tostring(child.TextColor3))
						elseif child:IsA("ImageLabel") then
							Log("      ImageLabel: " .. tostring(child.Image))
						end
					end
				end
			end
			if sgCount == 0 then Log("    NENHUM SurfaceGui encontrado") end

			-- GUI NOS PARTS
			Log("  [GUI NOS PARTS]")
			for _, part in ipairs(char:GetChildren()) do
				if part:IsA("BasePart") then
					for _, obj in ipairs(part:GetChildren()) do
						if obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") then
							Log("    " .. obj.Name .. " em " .. part.Name)
							for _, child in ipairs(obj:GetDescendants()) do
								if child:IsA("TextLabel") then
									Log("      TextLabel: '" .. child.Text .. "' Cor: " .. tostring(child.TextColor3))
								end
							end
						end
					end
				end
			end
		else
			Log("  SEM CHARACTER")
		end
	end
end

-- 3. HIGHLIGHTS NO WORKSPACE INTEIRO
Log("")
LogDash()
Log("HIGHLIGHTS NO WORKSPACE INTEIRO")
LogDash()

local wsHighlights = {}
for _, obj in ipairs(Workspace:GetDescendants()) do
	if obj:IsA("Highlight") then
		table.insert(wsHighlights, obj)
	end
end

Log("Total: " .. #wsHighlights)

for i, hl in ipairs(wsHighlights) do
	Log("")
	Log("Highlight #" .. i)
	Log("  Name: " .. hl.Name)
	Log("  FillColor: " .. tostring(hl.FillColor))
	Log("  OutlineColor: " .. tostring(hl.OutlineColor))
	Log("  FillTransparency: " .. tostring(hl.FillTransparency))
	Log("  Adornee: " .. tostring(hl.Adornee))
	Log("  Parent: " .. tostring(hl.Parent:GetFullName()))

	if hl.Adornee then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				if hl.Adornee == player.Character or hl.Adornee:IsDescendantOf(player.Character) then
					Log("  -> PERTENCE A: " .. player.Name)
				end
			end
		end
	end
end

-- 4. BILLBOARDS COM NOMES DE JOGADORES
Log("")
LogDash()
Log("BILLBOARDS COM NOMES DE JOGADORES")
LogDash()

for _, gui in ipairs(PlayerGui:GetDescendants()) do
	if gui:IsA("BillboardGui") then
		for _, child in ipairs(gui:GetDescendants()) do
			if child:IsA("TextLabel") then
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer then
						if string.find(child.Text, player.Name)
							or string.find(child.Text, player.DisplayName) then
							Log("")
							Log("Billboard: " .. gui.Name)
							Log("  Texto: '" .. child.Text .. "'")
							Log("  TextColor3: " .. tostring(child.TextColor3))
							Log("  -> JOGADOR: " .. player.Name)
						end
					end
				end
			end
		end
	end
end

-- 5. TODOS OS HIGHLIGHTS DO JOGO
Log("")
LogDash()
Log("TODOS OS HIGHLIGHTS EM TODO O JOGO")
LogDash()

local allHL = {}
for _, obj in ipairs(game:GetDescendants()) do
	if obj:IsA("Highlight") then
		table.insert(allHL, obj)
	end
end

Log("Total: " .. #allHL)

for i, hl in ipairs(allHL) do
	Log("")
	Log("Highlight #" .. i)
	Log("  Name: " .. hl.Name)
	Log("  FillColor: " .. tostring(hl.FillColor))
	Log("  OutlineColor: " .. tostring(hl.OutlineColor))
	Log("  Parent: " .. tostring(hl.Parent:GetFullName()))

	if hl.Adornee then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				if hl.Adornee == player.Character or hl.Adornee:IsDescendantOf(player.Character) then
					Log("  -> PLAYER: " .. player.Name)
				end
			end
		end
	end
end

-- 6. SURFACE GUI EM PARTS DOS PLAYERS
Log("")
LogDash()
Log("SURFACE GUI EM PARTS DOS PLAYERS")
LogDash()

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer and player.Character then
		for _, part in ipairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				for _, gui in ipairs(part:GetChildren()) do
					if gui:IsA("SurfaceGui") then
						Log("")
						Log(player.Name .. " - " .. part.Name)
						Log("  SurfaceGui: " .. gui.Name)
						for _, child in ipairs(gui:GetDescendants()) do
							if child:IsA("TextLabel") then
								Log("    TextLabel: '" .. child.Text .. "' Cor: " .. tostring(child.TextColor3))
							elseif child:IsA("ImageLabel") then
								Log("    ImageLabel: " .. tostring(child.Image))
							end
						end
					end
				end
			end
		end
	end
end

-- 7. BILLBOARDGUI DIRETO NOS CHARACTERS
Log("")
LogDash()
Log("BILLBOARDGUI DIRETO NOS CHARACTERS")
LogDash()

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer and player.Character then
		for _, obj in ipairs(player.Character:GetDescendants()) do
			if obj:IsA("BillboardGui") then
				Log("")
				Log(player.Name .. " - " .. obj.Name)
				for _, child in ipairs(obj:GetDescendants()) do
					if child:IsA("TextLabel") then
						Log("  TextLabel: '" .. child.Text .. "' Cor: " .. tostring(child.TextColor3))
					elseif child:IsA("ImageLabel") then
						Log("  ImageLabel: " .. tostring(child.Image))
					end
				end
			end
		end
	end
end

-- 8. PROCURAR POR "ESP", "NAME", "TAG"
Log("")
LogDash()
Log("PROCURANDO POR 'ESP', 'NAME', 'TAG', 'HEALTH'")
LogDash()

for _, obj in ipairs(game:GetDescendants()) do
	local name = string.lower(obj.Name)
	if string.find(name, "esp") or string.find(name, "name")
		or string.find(name, "tag") or string.find(name, "health")
		or string.find(name, "hud") or string.find(name, "info")
		or string.find(name, "label") or string.find(name, "display") then

		if obj:IsA("TextLabel") or obj:IsA("ImageLabel") or obj:IsA("Frame")
			or obj:IsA("BillboardGui") or obj:IsA("Highlight") then
			Log("")
			Log(obj.ClassName .. ": " .. obj.Name)
			Log("  Parent: " .. tostring(obj.Parent:GetFullName()))
			if obj:IsA("TextLabel") then
				Log("  Text: '" .. obj.Text .. "'")
				Log("  TextColor3: " .. tostring(obj.TextColor3))
			end
			if obj:IsA("ImageLabel") then
				Log("  Image: " .. tostring(obj.Image))
				Log("  ImageColor3: " .. tostring(obj.ImageColor3))
			end
		end
	end
end

Log("")
LogLine()
Log("FIM DO DIAGNÓSTICO")
LogLine()

--============================================================
-- GUI COM BOTÃO DE COPIAR
--============================================================

local FullText = table.concat(Output, "\n")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DiagnosticoCopy"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = PlayerGui

-- Fundo escuro
local Backdrop = Instance.new("Frame")
Backdrop.Size = UDim2.fromScale(1, 1)
Backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Backdrop.BackgroundTransparency = 0.3
Backdrop.BorderSizePixel = 0
Backdrop.Parent = ScreenGui

-- Painel principal
local Panel = Instance.new("Frame")
Panel.Size = UDim2.fromOffset(500, 450)
Panel.Position = UDim2.new(0.5, -250, 0.5, -225)
Panel.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
Panel.BorderSizePixel = 0
Panel.Parent = ScreenGui

Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 14)

local PanelStroke = Instance.new("UIStroke")
PanelStroke.Color = Color3.fromRGB(0, 170, 255)
PanelStroke.Thickness = 1.5
PanelStroke.Transparency = 0.5
PanelStroke.Parent = Panel

-- Top bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = Panel

Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 14)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 1, 0)
TitleLabel.Position = UDim2.fromOffset(15, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "DIAGNÓSTICO SONIC HUB"
TitleLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Texto do output
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -120)
ScrollFrame.Position = UDim2.fromOffset(10, 58)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = Panel

Instance.new("UICorner", ScrollFrame).CornerRadius = UDim.new(0, 8)

local OutputLabel = Instance.new("TextLabel")
OutputLabel.Size = UDim2.new(1, -10, 0, 0)
OutputLabel.Position = UDim2.fromOffset(5, 5)
OutputLabel.BackgroundTransparency = 1
OutputLabel.Text = FullText
OutputLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
OutputLabel.Font = Enum.Font.RobotoMono
OutputLabel.TextSize = 10
OutputLabel.TextXAlignment = Enum.TextXAlignment.Left
OutputLabel.TextYAlignment = Enum.TextYAlignment.Top
OutputLabel.TextWrapped = true
OutputLabel.AutomaticSize = Enum.AutomaticSize.Y
OutputLabel.Parent = ScrollFrame

-- Botão de copiar
local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(1, -20, 0, 44)
CopyBtn.Position = UDim2.new(0, 10, 1, -54)
CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
CopyBtn.BorderSizePixel = 0
CopyBtn.Text = "COPIAR DIAGNÓSTICO"
CopyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 14
CopyBtn.AutoButtonColor = false
CopyBtn.Parent = Panel

Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 8)

-- Fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(30, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TopBar

Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- Função copiar
local function CopyToClipboard()
	pcall(function()
		if setclipboard then
			setclipboard(FullText)
		elseif syn and syn.write_clipboard then
			syn.write_clipboard(FullText)
		end
	end)

	CopyBtn.Text = "COPIADO!"
	CopyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)

	task.delay(2, function()
		CopyBtn.Text = "COPIAR DIAGNÓSTICO"
		CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	end)
end

CopyBtn.MouseButton1Click:Connect(CopyToClipboard)

CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

print("DIAGNÓSTICO PRONTO! Clique em 'COPIAR DIAGNÓSTICO' e cole aqui.")

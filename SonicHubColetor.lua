-- ============================================
-- SHADOW HUB - COLETOR DE DADOS (MOBILE)
-- ============================================

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "Collector"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 400)
frame.Position = UDim2.new(0.5, -160, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(180, 0, 255)

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
title.BackgroundTransparency = 0.8
title.Text = "SHADOW HUB - COLETOR"
title.TextColor3 = Color3.fromRGB(180, 0, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

-- Scroll Frame
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -10, 1, -120)
scroll.Position = UDim2.new(0, 5, 0, 35)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(180, 0, 255)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 2)

local textLabel = Instance.new("TextLabel", scroll)
textLabel.Size = UDim2.new(1, 0, 0, 0)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
textLabel.TextWrapped = true
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.TextYAlignment = Enum.TextYAlignment.Top
textLabel.Font = Enum.Font.Code
textLabel.TextSize = 10
textLabel.AutomaticSize = Enum.AutomaticSize.Y

-- Status Label
local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, 0, 0, 15)
statusLabel.Position = UDim2.new(0, 0, 1, -75)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Toque em 'COLETAR' primeiro"
statusLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10

-- COLETAR Button
local collectBtn = Instance.new("TextButton", frame)
collectBtn.Size = UDim2.new(0.48, -5, 0, 35)
collectBtn.Position = UDim2.new(0.01, 5, 1, -38)
collectBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
collectBtn.Text = "COLETAR"
collectBtn.TextColor3 = Color3.new(1, 1, 1)
collectBtn.Font = Enum.Font.GothamBold
collectBtn.TextSize = 14
Instance.new("UICorner", collectBtn).CornerRadius = UDim.new(0, 6)

-- COPIAR Button
local copyBtn = Instance.new("TextButton", frame)
copyBtn.Size = UDim2.new(0.48, -5, 0, 35)
copyBtn.Position = UDim2.new(0.51, 0, 1, -38)
copyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
copyBtn.Text = "COPIAR"
copyBtn.TextColor3 = Color3.new(1, 1, 1)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 14
copyBtn.AutoButtonColor = true
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)

-- FECHAR Button
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(1, 0, 0, 20)
closeBtn.Position = UDim2.new(0, 0, 1, -18)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Text = "FECHAR"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 10
closeBtn.BackgroundTransparency = 0.7
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

-- COLLECT DATA
local collectedData = ""

local function CollectData()
    local r = {}
    table.insert(r, "=== SHADOW HUB DATA ===")
    table.insert(r, "")
    
    -- Character + Tools
    table.insert(r, "--- TOOLS EQUIPPED ---")
    if LocalPlayer.Character then
        for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("Tool") then
                table.insert(r, "TOOL: " .. v.Name)
                for _, val in ipairs(v:GetDescendants()) do
                    if val:IsA("ValueBase") then
                        table.insert(r, "  " .. val.ClassName .. " '" .. val.Name .. "' = " .. tostring(val.Value))
                    end
                end
                for _, remote in ipairs(v:GetDescendants()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        table.insert(r, "  " .. remote.ClassName .. " '" .. remote.Name .. "'")
                    end
                end
            end
        end
    end
    
    -- Backpack
    table.insert(r, "")
    table.insert(r, "--- TOOLS BACKPACK ---")
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, v in ipairs(backpack:GetDescendants()) do
            if v:IsA("Tool") then
                table.insert(r, "TOOL: " .. v.Name)
                for _, val in ipairs(v:GetDescendants()) do
                    if val:IsA("ValueBase") then
                        table.insert(r, "  " .. val.ClassName .. " '" .. val.Name .. "' = " .. tostring(val.Value))
                    end
                end
                for _, remote in ipairs(v:GetDescendants()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        table.insert(r, "  " .. remote.ClassName .. " '" .. remote.Name .. "'")
                    end
                end
            end
        end
    end
    
    -- Weapon UI
    table.insert(r, "")
    table.insert(r, "--- WEAPON UI ---")
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") then
                local name = gui.Name:lower()
                if name:find("ammo") or name:find("clip") or name:find("bullet") or name:find("weapon") or name:find("mag") then
                    table.insert(r, gui.Name .. " = '" .. gui.Text .. "'")
                end
            end
        end
    end
    
    -- Highlights
    table.insert(r, "")
    table.insert(r, "--- TEAMS ---")
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, v in ipairs(player.Character:GetDescendants()) do
                if v:IsA("Highlight") then
                    local oc = v.OutlineColor
                    table.insert(r, player.DisplayName .. ": RGB(" .. math.floor(oc.R*255) .. "," .. math.floor(oc.G*255) .. "," .. math.floor(oc.B*255) .. ")")
                end
            end
        end
    end
    
    -- Remotes
    table.insert(r, "")
    table.insert(r, "--- REMOTES ---")
    local RS = game:GetService("ReplicatedStorage")
    for _, remote in ipairs(RS:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local n = remote.Name:lower()
            if n:find("reload") or n:find("shoot") or n:find("fire") or n:find("weapon") or n:find("ammo") then
                table.insert(r, remote.ClassName .. " '" .. remote.Name .. "'")
            end
        end
    end
    
    table.insert(r, "")
    table.insert(r, "=== FIM ===")
    
    collectedData = table.concat(r, "\n")
    textLabel.Text = collectedData
    statusLabel.Text = "Dados coletados! Toque em COPIAR"
    statusLabel.TextColor3 = Color3.fromRGB(50, 255, 100)
end

-- COLLECT
collectBtn.MouseButton1Click:Connect(CollectData)

-- COPY
copyBtn.MouseButton1Click:Connect(function()
    if collectedData == "" then
        statusLabel.Text = "Colete os dados primeiro!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    pcall(function()
        if setclipboard then
            setclipboard(collectedData)
        end
    end)
    
    statusLabel.Text = "COPIADO! Manda pro dev!"
    statusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
    
    -- Flash effect
    copyBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
    task.delay(0.3, function()
        copyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    end)
end)

-- CLOSE
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

print("[SH] Coletor aberto!")

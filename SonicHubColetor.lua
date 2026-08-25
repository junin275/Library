-- ============================================
-- SHADOW HUB - COLETOR COMPLETO (MOBILE)
-- ============================================

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "CollectorV2"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 450)
frame.Position = UDim2.new(0.5, -175, 0.5, -225)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(180, 0, 255)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
title.BackgroundTransparency = 0.8
title.Text = "SHADOW HUB - COLETOR V2"
title.TextColor3 = Color3.fromRGB(180, 0, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -10, 1, -130)
scroll.Position = UDim2.new(0, 5, 0, 35)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(180, 0, 255)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 2)

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

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, 0, 0, 15)
statusLabel.Position = UDim2.new(0, 0, 1, -85)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Toque em 'COLETAR'"
statusLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10

local collectBtn = Instance.new("TextButton", frame)
collectBtn.Size = UDim2.new(0.48, -5, 0, 35)
collectBtn.Position = UDim2.new(0.01, 5, 1, -48)
collectBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
collectBtn.Text = "COLETAR"
collectBtn.TextColor3 = Color3.new(1, 1, 1)
collectBtn.Font = Enum.Font.GothamBold
collectBtn.TextSize = 14
Instance.new("UICorner", collectBtn).CornerRadius = UDim.new(0, 6)

local copyBtn = Instance.new("TextButton", frame)
copyBtn.Size = UDim2.new(0.48, -5, 0, 35)
copyBtn.Position = UDim2.new(0.51, 0, 1, -48)
copyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
copyBtn.Text = "COPIAR"
copyBtn.TextColor3 = Color3.new(1, 1, 1)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 14
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(1, 0, 0, 20)
closeBtn.Position = UDim2.new(0, 0, 1, -23)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Text = "FECHAR"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 10
closeBtn.BackgroundTransparency = 0.7
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

local collectedData = ""

local function CollectData()
    local r = {}
    table.insert(r, "=== SHADOW HUB DATA V2 ===")
    table.insert(r, "")
    
    -- 1. ALL VALUES IN CHARACTER (including tools and their descendants)
    table.insert(r, "--- CHARACTER ALL VALUES ---")
    if LocalPlayer.Character then
        for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("ValueBase") then
                table.insert(r, v:GetFullName() .. " = " .. tostring(v.Value))
            end
        end
    end
    table.insert(r, "")
    
    -- 2. BACKPACK ALL VALUES
    table.insert(r, "--- BACKPACK ALL VALUES ---")
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, v in ipairs(backpack:GetDescendants()) do
            if v:IsA("ValueBase") then
                table.insert(r, v:GetFullName() .. " = " .. tostring(v.Value))
            end
        end
    end
    table.insert(r, "")
    
    -- 3. ALL REMOTES IN TOOL
    table.insert(r, "--- TOOL REMOTES ---")
    if LocalPlayer.Character then
        for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                table.insert(r, v:GetFullName() .. " (" .. v.ClassName .. ")")
            end
        end
    end
    if backpack then
        for _, v in ipairs(backpack:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                table.insert(r, v:GetFullName() .. " (" .. v.ClassName .. ")")
            end
        end
    end
    table.insert(r, "")
    
    -- 4. WEAPON UI DETAILS
    table.insert(r, "--- WEAPON UI ---")
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        -- Search all TextLabels and TextButtons
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                local name = gui.Name:lower()
                local text = gui.Text
                if name:find("weapon") or name:find("ammo") or name:find("clip") or name:find("bullet") or name:find("mag") or name:find("gun") or name:find("fire") or name:find("shoot") then
                    table.insert(r, gui.ClassName .. " '" .. gui.Name .. "' = '" .. text .. "'")
                end
            end
        end
        
        -- Search all ImageLabels
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("ImageLabel") then
                local name = gui.Name:lower()
                if name:find("weapon") or name:find("ammo") or name:find("gun") or name:find("crosshair") then
                    table.insert(r, "ImageLabel '" .. gui.Name .. "' Image=" .. gui.Image)
                end
            end
        end
    end
    table.insert(r, "")
    
    -- 5. STUI / SCOOGUI DETAILS
    table.insert(r, "--- STUI/SCOOGUI DETAILS ---")
    if playerGui then
        for _, screenGui in ipairs(playerGui:GetChildren()) do
            if screenGui:IsA("ScreenGui") then
                local name = screenGui.Name:lower()
                if name:find("stui") or name:find("scooge") or name:find("weapon") or name:find("hud") or name:find("game") then
                    table.insert(r, "ScreenGui: " .. screenGui.Name)
                    -- Get all frames with text
                    for _, desc in ipairs(screenGui:GetDescendants()) do
                        if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                            if desc.Text ~= "" and desc.Text ~= " " then
                                table.insert(r, "  " .. desc.Name .. " = '" .. desc.Text .. "'")
                            end
                        end
                    end
                end
            end
        end
    end
    table.insert(r, "")
    
    -- 6. ALL REMOTES IN REPLICATEDSTORAGE
    table.insert(r, "--- ALL REPLICATEDSTORAGE REMOTES ---")
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            table.insert(r, remote.ClassName .. " '" .. remote.Name .. "'")
        end
    end
    table.insert(r, "")
    
    -- 7. LEADERSTATS / VALUES IN PLAYER
    table.insert(r, "--- PLAYER VALUES ---")
    for _, v in ipairs(LocalPlayer:GetChildren()) do
        if v:IsA("ValueBase") then
            table.insert(r, v.ClassName .. " '" .. v.Name .. "' = " .. tostring(v.Value))
        end
    end
    table.insert(r, "")
    
    -- 8. ALL TOOLS FULL PATH
    table.insert(r, "--- ALL TOOLS ---")
    for _, tool in ipairs(game:GetDescendants()) do
        if tool:IsA("Tool") then
            table.insert(r, "Tool: " .. tool:GetFullName())
        end
    end
    table.insert(r, "")
    
    table.insert(r, "=== FIM ===")
    
    collectedData = table.concat(r, "\n")
    textLabel.Text = collectedData
    statusLabel.Text = "Dados coletados! Toque em COPIAR"
    statusLabel.TextColor3 = Color3.fromRGB(50, 255, 100)
end

collectBtn.MouseButton1Click:Connect(CollectData)

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
    copyBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
    task.delay(0.3, function()
        copyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    end)
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

print("[SH] Coletor V2 aberto!")

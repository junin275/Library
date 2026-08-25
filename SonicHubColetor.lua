-- ============================================
-- SHADOW HUB - COLETOR DE AMMO (MOBILE)
-- ============================================

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AmmoCollector"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 380, 0, 550)
frame.Position = UDim2.new(0.5, -190, 0.5, -275)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(180, 0, 255)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
title.BackgroundTransparency = 0.8
title.Text = "COLETOR DE AMMO"
title.TextColor3 = Color3.fromRGB(180, 0, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -10, 1, -140)
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
statusLabel.Position = UDim2.new(0, 0, 1, -95)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Equipe uma arma e toque em COLETAR"
statusLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10

local collectBtn = Instance.new("TextButton", frame)
collectBtn.Size = UDim2.new(0.48, -5, 0, 35)
collectBtn.Position = UDim2.new(0.01, 5, 1, -55)
collectBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
collectBtn.Text = "COLETAR"
collectBtn.TextColor3 = Color3.new(1, 1, 1)
collectBtn.Font = Enum.Font.GothamBold
collectBtn.TextSize = 14
Instance.new("UICorner", collectBtn).CornerRadius = UDim.new(0, 6)

local copyBtn = Instance.new("TextButton", frame)
copyBtn.Size = UDim2.new(0.48, -5, 0, 35)
copyBtn.Position = UDim2.new(0.51, 0, 1, -55)
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
    table.insert(r, "=== AMMO DATA ===")
    table.insert(r, "")
    
    -- 1. ALL TEXTLABELS WITH NUMBERS (could be ammo)
    table.insert(r, "--- TEXT WITH NUMBERS ---")
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                local text = gui.Text
                -- Check if text contains numbers
                if text:match("%d") and #text < 20 then
                    table.insert(r, gui:GetFullName())
                    table.insert(r, "  Text: '" .. text .. "'")
                    table.insert(r, "  Visible: " .. tostring(gui.Visible))
                    table.insert(r, "")
                end
            end
        end
    end
    table.insert(r, "")
    
    -- 2. WEAPON HUD AREA (look for frames near bottom/right of screen)
    table.insert(r, "--- WEAPON HUD ---")
    if playerGui then
        for _, screenGui in ipairs(playerGui:GetChildren()) do
            if screenGui:IsA("ScreenGui") then
                local name = screenGui.Name:lower()
                if name:find("hud") or name:find("weapon") or name:find("game") or name:find("stui") or name:find("scooge") or name:find("client") then
                    table.insert(r, "ScreenGui: " .. screenGui.Name)
                    -- Look for all descendants
                    for _, desc in ipairs(screenGui:GetDescendants()) do
                        if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                            if desc.Text ~= "" and desc.Text ~= " " then
                                table.insert(r, "  " .. desc.Name .. " = '" .. desc.Text .. "'")
                            end
                        end
                    end
                    table.insert(r, "")
                end
            end
        end
    end
    table.insert(r, "")
    
    -- 3. ALL VALUES IN TOOLS (including nested)
    table.insert(r, "--- TOOL VALUES (ALL) ---")
    if LocalPlayer.Character then
        for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(r, "Tool: " .. tool.Name)
                for _, v in ipairs(tool:GetDescendants()) do
                    table.insert(r, "  " .. v.ClassName .. " '" .. v.Name .. "' = " .. tostring(v))
                end
            end
        end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(r, "Tool: " .. tool.Name)
                for _, v in ipairs(tool:GetDescendants()) do
                    table.insert(r, "  " .. v.ClassName .. " '" .. v.Name .. "' = " .. tostring(v))
                end
            end
        end
    end
    table.insert(r, "")
    
    -- 4. ALL SCREEN GUIS
    table.insert(r, "--- ALL SCREEN GUIS ---")
    if playerGui then
        for _, screenGui in ipairs(playerGui:GetChildren()) do
            if screenGui:IsA("ScreenGui") then
                table.insert(r, screenGui.Name .. " (Enabled: " .. tostring(screenGui.Enabled) .. ")")
            end
        end
    end
    table.insert(r, "")
    
    -- 5. LOOK FOR AMMO-SPECIFIC NAMES
    table.insert(r, "--- AMMO SEARCH ---")
    if playerGui then
        for _, desc in ipairs(playerGui:GetDescendants()) do
            local name = desc.Name:lower()
            if name:find("ammo") or name:find("clip") or name:find("mag") or name:find("bullet") or name:find("reload") or name:find("round") then
                table.insert(r, desc.ClassName .. " '" .. desc.Name .. "'")
                if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                    table.insert(r, "  Text: '" .. desc.Text .. "'")
                end
                if desc:IsA("ValueBase") then
                    table.insert(r, "  Value: " .. tostring(desc.Value))
                end
                table.insert(r, "")
            end
        end
    end
    table.insert(r, "")
    
    -- 6. COREGUI (sometimes weapon UI is here)
    table.insert(r, "--- COREGUI ---")
    pcall(function()
        local coreGui = game:GetService("CoreGui")
        for _, desc in ipairs(coreGui:GetDescendants()) do
            if desc:IsA("TextLabel") then
                if desc.Text:match("%d") and #desc.Text < 20 then
                    table.insert(r, desc.Name .. " = '" .. desc.Text .. "'")
                end
            end
        end
    end)
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

print("[SH] Ammo Collector aberto!")

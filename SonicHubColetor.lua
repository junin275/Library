-- ============================================
-- SHADOW HUB - COLETOR MINI (MOBILE)
-- ============================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- GUI Mini
local gui = Instance.new("ScreenGui")
gui.Name = "AmmoMini"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Botao flutuante
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 60, 0, 60)
btn.Position = UDim2.new(0, 10, 0.5, -30)
btn.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
btn.Text = "COLETAR"
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 10
btn.Parent = gui
Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

-- Status popup
local popup = Instance.new("Frame")
popup.Size = UDim2.new(0, 200, 0, 40)
popup.Position = UDim2.new(0, 80, 0.5, -20)
popup.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
popup.BorderSizePixel = 0
popup.Visible = false
popup.Parent = gui
Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", popup).Color = Color3.fromRGB(0, 180, 100)

local popupText = Instance.new("TextLabel", popup)
popupText.Size = UDim2.new(1, 0, 1, 0)
popupText.BackgroundTransparency = 1
popupText.Text = "COPIADO!"
popupText.TextColor3 = Color3.fromRGB(0, 255, 100)
popupText.Font = Enum.Font.GothamBold
popupText.TextSize = 12

-- Funcao coletar
local function Collect()
    local r = {}
    table.insert(r, "=== AMMO DATA ===")
    
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        -- Numeros na tela
        for _, g in ipairs(playerGui:GetDescendants()) do
            if g:IsA("TextLabel") or g:IsA("TextButton") then
                local t = g.Text
                if t:match("%d") and #t < 15 then
                    table.insert(r, g.Name .. " = '" .. t .. "'")
                end
            end
        end
    end
    
    -- Arma equipada
    if LocalPlayer.Character then
        for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(r, "TOOL: " .. tool.Name)
                for _, v in ipairs(tool:GetDescendants()) do
                    if v:IsA("ValueBase") then
                        table.insert(r, "  " .. v.Name .. " = " .. tostring(v.Value))
                    end
                    if v:IsA("RemoteEvent") then
                        table.insert(r, "  Remote: " .. v.Name)
                    end
                end
            end
        end
    end
    
    -- Backpack
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(r, "BACKPACK: " .. tool.Name)
                for _, v in ipairs(tool:GetDescendants()) do
                    if v:IsA("ValueBase") then
                        table.insert(r, "  " .. v.Name .. " = " .. tostring(v.Value))
                    end
                end
            end
        end
    end
    
    -- ScreenGuis
    if playerGui then
        for _, sg in ipairs(playerGui:GetChildren()) do
            if sg:IsA("ScreenGui") then
                local n = sg.Name:lower()
                if n:find("hud") or n:find("weapon") or n:find("stui") or n:find("client") then
                    table.insert(r, "GUI: " .. sg.Name)
                    for _, d in ipairs(sg:GetDescendants()) do
                        if d:IsA("TextLabel") and d.Text ~= "" then
                            table.insert(r, "  " .. d.Name .. " = '" .. d.Text .. "'")
                        end
                    end
                end
            end
        end
    end
    
    local data = table.concat(r, "\n")
    
    pcall(function()
        if setclipboard then
            setclipboard(data)
        end
    end)
    
    popup.Visible = true
    popupText.Text = "COPIADO! (" .. #r .. " linhas)"
    task.delay(2, function()
        popup.Visible = false
    end)
end

btn.MouseButton1Click:Connect(Collect)

print("[SH] Ammo Mini aberto!")

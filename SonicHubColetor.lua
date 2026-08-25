local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "AmmoPath"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 60, 0, 60)
btn.Position = UDim2.new(0, 10, 0.5, -30)
btn.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
btn.Text = "PROCURAR"
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 9
btn.Parent = gui
Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

local popup = Instance.new("Frame")
popup.Size = UDim2.new(0, 250, 0, 40)
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

local function Collect()
    local r = {}
    table.insert(r, "=== AMMO PATH DATA ===")
    
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Find the "0 / 30" style ammo
    table.insert(r, "")
    table.insert(r, "--- AMMO (x / y) ---")
    for _, g in ipairs(playerGui:GetDescendants()) do
        if g:IsA("TextLabel") or g:IsA("TextButton") then
            local t = g.Text
            if t:match("%d+%s*/%s*%d+") then
                table.insert(r, "FOUND: '" .. t .. "'")
                table.insert(r, "  Name: " .. g.Name)
                table.insert(r, "  Class: " .. g.ClassName)
                table.insert(r, "  Path: " .. g:GetFullName())
                table.insert(r, "  Visible: " .. tostring(g.Visible))
                table.insert(r, "  Parent: " .. g.Parent:GetFullName())
                
                -- Check parent hierarchy
                local p = g.Parent
                for i = 1, 5 do
                    if p and p.Parent then
                        table.insert(r, "  Parent" .. i .. ": " .. p:GetFullName())
                        p = p.Parent
                    end
                end
                table.insert(r, "")
            end
        end
    end
    
    -- Also find single numbers that could be ammo
    table.insert(r, "--- SINGLE NUMBERS ---")
    for _, g in ipairs(playerGui:GetDescendants()) do
        if g:IsA("TextLabel") then
            local t = g.Text
            if t:match("^%d+$") and tonumber(t) and tonumber(t) <= 200 and tonumber(t) > 0 then
                table.insert(r, g.Name .. " = '" .. t .. "' Path: " .. g:GetFullName())
            end
        end
    end
    
    -- Weapon name in use
    table.insert(r, "")
    table.insert(r, "--- WEAPON IN USE ---")
    for _, g in ipairs(playerGui:GetDescendants()) do
        if g:IsA("TextLabel") then
            local t = g.Text
            if t:match("%[.-%]") then
                table.insert(r, g.Name .. " = '" .. t .. "' Path: " .. g:GetFullName())
            end
        end
    end
    
    table.insert(r, "")
    table.insert(r, "=== FIM ===")
    
    local data = table.concat(r, "\n")
    pcall(function()
        if setclipboard then setclipboard(data) end
    end)
    
    popup.Visible = true
    popupText.Text = "COPIADO! (" .. #r .. " linhas)"
    task.delay(2, function()
        popup.Visible = false
    end)
end

btn.MouseButton1Click:Connect(Collect)
print("[SH] Ammo Path aberto!")

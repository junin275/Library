local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "BtnFinder"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 60, 0, 60)
btn.Position = UDim2.new(0, 10, 0.5, -30)
btn.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
btn.Text = "ACHAR"
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 10
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
    table.insert(r, "=== BUTTONS ===")
    
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Find ALL TextButtons
    for _, g in ipairs(playerGui:GetDescendants()) do
        if g:IsA("TextButton") or g:IsA("ImageButton") then
            local name = g.Name:lower()
            local text = ""
            if g:IsA("TextButton") then text = g.Text end
            
            -- Check if could be reload
            if name:find("reload") or name:find("r") or name:find("ammo") or name:find("bullet") 
            or text:lower():find("reload") or text:lower():find("recarregar")
            or name:find("fire") or name:find("shoot") or name:find("attack") then
                table.insert(r, g.ClassName .. " '" .. g.Name .. "' Text='" .. text .. "'")
                table.insert(r, "  Path: " .. g:GetFullName())
                table.insert(r, "  Visible: " .. tostring(g.Visible))
                table.insert(r, "  Active: " .. tostring(g.Active))
                table.insert(r, "")
            end
        end
    end
    
    -- Find ALL buttons in ReactUI
    table.insert(r, "--- REACTUI BUTTONS ---")
    local reactUI = playerGui:FindFirstChild("ReactUI")
    if reactUI then
        for _, g in ipairs(reactUI:GetDescendants()) do
            if g:IsA("TextButton") or g:IsA("ImageButton") then
                local text = ""
                if g:IsA("TextButton") then text = g.Text end
                table.insert(r, g.Name .. " = '" .. text .. "'")
            end
        end
    end
    table.insert(r, "")
    
    -- Find buttons with images (could be icon buttons)
    table.insert(r, "--- IMAGE BUTTONS ---")
    for _, g in ipairs(playerGui:GetDescendants()) do
        if g:IsA("ImageButton") then
            table.insert(r, g.Name .. " Image=" .. g.Image)
            table.insert(r, "  Path: " .. g:GetFullName())
        end
    end
    table.insert(r, "")
    
    -- Find button-like frames
    table.insert(r, "--- CLICKABLE FRAMES ---")
    for _, g in ipairs(playerGui:GetDescendants()) do
        if g:IsA("Frame") and g.Active then
            local name = g.Name:lower()
            if name:find("reload") or name:find("btn") or name:find("button") then
                table.insert(r, g.Name .. " Active=true Path: " .. g:GetFullName())
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
print("[SH] Button Finder aberto!")

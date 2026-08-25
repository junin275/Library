-- ============================================
-- SHADOW HUB - DEBUG RELOAD (DELTA)
-- ============================================

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "DebugReload"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 250)
frame.Position = UDim2.new(0.5, -150, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(255, 100, 50)

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(255, 100, 50)
title.BackgroundTransparency = 0.8
title.Text = "DEBUG RELOAD - DELTA"
title.TextColor3 = Color3.fromRGB(255, 100, 50)
title.Font = Enum.Font.GothamBold
title.TextSize = 12

-- Ammo Display
local ammoLabel = Instance.new("TextLabel", frame)
ammoLabel.Size = UDim2.new(1, -10, 0, 30)
ammoLabel.Position = UDim2.new(0, 5, 0, 30)
ammoLabel.BackgroundTransparency = 1
ammoLabel.Text = "AMMO: verificando..."
ammoLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
ammoLabel.Font = Enum.Font.Code
ammoLabel.TextSize = 12

-- Status
local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, -10, 0, 30)
statusLabel.Position = UDim2.new(0, 5, 0, 60)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "STATUS: aguardando..."
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.Font = Enum.Font.Code
statusLabel.TextSize = 10

-- Button Status
local btnStatus = Instance.new("TextLabel", frame)
btnStatus.Size = UDim2.new(1, -10, 0, 30)
btnStatus.Position = UDim2.new(0, 5, 0, 90)
btnStatus.BackgroundTransparency = 1
btnStatus.Text = "BOTAO: procurando..."
btnStatus.TextColor3 = Color3.fromRGB(100, 200, 255)
btnStatus.Font = Enum.Font.Code
btnStatus.TextSize = 10

-- Test Reload Button
local testBtn = Instance.new("TextButton", frame)
testBtn.Size = UDim2.new(0.9, 0, 0, 35)
testBtn.Position = UDim2.new(0.05, 0, 0, 130)
testBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
testBtn.Text = "TESTAR RELOAD"
testBtn.TextColor3 = Color3.new(1, 1, 1)
testBtn.Font = Enum.Font.GothamBold
testBtn.TextSize = 12
Instance.new("UICorner", testBtn).CornerRadius = UDim.new(0, 6)

-- Test Key R Button
local testKeyBtn = Instance.new("TextButton", frame)
testKeyBtn.Size = UDim2.new(0.9, 0, 0, 35)
testKeyBtn.Position = UDim2.new(0.05, 0, 0, 170)
testKeyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 255)
testKeyBtn.Text = "TESTAR TECLA R"
testKeyBtn.TextColor3 = Color3.new(1, 1, 1)
testKeyBtn.Font = Enum.Font.GothamBold
testKeyBtn.TextSize = 12
Instance.new("UICorner", testKeyBtn).CornerRadius = UDim.new(0, 6)

-- Close Button
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0.9, 0, 0, 25)
closeBtn.Position = UDim2.new(0.05, 0, 0, 210)
closeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
closeBtn.Text = "FECHAR"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 10
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

-- Functions
local function GetAmmo()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end

    local ammoUI = playerGui:FindFirstChild("ReactUI")
        and playerGui.ReactUI:FindFirstChild("AmmoUI")
        and playerGui.ReactUI.AmmoUI:FindFirstChild("AmmoLine")
        and playerGui.ReactUI.AmmoLine:FindFirstChild("Text")
        and playerGui.ReactUI.AmmoLine.Text:FindFirstChild("Main")

    if ammoUI then
        local text = ammoUI.Text
        local current, max = text:match("(%d+)%s*|%s*(%d+)")
        if current and max then
            return tonumber(current), tonumber(max), text
        end
    end
    return nil
end

local function GetReloadButton()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    local reactUI = playerGui:FindFirstChild("ReactUI")
    if not reactUI then return nil end
    local mobileUI = reactUI:FindFirstChild("MobileControlsUI")
    if not mobileUI then return nil end
    return mobileUI:FindFirstChild("ReloadButton")
end

local function TestReload()
    local reloadBtn = GetReloadButton()
    if not reloadBtn then
        btnStatus.Text = "BOTAO: NAO ENCONTRADO!"
        return
    end

    local absPos = reloadBtn.AbsolutePosition
    local absSize = reloadBtn.AbsoluteSize
    local centerX = absPos.X + absSize.X / 2
    local centerY = absPos.Y + absSize.Y / 2

    btnStatus.Text = "BOTAO: " .. math.floor(centerX) .. "," .. math.floor(centerY)
    statusLabel.Text = "STATUS: clicando..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)

    -- Method 1: VirtualInputManager
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
        task.wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
    end)

    statusLabel.Text = "STATUS: cliquei VIM!"
    task.wait(1)

    -- Check if ammo changed
    local newAmmo = GetAmmo()
    if newAmmo then
        statusLabel.Text = "STATUS: ammo=" .. tostring(newAmmo)
    end
end

local function TestKeyR()
    statusLabel.Text = "STATUS: tecla R..."
    statusLabel.TextColor3 = Color3.fromRGB(100, 100, 255)

    -- Try keypress
    pcall(function()
        -- Delta keypress
        if keypress then
            keypress(0x52) -- R key
            task.wait(0.1)
            keyrelease(0x52)
        end
    end)

    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
    end)

    statusLabel.Text = "STATUS: enviei R!"
    task.wait(1)
end

-- Update Loop
task.spawn(function()
    while true do
        local ammo, max, raw = GetAmmo()
        if ammo then
            ammoLabel.Text = "AMMO: " .. ammo .. " / " .. max .. " [" .. raw .. "]"
        else
            ammoLabel.Text = "AMMO: nao encontrado"
        end
        task.wait(0.5)
    end
end)

testBtn.MouseButton1Click:Connect(TestReload)
testKeyBtn.MouseButton1Click:Connect(TestKeyR)
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

print("[SH] Debug Reload Delta aberto!")

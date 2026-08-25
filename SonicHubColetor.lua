-- ============================================
-- SHADOW HUB - MONITOR DE ARMA (MOBILE)
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "WeaponMonitor"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 500)
frame.Position = UDim2.new(0.5, -175, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(180, 0, 255)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
title.BackgroundTransparency = 0.8
title.Text = "WEAPON MONITOR"
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
statusLabel.Text = "Observando armas... Atire!"
statusLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10

local clearBtn = Instance.new("TextButton", frame)
clearBtn.Size = UDim2.new(0.48, -5, 0, 35)
clearBtn.Position = UDim2.new(0.01, 5, 1, -55)
clearBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
clearBtn.Text = "LIMPAR"
clearBtn.TextColor3 = Color3.new(1, 1, 1)
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 14
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 6)

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

local logs = {}
local collectedData = ""

local function AddLog(msg)
    table.insert(logs, os.date("%H:%M:%S") .. " " .. msg)
    textLabel.Text = table.concat(logs, "\n")
end

-- Monitor ShootEvent
local shootEvent = ReplicatedStorage:FindFirstChild("ShootEvent")
if shootEvent then
    -- Hook into shoot event
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and self == shootEvent then
            AddLog("[SHOOT] ShootEvent Fired!")
        end
        return oldNamecall(self, ...)
    end)
end

-- Monitor all remotes firing
for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        local connection
        connection = remote.OnClientEvent:Connect(function(...)
            local args = {...}
            local argStr = ""
            for i, v in ipairs(args) do
                argStr = argStr .. tostring(v) .. " "
            end
            AddLog("[REMOTE] " .. remote.Name .. ": " .. argStr)
        end)
    end
end

-- Monitor character tool changes
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    AddLog("[CHAR] Character loaded: " .. char.Name)
    
    -- Monitor tool equipped
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            AddLog("[TOOL] Equipped: " .. child.Name)
            
            -- Monitor all values in tool
            for _, val in ipairs(child:GetDescendants()) do
                if val:IsA("ValueBase") then
                    AddLog("[VALUE] " .. val.Name .. " = " .. tostring(val.Value))
                end
            end
        end
    end
end)

-- Monitor backpack changes
LocalPlayer.Backpack.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        AddLog("[BACKPACK] Tool added: " .. child.Name)
    end
end)

LocalPlayer.Backpack.ChildRemoved:Connect(function(child)
    if child:IsA("Tool") then
        AddLog("[BACKPACK] Tool removed: " .. child.Name)
    end
end)

-- Monitor game events
game:GetService("Players").PlayerAdded:Connect(function(p)
    AddLog("[PLAYER] " .. p.Name .. " joined")
end)

game:GetService("Players").PlayerRemoving:Connect(function(p)
    AddLog("[PLAYER] " .. p.Name .. " left")
end)

-- Monitor workspace changes (for weapon drops, etc.)
Workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("Tool") then
        AddLog("[WORKSPACE] Tool found: " .. desc:GetFullName())
    end
end)

-- Auto collect basic info
task.spawn(function()
    task.wait(2)
    AddLog("=== INFORMACOES ===")
    AddLog("Arma equipada: " .. tostring(LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")))
    AddLog("Remotes monitorados!")
    AddLog("")
    AddLog("=== ATIRE PRA VER ===")
    AddLog("Observando ShootEvent...")
    AddLog("")
end)

clearBtn.MouseButton1Click:Connect(function()
    logs = {}
    textLabel.Text = ""
    statusLabel.Text = "Limpo! Atire pra ver eventos"
end)

copyBtn.MouseButton1Click:Connect(function()
    collectedData = table.concat(logs, "\n")
    pcall(function()
        if setclipboard then
            setclipboard(collectedData)
        end
    end)
    statusLabel.Text = "COPIADO!"
    statusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

print("[SH] Weapon Monitor aberto!")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "AmmoWatch"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main label
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 350, 0, 25)
label.Position = UDim2.new(0.5, -175, 0, 5)
label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
label.BackgroundTransparency = 0.3
label.TextColor3 = Color3.fromRGB(0, 255, 0)
label.Font = Enum.Font.Code
label.TextSize = 13
label.Text = "AMMO: carregando..."
label.Parent = gui

-- Log label
local log = Instance.new("TextLabel")
log.Size = UDim2.new(0, 350, 0, 120)
log.Position = UDim2.new(0.5, -175, 0, 35)
log.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
log.BackgroundTransparency = 0.3
log.TextColor3 = Color3.fromRGB(255, 255, 100)
log.Font = Enum.Font.Code
log.TextSize = 11
log.Text = ""
log.TextYAlignment = Enum.TextYAlignment.Top
log.TextWrapped = true
log.Parent = gui

local lastAmmo = nil
local logs = {}

local function GetAmmoText()
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	if not playerGui then return nil end
	local reactUI = playerGui:FindFirstChild("ReactUI")
	if not reactUI then return nil end
	local ammoUI = reactUI:FindFirstChild("AmmoUI")
	if not ammoUI then return nil end
	local ammoLine = ammoUI:FindFirstChild("AmmoLine")
	if not ammoLine then return nil end
	local text = ammoLine:FindFirstChild("Text")
	if not text then return nil end
	local main = text:FindFirstChild("Main")
	if not main then return nil end
	return main.Text
end

local function ParseAmmo(raw)
	if not raw then return nil, nil end
	local current, max = raw:match("(%d+)%s*|%s*(%d+)")
	if current and max then
		return tonumber(current), tonumber(max)
	end
	return nil, nil
end

local function AddLog(msg)
	table.insert(logs, 1, os.date("%H:%M:%S") .. " " .. msg)
	if #logs > 8 then table.remove(logs) end
	log.Text = table.concat(logs, "\n")
end

RunService.RenderStepped:Connect(function()
	local raw = GetAmmoText()
	if raw then
		local current, max = ParseAmmo(raw)
		if current then
			label.Text = "AMMO: " .. current .. " / " .. max .. "  RAW: " .. raw

			if lastAmmo and current ~= lastAmmo then
				AddLog("MUDOU: " .. lastAmmo .. " -> " .. current)

				if current == 0 then
					AddLog(">>> AMMO ZERO! Ia recarregar <<<")
					label.TextColor3 = Color3.fromRGB(255, 0, 0)
				elseif current > 0 then
					label.TextColor3 = Color3.fromRGB(0, 255, 0)
				end
			end

			lastAmmo = current
		else
			label.Text = "NAO PARSEOU: " .. raw
			label.TextColor3 = Color3.fromRGB(255, 255, 0)
		end
	else
		label.Text = "NAO ACHOU AmmoUI"
		label.TextColor3 = Color3.fromRGB(255, 0, 0)
	end
end)

print("[SH] Ammo Watch aberto! Atira pra ver!")

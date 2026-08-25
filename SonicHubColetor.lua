local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "AmmoDebug"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 300, 0, 30)
label.Position = UDim2.new(0.5, -150, 0, 10)
label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
label.BackgroundTransparency = 0.3
label.TextColor3 = Color3.fromRGB(0, 255, 0)
label.Font = Enum.Font.Code
label.TextSize = 14
label.Text = "AMMO: carregando..."
label.Parent = gui

RunService.RenderStepped:Connect(function()
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	if not playerGui then label.Text = "NO PLAYERGUI" return end

	-- Try direct path
	local ok, result = pcall(function()
		local reactUI = playerGui:WaitForChild("ReactUI", 3)
		if not reactUI then return "NO ReactUI" end

		local ammoUI = reactUI:FindFirstChild("AmmoUI")
		if not ammoUI then return "NO AmmoUI" end

		local ammoLine = ammoUI:FindFirstChild("AmmoLine")
		if not ammoLine then return "NO AmmoLine" end

		local text = ammoLine:FindFirstChild("Text")
		if not text then return "NO Text" end

		local main = text:FindFirstChild("Main")
		if not main then return "NO Main" end

		return "Main.Text = '" .. main.Text .. "'"
	end)

	if ok then
		label.Text = "AMMO: " .. result
	else
		label.Text = "ERROR: " .. tostring(result)
	end
end)

print("[SH] Ammo Debug aberto!")

-- ============================================
-- SHADOW HUB - COLETOR DE DADOS
-- Cole todo o resultado e mande pro dev
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local result = {}
table.insert(result, "========================================")
table.insert(result, "SHADOW HUB - DADOS COLETADOS")
table.insert(result, "========================================")
table.insert(result, "")

-- 1. CHARACTER INFO
table.insert(result, "--- CHARACTER ---")
if LocalPlayer.Character then
    local char = LocalPlayer.Character
    table.insert(result, "Character: " .. char.Name)
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("Tool") then
            table.insert(result, "  TOOL: " .. v.Name)
            table.insert(result, "    CanBeDropped: " .. tostring(v.CanBeDropped))
            table.insert(result, "    RequiresHandle: " .. tostring(v.RequiresHandle))
            table.insert(result, "    ClassName: " .. v.ClassName)
            
            -- Values
            table.insert(result, "    VALUES:")
            for _, val in ipairs(v:GetDescendants()) do
                if val:IsA("ValueBase") then
                    table.insert(result, "      " .. val.ClassName .. " '" .. val.Name .. "' = " .. tostring(val.Value))
                end
            end
            
            -- RemoteEvents
            table.insert(result, "    REMOTES:")
            for _, remote in ipairs(v:GetDescendants()) do
                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                    table.insert(result, "      " .. remote.ClassName .. " '" .. remote.Name .. "'")
                end
            end
            
            -- Scripts
            table.insert(result, "    SCRIPTS:")
            for _, script in ipairs(v:GetDescendants()) do
                if script:IsA("BaseScript") then
                    table.insert(result, "      " .. script.ClassName .. " '" .. script.Name .. "'")
                end
            end
        end
    end
else
    table.insert(result, "NO CHARACTER FOUND")
end
table.insert(result, "")

-- 2. BACKPACK INFO
table.insert(result, "--- BACKPACK ---")
local backpack = LocalPlayer:FindFirstChild("Backpack")
if backpack then
    for _, v in ipairs(backpack:GetDescendants()) do
        if v:IsA("Tool") then
            table.insert(result, "  TOOL: " .. v.Name)
            for _, val in ipairs(v:GetDescendants()) do
                if val:IsA("ValueBase") then
                    table.insert(result, "    " .. val.ClassName .. " '" .. val.Name .. "' = " .. tostring(val.Value))
                end
            end
            for _, remote in ipairs(v:GetDescendants()) do
                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                    table.insert(result, "    " .. remote.ClassName .. " '" .. remote.Name .. "'")
                end
            end
        end
    end
else
    table.insert(result, "NO BACKPACK")
end
table.insert(result, "")

-- 3. PLAYERGui WEAPON UI
table.insert(result, "--- WEAPON UI (PlayerGui) ---")
local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
if playerGui then
    for _, gui in ipairs(playerGui:GetDescendants()) do
        if gui:IsA("Frame") or gui:IsA("TextLabel") or gui:IsA("ImageLabel") then
            if gui.Name:lower():find("ammo") or gui.Name:lower():find("clip") or gui.Name:lower():find("weapon") or gui.Name:lower():find("gun") or gui.Name:lower():find("bullet") then
                table.insert(result, "  " .. gui.ClassName .. " '" .. gui.Name .. "'")
                if gui:IsA("TextLabel") then
                    table.insert(result, "    Text: " .. gui.Text)
                end
            end
        end
    end
end
table.insert(result, "")

-- 4. STUI weapon UIs
table.insert(result, "--- STUI WEAPON FRAMES ---")
if playerGui then
    local stui = playerGui:FindFirstChild("ScoogeUI") or playerGui:FindFirstChild("STUI")
    if stui then
        table.insert(result, "Found: " .. stui.Name)
        for _, frame in ipairs(stui:GetDescendants()) do
            if frame:IsA("Frame") then
                local name = frame.Name:lower()
                if name:find("weapon") or name:find("gun") or name:find("ammo") or name:find("clip") or name:find("bullet") then
                    table.insert(result, "  Frame: " .. frame.Name)
                end
            end
        end
    end
end
table.insert(result, "")

-- 5. HIGHLIGHT COLORS (TEAM INFO)
table.insert(result, "--- HIGHLIGHT TEAMS ---")
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        local char = player.Character
        if char then
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("Highlight") then
                    local oc = v.OutlineColor
                    local fc = v.FillColor
                    table.insert(result, player.DisplayName .. ": Outline(" .. 
                        math.floor(oc.R*255) .. "," .. math.floor(oc.G*255) .. "," .. math.floor(oc.B*255) .. ") " ..
                        "Fill(" .. math.floor(fc.R*255) .. "," .. math.floor(fc.G*255) .. "," .. math.floor(fc.B*255) .. ")")
                end
            end
        end
    end
end
table.insert(result, "")

-- 6. REMOTES IN REPLICATEDSTORAGE
table.insert(result, "--- REPLICATEDSTORAGE REMOTES ---")
for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
        if remote.Name:lower():find("reload") or remote.Name:lower():find("shoot") or remote.Name:lower():find("fire") or remote.Name:lower():find("weapon") or remote.Name:lower():find("ammo") then
            table.insert(result, "  " .. remote.ClassName .. " '" .. remote.Name .. "'")
        end
    end
end
table.insert(result, "")

-- 7. COREGUI (SCREEN GUIS)
table.insert(result, "--- SCREEN GUIS ---")
if playerGui then
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            table.insert(result, "  " .. gui.Name .. " (Enabled: " .. tostring(gui.Enabled) .. ")")
        end
    end
end
table.insert(result, "")

-- 8. ALL TOOLS IN GAME
table.insert(result, "--- ALL TOOLS IN WORKSPACE ---")
local Workspace = game:GetService("Workspace")
for _, tool in ipairs(Workspace:GetDescendants()) do
    if tool:IsA("Tool") then
        table.insert(result, "  Tool: " .. tool:GetFullName())
    end
end
table.insert(result, "")

-- FINAL
table.insert(result, "========================================")
table.insert(result, "FIM DOS DADOS")
table.insert(result, "========================================")

-- Print all
local fullResult = table.concat(result, "\n")
print(fullResult)

-- Also copy to clipboard
pcall(function()
    if setclipboard then
        setclipboard(fullResult)
    end
end)

return fullResult

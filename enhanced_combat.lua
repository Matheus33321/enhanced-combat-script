-- Clean Combat Enhancer - No diagnostics, direct execution
-- Replace your GitHub file with this code ONLY

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Clean up any existing GUIs
for _, gui in pairs(playerGui:GetChildren()) do
    if gui.Name == "CombatEnhancerGui" or gui.Name == "CombatEnhancerDiagnostic" then
        gui:Destroy()
    end
end

print("🚀 Combat Enhancer - Loading...")

local improvements = {
    infiniteStamina = false,
    noStun = false,
    reducedCooldown = false,
    fastCombo = false
}

-- Create GUI immediately
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CombatEnhancerGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Parent = screenGui
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
frame.BorderSizePixel = 0
frame.Position = UDim2.new(0, 50, 0, 50)
frame.Size = UDim2.new(0, 250, 0, 300)
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Parent = frame
title.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
title.BorderSizePixel = 0
title.Size = UDim2.new(1, 0, 0, 40)
title.Font = Enum.Font.GothamBold
title.Text = "⚡ COMBAT ENHANCER"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

local titleFix = Instance.new("Frame")
titleFix.Parent = title
titleFix.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
titleFix.BorderSizePixel = 0
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.Size = UDim2.new(1, 0, 0.5, 0)

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = title
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.BorderSizePixel = 0
closeBtn.Position = UDim2.new(1, -35, 0.5, -12)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 14

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 12)
closeBtnCorner.Parent = closeBtn

-- Status
local status = Instance.new("TextLabel")
status.Parent = frame
status.BackgroundTransparency = 1
status.Position = UDim2.new(0, 10, 0, 50)
status.Size = UDim2.new(1, -20, 0, 20)
status.Font = Enum.Font.Gotham
status.Text = "Ready - Press F1 to toggle"
status.TextColor3 = Color3.fromRGB(100, 255, 100)
status.TextSize = 11

-- Buttons
local yPos = 80
local buttons = {}

local options = {
    {name = "♾️ Infinite Stamina", key = "infiniteStamina"},
    {name = "🛡️ No Stun", key = "noStun"},
    {name = "⚡ Reduced Cooldown", key = "reducedCooldown"},
    {name = "🔥 Fast Combo", key = "fastCombo"}
}

for _, option in ipairs(options) do
    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    btn.BorderSizePixel = 0
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = "❌ " .. option.name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        improvements[option.key] = not improvements[option.key]
        if improvements[option.key] then
            btn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
            btn.Text = "✅ " .. option.name
            status.Text = option.name .. " - ENABLED"
            status.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            btn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
            btn.Text = "❌ " .. option.name
            status.Text = option.name .. " - DISABLED"
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        applyImprovement(option.key, improvements[option.key])
    end)

    yPos = yPos + 50
end

-- Apply improvements function
function applyImprovement(key, enabled)
    if key == "infiniteStamina" then
        if enabled then
            spawn(function()
                while improvements.infiniteStamina do
                    pcall(function()
                        if player.Character and player.Character:FindFirstChild("Humanoid") then
                            local combatState = player.Character.Humanoid:FindFirstChild("CombatState")
                            if combatState and combatState:FindFirstChild("Stamina") then
                                combatState.Stamina.Value = 100
                            end
                        end
                    end)
                    wait(0.1)
                end
            end)
        end
    
    elseif key == "noStun" then
        if enabled then
            spawn(function()
                while improvements.noStun do
                    pcall(function()
                        if player.Character and player.Character:FindFirstChild("Humanoid") then
                            local combatState = player.Character.Humanoid:FindFirstChild("CombatState")
                            if combatState and combatState:FindFirstChild("Stunned") then
                                if combatState.Stunned.Value == true then
                                    combatState.Stunned.Value = false
                                end
                            end
                        end
                    end)
                    wait(0.05)
                end
            end)
        end
    
    elseif key == "reducedCooldown" then
        pcall(function()
            local config = ReplicatedStorage:FindFirstChild("CombatConfiguration")
            if config and config:FindFirstChild("Attacking") then
                local cooldowns = config.Attacking:FindFirstChild("Cooldowns")
                if cooldowns then
                    for _, cooldown in pairs(cooldowns:GetChildren()) do
                        if cooldown:IsA("NumberValue") then
                            if enabled then
                                if not cooldown:GetAttribute("Original") then
                                    cooldown:SetAttribute("Original", cooldown.Value)
                                end
                                cooldown.Value = cooldown:GetAttribute("Original") * 0.2
                            else
                                if cooldown:GetAttribute("Original") then
                                    cooldown.Value = cooldown:GetAttribute("Original")
                                end
                            end
                        end
                    end
                end
            end
        end)
    
    elseif key == "fastCombo" then
        pcall(function()
            local config = ReplicatedStorage:FindFirstChild("CombatConfiguration")
            if config and config:FindFirstChild("Combo") then
                local expireTime = config.Combo:FindFirstChild("ExpireTime")
                if expireTime then
                    if enabled then
                        if not expireTime:GetAttribute("Original") then
                            expireTime:SetAttribute("Original", expireTime.Value)
                        end
                        expireTime.Value = 999999
                    else
                        if expireTime:GetAttribute("Original") then
                            expireTime.Value = expireTime:GetAttribute("Original")
                        end
                    end
                end
            end
        end)
    end
end

-- Event handlers
closeBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        screenGui.Enabled = not screenGui.Enabled
    elseif input.KeyCode == Enum.KeyCode.F2 then
        improvements.infiniteStamina = not improvements.infiniteStamina
        applyImprovement("infiniteStamina", improvements.infiniteStamina)
        status.Text = "Infinite Stamina: " .. (improvements.infiniteStamina and "ON" or "OFF")
    end
end)

-- Character respawn handler
player.CharacterAdded:Connect(function(character)
    wait(2)
    for key, enabled in pairs(improvements) do
        if enabled then
            applyImprovement(key, enabled)
        end
    end
end)

-- Initial setup if character exists
if player.Character then
    spawn(function()
        wait(2)
        for key, enabled in pairs(improvements) do
            if enabled then
                applyImprovement(key, enabled)
            end
        end
    end)
end

print("✅ Combat Enhancer loaded!")
print("📋 Press F1 to toggle GUI")
print("📋 Press F2 for quick infinite stamina")

return improvements

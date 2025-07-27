-- Direct Combat Enhancer - Baseado no seu sistema original
-- Execute: loadstring(game:HttpGet("https://raw.githubusercontent.com/Matheus33321/enhanced-combat-script/main/enhanced_combat.lua"))()

print("🚀 Combat Enhancer - Direct Mode")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove any existing GUI
local existingGui = playerGui:FindFirstChild("CombatEnhancerGui")
if existingGui then existingGui:Destroy() end

-- Configuration
local improvements = {
    infiniteStamina = false,
    noStun = false,
    reducedCooldown = false,
    fastCombo = false,
    superSpeed = false
}

local originalValues = {}

-- Create simple GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CombatEnhancerGui"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0, 20, 0, 100)
    mainFrame.Size = UDim2.new(0, 280, 0, 350)
    mainFrame.Active = true
    mainFrame.Draggable = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    -- Header
    local header = Instance.new("Frame")
    header.Parent = mainFrame
    header.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, 40)

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header

    local headerFix = Instance.new("Frame")
    headerFix.Parent = header
    headerFix.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
    headerFix.BorderSizePixel = 0
    headerFix.Position = UDim2.new(0, 0, 0.5, 0)
    headerFix.Size = UDim2.new(1, 0, 0.5, 0)

    local title = Instance.new("TextLabel")
    title.Parent = header
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Font = Enum.Font.GothamBold
    title.Text = "⚡ Combat Enhancer"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Center

    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = header
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.BorderSizePixel = 0
    closeBtn.Position = UDim2.new(1, -35, 0.5, -12)
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16

    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 12)
    closeBtnCorner.Parent = closeBtn

    -- Status
    local status = Instance.new("TextLabel")
    status.Parent = mainFrame
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    status.BorderSizePixel = 0
    status.Position = UDim2.new(0, 10, 0, 50)
    status.Size = UDim2.new(1, -20, 0, 25)
    status.Font = Enum.Font.Gotham
    status.Text = "Status: Ready"
    status.TextColor3 = Color3.fromRGB(100, 255, 100)
    status.TextSize = 12

    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 4)
    statusCorner.Parent = status

    -- Buttons
    local yPos = 85
    local buttons = {}

    local options = {
        {name = "♾️ Infinite Stamina", key = "infiniteStamina"},
        {name = "🛡️ No Stun", key = "noStun"},
        {name = "⚡ Reduced Cooldown", key = "reducedCooldown"},
        {name = "🔥 Fast Combo", key = "fastCombo"},
        {name = "💨 Super Speed", key = "superSpeed"}
    }

    for _, option in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Parent = mainFrame
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        btn.BorderSizePixel = 0
        btn.Position = UDim2.new(0, 10, 0, yPos)
        btn.Size = UDim2.new(1, -20, 0, 35)
        btn.Font = Enum.Font.GothamSemibold
        btn.Text = "OFF - " .. option.name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 12

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            improvements[option.key] = not improvements[option.key]
            if improvements[option.key] then
                btn.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
                btn.Text = "ON - " .. option.name
                status.Text = "Status: " .. option.name .. " enabled"
                status.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                btn.Text = "OFF - " .. option.name
                status.Text = "Status: " .. option.name .. " disabled"
                status.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
            applyImprovement(option.key, improvements[option.key])
        end)

        buttons[option.key] = btn
        yPos = yPos + 45
    end

    closeBtn.MouseButton1Click:Connect(function()
        screenGui.Enabled = not screenGui.Enabled
    end)

    return screenGui, status
end

-- Apply improvements
function applyImprovement(key, enabled)
    spawn(function()
        if key == "infiniteStamina" then
            if enabled then
                spawn(function()
                    while improvements.infiniteStamina do
                        pcall(function()
                            if player.Character and player.Character:FindFirstChild("Humanoid") then
                                local combatState = player.Character.Humanoid:FindFirstChild("CombatState")
                                if combatState then
                                    local stamina = combatState:FindFirstChild("Stamina")
                                    if stamina and stamina.Value < 100 then
                                        stamina.Value = 100
                                    end
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
                                if combatState then
                                    local stunned = combatState:FindFirstChild("Stunned")
                                    if stunned and stunned.Value == true then
                                        stunned.Value = false
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
                if config then
                    local attacking = config:FindFirstChild("Attacking")
                    if attacking then
                        local cooldowns = attacking:FindFirstChild("Cooldowns")
                        if cooldowns then
                            for _, cooldown in pairs(cooldowns:GetChildren()) do
                                if cooldown:IsA("NumberValue") then
                                    if not originalValues[cooldown.Name] then
                                        originalValues[cooldown.Name] = cooldown.Value
                                    end
                                    cooldown.Value = enabled and originalValues[cooldown.Name] * 0.3 or originalValues[cooldown.Name]
                                end
                            end
                        end
                    end
                end
            end)

        elseif key == "fastCombo" then
            pcall(function()
                local config = ReplicatedStorage:FindFirstChild("CombatConfiguration")
                if config then
                    local combo = config:FindFirstChild("Combo")
                    if combo then
                        local expireTime = combo:FindFirstChild("ExpireTime")
                        if expireTime then
                            if not originalValues.ExpireTime then
                                originalValues.ExpireTime = expireTime.Value
                            end
                            expireTime.Value = enabled and 999999 or originalValues.ExpireTime
                        end
                    end
                end
            end)

        elseif key == "superSpeed" then
            if enabled then
                pcall(function()
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        if not originalValues.WalkSpeed then
                            originalValues.WalkSpeed = player.Character.Humanoid.WalkSpeed
                        end
                        player.Character.Humanoid.WalkSpeed = 30
                    end
                end)
            else
                pcall(function()
                    if player.Character and player.Character:FindFirstChild("Humanoid") and originalValues.WalkSpeed then
                        player.Character.Humanoid.WalkSpeed = originalValues.WalkSpeed
                    end
                end)
            end
        end
    end)
end

-- Character handling
local function onCharacterAdded(character)
    wait(3) -- Wait for combat system
    
    -- Apply active improvements
    for key, enabled in pairs(improvements) do
        if enabled then
            applyImprovement(key, enabled)
        end
    end
end

-- Create GUI
local gui, statusLabel = createGUI()

-- Hotkeys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        gui.Enabled = not gui.Enabled
    elseif input.KeyCode == Enum.KeyCode.F2 then
        improvements.infiniteStamina = not improvements.infiniteStamina
        applyImprovement("infiniteStamina", improvements.infiniteStamina)
        statusLabel.Text = "Status: Infinite Stamina " .. (improvements.infiniteStamina and "ON" or "OFF")
        statusLabel.TextColor3 = improvements.infiniteStamina and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    elseif input.KeyCode == Enum.KeyCode.F3 then
        improvements.noStun = not improvements.noStun
        applyImprovement("noStun", improvements.noStun)
        statusLabel.Text = "Status: No Stun " .. (improvements.noStun and "ON" or "OFF")
        statusLabel.TextColor3 = improvements.noStun and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    end
end)

-- Connect events
player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
    spawn(function()
        onCharacterAdded(player.Character)
    end)
end

-- Success message
wait(1)
print("✅ Combat Enhancer loaded successfully!")
print("📋 Controls:")
print("   F1 - Toggle GUI")
print("   F2 - Quick Infinite Stamina")
print("   F3 - Quick No Stun")
print("🎯 Ready to enhance your combat!")

return improvements

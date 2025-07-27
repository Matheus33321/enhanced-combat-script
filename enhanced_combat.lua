-- Enhanced Combat System - Fixed Version with Diagnostics
-- Execute with: loadstring(game:HttpGet("https://raw.githubusercontent.com/Matheus33321/enhanced-combat-script/main/enhanced_combat.lua"))()

print("🔄 Loading Combat Enhancer...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Diagnostic function
local function diagnoseGame()
    print("🔍 DIAGNOSING GAME COMPATIBILITY...")
    print("=" .. string.rep("=", 40) .. "=")
    
    -- Check ReplicatedStorage
    if not ReplicatedStorage then
        print("❌ ReplicatedStorage not found!")
        return false
    end
    print("✅ ReplicatedStorage found")
    
    -- List all children in ReplicatedStorage
    print("📁 ReplicatedStorage contents:")
    for _, child in pairs(ReplicatedStorage:GetChildren()) do
        print("   - " .. child.Name .. " (" .. child.ClassName .. ")")
    end
    
    -- Check for combat-related folders
    local combatConfig = ReplicatedStorage:FindFirstChild("CombatConfiguration")
    local remotes = ReplicatedStorage:FindFirstChild("Events") or ReplicatedStorage:FindFirstChild("Remotes")
    
    if combatConfig then
        print("✅ CombatConfiguration found")
        print("📁 CombatConfiguration contents:")
        for _, child in pairs(combatConfig:GetChildren()) do
            print("   - " .. child.Name .. " (" .. child.ClassName .. ")")
        end
    else
        print("❌ CombatConfiguration not found")
        print("🔍 Looking for alternative combat systems...")
        
        -- Look for common combat system names
        local alternatives = {
            "Combat", "CombatSystem", "Fighting", "FightingSystem", 
            "Battle", "BattleSystem", "PvP", "PvPSystem", "Configuration", "Config"
        }
        
        for _, name in pairs(alternatives) do
            local found = ReplicatedStorage:FindFirstChild(name)
            if found then
                print("🔍 Found potential combat system: " .. name)
            end
        end
    end
    
    if remotes then
        print("✅ Events/Remotes found")
        print("📁 Events contents:")
        for _, child in pairs(remotes:GetChildren()) do
            print("   - " .. child.Name .. " (" .. child.ClassName .. ")")
        end
    else
        print("❌ Events/Remotes not found")
    end
    
    -- Check character
    if player.Character then
        print("✅ Character found")
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            print("✅ Humanoid found")
            local combatState = humanoid:FindFirstChild("CombatState")
            if combatState then
                print("✅ CombatState found in Humanoid")
                print("📁 CombatState contents:")
                for _, child in pairs(combatState:GetChildren()) do
                    print("   - " .. child.Name .. " (" .. child.ClassName .. "): " .. tostring(child.Value))
                end
            else
                print("❌ CombatState not found in Humanoid")
            end
        else
            print("❌ Humanoid not found")
        end
    else
        print("❌ Character not spawned")
    end
    
    print("=" .. string.rep("=", 40) .. "=")
    return combatConfig ~= nil
end

-- Configuration for improvements
local improvements = {
    reducedCooldown = false,
    expandedHitbox = false,
    optimizedAttack = false,
    infiniteStamina = false,
    fastCombo = false,
    noStun = false,
    superKnockback = false,
    autoBlock = false
}

-- Original values backup
local originalValues = {}

-- Create simple diagnostic GUI
local function createDiagnosticGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CombatEnhancerDiagnostic"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Active = true
    mainFrame.Draggable = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Font = Enum.Font.GothamBold
    title.Text = "🔧 Combat Enhancer - Diagnostic"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "LogFrame"
    scrollFrame.Parent = mainFrame
    scrollFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.Position = UDim2.new(0, 10, 0, 50)
    scrollFrame.Size = UDim2.new(1, -20, 1, -100)
    scrollFrame.ScrollBarThickness = 5

    local logCorner = Instance.new("UICorner")
    logCorner.CornerRadius = UDim.new(0, 6)
    logCorner.Parent = scrollFrame

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "LogText"
    textLabel.Parent = scrollFrame
    textLabel.BackgroundTransparency = 1
    textLabel.Position = UDim2.new(0, 10, 0, 10)
    textLabel.Size = UDim2.new(1, -20, 0, 1000)
    textLabel.Font = Enum.Font.Code
    textLabel.Text = "Checking game compatibility...\n\nPlease wait..."
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 12
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true

    local retryButton = Instance.new("TextButton")
    retryButton.Name = "RetryButton"
    retryButton.Parent = mainFrame
    retryButton.BackgroundColor3 = Color3.fromRGB(85, 170, 85)
    retryButton.BorderSizePixel = 0
    retryButton.Position = UDim2.new(0, 10, 1, -40)
    retryButton.Size = UDim2.new(0, 100, 0, 30)
    retryButton.Font = Enum.Font.GothamSemibold
    retryButton.Text = "🔄 Retry"
    retryButton.TextColor3 = Color3.fromRGV(255, 255, 255)
    retryButton.TextSize = 14

    local retryCorner = Instance.new("UICorner")
    retryCorner.CornerRadius = UDim.new(0, 6)
    retryCorner.Parent = retryButton

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(170, 85, 85)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -110, 1, -40)
    closeButton.Size = UDim2.new(0, 100, 0, 30)
    closeButton.Font = Enum.Font.GothamSemibold
    closeButton.Text = "❌ Close"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 14

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    return screenGui, textLabel, retryButton
end

-- Create enhanced GUI (only if compatible)
local function createEnhancedGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CombatEnhancerGui"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
    mainFrame.Size = UDim2.new(0, 320, 0, 400)
    mainFrame.Active = true
    mainFrame.Draggable = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Parent = mainFrame
    header.BackgroundColor3 = Color3.fromRGB(120, 50, 200)
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, 50)

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header

    local headerCover = Instance.new("Frame")
    headerCover.Name = "HeaderCover"
    headerCover.Parent = header
    headerCover.BackgroundColor3 = Color3.fromRGB(120, 50, 200)
    headerCover.BorderSizePixel = 0
    headerCover.Position = UDim2.new(0, 0, 0.5, 0)
    headerCover.Size = UDim2.new(1, 0, 0.5, 0)

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Parent = header
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 15, 0, 0)
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Font = Enum.Font.GothamBold
    title.Text = "⚡ COMBAT ENHANCER"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Parent = header
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -40, 0.5, -15)
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeButton

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Parent = mainFrame
    statusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    statusLabel.BorderSizePixel = 0
    statusLabel.Position = UDim2.new(0, 10, 0, 60)
    statusLabel.Size = UDim2.new(1, -20, 0, 30)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = "🔧 Ready for enhancements"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    statusLabel.TextSize = 14

    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = statusLabel

    -- Simple toggle buttons for now
    local yPos = 100
    local buttons = {}
    
    local options = {
        {name = "Infinite Stamina", key = "infiniteStamina"},
        {name = "Reduced Cooldown", key = "reducedCooldown"},
        {name = "No Stun", key = "noStun"},
        {name = "Fast Combo", key = "fastCombo"}
    }

    for i, option in ipairs(options) do
        local button = Instance.new("TextButton")
        button.Name = option.key
        button.Parent = mainFrame
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        button.BorderSizePixel = 0
        button.Position = UDim2.new(0, 10, 0, yPos)
        button.Size = UDim2.new(1, -20, 0, 40)
        button.Font = Enum.Font.GothamSemibold
        button.Text = "❌ " .. option.name
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 14

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button

        button.MouseButton1Click:Connect(function()
            improvements[option.key] = not improvements[option.key]
            if improvements[option.key] then
                button.BackgroundColor3 = Color3.fromRGB(85, 170, 85)
                button.Text = "✅ " .. option.name
                statusLabel.Text = "✅ " .. option.name .. " enabled"
                statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                button.BackgroundColor3 = Color3.fromRGB(60, 60, 65)  
                button.Text = "❌ " .. option.name
                statusLabel.Text = "❌ " .. option.name .. " disabled"
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
            applyImprovement(option.key, improvements[option.key])
        end)

        buttons[option.key] = button
        yPos = yPos + 50
    end

    closeButton.MouseButton1Click:Connect(function()
        screenGui.Enabled = false
    end)

    return screenGui
end

-- Apply improvements function
function applyImprovement(key, enabled)
    if not player.Character then 
        print("⚠️ Character not found")
        return 
    end
    
    pcall(function()
        if key == "infiniteStamina" then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                local combatState = humanoid:FindFirstChild("CombatState")
                if combatState then
                    local stamina = combatState:FindFirstChild("Stamina")
                    if stamina then
                        if enabled then
                            -- Try to find max stamina value
                            local maxStamina = 100 -- default
                            local rs = ReplicatedStorage
                            local config = rs:FindFirstChild("CombatConfiguration")
                            if config then
                                local staminaConfig = config:FindFirstChild("Stamina")
                                if staminaConfig then
                                    local maxStaminaValue = staminaConfig:FindFirstChild("MaxStamina")
                                    if maxStaminaValue then
                                        maxStamina = maxStaminaValue.Value
                                    end
                                end
                            end
                            
                            stamina.Value = maxStamina
                            print("✅ Infinite stamina enabled")
                            
                            -- Keep stamina at max
                            local connection
                            connection = stamina.Changed:Connect(function()
                                if improvements.infiniteStamina and stamina.Value < maxStamina then
                                    stamina.Value = maxStamina
                                end
                                if not improvements.infiniteStamina then
                                    connection:Disconnect()
                                end
                            end)
                        else
                            print("❌ Infinite stamina disabled")
                        end
                    else
                        print("⚠️ Stamina value not found in CombatState")
                    end
                else
                    print("⚠️ CombatState not found in Humanoid")
                end
            else
                print("⚠️ Humanoid not found in Character")
            end
        
        elseif key == "noStun" then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                local combatState = humanoid:FindFirstChild("CombatState")
                if combatState then
                    local stunned = combatState:FindFirstChild("Stunned")
                    if stunned then
                        if enabled then
                            local connection
                            connection = stunned.Changed:Connect(function()
                                if improvements.noStun and stunned.Value then
                                    stunned.Value = false
                                    print("🛡️ Stun blocked!")
                                end
                                if not improvements.noStun then
                                    connection:Disconnect()
                                end
                            end)
                            print("✅ No stun enabled")
                        else
                            print("❌ No stun disabled")
                        end
                    else
                        print("⚠️ Stunned value not found")
                    end
                else
                    print("⚠️ CombatState not found")
                end
            end
        
        elseif key == "reducedCooldown" then
            local config = ReplicatedStorage:FindFirstChild("CombatConfiguration")
            if config then
                local attacking = config:FindFirstChild("Attacking")
                if attacking then
                    local cooldowns = attacking:FindFirstChild("Cooldowns")
                    if cooldowns then
                        for _, cooldown in pairs(cooldowns:GetChildren()) do
                            if cooldown:IsA("NumberValue") then
                                if not originalValues[cooldown] then
                                    originalValues[cooldown] = cooldown.Value
                                end
                                cooldown.Value = enabled and originalValues[cooldown] * 0.3 or originalValues[cooldown]
                            end
                        end
                        print(enabled and "✅ Reduced cooldown enabled" or "❌ Reduced cooldown disabled")
                    else
                        print("⚠️ Cooldowns not found")
                    end
                else
                    print("⚠️ Attacking config not found")
                end
            else
                print("⚠️ CombatConfiguration not found")
            end
        
        elseif key == "fastCombo" then
            local config = ReplicatedStorage:FindFirstChild("CombatConfiguration")
            if config then
                local combo = config:FindFirstChild("Combo")
                if combo then
                    local expireTime = combo:FindFirstChild("ExpireTime")
                    if expireTime then
                        if not originalValues[expireTime] then
                            originalValues[expireTime] = expireTime.Value
                        end
                        expireTime.Value = enabled and 999999 or originalValues[expireTime]
                        print(enabled and "✅ Fast combo enabled" or "❌ Fast combo disabled")
                    else
                        print("⚠️ ExpireTime not found")
                    end
                else
                    print("⚠️ Combo config not found")
                end
            else
                print("⚠️ CombatConfiguration not found")
            end
        end
    end)
end

-- Character initialization
local function onCharacterAdded(character)
    wait(2)
    print("🔄 Character spawned, initializing combat system...")
    
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then 
        print("❌ Humanoid not found")
        return 
    end
    
    local combatState = humanoid:WaitForChild("CombatState", 10)
    if not combatState then 
        print("❌ CombatState not found - Combat system may not be initialized yet")
        return 
    end
    
    print("✅ Combat system detected!")
    
    -- Apply enabled improvements
    for key, enabled in pairs(improvements) do
        if enabled then
            applyImprovement(key, true)
        end
    end
end

-- Main initialization
local function initialize()
    print("🚀 Initializing Combat Enhancer...")
    
    -- Create diagnostic GUI
    local diagGui, logText, retryButton = createDiagnosticGui()
    
    -- Run diagnostics
    spawn(function()
        wait(1)
        
        -- Capture print output for GUI
        local logs = {}
        local oldPrint = print
        print = function(...)
            local args = {...}
            local str = ""
            for i, arg in ipairs(args) do
                str = str .. tostring(arg)
                if i < #args then str = str .. " " end
            end
            table.insert(logs, str)
            logText.Text = table.concat(logs, "\n")
            oldPrint(...)
        end
        
        local isCompatible = diagnoseGame()
        
        print = oldPrint -- Restore original print
        
        if isCompatible then
            print("✅ Game appears compatible! Creating enhanced GUI...")
            wait(2)
            diagGui:Destroy()
            
            local enhancedGui = createEnhancedGui()
            
            -- Setup hotkeys
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                
                if input.KeyCode == Enum.KeyCode.F1 then
                    enhancedGui.Enabled = not enhancedGui.Enabled
                elseif input.KeyCode == Enum.KeyCode.F2 then
                    improvements.infiniteStamina = not improvements.infiniteStamina
                    applyImprovement("infiniteStamina", improvements.infiniteStamina)
                    print("⚡ Infinite Stamina:", improvements.infiniteStamina and "ON" or "OFF")
                end
            end)
            
            print("🎯 Combat Enhancer loaded successfully!")
            print("📋 Press F1 to toggle GUI, F2 for quick infinite stamina toggle")
            
        else
            print("❌ Game does not appear to be compatible")
            print("This script works with games that have:")
            print("- ReplicatedStorage.CombatConfiguration")
            print("- Character.Humanoid.CombatState")
            
            retryButton.MouseButton1Click:Connect(function()
                diagGui:Destroy()
                initialize()
            end)
        end
    end)
end

-- Connect character events
player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
    spawn(function()
        onCharacterAdded(player.Character)
    end)
end

-- Start initialization
initialize()

return improvements

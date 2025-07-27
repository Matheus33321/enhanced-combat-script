-- Enhanced Combat System with Improvements Menu
-- For GitHub hosting: enhanced_combat.lua
-- Execute with: loadstring(game:HttpGet("https://raw.githubusercontent.com/[SEU_USUARIO]/[SEU_REPOSITORIO]/main/enhanced_combat.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

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

-- Create enhanced GUI
local function createGui()
    -- Remove existing GUI if it exists
    local existingGui = playerGui:FindFirstChild("CombatEnhancerGui")
    if existingGui then
        existingGui:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CombatEnhancerGui"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 10

    -- Main frame with modern design
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
    mainFrame.Size = UDim2.new(0, 320, 0, 450)
    mainFrame.Active = true
    mainFrame.Draggable = true

    -- Add shadow effect
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Parent = screenGui
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.3
    shadow.BorderSizePixel = 0
    shadow.Position = UDim2.new(0.02, 3, 0.1, 3)
    shadow.Size = UDim2.new(0, 320, 0, 450)
    shadow.ZIndex = mainFrame.ZIndex - 1

    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 12)
    shadowCorner.Parent = shadow

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    -- Header with gradient
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Parent = mainFrame
    header.BackgroundColor3 = Color3.fromRGB(120, 50, 200)
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, 50)

    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 50, 200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 30, 160))
    }
    headerGradient.Rotation = 45
    headerGradient.Parent = header

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header

    -- Fix header corners (only top corners should be rounded)
    local headerCover = Instance.new("Frame")
    headerCover.Name = "HeaderCover"
    headerCover.Parent = header
    headerCover.BackgroundColor3 = Color3.fromRGB(120, 50, 200)
    headerCover.BorderSizePixel = 0
    headerCover.Position = UDim2.new(0, 0, 0.5, 0)
    headerCover.Size = UDim2.new(1, 0, 0.5, 0)

    -- Title with icon
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

    -- Close button
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

    -- Status indicator
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

    -- Scroll frame for options
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "OptionsFrame"
    scrollFrame.Parent = mainFrame
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.Position = UDim2.new(0, 10, 0, 100)
    scrollFrame.Size = UDim2.new(1, -20, 1, -110)
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 30, 160)

    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = scrollFrame
    listLayout.Padding = UDim.new(0, 10)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Enhanced toggle options
    local options = {
        {name = "⚡ Reduced Cooldown", desc = "Attack 50% faster", key = "reducedCooldown", color = Color3.fromRGB(255, 200, 50)},
        {name = "🎯 Expanded Hitbox", desc = "Double attack range", key = "expandedHitbox", color = Color3.fromRGB(50, 200, 255)},
        {name = "💥 Optimized Attack", desc = "1.5x damage multiplier", key = "optimizedAttack", color = Color3.fromRGB(255, 100, 100)},
        {name = "♾️ Infinite Stamina", desc = "Never get tired", key = "infiniteStamina", color = Color3.fromRGB(100, 255, 100)},
        {name = "⚡ Fast Combo", desc = "Instant combo chains", key = "fastCombo", color = Color3.fromRGB(255, 150, 255)},
        {name = "🛡️ No Stun", desc = "Stun immunity", key = "noStun", color = Color3.fromRGB(200, 200, 255)},
        {name = "🚀 Super Knockback", desc = "2x knockback power", key = "superKnockback", color = Color3.fromRGB(255, 180, 100)},
        {name = "🤖 Auto Block", desc = "Automatic defense", key = "autoBlock", color = Color3.fromRGB(150, 255, 150)}
    }

    for i, option in ipairs(options) do
        local optionFrame = Instance.new("Frame")
        optionFrame.Name = option.key
        optionFrame.Parent = scrollFrame
        optionFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        optionFrame.BorderSizePixel = 0
        optionFrame.Size = UDim2.new(1, 0, 0, 70)
        optionFrame.LayoutOrder = i

        local optionCorner = Instance.new("UICorner")
        optionCorner.CornerRadius = UDim.new(0, 8)
        optionCorner.Parent = optionFrame

        -- Colored left border
        local colorBar = Instance.new("Frame")
        colorBar.Name = "ColorBar"
        colorBar.Parent = optionFrame
        colorBar.BackgroundColor3 = option.color
        colorBar.BorderSizePixel = 0
        colorBar.Size = UDim2.new(0, 4, 1, 0)

        local colorCorner = Instance.new("UICorner")
        colorCorner.CornerRadius = UDim.new(0, 2)
        colorCorner.Parent = colorBar

        -- Toggle switch
        local toggleBackground = Instance.new("Frame")
        toggleBackground.Name = "ToggleBG"
        toggleBackground.Parent = optionFrame
        toggleBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        toggleBackground.BorderSizePixel = 0
        toggleBackground.Position = UDim2.new(1, -70, 0.5, -12)
        toggleBackground.Size = UDim2.new(0, 50, 0, 24)

        local toggleBGCorner = Instance.new("UICorner")
        toggleBGCorner.CornerRadius = UDim.new(0, 12)
        toggleBGCorner.Parent = toggleBackground

        local toggleButton = Instance.new("TextButton")
        toggleButton.Name = "Toggle"
        toggleButton.Parent = toggleBackground
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        toggleButton.BorderSizePixel = 0
        toggleButton.Position = UDim2.new(0, 2, 0, 2)
        toggleButton.Size = UDim2.new(0, 20, 0, 20)
        toggleButton.Text = ""

        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 10)
        toggleCorner.Parent = toggleButton

        local optionTitle = Instance.new("TextLabel")
        optionTitle.Name = "Title"
        optionTitle.Parent = optionFrame
        optionTitle.BackgroundTransparency = 1
        optionTitle.Position = UDim2.new(0, 15, 0, 8)
        optionTitle.Size = UDim2.new(1, -90, 0, 25)
        optionTitle.Font = Enum.Font.GothamSemibold
        optionTitle.Text = option.name
        optionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        optionTitle.TextSize = 14
        optionTitle.TextXAlignment = Enum.TextXAlignment.Left

        local optionDesc = Instance.new("TextLabel")
        optionDesc.Name = "Description"
        optionDesc.Parent = optionFrame
        optionDesc.BackgroundTransparency = 1
        optionDesc.Position = UDim2.new(0, 15, 0, 35)
        optionDesc.Size = UDim2.new(1, -90, 0, 20)
        optionDesc.Font = Enum.Font.Gotham
        optionDesc.Text = option.desc
        optionDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
        optionDesc.TextSize = 12
        optionDesc.TextXAlignment = Enum.TextXAlignment.Left

        -- Toggle functionality with animation
        toggleButton.MouseButton1Click:Connect(function()
            improvements[option.key] = not improvements[option.key]
            
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            if improvements[option.key] then
                -- ON state
                local moveTween = TweenService:Create(toggleButton, tweenInfo, {Position = UDim2.new(0, 2, 0, 2)})
                local colorTween = TweenService:Create(toggleButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(200, 200, 200)})
                local bgTween = TweenService:Create(toggleBackground, tweenInfo, {BackgroundColor3 = Color3.fromRGB(60, 60, 65)})
                
                moveTween:Play()
                colorTween:Play()
                bgTween:Play()
                
                statusLabel.Text = "❌ " .. option.name:gsub("^[^%s]*%s", "") .. " disabled"
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
            
            applyImprovement(option.key, improvements[option.key])
        end)
    end

    -- Update scroll canvas size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 80)

    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    return screenGui
end

-- Apply improvements function
function applyImprovement(key, enabled)
    if not player.Character then return end
    
    local rs = game.ReplicatedStorage
    if not rs then 
        warn("ReplicatedStorage not found!")
        return 
    end
    
    local config = rs:FindFirstChild("CombatConfiguration")
    if not config then 
        warn("CombatConfiguration not found in ReplicatedStorage!")
        return 
    end

    pcall(function()
        if key == "reducedCooldown" then
            local cooldowns = config.Attacking:FindFirstChild("Cooldowns")
            if cooldowns then
                for _, cooldown in pairs(cooldowns:GetChildren()) do
                    if cooldown:IsA("NumberValue") then
                        if not originalValues[cooldown] then
                            originalValues[cooldown] = cooldown.Value
                        end
                        cooldown.Value = enabled and originalValues[cooldown] * 0.5 or originalValues[cooldown]
                    end
                end
            end
        
        elseif key == "expandedHitbox" then
            local ranges = config.Attacking:FindFirstChild("Ranges")
            if ranges then
                for _, range in pairs(ranges:GetChildren()) do
                    if range:IsA("NumberValue") then
                        if not originalValues[range] then
                            originalValues[range] = range.Value
                        end
                        range.Value = enabled and originalValues[range] * 2 or originalValues[range]
                    end
                end
            end
        
        elseif key == "optimizedAttack" then
            local comboDamage = config.Damage:FindFirstChild("ComboDamage")
            if comboDamage then
                for _, damage in pairs(comboDamage:GetChildren()) do
                    if damage:IsA("NumberValue") then
                        if not originalValues[damage] then
                            originalValues[damage] = damage.Value
                        end
                        damage.Value = enabled and originalValues[damage] * 1.5 or originalValues[damage]
                    end
                end
            end
        
        elseif key == "infiniteStamina" then
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                local combatState = player.Character.Humanoid:FindFirstChild("CombatState")
                if combatState then
                    local stamina = combatState:FindFirstChild("Stamina")
                    if stamina then
                        if enabled then
                            local maxStamina = config.Stamina.MaxStamina.Value
                            stamina.Value = maxStamina
                            
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
                        end
                    end
                end
            end
        
        elseif key == "fastCombo" then
            local expireTime = config.Combo:FindFirstChild("ExpireTime")
            if expireTime then
                if not originalValues[expireTime] then
                    originalValues[expireTime] = expireTime.Value
                end
                expireTime.Value = enabled and 999999 or originalValues[expireTime]
            end
        
        elseif key == "noStun" then
            if enabled and player.Character and player.Character:FindFirstChild("Humanoid") then
                local combatState = player.Character.Humanoid:FindFirstChild("CombatState")
                if combatState then
                    local stunned = combatState:FindFirstChild("Stunned")
                    if stunned then
                        local connection
                        connection = stunned.Changed:Connect(function()
                            if improvements.noStun and stunned.Value then
                                stunned.Value = false
                            end
                            if not improvements.noStun then
                                connection:Disconnect()
                            end
                        end)
                    end
                end
            end
        
        elseif key == "superKnockback" then
            local comboKnockback = config.Knockback:FindFirstChild("ComboKnockback")
            if comboKnockback then
                for _, knockback in pairs(comboKnockback:GetChildren()) do
                    if knockback:IsA("NumberValue") then
                        if not originalValues[knockback] then
                            originalValues[knockback] = knockback.Value
                        end
                        knockback.Value = enabled and originalValues[knockback] * 2 or originalValues[knockback]
                    end
                end
            end
        
        elseif key == "autoBlock" then
            if enabled then
                local connection
                connection = RunService.Heartbeat:Connect(function()
                    if not improvements.autoBlock then
                        connection:Disconnect()
                        return
                    end
                    
                    pcall(function()
                        if player.Character and player.Character:FindFirstChild("Humanoid") then
                            local combatState = player.Character.Humanoid:FindFirstChild("CombatState")
                            if combatState then
                                local blocking = combatState:FindFirstChild("Blocking")
                                local attacking = combatState:FindFirstChild("Attacking")
                                
                                if blocking and attacking and not blocking.Value and not attacking.Value then
                                    local rs = game.ReplicatedStorage
                                    local events = rs:FindFirstChild("Events")
                                    if events and events:FindFirstChild("DoBlock") then
                                        events.DoBlock:FireServer(true)
                                    end
                                end
                            end
                        end
                    end)
                end)
            end
        end
    end)
end

-- Enhanced character initialization
local function onCharacterAdded(character)
    wait(3) -- Wait longer for combat system to fully initialize
    
    -- Verify combat system exists
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then return end
    
    local combatState = humanoid:WaitForChild("CombatState", 10)
    if not combatState then 
        warn("Combat system not detected. Make sure you're in a compatible game.")
        return 
    end
    
    print("✅ Combat system detected! Applying enhancements...")
    
    -- Apply any currently enabled improvements
    for key, enabled in pairs(improvements) do
        if enabled then
            applyImprovement(key, true)
        end
    end
end

-- Connect events
player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
    spawn(function()
        onCharacterAdded(player.Character)
    end)
end

-- Create and show GUI
local gui = createGui()

-- Hotkeys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        if gui and gui.Parent then
            gui.Enabled = not gui.Enabled
        end
    elseif input.KeyCode == Enum.KeyCode.F2 then
        -- Quick toggle for reduced cooldown
        improvements.reducedCooldown = not improvements.reducedCooldown
        applyImprovement("reducedCooldown", improvements.reducedCooldown)
        print("⚡ Reduced Cooldown:", improvements.reducedCooldown and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.F3 then
        -- Quick toggle for expanded hitbox
        improvements.expandedHitbox = not improvements.expandedHitbox
        applyImprovement("expandedHitbox", improvements.expandedHitbox)
        print("🎯 Expanded Hitbox:", improvements.expandedHitbox and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.F4 then
        -- Quick toggle for infinite stamina
        improvements.infiniteStamina = not improvements.infiniteStamina
        applyImprovement("infiniteStamina", improvements.infiniteStamina)
        print("♾️ Infinite Stamina:", improvements.infiniteStamina and "ON" or "OFF")
    end
end)

-- Enhanced notification system
local function showNotification(text, color)
    local notification = Instance.new("ScreenGui")
    notification.Name = "Notification"
    notification.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Parent = notification
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0.5, -150, 0, -50)
    frame.Size = UDim2.new(0, 300, 0, 40)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    
    -- Animate in
    local tweenIn = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -150, 0, 20)
    })
    tweenIn:Play()
    
    -- Animate out after delay
    spawn(function()
        wait(2)
        local tweenOut = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Position = UDim2.new(0.5, -150, 0, -50)
        })
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            notification:Destroy()
        end)
    end)
end

-- Welcome message
showNotification("🚀 Combat Enhancer Loaded!", Color3.fromRGB(100, 255, 100))
wait(0.5)
showNotification("Press F1 to open menu", Color3.fromRGB(180, 180, 255))

-- Console output
print("=" .. string.rep("=", 50) .. "=")
print("🚀 COMBAT ENHANCER v2.0 LOADED SUCCESSFULLY!")
print("=" .. string.rep("=", 50) .. "=")
print("📋 Controls:")
print("   F1 - Toggle main menu")
print("   F2 - Quick toggle: Reduced Cooldown")
print("   F3 - Quick toggle: Expanded Hitbox") 
print("   F4 - Quick toggle: Infinite Stamina")
print("⚠️  This script is for testing purposes only!")
print("🎯 Compatible with combat systems using ReplicatedStorage.CombatConfiguration")
print("=" .. string.rep("=", 50) .. "=")

-- Return the improvements table for external access
return improvements0, 28, 0, 2)})
                local colorTween = TweenService:Create(toggleButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(100, 255, 100)})
                local bgTween = TweenService:Create(toggleBackground, tweenInfo, {BackgroundColor3 = Color3.fromRGB(80, 180, 80)})
                
                moveTween:Play()
                colorTween:Play()
                bgTween:Play()
                
                statusLabel.Text = "✅ " .. option.name:gsub("^[^%s]*%s", "") .. " enabled"
                statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                -- OFF state
                local moveTween = TweenService:Create(toggleButton, tweenInfo, {Position = UDim2.new(

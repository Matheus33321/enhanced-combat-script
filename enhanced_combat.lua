-- Enhanced Combat Script with GUI Menu
-- Execute via: loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/enhanced-combat.lua"))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configuration
local EnhancedConfig = {
    Enabled = false,
    ReducedCooldown = false,
    ExpandedHitbox = false,
    OptimizedAttack = false,
    UnlimitedStamina = false,
    AutoCombo = false,
    BypassBlock = false,
    NoStun = false,
    InfiniteBlockHealth = false,
    RangeMultiplier = 2.5,
    CooldownMultiplier = 0.2,
    HitboxMultiplier = 3.0,
    DamageMultiplier = 1.5
}

-- GUI Creation
local function createGUI()
    -- Check if GUI already exists
    if playerGui:FindFirstChild("EnhancedCombatGUI") then
        playerGui.EnhancedCombatGUI:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EnhancedCombatGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 380, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -190, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    -- Corner rounding
    local corner1 = Instance.new("UICorner")
    corner1.CornerRadius = UDim.new(0, 12)
    corner1.Parent = mainFrame

    -- Shadow effect
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.Position = UDim2.new(0, -3, 0, -3)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.5
    shadow.BorderSizePixel = 0
    shadow.ZIndex = -1
    shadow.Parent = mainFrame

    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 12)
    shadowCorner.Parent = shadow

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 55)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    title.BorderSizePixel = 0
    title.Text = "⚡ Enhanced Combat Menu"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = title

    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Position = UDim2.new(1, -45, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = title

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeButton

    -- Status Label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -20, 0, 25)
    statusLabel.Position = UDim2.new(0, 10, 0, 65)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Disconnected"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = mainFrame

    -- Scroll Frame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -20, 1, -110)
    scrollFrame.Position = UDim2.new(0, 10, 0, 95)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = mainFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = scrollFrame

    -- Toggle Functions
    local function createToggle(name, description, configKey, layoutOrder)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = name .. "Toggle"
        toggleFrame.Size = UDim2.new(1, 0, 0, 65)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        toggleFrame.BorderSizePixel = 0
        toggleFrame.LayoutOrder = layoutOrder
        toggleFrame.Parent = scrollFrame

        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 8)
        frameCorner.Parent = toggleFrame

        local toggleButton = Instance.new("TextButton")
        toggleButton.Name = "ToggleButton"
        toggleButton.Size = UDim2.new(0, 60, 0, 30)
        toggleButton.Position = UDim2.new(1, -70, 0.5, -15)
        toggleButton.BackgroundColor3 = EnhancedConfig[configKey] and Color3.fromRGB(50, 200, 80) or Color3.fromRGB(200, 60, 60)
        toggleButton.BorderSizePixel = 0
        toggleButton.Text = EnhancedConfig[configKey] and "ON" or "OFF"
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.TextScaled = true
        toggleButton.Font = Enum.Font.GothamBold
        toggleButton.Parent = toggleFrame

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = toggleButton

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, -80, 0, 22)
        nameLabel.Position = UDim2.new(0, 15, 0, 8)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.Parent = toggleFrame

        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "DescLabel"
        descLabel.Size = UDim2.new(1, -80, 0, 18)
        descLabel.Position = UDim2.new(0, 15, 0, 35)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = description
        descLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextScaled = true
        descLabel.Font = Enum.Font.Gotham
        descLabel.Parent = toggleFrame

        toggleButton.MouseButton1Click:Connect(function()
            EnhancedConfig[configKey] = not EnhancedConfig[configKey]
            toggleButton.Text = EnhancedConfig[configKey] and "ON" or "OFF"
            toggleButton.BackgroundColor3 = EnhancedConfig[configKey] and Color3.fromRGB(50, 200, 80) or Color3.fromRGB(200, 60, 60)
            
            -- Tween animation
            local tween = TweenService:Create(toggleButton, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 65, 0, 35)
            })
            tween:Play()
            tween.Completed:Connect(function()
                local backTween = TweenService:Create(toggleButton, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 60, 0, 30)
                })
                backTween:Play()
            end)
        end)

        -- Hover effects
        toggleButton.MouseEnter:Connect(function()
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
        end)

        toggleButton.MouseLeave:Connect(function()
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        end)
    end

    -- Create Toggles
    createToggle("🔥 Master Toggle", "Enable/Disable all combat enhancements", "Enabled", 1)
    createToggle("⚡ Reduced Cooldown", "80% faster attack cooldown", "ReducedCooldown", 2)
    createToggle("🎯 Expanded Hitbox", "3x larger hitbox detection", "ExpandedHitbox", 3)
    createToggle("🚀 Optimized Attack", "Skip attack restrictions", "OptimizedAttack", 4)
    createToggle("♾️ Unlimited Stamina", "Infinite stamina for all actions", "UnlimitedStamina", 5)
    createToggle("🔄 Auto Combo", "Always continue combo chains", "AutoCombo", 6)
    createToggle("🛡️ Bypass Block", "Ignore all blocking defenses", "BypassBlock", 7)
    createToggle("💪 No Stun", "Immunity to stun effects", "NoStun", 8)
    createToggle("🛡️ Infinite Block Health", "Unlimited block durability", "InfiniteBlockHealth", 9)

    -- Update canvas size
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
    end)

    -- Drag functionality
    local dragToggle = nil
    local dragStart = nil
    local startPos = nil

    local function updateInput(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragToggle then
                updateInput(input)
            end
        end
    end)

    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        closeTween:Play()
        closeTween.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end)

    -- Toggle GUI with key
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
            mainFrame.Visible = not mainFrame.Visible
            if mainFrame.Visible then
                mainFrame.Size = UDim2.new(0, 0, 0, 0)
                mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
                local openTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 380, 0, 500),
                    Position = UDim2.new(0.5, -190, 0.5, -250)
                })
                openTween:Play()
            end
        end
    end)

    return screenGui, statusLabel
end

-- Combat State Management
local function getCombatState(character)
    if not character then return nil end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return nil end
    return humanoid:FindFirstChild("CombatState")
end

-- Enhanced Attack Function Override
local function setupAttackEnhancements()
    local rs = ReplicatedStorage
    local config = rs:WaitForChild("CombatConfiguration", 5)
    local rsEvents = rs:WaitForChild("Events", 5)
    
    if not config or not rsEvents then
        warn("Required services not found")
        return false
    end

    -- Get attack animations
    local attackAnimations = {}
    local animFolder = config:FindFirstChild("Attacking")
    if animFolder and animFolder:FindFirstChild("Animations") then
        for i = 1, #animFolder.Animations:GetChildren() do
            attackAnimations[i] = animFolder.Animations:FindFirstChild(tostring(i))
        end
    end

    -- Enhanced doAttack function
    local function enhancedDoAttack(plr)
        if not EnhancedConfig.Enabled then return end
        
        local char = plr.Character
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")

        if not (char and hum and hum.Health > 0 and root) then
            return
        end

        local combatState = getCombatState(char)
        if not combatState then return end

        local stamina = combatState:FindFirstChild("Stamina")
        local attacking = combatState:FindFirstChild("Attacking")
        local attackCooldown = combatState:FindFirstChild("AttackCooldown")
        local combo = combatState:FindFirstChild("Combo")
        local lastAttacked = combatState:FindFirstChild("LastAttacked")
        local stunned = combatState:FindFirstChild("Stunned")

        if not (stamina and attacking and attackCooldown and combo and lastAttacked and stunned) then
            return
        end

        -- Unlimited Stamina
        local attackCost = EnhancedConfig.UnlimitedStamina and 0 or (config.Stamina.MinStamina and config.Stamina.MinStamina.Value or 10)
        if stamina.Value < attackCost then
            if EnhancedConfig.UnlimitedStamina then
                stamina.Value = config.Stamina.MaxStamina.Value
            else
                return
            end
        end

        -- No Stun Override
        if EnhancedConfig.NoStun then
            stunned.Value = false
        end

        -- Optimized Attack - bypass restrictions
        if attacking.Value and not EnhancedConfig.OptimizedAttack then
            return
        end

        if stunned.Value and not EnhancedConfig.NoStun then
            return
        end

        stamina.Value = math.max(0, stamina.Value - attackCost)

        local comboExpireTime = config.Combo.ExpireTime.Value
        local baseAttackRange = config.Attacking.Ranges[tostring(combo.Value)] and config.Attacking.Ranges[tostring(combo.Value)].Value or 10
        local attackRange = EnhancedConfig.ExpandedHitbox and baseAttackRange * EnhancedConfig.RangeMultiplier or baseAttackRange

        if not stunned.Value and (not attackCooldown.Value or EnhancedConfig.OptimizedAttack) then
            attackCooldown.Value = true
            attacking.Value = true

            combo.Value = combo.Value + 1
            if combo.Value > #attackAnimations or tick() - lastAttacked.Value >= comboExpireTime then
                combo.Value = 1
            end
            lastAttacked.Value = tick()

            task.spawn(function()
                -- Play woosh sound
                local wooshes = config.SoundEffects.Wooshes:GetChildren()
                if #wooshes > 0 then
                    local wooshSound = wooshes[math.random(1, #wooshes)]:Clone()
                    wooshSound.Parent = root
                    wooshSound:Play()
                    task.spawn(function()
                        wooshSound.Ended:Wait()
                        wooshSound:Destroy()
                    end)
                end

                -- Enhanced knockback
                local direction = root.CFrame.LookVector
                local knockback = config.Attacking.Dash[tostring(combo.Value)] and config.Attacking.Dash[tostring(combo.Value)].Value or 0
                if rsEvents:FindFirstChild("DealKnockback") then
                    rsEvents.DealKnockback:FireClient(plr, direction, knockback)
                end

                -- Animation
                local animation = attackAnimations[combo.Value]
                if animation then
                    local animTrack = hum.Animator:LoadAnimation(animation)
                    animTrack:Play()

                    -- Enhanced hit detection
                    local hitConnection
                    hitConnection = animTrack:GetMarkerReachedSignal("Hit"):Connect(function(attackingBodyPart)
                        local bodyPart = char:FindFirstChild(attackingBodyPart)
                        if not bodyPart then return end
                        
                        local bodyPartBottom = bodyPart.CFrame - bodyPart.CFrame.UpVector * bodyPart.Size.Y / 2

                        -- Enhanced hitbox size
                        local hitboxSize = EnhancedConfig.ExpandedHitbox and root.Size * EnhancedConfig.HitboxMultiplier or root.Size

                        local charactersToInclude = {}
                        for _, otherPlayer in pairs(Players:GetPlayers()) do
                            if otherPlayer ~= plr and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Humanoid") and otherPlayer.Character.Humanoid.Health > 0 then
                                table.insert(charactersToInclude, otherPlayer.Character)
                            end
                        end

                        local hitTarget = false

                        -- Enhanced area detection
                        if EnhancedConfig.ExpandedHitbox and #charactersToInclude > 0 then
                            local hitboxCFrame = root.CFrame
                            local overlapParams = OverlapParams.new()
                            overlapParams.FilterType = Enum.RaycastFilterType.Include
                            overlapParams.FilterDescendantsInstances = charactersToInclude

                            local success, nearbyParts = pcall(function()
                                return workspace:GetPartBoundsInBox(hitboxCFrame, hitboxSize, overlapParams)
                            end)

                            if success and nearbyParts then
                                for _, part in pairs(nearbyParts) do
                                    local hitChar = part.Parent
                                    if hitChar:FindFirstChild("Humanoid") or (hitChar.Parent and hitChar.Parent:FindFirstChild("Humanoid")) then
                                        hitChar = hitChar:FindFirstChild("Humanoid") and hitChar or hitChar.Parent
                                        if hitChar.Humanoid and hitChar.Humanoid.Health > 0 then
                                            local bypassBlock = EnhancedConfig.BypassBlock
                                            local knockbackDirection = root.CFrame.LookVector
                                            
                                            -- Create visual effect
                                            task.spawn(function()
                                                if config.ParticleEffects and config.ParticleEffects.Combos and config.ParticleEffects.Combos:FindFirstChild(tostring(combo.Value)) then
                                                    local comboParticleFolder = config.ParticleEffects.Combos[tostring(combo.Value)]
                                                    if comboParticleFolder:FindFirstChild("ParticleContainer") then
                                                        local comboParticle = comboParticleFolder.ParticleContainer:Clone()
                                                        comboParticle.CFrame = CFrame.new(bodyPartBottom.Position, bodyPartBottom.Position + knockbackDirection * 10)
                                                        
                                                        local effectsContainer = workspace:FindFirstChild("EFFECTS CONTAINER")
                                                        if effectsContainer then
                                                            comboParticle.Parent = effectsContainer
                                                        else
                                                            comboParticle.Parent = workspace
                                                        end
                                                        
                                                        -- Sound effect
                                                        if config.SoundEffects and config.SoundEffects.Combos and config.SoundEffects.Combos:FindFirstChild(tostring(combo.Value)) then
                                                            local comboSound = config.SoundEffects.Combos[tostring(combo.Value)]:Clone()
                                                            comboSound.Parent = comboParticle
                                                            comboSound:Play()
                                                        end
                                                    end
                                                end
                                            end)
                                            
                                            -- Deal damage
                                            local ss = ServerStorage
                                            if ss and ss:FindFirstChild("Events") and ss.Events:FindFirstChild("DealDamage") then
                                                ss.Events.DealDamage:Fire(char, hitChar, bypassBlock, knockbackDirection)
                                            end
                                            hitTarget = true
                                            break
                                        end
                                    end
                                end
                            end
                        end

                        -- Regular raycast detection
                        if not hitTarget and #charactersToInclude > 0 then
                            local rp = RaycastParams.new()
                            rp.FilterType = Enum.RaycastFilterType.Include
                            rp.FilterDescendantsInstances = charactersToInclude

                            local success, hitRay = pcall(function()
                                return workspace:Blockcast(root.CFrame, hitboxSize, root.CFrame.LookVector * attackRange, rp)
                            end)

                            if success and hitRay then
                                local hitChar = hitRay.Instance.Parent
                                if hitChar:FindFirstChild("Humanoid") or (hitChar.Parent and hitChar.Parent:FindFirstChild("Humanoid")) then
                                    hitChar = hitChar:FindFirstChild("Humanoid") and hitChar or hitChar.Parent
                                    if hitChar.Humanoid and hitChar.Humanoid.Health > 0 then
                                        local bypassBlock = EnhancedConfig.BypassBlock or hitRay.Normal == Enum.NormalId.Back
                                        local knockbackDirection = root.CFrame.LookVector
                                        
                                        -- Visual effect
                                        task.spawn(function()
                                            if config.ParticleEffects and config.ParticleEffects.Combos and config.ParticleEffects.Combos:FindFirstChild(tostring(combo.Value)) then
                                                local comboParticleFolder = config.ParticleEffects.Combos[tostring(combo.Value)]
                                                if comboParticleFolder:FindFirstChild("ParticleContainer") then
                                                    local comboParticle = comboParticleFolder.ParticleContainer:Clone()
                                                    comboParticle.CFrame = CFrame.new(bodyPartBottom.Position, bodyPartBottom.Position + knockbackDirection * 10)
                                                    
                                                    local effectsContainer = workspace:FindFirstChild("EFFECTS CONTAINER")
                                                    if effectsContainer then
                                                        comboParticle.Parent = effectsContainer
                                                    else
                                                        comboParticle.Parent = workspace
                                                    end
                                                end
                                            end
                                        end)
                                        
                                        -- Deal damage
                                        local ss = ServerStorage
                                        if ss and ss:FindFirstChild("Events") and ss.Events:FindFirstChild("DealDamage") then
                                            ss.Events.DealDamage:Fire(char, hitChar, bypassBlock, knockbackDirection)
                                        end
                                        hitTarget = true
                                    end
                                end
                            end
                        end

                        -- Auto combo logic
                        if not hitTarget and not EnhancedConfig.AutoCombo then
                            if config.Combo and config.Combo.CanComboWithoutHitting and config.Combo.CanComboWithoutHitting.Value == false then
                                lastAttacked.Value = 0
                            end
                        end
                        
                        hitConnection:Disconnect()
                    end)

                    animTrack.Stopped:Connect(function()
                        animTrack:Destroy()
                    end)
                end
            end)

            -- Enhanced cooldown
            local baseCooldownTime = config.Attacking.Cooldowns[tostring(combo.Value)] and config.Attacking.Cooldowns[tostring(combo.Value)].Value or 1
            local cooldownTime = EnhancedConfig.ReducedCooldown and baseCooldownTime * EnhancedConfig.CooldownMultiplier or baseCooldownTime
            
            task.wait(cooldownTime)

            attacking.Value = false
            attackCooldown.Value = false
        end
    end

    -- Connect the enhanced function
    if rsEvents:FindFirstChild("DoAttack") then
        rsEvents.DoAttack.OnServerEvent:Connect(enhancedDoAttack)
        return true
    end
    
    return false
end

-- Continuous Enhancements
local function startContinuousEnhancements()
    RunService.Heartbeat:Connect(function()
        if not EnhancedConfig.Enabled then return end
        
        local character = player.Character
        if not character then return end
        
        local combatState = getCombatState(character)
        if not combatState then return end

        -- Unlimited Stamina
        if EnhancedConfig.UnlimitedStamina then
            local stamina = combatState:FindFirstChild("Stamina")
            if stamina then
                local config = ReplicatedStorage:FindFirstChild("CombatConfiguration")
                if config and config.Stamina and config.Stamina.MaxStamina then
                    stamina.Value = config.Stamina.MaxStamina.Value
                end
            end
        end

        -- No Stun
        if EnhancedConfig.NoStun then
            local stunned = combatState:FindFirstChild("Stunned")
            if stunned then
                stunned.Value = false
            end
        end

        -- Infinite Block Health
        if EnhancedConfig.InfiniteBlockHealth then
            local blockHealth = combatState:FindFirstChild("BlockHealth")
            if blockHealth then
                local config = ReplicatedStorage:FindFirstChild("CombatConfiguration")
                if config and config.Blocking and config.Blocking.MaxHealth then
                    blockHealth.Value = config.Blocking.MaxHealth.Value
                end
            end
        end
    end)
end

-- Initialize
local function initialize()
    local gui, statusLabel = createGUI()
    
    -- Try to setup enhancements
    local success = setupAttackEnhancements()
    
    if success then
        statusLabel.Text = "Status: ✅ Connected"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        statusLabel.Text = "Status: ⚠️ Partial Connection"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    end
    
    startContinuousEnhancements()
    
    print("🔥 Enhanced Combat Script loaded!")
    print("📖 Press Right Ctrl to toggle menu")
    print("⚡ Features: Reduced Cooldown, Expanded Hitbox, Unlimited Stamina, Auto Combo, Bypass Block, No Stun")
end

-- Auto-retry connection
task.spawn(function()
    local retryCount = 0
    while retryCount < 5 do
        local success = pcall(initialize)
        if success then
            break
        else
            retryCount = retryCount + 1
            print("Retrying connection... (" .. retryCount .. "/5)")
            task.wait(2)
        end
    end
    if retryCount >= 5 then
        warn("Failed to connect after 5 retries.")
    end
end)

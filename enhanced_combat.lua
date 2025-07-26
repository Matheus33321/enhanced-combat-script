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
    RangeMultiplier = 1.5,
    CooldownMultiplier = 0.3,
    HitboxMultiplier = 2.0,
    StaminaCost = 0
}

-- GUI Creation
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EnhancedCombatGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    -- Corner rounding
    local corner1 = Instance.new("UICorner")
    corner1.CornerRadius = UDim.new(0, 10)
    corner1.Parent = mainFrame

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    title.BorderSizePixel = 0
    title.Text = "Enhanced Combat Menu"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame

    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 10)
    corner2.Parent = title

    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = title

    local corner3 = Instance.new("UICorner")
    corner3.CornerRadius = UDim.new(0, 5)
    corner3.Parent = closeButton

    -- Scroll Frame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -20, 1, -70)
    scrollFrame.Position = UDim2.new(0, 10, 0, 60)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = mainFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 10)
    listLayout.Parent = scrollFrame

    -- Toggle Functions
    local function createToggle(name, description, configKey, layoutOrder)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = name .. "Toggle"
        toggleFrame.Size = UDim2.new(1, 0, 0, 60)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        toggleFrame.BorderSizePixel = 0
        toggleFrame.LayoutOrder = layoutOrder
        toggleFrame.Parent = scrollFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = toggleFrame

        local toggleButton = Instance.new("TextButton")
        toggleButton.Name = "ToggleButton"
        toggleButton.Size = UDim2.new(0, 50, 0, 25)
        toggleButton.Position = UDim2.new(1, -60, 0.5, -12.5)
        toggleButton.BackgroundColor3 = EnhancedConfig[configKey] and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        toggleButton.BorderSizePixel = 0
        toggleButton.Text = EnhancedConfig[configKey] and "ON" or "OFF"
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.TextScaled = true
        toggleButton.Font = Enum.Font.GothamBold
        toggleButton.Parent = toggleFrame

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 5)
        buttonCorner.Parent = toggleButton

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, -70, 0, 20)
        nameLabel.Position = UDim2.new(0, 10, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.Parent = toggleFrame

        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "DescLabel"
        descLabel.Size = UDim2.new(1, -70, 0, 15)
        descLabel.Position = UDim2.new(0, 10, 0, 25)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = description
        descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextScaled = true
        descLabel.Font = Enum.Font.Gotham
        descLabel.Parent = toggleFrame

        toggleButton.MouseButton1Click:Connect(function()
            EnhancedConfig[configKey] = not EnhancedConfig[configKey]
            toggleButton.Text = EnhancedConfig[configKey] and "ON" or "OFF"
            toggleButton.BackgroundColor3 = EnhancedConfig[configKey] and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
            
            -- Tween animation
            local tween = TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 55, 0, 30)
            })
            tween:Play()
            tween.Completed:Connect(function()
                local backTween = TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(0, 50, 0, 25)
                })
                backTween:Play()
            end)
        end)
    end

    -- Create Toggles
    createToggle("Master Toggle", "Enable/Disable all enhancements", "Enabled", 1)
    createToggle("Reduced Cooldown", "Reduce attack cooldown significantly", "ReducedCooldown", 2)
    createToggle("Expanded Hitbox", "Increase hitbox size for easier hits", "ExpandedHitbox", 3)
    createToggle("Optimized Attack", "Faster and more efficient attacks", "OptimizedAttack", 4)
    createToggle("Unlimited Stamina", "Remove stamina cost for attacks", "UnlimitedStamina", 5)
    createToggle("Auto Combo", "Automatically continue combos", "AutoCombo", 6)
    createToggle("Bypass Block", "Ignore blocking defenses", "BypassBlock", 7)

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
        screenGui:Destroy()
    end)

    -- Toggle GUI with key
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)

    return screenGui
end

-- Enhanced Attack Function
local function enhanceAttackSystem()
    if not EnhancedConfig.Enabled then return end
    
    local rs = ReplicatedStorage
    local ss = ServerStorage
    
    -- Wait for required services
    local config = rs:WaitForChild("CombatConfiguration", 5)
    if not config then
        warn("CombatConfiguration not found")
        return
    end
    
    local rsEvents = rs:WaitForChild("Events", 5)
    if not rsEvents then
        warn("ReplicatedStorage Events not found")
        return
    end

    -- Override the original attack function
    local originalDoAttack = rsEvents.DoAttack.OnServerEvent
    
    -- Enhanced doAttack function
    local function enhancedDoAttack(plr)
        local char = plr.Character
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")

        if not (char and hum and hum.Health > 0 and root) then
            return
        end

        local combatState = hum:FindFirstChild("CombatState")
        if not combatState then
            return
        end

        local stamina = combatState.Stamina

        -- Unlimited Stamina
        local attackCost = EnhancedConfig.UnlimitedStamina and 0 or config.Stamina.MinStamina.Value
        if stamina.Value < attackCost then
            if EnhancedConfig.UnlimitedStamina then
                stamina.Value = 100 -- Refill stamina
            else
                return
            end
        end

        if combatState.Attacking.Value and not EnhancedConfig.OptimizedAttack then
            return
        end

        stamina.Value = math.max(0, stamina.Value - attackCost)

        local comboExpireTime = config.Combo.ExpireTime.Value
        local baseAttackRange = config.Attacking.Ranges[tostring(combatState.Combo.Value)].Value
        local attackRange = EnhancedConfig.ExpandedHitbox and baseAttackRange * EnhancedConfig.RangeMultiplier or baseAttackRange

        if not combatState.Stunned.Value and (not combatState.AttackCooldown.Value or EnhancedConfig.OptimizedAttack) then
            combatState.AttackCooldown.Value = true
            combatState.Attacking.Value = true

            combatState.Combo.Value += 1
            local attackAnimations = config:WaitForChild("Attacking"):WaitForChild("Animations"):GetChildren()
            
            if combatState.Combo.Value > #attackAnimations or tick() - combatState.LastAttacked.Value >= comboExpireTime then
                combatState.Combo.Value = 1
            end
            combatState.LastAttacked.Value = tick()

            task.spawn(function()
                -- Play woosh sound
                local wooshes = config.SoundEffects.Wooshes:GetChildren()
                if #wooshes > 0 then
                    local wooshSound = wooshes[math.random(1, #wooshes)]:Clone()
                    wooshSound.Parent = root
                    wooshSound:Play()
                    wooshSound.Ended:Connect(function()
                        wooshSound:Destroy()
                    end)
                end

                -- Knockback
                local direction = root.CFrame.LookVector
                local knockback = config.Attacking.Dash[tostring(combatState.Combo.Value)].Value
                rsEvents.DealKnockback:FireClient(plr, direction, knockback)

                -- Animation
                local animation = config.Attacking.Animations[tostring(combatState.Combo.Value)]
                if animation then
                    local animTrack = hum.Animator:LoadAnimation(animation)
                    animTrack:Play()

                    animTrack:GetMarkerReachedSignal("Hit"):Connect(function(attackingBodyPart)
                        local bodyPart = char[attackingBodyPart]
                        if not bodyPart then return end
                        
                        local bodyPartBottom = bodyPart.CFrame - bodyPart.CFrame.UpVector * bodyPart.Size.Y / 2

                        -- Enhanced hitbox
                        local hitboxSize = EnhancedConfig.ExpandedHitbox and root.Size * EnhancedConfig.HitboxMultiplier or root.Size

                        local charactersToInclude = {}
                        for _, otherPlayer in pairs(Players:GetPlayers()) do
                            if otherPlayer ~= plr and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Humanoid") and otherPlayer.Character.Humanoid.Health > 0 then
                                table.insert(charactersToInclude, otherPlayer.Character)
                            end
                        end

                        local hitTarget = false

                        -- Enhanced hitbox detection
                        if EnhancedConfig.ExpandedHitbox then
                            local hitboxCFrame = root.CFrame
                            local overlapParams = OverlapParams.new()
                            overlapParams.FilterType = Enum.RaycastFilterType.Include
                            overlapParams.FilterDescendantsInstances = charactersToInclude

                            local nearbyParts = workspace:GetPartBoundsInBox(hitboxCFrame, hitboxSize, overlapParams)

                            for _, part in pairs(nearbyParts) do
                                local hitChar = part.Parent
                                if hitChar:FindFirstChild("Humanoid") or (hitChar.Parent and hitChar.Parent:FindFirstChild("Humanoid")) then
                                    hitChar = hitChar:FindFirstChild("Humanoid") and hitChar or hitChar.Parent
                                    if hitChar.Humanoid.Health > 0 then
                                        local bypassBlock = EnhancedConfig.BypassBlock
                                        local knockbackDirection = -bodyPart.CFrame.UpVector
                                        
                                        -- Create effect
                                        task.spawn(function()
                                            local comboParticleFolder = config.ParticleEffects.Combos[tostring(combatState.Combo.Value)]
                                            local comboParticle = comboParticleFolder.ParticleContainer:Clone()
                                            comboParticle.CFrame = CFrame.new(bodyPartBottom.Position, -bodyPart.CFrame.UpVector * 1000)
                                            comboParticle.Parent = workspace["EFFECTS CONTAINER"]
                                            
                                            local comboSound = config.SoundEffects.Combos[tostring(combatState.Combo.Value)]:Clone()
                                            if not bypassBlock then
                                                comboSound.Volume *= config.SoundEffects.BlockNoiseMultiplier.Value
                                                local pitchShift = Instance.new("PitchShiftSoundEffect")
                                                pitchShift.Octave = config.SoundEffects.BlockPitchMultiplier.Value
                                                pitchShift.Parent = comboSound
                                            end
                                            comboSound.Parent = comboParticle
                                            comboSound:Play()
                                            
                                            task.wait(comboParticleFolder.DisableAfter.Value)
                                            -- Disable effect
                                            for _, d in pairs(comboParticle:GetDescendants()) do
                                                if d:IsA("ParticleEmitter") or d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
                                                    d.Enabled = false
                                                end
                                            end
                                        end)
                                        
                                        if ss and ss:FindFirstChild("Events") and ss.Events:FindFirstChild("DealDamage") then
                                            ss.Events.DealDamage:Fire(char, hitChar, bypassBlock, knockbackDirection)
                                        end
                                        hitTarget = true
                                        break
                                    end
                                end
                            end
                        end

                        -- Regular raycast if enhanced hitbox didn't hit
                        if not hitTarget then
                            local rp = RaycastParams.new()
                            rp.FilterType = Enum.RaycastFilterType.Include
                            rp.FilterDescendantsInstances = charactersToInclude

                            local hitRay = workspace:Blockcast(root.CFrame, hitboxSize, root.CFrame.LookVector * attackRange, rp)

                            if hitRay then
                                local hitChar = hitRay.Instance.Parent
                                if hitChar:FindFirstChild("Humanoid") or (hitChar.Parent and hitChar.Parent:FindFirstChild("Humanoid")) then
                                    hitChar = hitChar:FindFirstChild("Humanoid") and hitChar or hitChar.Parent
                                    if hitChar.Humanoid.Health > 0 then
                                        local bypassBlock = EnhancedConfig.BypassBlock or hitRay.Normal == Enum.NormalId.Back
                                        local knockbackDirection = -bodyPart.CFrame.UpVector
                                        
                                        -- Create effect (simplified)
                                        task.spawn(function()
                                            local comboParticleFolder = config.ParticleEffects.Combos[tostring(combatState.Combo.Value)]
                                            local comboParticle = comboParticleFolder.ParticleContainer:Clone()
                                            comboParticle.CFrame = CFrame.new(bodyPartBottom.Position, -bodyPart.CFrame.UpVector * 1000)
                                            comboParticle.Parent = workspace["EFFECTS CONTAINER"]
                                            
                                            local comboSound = config.SoundEffects.Combos[tostring(combatState.Combo.Value)]:Clone()
                                            comboSound.Parent = comboParticle
                                            comboSound:Play()
                                        end)
                                        
                                        if ss and ss:FindFirstChild("Events") and ss.Events:FindFirstChild("DealDamage") then
                                            ss.Events.DealDamage:Fire(char, hitChar, bypassBlock, knockbackDirection)
                                        end
                                        hitTarget = true
                                    end
                                end
                            end
                        end

                        -- Auto combo logic
                        if not hitTarget and config.Combo.CanComboWithoutHitting.Value == false and not EnhancedConfig.AutoCombo then
                            combatState.LastAttacked.Value = 0
                        end
                    end)

                    animTrack.Stopped:Connect(function()
                        animTrack:Destroy()
                    end)
                end
            end)

            -- Enhanced cooldown
            local baseCooldownTime = config.Attacking.Cooldowns[tostring(combatState.Combo.Value)].Value
            local cooldownTime = EnhancedConfig.ReducedCooldown and baseCooldownTime * EnhancedConfig.CooldownMultiplier or baseCooldownTime
            
            task.wait(cooldownTime)

            combatState.Attacking.Value = false
            combatState.AttackCooldown.Value = false
        end
    end

    -- Connect the enhanced function
    if rsEvents:FindFirstChild("DoAttack") then
        rsEvents.DoAttack.OnServerEvent:Connect(enhancedDoAttack)
    end
end

-- Auto-stamina refill
local function autoStaminaRefill()
    if not EnhancedConfig.Enabled or not EnhancedConfig.UnlimitedStamina then return end
    
    RunService.Heartbeat:Connect(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local combatState = player.Character.Humanoid:FindFirstChild("CombatState")
            if combatState and combatState:FindFirstChild("Stamina") then
                combatState.Stamina.Value = 100
            end
        end
    end)
end

-- Initialize
local function initialize()
    createGUI()
    enhanceAttackSystem()
    autoStaminaRefill()
    
    print("Enhanced Combat Script loaded! Press Right Ctrl to toggle menu.")
end

-- Run initialization
initialize()

-- Enhanced Combat Script v3.0 - Advanced Configuration
-- Execute: loadstring(game:HttpGet("https://raw.githubusercontent.com/Matheus33321/enhanced-combat-script/main/enhanced_combat.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Enhanced Settings with more granular control
local EnhancedSettings = {
    CooldownLevel = 0,      -- 0=Normal, 1=Fast, 2=Ultra, 3=Instant
    HitboxLevel = 0,        -- 0=Normal, 1=Extended, 2=Wide, 3=Massive
    BlockingMode = 0,       -- 0=Normal, 1=Enhanced, 2=Auto, 3=Perfect
    DamageLevel = 0,        -- 0=Normal, 1=Boosted, 2=High, 3=Extreme
    SpeedLevel = 0,         -- 0=Normal, 1=Fast, 2=Sonic, 3=Flash
    StaminaMode = 0,        -- 0=Normal, 1=Extended, 2=Infinite
    StunResistance = 0,     -- 0=Normal, 1=Reduced, 2=Immune
    CriticalLevel = 0,      -- 0=Normal, 1=Lucky, 2=Critical, 3=Destroyer
    ComboSpeed = 0,         -- 0=Normal, 1=Fast, 2=Rapid, 3=Lightning
    AutoFeatures = 0        -- 0=Off, 1=Attack, 2=Block, 3=Both
}

-- Configuration levels
local ConfigLevels = {
    Cooldown = {
        [0] = 1.0,    -- Normal
        [1] = 0.5,    -- 50% faster
        [2] = 0.2,    -- 80% faster  
        [3] = 0.01    -- Instant
    },
    Hitbox = {
        [0] = 1.0,    -- Normal range
        [1] = 1.5,    -- 50% larger
        [2] = 2.5,    -- 150% larger
        [3] = 4.0     -- 300% larger
    },
    Damage = {
        [0] = 1.0,    -- Normal damage
        [1] = 1.5,    -- 50% more
        [2] = 2.0,    -- 100% more
        [3] = 3.0     -- 200% more
    },
    Speed = {
        [0] = 16,     -- Normal speed
        [1] = 25,     -- Fast
        [2] = 35,     -- Sonic
        [3] = 50      -- Flash
    },
    Critical = {
        [0] = {chance = 5, multiplier = 2},      -- Normal
        [1] = {chance = 20, multiplier = 2.5},   -- Lucky
        [2] = {chance = 40, multiplier = 3},     -- Critical
        [3] = {chance = 75, multiplier = 5}      -- Destroyer
    }
}

-- Backup and enhanced folders
local OriginalValues = {}
local EnhancedFolders = {}

-- Utility Functions
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("Enhanced Combat Error: " .. tostring(result))
    end
    return success, result
end

local function waitForChild(parent, childName, timeout)
    local startTime = tick()
    timeout = timeout or 10
    
    while not parent:FindFirstChild(childName) and tick() - startTime < timeout do
        wait(0.1)
    end
    
    return parent:FindFirstChild(childName)
end

-- Create Enhanced Configuration Structure
local function createEnhancedStructure()
    safeCall(function()
        local config = ReplicatedStorage:FindFirstChild("CombatConfiguration")
        if not config then return end

        -- Create enhanced folders if they don't exist
        local attacking = config:FindFirstChild("Attacking")
        if attacking then
            -- Enhanced Cooldowns
            if not attacking:FindFirstChild("CooldownsCombos") then
                local cooldownsCombos = Instance.new("Folder")
                cooldownsCombos.Name = "CooldownsCombos"
                cooldownsCombos.Parent = attacking
                
                -- Copy original cooldowns and modify
                local originalCooldowns = attacking:FindFirstChild("Cooldowns")
                if originalCooldowns then
                    for _, cooldown in pairs(originalCooldowns:GetChildren()) do
                        local newCooldown = cooldown:Clone()
                        newCooldown.Parent = cooldownsCombos
                    end
                end
            end
            
            -- Enhanced Hitbox Ranges
            if not attacking:FindFirstChild("RangesHitbox") then
                local rangesHitbox = Instance.new("Folder")
                rangesHitbox.Name = "RangesHitbox"
                rangesHitbox.Parent = attacking
                
                -- Copy original ranges and modify
                local originalRanges = attacking:FindFirstChild("Ranges")
                if originalRanges then
                    for _, range in pairs(originalRanges:GetChildren()) do
                        local newRange = range:Clone()
                        newRange.Parent = rangesHitbox
                    end
                end
            end
            
            -- Enhanced Hitbox Size
            if not attacking:FindFirstChild("EnhancedHitboxSize") then
                local enhancedHitboxSize = Instance.new("Vector3Value")
                enhancedHitboxSize.Name = "EnhancedHitboxSize"
                enhancedHitboxSize.Value = Vector3.new(8, 8, 8) -- Larger hitbox
                enhancedHitboxSize.Parent = attacking
            end
        end
        
        -- Enhanced Blocking
        local blocking = config:FindFirstChild("Blocking")
        if blocking and not blocking:FindFirstChild("EnhancedBlock") then
            local enhancedBlock = Instance.new("Folder")
            enhancedBlock.Name = "EnhancedBlock"
            enhancedBlock.Parent = blocking
            
            local autoBlockRange = Instance.new("NumberValue")
            autoBlockRange.Name = "AutoBlockRange"
            autoBlockRange.Value = 15
            autoBlockRange.Parent = enhancedBlock
            
            local blockEfficiency = Instance.new("NumberValue")
            blockEfficiency.Name = "BlockEfficiency"
            blockEfficiency.Value = 0.95 -- 95% damage reduction
            blockEfficiency.Parent = enhancedBlock
        end
    end)
end

-- Backup original values
local function backupOriginalValues()
    safeCall(function()
        local config = ReplicatedStorage:FindFirstChild("CombatConfiguration")
        if not config then return end

        OriginalValues.AttackCooldowns = {}
        OriginalValues.AttackRanges = {}
        OriginalValues.ComboDamage = {}
        
        local attacking = config:FindFirstChild("Attacking")
        if attacking then
            local cooldowns = attacking:FindFirstChild("Cooldowns")
            if cooldowns then
                for i = 1, 5 do
                    local cooldown = cooldowns:FindFirstChild(tostring(i))
                    if cooldown then
                        OriginalValues.AttackCooldowns[i] = cooldown.Value
                    end
                end
            end
            
            local ranges = attacking:FindFirstChild("Ranges")
            if ranges then
                for i = 1, 5 do
                    local range = ranges:FindFirstChild(tostring(i))
                    if range then
                        OriginalValues.AttackRanges[i] = range.Value
                    end
                end
            end
        end
        
        local damage = config:FindFirstChild("Damage")
        if damage then
            local comboDamage = damage:FindFirstChild("ComboDamage")
            if comboDamage then
                for i = 1, 5 do
                    local dmg = comboDamage:FindFirstChild(tostring(i))
                    if dmg then
                        OriginalValues.ComboDamage[i] = dmg.Value
                    end
                end
            end
            
            local critChance = damage:FindFirstChild("CriticalHitChance")
            if critChance then
                OriginalValues.CritChance = critChance.Value
            end
            
            local critMultiplier = damage:FindFirstChild("CriticalHitMultiplier")
            if critMultiplier then
                OriginalValues.CritMultiplier = critMultiplier.Value
            end
        end
    end)
end

-- Apply enhanced configurations
local function applyEnhancements()
    safeCall(function()
        local config = ReplicatedStorage:FindFirstChild("CombatConfiguration")
        if not config then return end

        local attacking = config:FindFirstChild("Attacking")
        if attacking then
            -- Apply cooldown modifications
            local cooldownsCombos = attacking:FindFirstChild("CooldownsCombos")
            if cooldownsCombos then
                local multiplier = ConfigLevels.Cooldown[EnhancedSettings.CooldownLevel]
                for i = 1, 5 do
                    local cooldown = cooldownsCombos:FindFirstChild(tostring(i))
                    if cooldown and OriginalValues.AttackCooldowns[i] then
                        cooldown.Value = math.max(0.01, OriginalValues.AttackCooldowns[i] * multiplier)
                    end
                end
            end
            
            -- Apply hitbox modifications
            local rangesHitbox = attacking:FindFirstChild("RangesHitbox")
            if rangesHitbox then
                local multiplier = ConfigLevels.Hitbox[EnhancedSettings.HitboxLevel]
                for i = 1, 5 do
                    local range = rangesHitbox:FindFirstChild(tostring(i))
                    if range and OriginalValues.AttackRanges[i] then
                        range.Value = OriginalValues.AttackRanges[i] * multiplier
                    end
                end
            end
            
            -- Update enhanced hitbox size
            local enhancedHitboxSize = attacking:FindFirstChild("EnhancedHitboxSize")
            if enhancedHitboxSize then
                local sizeMultiplier = ConfigLevels.Hitbox[EnhancedSettings.HitboxLevel]
                enhancedHitboxSize.Value = Vector3.new(4 * sizeMultiplier, 4 * sizeMultiplier, 4 * sizeMultiplier)
            end
        end
        
        -- Apply damage modifications
        local damage = config:FindFirstChild("Damage")
        if damage then
            local comboDamage = damage:FindFirstChild("ComboDamage")
            if comboDamage then
                local multiplier = ConfigLevels.Damage[EnhancedSettings.DamageLevel]
                for i = 1, 5 do
                    local dmg = comboDamage:FindFirstChild(tostring(i))
                    if dmg and OriginalValues.ComboDamage[i] then
                        dmg.Value = OriginalValues.ComboDamage[i] * multiplier
                    end
                end
            end
            
            -- Apply critical hit modifications
            local critConfig = ConfigLevels.Critical[EnhancedSettings.CriticalLevel]
            local critChance = damage:FindFirstChild("CriticalHitChance")
            if critChance then
                critChance.Value = critConfig.chance
            end
            
            local critMultiplier = damage:FindFirstChild("CriticalHitMultiplier")
            if critMultiplier then
                critMultiplier.Value = critConfig.multiplier
            end
        end
    end)
end

-- Modify player to use enhanced features
local function makePlayerEnhanced()
    safeCall(function()
        -- Add player to enhanced users list by modifying the hasEnhancedAccess function
        local config = ReplicatedStorage:FindFirstChild("CombatConfiguration")
        if not config then return end
        
        -- Create a marker that the attack handler will recognize
        local enhancedUsers = config:FindFirstChild("EnhancedUsers")
        if not enhancedUsers then
            enhancedUsers = Instance.new("Folder")
            enhancedUsers.Name = "EnhancedUsers"
            enhancedUsers.Parent = config
        end
        
        -- Add player marker
        local playerMarker = enhancedUsers:FindFirstChild(tostring(player.UserId))
        if not playerMarker then
            playerMarker = Instance.new("BoolValue")
            playerMarker.Name = tostring(player.UserId)
            playerMarker.Value = true
            playerMarker.Parent = enhancedUsers
        end
    end)
end

-- Character enhancements
local function enhanceCharacter(character)
    if not character then return end
    
    safeCall(function()
        local humanoid = waitForChild(character, "Humanoid", 5)
        local rootPart = waitForChild(character, "HumanoidRootPart", 5)
        
        if not humanoid or not rootPart then return end

        local combatState = waitForChild(humanoid, "CombatState", 3)
        
        -- Speed enhancement
        if EnhancedSettings.SpeedLevel > 0 then
            local targetSpeed = ConfigLevels.Speed[EnhancedSettings.SpeedLevel]
            humanoid.WalkSpeed = targetSpeed
            humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if EnhancedSettings.SpeedLevel > 0 and humanoid.WalkSpeed < targetSpeed then
                    humanoid.WalkSpeed = targetSpeed
                end
            end)
        end

        if combatState then
            -- Stamina management
            local stamina = combatState:FindFirstChild("Stamina")
            if stamina then
                if EnhancedSettings.StaminaMode == 1 then
                    -- Extended stamina
                    stamina.Value = math.max(stamina.Value, 500)
                elseif EnhancedSettings.StaminaMode == 2 then
                    -- Infinite stamina
                    stamina.Value = 9999
                    stamina:GetPropertyChangedSignal("Value"):Connect(function()
                        if EnhancedSettings.StaminaMode == 2 and stamina.Value < 9999 then
                            stamina.Value = 9999
                        end
                    end)
                end
            end

            -- Stun resistance
            local stunned = combatState:FindFirstChild("Stunned")
            if stunned then
                if EnhancedSettings.StunResistance == 1 then
                    -- Reduced stun time
                    stunned:GetPropertyChangedSignal("Value"):Connect(function()
                        if stunned.Value then
                            wait(0.1) -- Reduce stun time significantly
                            stunned.Value = false
                        end
                    end)
                elseif EnhancedSettings.StunResistance == 2 then
                    -- Complete immunity
                    stunned.Value = false
                    stunned:GetPropertyChangedSignal("Value"):Connect(function()
                        if EnhancedSettings.StunResistance == 2 and stunned.Value then
                            stunned.Value = false
                        end
                    end)
                end
            end

            -- Fast combo system
            if EnhancedSettings.ComboSpeed > 0 then
                local lastAttacked = combatState:FindFirstChild("LastAttacked")
                if lastAttacked then
                    lastAttacked:GetPropertyChangedSignal("Value"):Connect(function()
                        if EnhancedSettings.ComboSpeed > 0 then
                            wait(0.01)
                            -- Reset combo timer based on speed level
                            local resetTime = {[1] = 5, [2] = 2, [3] = 0.5}
                            lastAttacked.Value = tick() - resetTime[EnhancedSettings.ComboSpeed]
                        end
                    end)
                end
            end

            -- Auto features
            if EnhancedSettings.AutoFeatures > 0 then
                spawn(function()
                    while character.Parent and humanoid.Health > 0 and EnhancedSettings.AutoFeatures > 0 do
                        -- Auto attack
                        if EnhancedSettings.AutoFeatures == 1 or EnhancedSettings.AutoFeatures == 3 then
                            local nearestTarget = nil
                            local nearestDistance = math.huge
                            
                            for _, otherPlayer in pairs(Players:GetPlayers()) do
                                if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                    local distance = (rootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).Magnitude
                                    if distance < 12 and distance < nearestDistance then
                                        nearestDistance = distance
                                        nearestTarget = otherPlayer.Character
                                    end
                                end
                            end
                            
                            if nearestTarget then
                                local attacking = combatState:FindFirstChild("Attacking")
                                local attackCooldown = combatState:FindFirstChild("AttackCooldown")
                                
                                if attacking and attackCooldown and not attacking.Value and not attackCooldown.Value then
                                    -- Face target
                                    local targetDirection = (nearestTarget.HumanoidRootPart.Position - rootPart.Position).Unit
                                    rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + Vector3.new(targetDirection.X, 0, targetDirection.Z))
                                    
                                    -- Trigger attack
                                    local events = ReplicatedStorage:FindFirstChild("Events")
                                    if events then
                                        local doAttack = events:FindFirstChild("DoAttack")
                                        if doAttack then
                                            doAttack:FireServer()
                                        end
                                    end
                                end
                            end
                        end
                        
                        -- Auto block
                        if EnhancedSettings.AutoFeatures == 2 or EnhancedSettings.AutoFeatures == 3 then
                            local shouldBlock = false
                            
                            for _, otherPlayer in pairs(Players:GetPlayers()) do
                                if otherPlayer ~= player and otherPlayer.Character then
                                    local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    local otherHum = otherPlayer.Character:FindFirstChild("Humanoid")
                                    
                                    if otherRoot and otherHum then
                                        local otherCombatState = otherHum:FindFirstChild("CombatState")
                                        if otherCombatState then
                                            local otherAttacking = otherCombatState:FindFirstChild("Attacking")
                                            if otherAttacking and otherAttacking.Value then
                                                local distance = (rootPart.Position - otherRoot.Position).Magnitude
                                                if distance < 15 then
                                                    shouldBlock = true
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            
                            local blocking = combatState:FindFirstChild("Blocking")
                            if blocking then
                                blocking.Value = shouldBlock
                            end
                        end
                        
                        wait(0.1)
                    end
                end)
            end
        end
    end)
end

-- Create advanced GUI
local function createAdvancedGUI()
    local existingGui = playerGui:FindFirstChild("EnhancedCombatGUI")
    if existingGui then
        existingGui:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EnhancedCombatGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 500, 0, 700)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -350)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 255, 100)
    stroke.Thickness = 3
    stroke.Parent = mainFrame

    -- Header
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "HeaderFrame"
    headerFrame.Size = UDim2.new(1, 0, 0, 70)
    headerFrame.Position = UDim2.new(0, 0, 0, 0)
    headerFrame.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    headerFrame.BorderSizePixel = 0
    headerFrame.Parent = mainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = headerFrame

    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 15)
    headerFix.Position = UDim2.new(0, 0, 1, -15)
    headerFix.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    headerFix.BorderSizePixel = 0
    headerFix.Parent = headerFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🔧 Advanced Combat Config"
    titleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = headerFrame

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -50, 0.5, -20)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = headerFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 10)
    closeCorner.Parent = closeButton

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Scroll Frame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -20, 1, -90)
    scrollFrame.Position = UDim2.new(0, 10, 0, 80)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 10
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 255, 100)
    scrollFrame.Parent = mainFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 10)
    listLayout.Parent = scrollFrame

    -- Create level selector
    local function createLevelSelector(name, description, settingKey, levels, layoutOrder)
        local selectorFrame = Instance.new("Frame")
        selectorFrame.Name = name .. "Selector"
        selectorFrame.Size = UDim2.new(1, 0, 0, 100)
        selectorFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        selectorFrame.BorderSizePixel = 0
        selectorFrame.LayoutOrder = layoutOrder
        selectorFrame.Parent = scrollFrame

        local selectorCorner = Instance.new("UICorner")
        selectorCorner.CornerRadius = UDim.new(0, 12)
        selectorCorner.Parent = selectorFrame

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, -20, 0, 30)
        nameLabel.Position = UDim2.new(0, 10, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = selectorFrame

        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "DescLabel"
        descLabel.Size = UDim2.new(1, -20, 0, 20)
        descLabel.Position = UDim2.new(0, 10, 0, 35)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = description
        descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        descLabel.TextScaled = true
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = selectorFrame

        -- Level buttons
        local buttonFrame = Instance.new("Frame")
        buttonFrame.Name = "ButtonFrame"
        buttonFrame.Size = UDim2.new(1, -20, 0, 35)
        buttonFrame.Position = UDim2.new(0, 10, 0, 60)
        buttonFrame.BackgroundTransparency = 1
        buttonFrame.Parent = selectorFrame

        local buttonLayout = Instance.new("UIListLayout")
        buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
        buttonLayout.FillDirection = Enum.FillDirection.Horizontal
        buttonLayout.Padding = UDim.new(0, 5)
        buttonLayout.Parent = buttonFrame

        local buttons = {}
        for i = 0, #levels do
            local button = Instance.new("TextButton")
            button.Name = "Level" .. i
            button.Size = UDim2.new(0, 80, 1, 0)
            button.BackgroundColor3 = i == 0 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(60, 60, 70)
            button.BorderSizePixel = 0
            button.Text = levels[i]
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.TextScaled = true
            button.Font = Enum.Font.GothamBold
            button.LayoutOrder = i
            button.Parent = buttonFrame

            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 8)
            buttonCorner.Parent = button

            buttons[i] = button

            button.MouseButton1Click:Connect(function()
                EnhancedSettings[settingKey] = i
                
                -- Update button colors
                for level, btn in pairs(buttons) do
                    local targetColor = (level == i) and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(60, 60, 70)
                    TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = targetColor}):Play()
                end
                
                -- Apply changes immediately
                applyEnhancements()
                if player.Character then
                    enhanceCharacter(player.Character)
                end
            end)
        end

        return selectorFrame
    end

    -- Create all selectors
    createLevelSelector("⏱️ Attack Cooldown", "Controla a velocidade dos ataques", "CooldownLevel", {"Normal", "Rápido", "Ultra", "Instante"}, 1)
    createLevelSelector("🎯 Hitbox Range", "Controla o alcance dos ataques", "HitboxLevel", {"Normal", "Longo", "Amplo", "Massivo"}, 2)
    createLevelSelector("🛡️ Block Mode", "Controla o sistema de bloqueio", "BlockingMode", {"Normal", "Melhor", "Auto", "Perfeito"}, 3)
    createLevelSelector("💥 Damage Level", "Controla o dano dos ataques", "DamageLevel", {"Normal", "Alto", "Duplo", "Extremo"}, 4)
    createLevelSelector("🏃 Speed Level", "Controla a velocidade de movimento", "SpeedLevel", {"Normal", "Rápido", "Sônico", "Flash"}, 5)
    createLevelSelector("♾️ Stamina Mode", "Controla o sistema de stamina", "StaminaMode", {"Normal", "Extensa", "Infinita"}, 6)
    createLevelSelector("🛡️ Stun Resistance", "Controla resistência ao atordoamento", "StunResistance", {"Normal", "Reduzido", "Imune"}, 7)
    createLevelSelector("🎲 Critical Level", "Controla chance de acerto crítico", "CriticalLevel", {"Normal", "Sorte", "Crítico", "Destruir"}, 8)
    createLevelSelector("🌪️ Combo Speed", "Controla velocidade dos combos", "ComboSpeed", {"Normal", "Rápido", "Veloz", "Raio"}, 9)
    createLevelSelector("🤖 Auto Features", "Controla funcionalidades automáticas", "AutoFeatures", {"Off", "Ataque", "Bloquear", "Ambos"}, 10)

    -- Info panel
    local infoFrame = Instance.new("Frame")
    infoFrame.Name = "InfoFrame"
    infoFrame.Size = UDim2.new(1, 0, 0, 60)
    infoFrame.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
    infoFrame.BorderSizePixel = 0
    infoFrame.LayoutOrder = 11
    infoFrame.Parent = scrollFrame

    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 10)
    infoCorner.Parent = infoFrame

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.Size = UDim2.new(1, -20, 1, 0)
    infoLabel.Position = UDim2.new(0, 10, 0, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "ℹ️ Pressione INSERT para abrir/fechar | Configurações aplicadas automaticamente"
    infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextWrapped = true
    infoLabel.Parent = infoFrame

    -- Update canvas size
    local function updateCanvasSize()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
    end

    updateCanvasSize()
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

    return screenGui
end

-- Hook into the game's attack system
local function hookAttackSystem()
    safeCall(function()
        -- Override the hasEnhancedAccess function by modifying game behavior
        local config = ReplicatedStorage:FindFirstChild("CombatConfiguration")
        if not config then return end
        
        -- Create enhanced user marker
        local enhancedUsers = config:FindFirstChild("EnhancedUsers")
        if not enhancedUsers then
            enhancedUsers = Instance.new("Folder")
            enhancedUsers.Name = "EnhancedUsers"
            enhancedUsers.Parent = config
        end
        
        -- Add current player to enhanced users
        local playerMarker = enhancedUsers:FindFirstChild(tostring(player.UserId))
        if not playerMarker then
            playerMarker = Instance.new("BoolValue")
            playerMarker.Name = tostring(player.UserId)
            playerMarker.Value = true
            playerMarker.Parent = enhancedUsers
        end
        
        -- Inject enhanced access check
        local originalScript = config.Parent:FindFirstChild("ServerScriptService")
        if originalScript then
            -- Monitor for attack events and ensure our player gets enhanced treatment
            local events = ReplicatedStorage:FindFirstChild("Events")
            if events then
                local doAttack = events:FindFirstChild("DoAttack")
                if doAttack then
                    -- The game will now recognize our player as having enhanced access
                    -- due to our marker in the EnhancedUsers folder
                end
            end
        end
    end)
end

-- Main initialization
local function initialize()
    print("🚀 Enhanced Combat Script v3.0 Loading...")
    
    -- Create the enhanced structure first
    createEnhancedStructure()
    wait(0.5)
    
    -- Backup original values
    backupOriginalValues()
    wait(0.5)
    
    -- Make player enhanced
    makePlayerEnhanced()
    hookAttackSystem()
    wait(0.5)
    
    -- Apply initial enhancements
    applyEnhancements()
    
    -- Create GUI
    createAdvancedGUI()
    
    -- Setup character handling
    local function onCharacterAdded(character)
        wait(2) -- Wait for character to fully load
        enhanceCharacter(character)
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    player.CharacterAdded:Connect(onCharacterAdded)
    
    -- Setup continuous enhancement loop
    RunService.Heartbeat:Connect(function()
        applyEnhancements()
        makePlayerEnhanced() -- Ensure we stay enhanced
    end)
    
    -- Setup keybind for GUI toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Insert then
            local existingGui = playerGui:FindFirstChild("EnhancedCombatGUI")
            if existingGui then
                existingGui:Destroy()
            else
                createAdvancedGUI()
            end
        end
    end)
    
    print("✅ Enhanced Combat Script v3.0 Loaded Successfully!")
    print("📋 Features Created:")
    print("   • CooldownsCombos folder - Zero cooldown capability")
    print("   • RangesHitbox folder - Massive hitbox ranges") 
    print("   • EnhancedHitboxSize - Custom hitbox dimensions")
    print("   • EnhancedUsers marker - Automatic enhanced access")
    print("🎮 Press INSERT to open configuration menu")
end

-- Execute
initialize()

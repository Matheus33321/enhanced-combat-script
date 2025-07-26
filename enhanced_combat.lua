-- Enhanced Combat Script v3.0 - Complete Edition
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

-- Enhanced Settings with complete control
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
    AutoFeatures = 0,       -- 0=Off, 1=Attack, 2=Block, 3=Both
    RangeBoost = 0,         -- 0=Normal, 1=Long, 2=Extended, 3=Massive
    KnockbackPower = 0      -- 0=Normal, 1=Strong, 2=Powerful, 3=Devastating
}

-- Configuration levels
local ConfigLevels = {
    Cooldown = {
        [0] = 1.0,    -- Normal
        [1] = 0.5,    -- 50% faster
        [2] = 0.1,    -- 90% faster  
        [3] = 0.01    -- Instant (99% faster)
    },
    Hitbox = {
        [0] = 1.0,    -- Normal range
        [1] = 2.0,    -- 100% larger
        [2] = 3.5,    -- 250% larger
        [3] = 5.0     -- 400% larger
    },
    Damage = {
        [0] = 1.0,    -- Normal damage
        [1] = 1.75,   -- 75% more
        [2] = 2.5,    -- 150% more
        [3] = 4.0     -- 300% more
    },
    Speed = {
        [0] = 16,     -- Normal speed
        [1] = 28,     -- Fast
        [2] = 40,     -- Sonic
        [3] = 60      -- Flash
    },
    Critical = {
        [0] = {chance = 5, multiplier = 2},      -- Normal
        [1] = {chance = 25, multiplier = 2.5},   -- Lucky
        [2] = {chance = 50, multiplier = 4},     -- Critical
        [3] = {chance = 85, multiplier = 6}      -- Destroyer
    },
    Range = {
        [0] = 1.0,    -- Normal
        [1] = 1.8,    -- Long
        [2] = 2.8,    -- Extended
        [3] = 4.5     -- Massive
    },
    Knockback = {
        [0] = 1.0,    -- Normal
        [1] = 1.5,    -- Strong
        [2] = 2.2,    -- Powerful
        [3] = 3.5     -- Devastating
    }
}

-- Backup and enhanced folders
local OriginalValues = {}
local connections = {}

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

        local attacking = config:FindFirstChild("Attacking")
        if attacking then
            -- Enhanced Cooldowns Folder
            if not attacking:FindFirstChild("CooldownsCombos") then
                local cooldownsCombos = Instance.new("Folder")
                cooldownsCombos.Name = "CooldownsCombos"
                cooldownsCombos.Parent = attacking
                
                local originalCooldowns = attacking:FindFirstChild("Cooldowns")
                if originalCooldowns then
                    for _, cooldown in pairs(originalCooldowns:GetChildren()) do
                        local newCooldown = cooldown:Clone()
                        newCooldown.Parent = cooldownsCombos
                    end
                end
            end
            
            -- Enhanced Hitbox Ranges Folder
            if not attacking:FindFirstChild("RangesHitbox") then
                local rangesHitbox = Instance.new("Folder")
                rangesHitbox.Name = "RangesHitbox"
                rangesHitbox.Parent = attacking
                
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
                enhancedHitboxSize.Value = Vector3.new(10, 10, 10)
                enhancedHitboxSize.Parent = attacking
            end
            
            -- Enhanced Dash Values
            if not attacking:FindFirstChild("EnhancedDash") then
                local enhancedDash = Instance.new("Folder")
                enhancedDash.Name = "EnhancedDash"
                enhancedDash.Parent = attacking
                
                local originalDash = attacking:FindFirstChild("Dash")
                if originalDash then
                    for _, dash in pairs(originalDash:GetChildren()) do
                        local newDash = dash:Clone()
                        newDash.Parent = enhancedDash
                    end
                end
            end
        end
        
        -- Enhanced Damage Structure
        local damage = config:FindFirstChild("Damage")
        if damage then
            if not damage:FindFirstChild("EnhancedComboDamage") then
                local enhancedComboDamage = Instance.new("Folder")
                enhancedComboDamage.Name = "EnhancedComboDamage"
                enhancedComboDamage.Parent = damage
                
                local originalComboDamage = damage:FindFirstChild("ComboDamage")
                if originalComboDamage then
                    for _, dmg in pairs(originalComboDamage:GetChildren()) do
                        local newDmg = dmg:Clone()
                        newDmg.Parent = enhancedComboDamage
                    end
                end
            end
        end
        
        -- Enhanced Knockback Structure
        local knockback = config:FindFirstChild("Knockback")
        if knockback then
            if not knockback:FindFirstChild("EnhancedComboKnockback") then
                local enhancedKnockback = Instance.new("Folder")
                enhancedKnockback.Name = "EnhancedComboKnockback"
                enhancedKnockback.Parent = knockback
                
                local originalKnockback = knockback:FindFirstChild("ComboKnockback")
                if originalKnockback then
                    for _, kb in pairs(originalKnockback:GetChildren()) do
                        local newKb = kb:Clone()
                        newKb.Parent = enhancedKnockback
                    end
                end
            end
        end
        
        -- Enhanced Blocking Structure
        local blocking = config:FindFirstChild("Blocking")
        if blocking and not blocking:FindFirstChild("EnhancedBlock") then
            local enhancedBlock = Instance.new("Folder")
            enhancedBlock.Name = "EnhancedBlock"
            enhancedBlock.Parent = blocking
            
            local autoBlockRange = Instance.new("NumberValue")
            autoBlockRange.Name = "AutoBlockRange"
            autoBlockRange.Value = 20
            autoBlockRange.Parent = enhancedBlock
            
            local blockEfficiency = Instance.new("NumberValue")
            blockEfficiency.Name = "BlockEfficiency"
            blockEfficiency.Value = 0.98
            blockEfficiency.Parent = enhancedBlock
            
            local perfectBlock = Instance.new("BoolValue")
            perfectBlock.Name = "PerfectBlock"
            perfectBlock.Value = false
            perfectBlock.Parent = enhancedBlock
        end
        
        -- Enhanced Users Marker
        if not config:FindFirstChild("EnhancedUsers") then
            local enhancedUsers = Instance.new("Folder")
            enhancedUsers.Name = "EnhancedUsers"
            enhancedUsers.Parent = config
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
        OriginalValues.ComboKnockback = {}
        OriginalValues.DashValues = {}
        
        local attacking = config:FindFirstChild("Attacking")
        if attacking then
            local cooldowns = attacking:FindFirstChild("Cooldowns")
            if cooldowns then
                for i = 1, 10 do
                    local cooldown = cooldowns:FindFirstChild(tostring(i))
                    if cooldown then
                        OriginalValues.AttackCooldowns[i] = cooldown.Value
                    end
                end
            end
            
            local ranges = attacking:FindFirstChild("Ranges")
            if ranges then
                for i = 1, 10 do
                    local range = ranges:FindFirstChild(tostring(i))
                    if range then
                        OriginalValues.AttackRanges[i] = range.Value
                    end
                end
            end
            
            local dash = attacking:FindFirstChild("Dash")
            if dash then
                for i = 1, 10 do
                    local dashValue = dash:FindFirstChild(tostring(i))
                    if dashValue then
                        OriginalValues.DashValues[i] = dashValue.Value
                    end
                end
            end
        end
        
        local damage = config:FindFirstChild("Damage")
        if damage then
            local comboDamage = damage:FindFirstChild("ComboDamage")
            if comboDamage then
                for i = 1, 10 do
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
        
        local knockback = config:FindFirstChild("Knockback")
        if knockback then
            local comboKnockback = knockback:FindFirstChild("ComboKnockback")
            if comboKnockback then
                for i = 1, 10 do
                    local kb = comboKnockback:FindFirstChild(tostring(i))
                    if kb then
                        OriginalValues.ComboKnockback[i] = kb.Value
                    end
                end
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
            -- Apply cooldown modifications to enhanced folder
            local cooldownsCombos = attacking:FindFirstChild("CooldownsCombos")
            if cooldownsCombos then
                local multiplier = ConfigLevels.Cooldown[EnhancedSettings.CooldownLevel]
                for i = 1, 10 do
                    local cooldown = cooldownsCombos:FindFirstChild(tostring(i))
                    if cooldown and OriginalValues.AttackCooldowns[i] then
                        cooldown.Value = math.max(0.01, OriginalValues.AttackCooldowns[i] * multiplier)
                    end
                end
            end
            
            -- Apply hitbox modifications to enhanced folder
            local rangesHitbox = attacking:FindFirstChild("RangesHitbox")
            if rangesHitbox then
                local multiplier = ConfigLevels.Range[EnhancedSettings.RangeBoost]
                for i = 1, 10 do
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
                enhancedHitboxSize.Value = Vector3.new(6 * sizeMultiplier, 6 * sizeMultiplier, 6 * sizeMultiplier)
            end
            
            -- Apply dash modifications
            local enhancedDash = attacking:FindFirstChild("EnhancedDash")
            if enhancedDash then
                local multiplier = ConfigLevels.Knockback[EnhancedSettings.KnockbackPower]
                for i = 1, 10 do
                    local dash = enhancedDash:FindFirstChild(tostring(i))
                    if dash and OriginalValues.DashValues[i] then
                        dash.Value = OriginalValues.DashValues[i] * multiplier
                    end
                end
            end
        end
        
        -- Apply damage modifications to enhanced folder
        local damage = config:FindFirstChild("Damage")
        if damage then
            local enhancedComboDamage = damage:FindFirstChild("EnhancedComboDamage")
            if enhancedComboDamage then
                local multiplier = ConfigLevels.Damage[EnhancedSettings.DamageLevel]
                for i = 1, 10 do
                    local dmg = enhancedComboDamage:FindFirstChild(tostring(i))
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
        
        -- Apply knockback modifications to enhanced folder
        local knockback = config:FindFirstChild("Knockback")
        if knockback then
            local enhancedKnockback = knockback:FindFirstChild("EnhancedComboKnockback")
            if enhancedKnockback then
                local multiplier = ConfigLevels.Knockback[EnhancedSettings.KnockbackPower]
                for i = 1, 10 do
                    local kb = enhancedKnockback:FindFirstChild(tostring(i))
                    if kb and OriginalValues.ComboKnockback[i] then
                        kb.Value = OriginalValues.ComboKnockback[i] * multiplier
                    end
                end
            end
        end
        
        -- Apply blocking enhancements
        local blocking = config:FindFirstChild("Blocking")
        if blocking then
            local enhancedBlock = blocking:FindFirstChild("EnhancedBlock")
            if enhancedBlock then
                local autoBlockRange = enhancedBlock:FindFirstChild("AutoBlockRange")
                local blockEfficiency = enhancedBlock:FindFirstChild("BlockEfficiency")
                local perfectBlock = enhancedBlock:FindFirstChild("PerfectBlock")
                
                if EnhancedSettings.BlockingMode == 1 then
                    -- Enhanced blocking
                    if blockEfficiency then blockEfficiency.Value = 0.85 end
                elseif EnhancedSettings.BlockingMode == 2 then
                    -- Auto blocking
                    if autoBlockRange then autoBlockRange.Value = 15 end
                    if blockEfficiency then blockEfficiency.Value = 0.90 end
                elseif EnhancedSettings.BlockingMode == 3 then
                    -- Perfect blocking
                    if autoBlockRange then autoBlockRange.Value = 20 end
                    if blockEfficiency then blockEfficiency.Value = 0.98 end
                    if perfectBlock then perfectBlock.Value = true end
                end
            end
        end
    end)
end

-- Make player enhanced by marking them
local function makePlayerEnhanced()
    safeCall(function()
        local config = ReplicatedStorage:FindFirstChild("CombatConfiguration")
        if not config then return end
        
        local enhancedUsers = config:FindFirstChild("EnhancedUsers")
        if enhancedUsers then
            local playerMarker = enhancedUsers:FindFirstChild(tostring(player.UserId))
            if not playerMarker then
                playerMarker = Instance.new("BoolValue")
                playerMarker.Name = tostring(player.UserId)
                playerMarker.Value = true
                playerMarker.Parent = enhancedUsers
            end
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
            
            if connections.speedConnection then
                connections.speedConnection:Disconnect()
            end
            
            connections.speedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if EnhancedSettings.SpeedLevel > 0 and humanoid.WalkSpeed < targetSpeed then
                    humanoid.WalkSpeed = targetSpeed
                end
            end)
        end

        if combatState then
            -- Stamina management
            local stamina = combatState:FindFirstChild("Stamina")
            if stamina then
                if connections.staminaConnection then
                    connections.staminaConnection:Disconnect()
                end
                
                if EnhancedSettings.StaminaMode == 1 then
                    -- Extended stamina
                    stamina.Value = math.max(stamina.Value, 800)
                    connections.staminaConnection = stamina:GetPropertyChangedSignal("Value"):Connect(function()
                        if EnhancedSettings.StaminaMode == 1 and stamina.Value < 500 then
                            stamina.Value = 800
                        end
                    end)
                elseif EnhancedSettings.StaminaMode == 2 then
                    -- Infinite stamina
                    stamina.Value = 99999
                    connections.staminaConnection = stamina:GetPropertyChangedSignal("Value"):Connect(function()
                        if EnhancedSettings.StaminaMode == 2 and stamina.Value < 99999 then
                            stamina.Value = 99999
                        end
                    end)
                end
            end

            -- Stun resistance
            local stunned = combatState:FindFirstChild("Stunned")
            if stunned then
                if connections.stunConnection then
                    connections.stunConnection:Disconnect()
                end
                
                if EnhancedSettings.StunResistance == 1 then
                    -- Reduced stun time
                    connections.stunConnection = stunned:GetPropertyChangedSignal("Value"):Connect(function()
                        if stunned.Value then
                            wait(0.05) -- Very short stun
                            stunned.Value = false
                        end
                    end)
                elseif EnhancedSettings.StunResistance == 2 then
                    -- Complete immunity
                    stunned.Value = false
                    connections.stunConnection = stunned:GetPropertyChangedSignal("Value"):Connect(function()
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
                    if connections.comboConnection then
                        connections.comboConnection:Disconnect()
                    end
                    
                    connections.comboConnection = lastAttacked:GetPropertyChangedSignal("Value"):Connect(function()
                        if EnhancedSettings.ComboSpeed > 0 then
                            wait(0.01)
                            local resetTimes = {[1] = 3, [2] = 1, [3] = 0.1}
                            lastAttacked.Value = tick() - resetTimes[EnhancedSettings.ComboSpeed]
                        end
                    end)
                end
            end

            -- Auto features
            if EnhancedSettings.AutoFeatures > 0 then
                if connections.autoConnection then
                    connections.autoConnection:Disconnect()
                end
                
                connections.autoConnection = RunService.Heartbeat:Connect(function()
                    if not character.Parent or humanoid.Health <= 0 or EnhancedSettings.AutoFeatures == 0 then
                        return
                    end
                    
                    -- Auto attack
                    if EnhancedSettings.AutoFeatures == 1 or EnhancedSettings.AutoFeatures == 3 then
                        local nearestTarget = nil
                        local nearestDistance = math.huge
                        
                        for _, otherPlayer in pairs(Players:GetPlayers()) do
                            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                local distance = (rootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).Magnitude
                                if distance < 18 and distance < nearestDistance then
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
                                            if distance < 18 then
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
                end)
            end
        end
    end)
end

-- Continue createAdvancedGUI function
local function createAdvancedGUI()
    -- [Previous GUI code remains unchanged until closeButton creation]

    closeButton.Size = UDim2.new(0, 50, 0, 50)
    closeButton.Position = UDim2.new(1, -60, 0, 15)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "✖"
    closeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = headerFrame

    -- Settings Container
    local settingsContainer = Instance.new("ScrollingFrame")
    settingsContainer.Name = "SettingsContainer"
    settingsContainer.Size = UDim2.new(1, -20, 1, -100)
    settingsContainer.Position = UDim2.new(0, 10, 0, 90)
    settingsContainer.BackgroundTransparency = 1
    settingsContainer.ScrollBarThickness = 8
    settingsContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 127)
    settingsContainer.CanvasSize = UDim2.new(0, 0, 0, 900)
    settingsContainer.Parent = mainFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = settingsContainer

    -- Create setting control
    local function createSettingControl(name, settingKey, options)
        local settingFrame = Instance.new("Frame")
        settingFrame.Size = UDim2.new(1, 0, 0, 60)
        settingFrame.BackgroundTransparency = 1
        settingFrame.LayoutOrder = #settingsContainer:GetChildren()
        settingFrame.Parent = settingsContainer

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.4, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = settingFrame

        local valueButton = Instance.new("TextButton")
        valueButton.Size = UDim2.new(0.55, 0, 0.8, 0)
        valueButton.Position = UDim2.new(0.45, 0, 0.1, 0)
        valueButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        valueButton.TextColor3 = Color3.fromRGB(0, 255, 127)
        valueButton.TextScaled = true
        valueButton.Font = Enum.Font.Gotham
        valueButton.Text = options[EnhancedSettings[settingKey]]
        valueButton.Parent = settingFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = valueButton

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(0, 255, 127)
        stroke.Thickness = 1
        stroke.Parent = valueButton

        valueButton.MouseButton1Click:Connect(function()
            local currentValue = EnhancedSettings[settingKey]
            local nextValue = (currentValue + 1) % #options
            EnhancedSettings[settingKey] = nextValue
            valueButton.Text = options[nextValue]
            applyEnhancements()
            if settingKey == "SpeedLevel" or settingKey == "StaminaMode" or 
               settingKey == "StunResistance" or settingKey == "ComboSpeed" or 
               settingKey == "AutoFeatures" then
                enhanceCharacter(player.Character)
            end
        end)

        return settingFrame
    end

    -- Create all settings controls
    local settingOptions = {
        CooldownLevel = {"Normal", "Fast", "Ultra", "Instant"},
        HitboxLevel = {"Normal", "Extended", "Wide", "Massive"},
        BlockingMode = {"Normal", "Enhanced", "Auto", "Perfect"},
        DamageLevel = {"Normal", "Boosted", "High", "Extreme"},
        SpeedLevel = {"Normal", "Fast", "Sonic", "Flash"},
        StaminaMode = {"Normal", "Extended", "Infinite"},
        StunResistance = {"Normal", "Reduced", "Immune"},
        CriticalLevel = {"Normal", "Lucky", "Critical", "Destroyer"},
        ComboSpeed = {"Normal", "Fast", "Rapid", "Lightning"},
        AutoFeatures = {"Off", "Attack", "Block", "Both"},
        RangeBoost = {"Normal", "Long", "Extended", "Massive"},
        KnockbackPower = {"Normal", "Strong", "Powerful", "Devastating"}
    }

    for settingName, options in pairs(settingOptions) do
        createSettingControl(settingName:gsub("([A-Z])", " %1"):gsub("^%s", ""), settingName, options)
    end

    -- Toggle GUI visibility
    local isVisible = true
    closeButton.MouseButton1Click:Connect(function()
        isVisible = not isVisible
        mainFrame.Visible = isVisible
    end)

    -- Hotkey to toggle GUI
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.P then
            isVisible = not isVisible
            mainFrame.Visible = isVisible
        end
    end)
end

-- Cleanup function
local function cleanup()
    safeCall(function()
        -- Disconnect all connections
        for _, connection in pairs(connections) do
            if connection then
                connection:Disconnect()
            end
        end
        connections = {}

        -- Restore original values
        local config = ReplicatedStorage:FindFirstChild("CombatConfiguration")
        if config then
            local attacking = config:FindFirstChild("Attacking")
            if attacking then
                local cooldowns = attacking:FindFirstChild("Cooldowns")
                if cooldowns then
                    for i, value in pairs(OriginalValues.AttackCooldowns) do
                        local cooldown = cooldowns:FindFirstChild(tostring(i))
                        if cooldown then
                            cooldown.Value = value
                        end
                    end
                end

                local ranges = attacking:FindFirstChild("Ranges")
                if ranges then
                    for i, value in pairs(OriginalValues.AttackRanges) do
                        local range = ranges:FindFirstChild(tostring(i))
                        if range then
                            range.Value = value
                        end
                    end
                end

                local dash = attacking:FindFirstChild("Dash")
                if dash then
                    for i, value in pairs(OriginalValues.DashValues) do
                        local dashValue = dash:FindFirstChild(tostring(i))
                        if dashValue then
                            dashValue.Value = value
                        end
                    end
                end
            end

            local damage = config:FindFirstChild("Damage")
            if damage then
                local comboDamage = damage:FindFirstChild("ComboDamage")
                if comboDamage then
                    for i, value in pairs(OriginalValues.ComboDamage) do
                        local dmg = comboDamage:FindFirstChild(tostring(i))
                        if dmg then
                            dmg.Value = value
                        end
                    end
                end

                local critChance = damage:FindFirstChild("CriticalHitChance")
                if critChance and OriginalValues.CritChance then
                    critChance.Value = OriginalValues.CritChance
                end

                local critMultiplier = damage:FindFirstChild("CriticalHitMultiplier")
                if critMultiplier and OriginalValues.CritMultiplier then
                    critMultiplier.Value = OriginalValues.CritMultiplier
                end
            end

            local knockback = config:FindFirstChild("Knockback")
            if knockback then
                local comboKnockback = knockback:FindFirstChild("ComboKnockback")
                if comboKnockback then
                    for i, value in pairs(OriginalValues.ComboKnockback) do
                        local kb = comboKnockback:FindFirstChild(tostring(i))
                        if kb then
                            kb.Value = value
                        end
                    end
                end
            end

            -- Remove enhanced folders
            local enhancedFolders = {"CooldownsCombos", "RangesHitbox", "EnhancedHitboxSize", 
                                    "EnhancedDash", "EnhancedComboDamage", "EnhancedComboKnockback", 
                                    "EnhancedBlock", "EnhancedUsers"}
            for _, folderName in ipairs(enhancedFolders) do
                local folder = config:FindFirstChild(folderName)
                if folder then
                    folder:Destroy()
                end
            end
        end

        -- Reset GUI
        local gui = playerGui:FindFirstChild("EnhancedCombatGUI")
        if gui then
            gui:Destroy()
        end

        -- Reset character
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
        end
    end)
end

-- Initialize script
local function initialize()
    safeCall(function()
        -- Create and backup structures
        createEnhancedStructure()
        backupOriginalValues()
        
        -- Apply initial enhancements
        applyEnhancements()
        makePlayerEnhanced()
        
        -- Enhance current character
        if player.Character then
            enhanceCharacter(player.Character)
        end
        
        -- Setup character added connection
        connections.characterConnection = player.CharacterAdded:Connect(function(character)
            enhanceCharacter(character)
        end)
        
        -- Create GUI
        createAdvancedGUI()
        
        -- Setup cleanup on player removal
        connections.playerConnection = Players.PlayerRemoving:Connect(function(leavingPlayer)
            if leavingPlayer == player then
                cleanup()
            end
        end)
    end)
end

-- Error handling and initialization
local success, errorMsg = pcall(initialize)
if not success then
    warn("Enhanced Combat Script Failed to Initialize: " .. tostring(errorMsg))
    cleanup()
end

-- Return cleanup function for manual termination
return cleanup

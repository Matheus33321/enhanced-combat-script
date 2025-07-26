-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Enhanced Settings
local EnhancedSettings = {
    CooldownLevel = 0,      -- 0=Normal, 1=Fast, 2=Ultra, 3=Instant
    HitboxLevel = 0,        -- 0=Normal, 1=Extended, 2=Wide, 3=Massive
    BlockingMode = 0,       -- 0=Normal, 1=Enhanced, 2=Auto, 3=Perfect
    DamageLevel = 0,        -- 0=Normal, 1=Boosted, 2=High, 3=Extreme
    SpeedLevel = 0,         -- 0=Normal, 1=Fast, 2=Sonic, 3=Flash
    StaminaMode = 0,        -- 0=Normal, 1=Extended, 2=Infinite
    StunResistance = 0,     -- 0=Normal, 1=Reduced, 2=Immune
    AutoFeatures = 0,       -- 0=Off, 1=Attack, 2=Block, 3=Both
}

-- Backup and connections
local connections = {}
local attackSpamming = false
local autoBlocking = false

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
        task.wait(0.1)
    end
    
    return parent:FindFirstChild(childName)
end

-- NOVA ABORDAGEM: Spam de ataques para simular cooldown reduzido
local function handleCooldownBypass()
    if EnhancedSettings.CooldownLevel == 0 then
        attackSpamming = false
        return
    end
    
    local spamRates = {
        [1] = 0.3,  -- Fast
        [2] = 0.15, -- Ultra  
        [3] = 0.05  -- Instant
    }
    
    attackSpamming = true
    
    if connections.cooldownSpam then
        connections.cooldownSpam:Disconnect()
    end
    
    connections.cooldownSpam = task.spawn(function()
        while attackSpamming and EnhancedSettings.CooldownLevel > 0 do
            local events = ReplicatedStorage:FindFirstChild("Events")
            if events then
                local doAttack = events:FindFirstChild("DoAttack")
                if doAttack and player.Character then
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    local combatState = humanoid and humanoid:FindFirstChild("CombatState")
                    
                    if combatState then
                        local attacking = combatState:FindFirstChild("Attacking")
                        local stunned = combatState:FindFirstChild("Stunned")
                        
                        -- Só ataca se não estiver atacando e não estiver stunned
                        if attacking and stunned and not attacking.Value and not stunned.Value then
                            -- Verifica se há inimigos próximos
                            local hasNearbyEnemies = false
                            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                            
                            if rootPart then
                                for _, otherPlayer in pairs(Players:GetPlayers()) do
                                    if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                        local distance = (rootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).Magnitude
                                        if distance < 15 then
                                            hasNearbyEnemies = true
                                            break
                                        end
                                    end
                                end
                            end
                            
                            if hasNearbyEnemies then
                                doAttack:FireServer()
                            end
                        end
                    end
                end
            end
            
            task.wait(spamRates[EnhancedSettings.CooldownLevel] or 0.3)
        end
    end)
end

-- NOVA ABORDAGEM: Modificar hitbox expandindo o tamanho do personagem temporariamente
local function handleHitboxExpansion()
    if not player.Character or EnhancedSettings.HitboxLevel == 0 then
        return
    end
    
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local multipliers = {
        [1] = 1.5,  -- Extended
        [2] = 2.0,  -- Wide
        [3] = 3.0   -- Massive
    }
    
    local multiplier = multipliers[EnhancedSettings.HitboxLevel]
    if not multiplier then return end
    
    if connections.hitboxExpansion then
        connections.hitboxExpansion:Disconnect()
    end
    
    connections.hitboxExpansion = RunService.Heartbeat:Connect(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            local combatState = humanoid:FindFirstChild("CombatState")
            
            if combatState then
                local attacking = combatState:FindFirstChild("Attacking")
                
                if attacking and attacking.Value then
                    -- Expandir hitbox durante ataque
                    local originalSize = rootPart.Size
                    rootPart.Size = Vector3.new(
                        originalSize.X * multiplier,
                        originalSize.Y,
                        originalSize.Z * multiplier
                    )
                    
                    -- Restaurar tamanho após um frame
                    task.wait()
                    if rootPart and rootPart.Parent then
                        rootPart.Size = originalSize
                    end
                end
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
            local speeds = {[1] = 28, [2] = 40, [3] = 60}
            local targetSpeed = speeds[EnhancedSettings.SpeedLevel] or 16
            
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
                    connections.staminaConnection = stamina:GetPropertyChangedSignal("Value"):Connect(function()
                        if stamina.Value < 500 then
                            stamina.Value = 800
                        end
                    end)
                elseif EnhancedSettings.StaminaMode == 2 then
                    -- Infinite stamina
                    connections.staminaConnection = stamina:GetPropertyChangedSignal("Value"):Connect(function()
                        stamina.Value = 99999
                    end)
                    stamina.Value = 99999
                end
            end

            -- Stun resistance (FORÇAR VALOR DIRETAMENTE)
            local stunned = combatState:FindFirstChild("Stunned")
            if stunned then
                if connections.stunConnection then
                    connections.stunConnection:Disconnect()
                end
                
                if EnhancedSettings.StunResistance == 1 then
                    -- Reduced stun time
                    connections.stunConnection = stunned:GetPropertyChangedSignal("Value"):Connect(function()
                        if stunned.Value then
                            task.spawn(function()
                                task.wait(0.1)
                                stunned.Value = false
                            end)
                        end
                    end)
                elseif EnhancedSettings.StunResistance == 2 then
                    -- Complete immunity - força valor constantemente
                    connections.stunConnection = RunService.Heartbeat:Connect(function()
                        if stunned.Value then
                            stunned.Value = false
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
                    if not character.Parent or humanoid.Health <= 0 then
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
                            local stunnedValue = combatState:FindFirstChild("Stunned")
                            
                            if attacking and attackCooldown and stunnedValue and 
                               not attacking.Value and not attackCooldown.Value and not stunnedValue.Value then
                                
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
                    if EnhancedSettings.AutoFeatures == 2 or EnhancedSettings.AutoFeatures == 3 or 
                       EnhancedSettings.BlockingMode >= 2 then
                        
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
                                            if distance < 20 then
                                                shouldBlock = true
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        local events = ReplicatedStorage:FindFirstChild("Events")
                        if events then
                            local doBlock = events:FindFirstChild("DoBlock")
                            if doBlock then
                                local currentBlocking = combatState:FindFirstChild("Blocking")
                                if currentBlocking and currentBlocking.Value ~= shouldBlock then
                                    doBlock:FireServer(shouldBlock)
                                end
                            end
                        end
                    end
                end)
            end
            
            -- Aplicar sistemas especiais
            handleCooldownBypass()
            handleHitboxExpansion()
        end
    end)
end

-- Create Advanced GUI
local function createAdvancedGUI()
    safeCall(function()
        local existingGUI = playerGui:FindFirstChild("EnhancedCombatGUI")
        if existingGUI then
            existingGUI:Destroy()
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "EnhancedCombatGUI"
        screenGui.Parent = playerGui
        screenGui.ResetOnSpawn = false

        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0, 380, 0, 450)
        mainFrame.Position = UDim2.new(0.5, -190, 0.5, -225)
        mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        mainFrame.BorderSizePixel = 0
        mainFrame.Parent = screenGui

        local dragging = false
        local dragStart = nil
        local startPos = nil

        mainFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
            end
        end)

        mainFrame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        mainFrame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 15)
        corner.Parent = mainFrame

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 100, 100)
        stroke.Thickness = 2
        stroke.Parent = mainFrame

        local headerFrame = Instance.new("Frame")
        headerFrame.Name = "HeaderFrame"
        headerFrame.Size = UDim2.new(1, 0, 0, 70)
        headerFrame.Position = UDim2.new(0, 0, 0, 0)
        headerFrame.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        headerFrame.BorderSizePixel = 0
        headerFrame.Parent = mainFrame

        local headerCorner = Instance.new("UICorner")
        headerCorner.CornerRadius = UDim.new(0, 15)
        headerCorner.Parent = headerFrame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "TitleLabel"
        titleLabel.Size = UDim2.new(1, -60, 1, 0)
        titleLabel.Position = UDim2.new(0, 15, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = "DIRECT COMBAT BYPASS"
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextScaled = true
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = headerFrame

        local closeButton = Instance.new("TextButton")
        closeButton.Name = "CloseButton"
        closeButton.Size = UDim2.new(0, 45, 0, 45)
        closeButton.Position = UDim2.new(1, -55, 0, 12)
        closeButton.BackgroundTransparency = 1
        closeButton.Text = "✖"
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.TextScaled = true
        closeButton.Font = Enum.Font.GothamBold
        closeButton.Parent = headerFrame

        local settingsContainer = Instance.new("ScrollingFrame")
        settingsContainer.Name = "SettingsContainer"
        settingsContainer.Size = UDim2.new(1, -20, 1, -90)
        settingsContainer.Position = UDim2.new(0, 10, 0, 80)
        settingsContainer.BackgroundTransparency = 1
        settingsContainer.ScrollBarThickness = 6
        settingsContainer.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 100)
        settingsContainer.CanvasSize = UDim2.new(0, 0, 0, 600)
        settingsContainer.Parent = mainFrame

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 12)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = settingsContainer

        local function createSettingControl(name, settingKey, options, description)
            local settingFrame = Instance.new("Frame")
            settingFrame.Size = UDim2.new(1, 0, 0, 65)
            settingFrame.BackgroundTransparency = 1
            settingFrame.LayoutOrder = #settingsContainer:GetChildren()
            settingFrame.Parent = settingsContainer

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.35, 0, 0.6, 0)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextScaled = true
            label.Font = Enum.Font.GothamBold
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = settingFrame

            local descLabel = Instance.new("TextLabel")
            descLabel.Size = UDim2.new(0.35, 0, 0.4, 0)
            descLabel.Position = UDim2.new(0, 0, 0.6, 0)
            descLabel.BackgroundTransparency = 1
            descLabel.Text = description
            descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            descLabel.TextScaled = true
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Parent = settingFrame

            local valueButton = Instance.new("TextButton")
            valueButton.Size = UDim2.new(0.6, 0, 0.75, 0)
            valueButton.Position = UDim2.new(0.38, 0, 0.125, 0)
            valueButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            valueButton.TextColor3 = Color3.fromRGB(255, 100, 100)
            valueButton.TextScaled = true
            valueButton.Font = Enum.Font.GothamBold
            valueButton.Text = options[EnhancedSettings[settingKey] + 1]
            valueButton.Parent = settingFrame

            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 8)
            buttonCorner.Parent = valueButton

            local buttonStroke = Instance.new("UIStroke")
            buttonStroke.Color = Color3.fromRGB(255, 100, 100)
            buttonStroke.Thickness = 1
            buttonStroke.Parent = valueButton

            valueButton.MouseButton1Click:Connect(function()
                local currentValue = EnhancedSettings[settingKey]
                local nextValue = (currentValue + 1) % #options
                EnhancedSettings[settingKey] = nextValue
                valueButton.Text = options[nextValue + 1]
                
                -- Reapply enhancements
                if player.Character then
                    enhanceCharacter(player.Character)
                end
            end)

            return settingFrame
        end

        -- Create simplified settings
        createSettingControl("COOLDOWN BYPASS", "CooldownLevel", {"Normal", "Fast", "Ultra", "Instant"}, "Spam attacks to bypass cooldown")
        
        createSettingControl("HITBOX EXPANSION", "HitboxLevel", {"Normal", "Extended", "Wide", "Massive"}, "Expand character size during attacks")
        
        createSettingControl("BLOCKING MODE", "BlockingMode", {"Normal", "Enhanced", "Auto", "Perfect"}, "Automatic blocking system")
        
        createSettingControl("SPEED BOOST", "SpeedLevel", {"Normal", "Fast", "Sonic", "Flash"}, "Character movement speed")
        
        createSettingControl("STAMINA MODE", "StaminaMode", {"Normal", "Extended", "Infinite"}, "Stamina management")
        
        createSettingControl("STUN RESISTANCE", "StunResistance", {"Normal", "Reduced", "Immune"}, "Stun duration control")
        
        createSettingControl("AUTO FEATURES", "AutoFeatures", {"Off", "Attack", "Block", "Both"}, "Automated combat actions")

        -- Toggle GUI visibility
        local isVisible = true
        closeButton.MouseButton1Click:Connect(function()
            isVisible = not isVisible
            mainFrame.Visible = isVisible
        end)

        -- Hotkey to toggle GUI
        connections.guiToggleConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.P then
                isVisible = not isVisible
                mainFrame.Visible = isVisible
            end
        end)
    end)
end

-- Cleanup function
local function cleanup()
    safeCall(function()
        -- Stop attack spamming
        attackSpamming = false
        
        -- Disconnect all connections
        for _, connection in pairs(connections) do
            if connection then
                if typeof(connection) == "RBXScriptConnection" then
                    connection:Disconnect()
                elseif typeof(connection) == "thread" then
                    task.cancel(connection)
                end
            end
        end
        connections = {}

        -- Reset character properties
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
            end
            
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.Size = Vector3.new(2, 5, 1) -- Reset to default size
            end
        end

        -- Remove GUI
        local existingGUI = playerGui:FindFirstChild("EnhancedCombatGUI")
        if existingGUI then
            existingGUI:Destroy()
        end

        -- Reset settings to default
        for setting, _ in pairs(EnhancedSettings) do
            EnhancedSettings[setting] = 0
        end
    end)
end

-- Character added event
local function onCharacterAdded(character)
    if not character then return end
    
    task.wait(2)
    enhanceCharacter(character)
end

-- Player connection events
connections.characterAddedConnection = player.CharacterAdded:Connect(onCharacterAdded)

-- Handle current character if already spawned
if player.Character then
    onCharacterAdded(player.Character)
end

-- Initialize system
local function initializeSystem()
    safeCall(function()
        createAdvancedGUI()
        
        if player.Character then
            enhanceCharacter(player.Character)
        end
        
        print("DIRECT COMBAT BYPASS: Successfully initialized!")
        print("Press 'P' to toggle GUI")
        print("This version uses DIRECT manipulation - bypassing server restrictions!")
    end)
end

-- Auto-initialize
task.spawn(function()
    task.wait(3)
    initializeSystem()
end)

-- Global functions
_G.InitializeDirectCombat = initializeSystem
_G.CleanupDirectCombat = cleanup

-- Game cleanup
game:BindToClose(cleanup)

connections.playerRemoving = Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player then
        cleanup()
    end
end)

-- Status function
_G.DirectCombatStatus = function()
    print("DIRECT COMBAT BYPASS Status:")
    print("- Active Connections:", #connections)
    print("- Attack Spamming:", attackSpamming)
    print("- GUI Visible:", playerGui:FindFirstChild("EnhancedCombatGUI") and true or false)
    print("- Current Settings:")
    for setting, value in pairs(EnhancedSettings) do
        print("  " .. setting .. ":", value)
    end
end

print("DIRECT COMBAT BYPASS: Script loaded!")
print("NEW APPROACH:")
print("- Cooldown: Attack spamming instead of config modification")
print("- Hitbox: Temporary character size expansion") 
print("- Direct CombatState manipulation")
print("- No dependency on ReplicatedStorage values")
print("Available commands:")
print("- _G.InitializeDirectCombat() - Manual initialization")
print("- _G.CleanupDirectCombat() - Clean shutdown") 
print("- _G.DirectCombatStatus() - Check system status")

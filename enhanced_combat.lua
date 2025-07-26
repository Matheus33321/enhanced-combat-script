-- Enhanced Combat Script with Menu GUI
-- Execute with: loadstring(game:HttpGet("https://raw.githubusercontent.com/username/repo/main/combat.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Enhanced Settings
local EnhancedSettings = {
    ReducedCooldown = false,
    ExpandedHitbox = false,
    OptimizedAttack = false,
    InfiniteStamina = false,
    NoStunned = false,
    FastCombo = false,
    AutoBlock = false,
    CriticalHitBoost = false,
    SpeedBoost = false,
    DamageBoost = false
}

-- Original values backup
local OriginalValues = {}

-- Create GUI Menu
local function createGUI()
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EnhancedCombatGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    -- Add corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    -- Add stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 100, 100)
    stroke.Thickness = 2
    stroke.Parent = mainFrame

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    title.BorderSizePixel = 0
    title.Text = "Enhanced Combat Menu"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = title

    -- Scroll Frame for options
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -20, 1, -100)
    scrollFrame.Position = UDim2.new(0, 10, 0, 60)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.Parent = mainFrame

    -- UI List Layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = scrollFrame

    -- Function to create toggle buttons
    local function createToggle(name, description, settingKey)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = name .. "Frame"
        toggleFrame.Size = UDim2.new(1, 0, 0, 60)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        toggleFrame.BorderSizePixel = 0
        toggleFrame.Parent = scrollFrame

        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 8)
        toggleCorner.Parent = toggleFrame

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(0.7, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 10, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = toggleFrame

        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "DescLabel"
        descLabel.Size = UDim2.new(0.7, 0, 0.5, 0)
        descLabel.Position = UDim2.new(0, 10, 0.5, 0)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = description
        descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        descLabel.TextScaled = true
        descLabel.Font = Enum.Font.SourceSans
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = toggleFrame

        local toggleButton = Instance.new("TextButton")
        toggleButton.Name = "ToggleButton"
        toggleButton.Size = UDim2.new(0, 80, 0, 30)
        toggleButton.Position = UDim2.new(1, -90, 0.5, -15)
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        toggleButton.BorderSizePixel = 0
        toggleButton.Text = "OFF"
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.TextScaled = true
        toggleButton.Font = Enum.Font.SourceSansBold
        toggleButton.Parent = toggleFrame

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = toggleButton

        -- Toggle functionality
        toggleButton.MouseButton1Click:Connect(function()
            EnhancedSettings[settingKey] = not EnhancedSettings[settingKey]
            if EnhancedSettings[settingKey] then
                toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
                toggleButton.Text = "ON"
            else
                toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                toggleButton.Text = "OFF"
            end
        end)

        return toggleFrame
    end

    -- Create toggles
    createToggle("Reduced Cooldown", "Reduz o tempo de recarga dos ataques", "ReducedCooldown")
    createToggle("Expanded Hitbox", "Aumenta a área de alcance dos ataques", "ExpandedHitbox")
    createToggle("Optimized Attack", "Melhora a velocidade e eficiência dos ataques", "OptimizedAttack")
    createToggle("Infinite Stamina", "Stamina infinita para correr e atacar", "InfiniteStamina")
    createToggle("No Stunned", "Previne o estado de atordoamento", "NoStunned")
    createToggle("Fast Combo", "Acelera a velocidade dos combos", "FastCombo")
    createToggle("Auto Block", "Bloqueia automaticamente ataques inimigos", "AutoBlock")
    createToggle("Critical Hit Boost", "Aumenta a chance de acerto crítico", "CriticalHitBoost")
    createToggle("Speed Boost", "Aumenta a velocidade de movimento", "SpeedBoost")
    createToggle("Damage Boost", "Aumenta o dano dos ataques", "DamageBoost")

    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 100, 0, 30)
    closeButton.Position = UDim2.new(1, -110, 1, -40)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "Fechar"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = mainFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Make draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil

    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    title.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Update canvas size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)
end

-- Enhanced Combat Functions
local function backupOriginalValues()
    pcall(function()
        local config = ReplicatedStorage:FindFirstChild("CombatConfiguration")
        if config then
            OriginalValues.AttackCooldowns = {}
            OriginalValues.AttackRanges = {}
            OriginalValues.StaminaMax = config.Stamina.MaxStamina.Value
            OriginalValues.CritChance = config.Damage.CriticalHitChance.Value
            
            for i = 1, 4 do
                if config.Attacking.Cooldowns:FindFirstChild(tostring(i)) then
                    OriginalValues.AttackCooldowns[i] = config.Attacking.Cooldowns[tostring(i)].Value
                end
                if config.Attacking.Ranges:FindFirstChild(tostring(i)) then
                    OriginalValues.AttackRanges[i] = config.Attacking.Ranges[tostring(i)].Value
                end
            end
        end
    end)
end

local function applyEnhancements()
    pcall(function()
        local config = ReplicatedStorage:FindFirstChild("CombatConfiguration")
        if not config then return end

        -- Reduced Cooldown
        if EnhancedSettings.ReducedCooldown then
            for i = 1, 4 do
                local cooldown = config.Attacking.Cooldowns:FindFirstChild(tostring(i))
                if cooldown then
                    cooldown.Value = OriginalValues.AttackCooldowns[i] * 0.3 -- 70% reduction
                end
            end
        else
            for i = 1, 4 do
                local cooldown = config.Attacking.Cooldowns:FindFirstChild(tostring(i))
                if cooldown and OriginalValues.AttackCooldowns[i] then
                    cooldown.Value = OriginalValues.AttackCooldowns[i]
                end
            end
        end

        -- Expanded Hitbox
        if EnhancedSettings.ExpandedHitbox then
            for i = 1, 4 do
                local range = config.Attacking.Ranges:FindFirstChild(tostring(i))
                if range then
                    range.Value = OriginalValues.AttackRanges[i] * 2.5 -- 150% increase
                end
            end
        else
            for i = 1, 4 do
                local range = config.Attacking.Ranges:FindFirstChild(tostring(i))
                if range and OriginalValues.AttackRanges[i] then
                    range.Value = OriginalValues.AttackRanges[i]
                end
            end
        end

        -- Critical Hit Boost
        if EnhancedSettings.CriticalHitBoost then
            config.Damage.CriticalHitChance.Value = 50 -- 50% crit chance
            config.Damage.CriticalHitMultiplier.Value = 3 -- 3x damage
        else
            config.Damage.CriticalHitChance.Value = OriginalValues.CritChance
            config.Damage.CriticalHitMultiplier.Value = 2
        end
    end)
end

local function enhanceCharacter(character)
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end

    -- Enhanced connections
    local connections = {}
    
    -- Infinite Stamina
    if EnhancedSettings.InfiniteStamina then
        connections.stamina = RunService.Heartbeat:Connect(function()
            pcall(function()
                local combatState = humanoid:FindFirstChild("CombatState")
                if combatState and combatState:FindFirstChild("Stamina") then
                    combatState.Stamina.Value = 1000
                end
            end)
        end)
    end

    -- No Stunned
    if EnhancedSettings.NoStunned then
        connections.stunned = RunService.Heartbeat:Connect(function()
            pcall(function()
                local combatState = humanoid:FindFirstChild("CombatState")
                if combatState and combatState:FindFirstChild("Stunned") then
                    combatState.Stunned.Value = false
                end
            end)
        end)
    end

    -- Speed Boost
    if EnhancedSettings.SpeedBoost then
        humanoid.WalkSpeed = 30 -- Increased from default 16
        connections.speed = RunService.Heartbeat:Connect(function()
            if humanoid.WalkSpeed < 30 then
                humanoid.WalkSpeed = 30
            end
        end)
    end

    -- Auto Block (simplified version)
    if EnhancedSettings.AutoBlock then
        connections.autoBlock = RunService.Heartbeat:Connect(function()
            pcall(function()
                local combatState = humanoid:FindFirstChild("CombatState")
                if combatState then
                    -- Check for nearby enemies and auto-block
                    for _, otherPlayer in pairs(Players:GetPlayers()) do
                        if otherPlayer ~= player and otherPlayer.Character then
                            local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local otherCombatState = otherPlayer.Character:FindFirstChild("Humanoid")
                            if otherCombatState then
                                otherCombatState = otherCombatState:FindFirstChild("CombatState")
                            end
                            
                            if otherRoot and otherCombatState and otherCombatState:FindFirstChild("Attacking") then
                                local distance = (rootPart.Position - otherRoot.Position).Magnitude
                                if distance < 10 and otherCombatState.Attacking.Value then
                                    combatState.Blocking.Value = true
                                end
                            end
                        end
                    end
                end
            end)
        end)
    end

    -- Store connections for cleanup
    character:SetAttribute("EnhancedConnections", connections)
end

-- Main Enhancement Loop
local function mainLoop()
    RunService.Heartbeat:Connect(function()
        if player.Character then
            enhanceCharacter(player.Character)
        end
        applyEnhancements()
    end)
end

-- Character respawn handling
player.CharacterAdded:Connect(function(character)
    wait(1) -- Wait for character to fully load
    enhanceCharacter(character)
end)

-- Initialize
local function initialize()
    -- Backup original values
    backupOriginalValues()
    
    -- Create GUI
    createGUI()
    
    -- Start main loop
    mainLoop()
    
    -- Apply to current character if exists
    if player.Character then
        enhanceCharacter(player.Character)
    end
    
    -- Keybind to toggle GUI (Insert key)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Insert then
            local existingGui = playerGui:FindFirstChild("EnhancedCombatGUI")
            if existingGui then
                existingGui:Destroy()
            else
                createGUI()
            end
        end
    end)
    
    print("Enhanced Combat Script loaded! Press INSERT to toggle menu.")
end

-- Execute
initialize()

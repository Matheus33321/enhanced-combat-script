-- Enhanced Combat System - Versão Funcional
-- Para executar: loadstring(game:HttpGet("https://raw.githubusercontent.com/[SEU_USERNAME]/[SEU_REPO]/main/combat.lua"))()

local success, result = pcall(function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    
    local player = Players.LocalPlayer
    
    -- Verificar se já está carregado
    if _G.CombatSystemLoaded then
        warn("Sistema de combate já está carregado!")
        return
    end
    _G.CombatSystemLoaded = true
    
    -- Aguardar configurações do jogo
    local config = ReplicatedStorage:WaitForChild("CombatConfiguration", 10)
    if not config then
        warn("❌ CombatConfiguration não encontrada!")
        return
    end
    
    -- Configurações das melhorias
    local improvements = {
        noCooldown = false,
        expandedHitbox = false,
        optimizedAttack = false,
        autoStamina = false,
        fastMovement = false,
        removeStun = false
    }
    
    -- Valores originais para restauração
    local originalValues = {}
    
    -- Função para salvar valores originais
    local function saveOriginalValues()
        pcall(function()
            -- Salvar cooldowns originais
            if config:FindFirstChild("Attacking") and config.Attacking:FindFirstChild("Cooldowns") then
                originalValues.cooldowns = {}
                for _, cooldown in pairs(config.Attacking.Cooldowns:GetChildren()) do
                    if cooldown:IsA("NumberValue") then
                        originalValues.cooldowns[cooldown.Name] = cooldown.Value
                    end
                end
            end
            
            -- Salvar ranges originais
            if config:FindFirstChild("Attacking") and config.Attacking:FindFirstChild("Ranges") then
                originalValues.ranges = {}
                for _, range in pairs(config.Attacking.Ranges:GetChildren()) do
                    if range:IsA("NumberValue") then
                        originalValues.ranges[range.Name] = range.Value
                    end
                end
            end
            
            -- Salvar stamina originais
            if config:FindFirstChild("Stamina") then
                if config.Stamina:FindFirstChild("AttackStaminaCost") then
                    originalValues.staminaCost = config.Stamina.AttackStaminaCost.Value
                end
                if config.Stamina:FindFirstChild("StaminaDecreaseRate") then
                    originalValues.staminaDecrease = config.Stamina.StaminaDecreaseRate.Value
                end
            end
            
            -- Salvar stun durations originais
            if config:FindFirstChild("Stunned") and config.Stunned:FindFirstChild("StunDurations") then
                originalValues.stunDurations = {}
                for _, stun in pairs(config.Stunned.StunDurations:GetChildren()) do
                    if stun:IsA("NumberValue") then
                        originalValues.stunDurations[stun.Name] = stun.Value
                    end
                end
            end
        end)
    end
    
    -- Aplicar melhorias nas configurações do jogo
    local function applyImprovements()
        task.spawn(function()
            while _G.CombatSystemLoaded do
                pcall(function()
                    -- Sem Cooldown
                    if improvements.noCooldown and config:FindFirstChild("Attacking") and config.Attacking:FindFirstChild("Cooldowns") then
                        for _, cooldown in pairs(config.Attacking.Cooldowns:GetChildren()) do
                            if cooldown:IsA("NumberValue") then
                                cooldown.Value = 0
                            end
                        end
                    elseif not improvements.noCooldown and originalValues.cooldowns then
                        for name, value in pairs(originalValues.cooldowns) do
                            local cooldown = config.Attacking.Cooldowns:FindFirstChild(name)
                            if cooldown and cooldown:IsA("NumberValue") then
                                cooldown.Value = value
                            end
                        end
                    end
                    
                    -- Hitbox Expandida
                    if improvements.expandedHitbox and config:FindFirstChild("Attacking") and config.Attacking:FindFirstChild("Ranges") then
                        for _, range in pairs(config.Attacking.Ranges:GetChildren()) do
                            if range:IsA("NumberValue") then
                                range.Value = originalValues.ranges and originalValues.ranges[range.Name] and originalValues.ranges[range.Name] * 2.5 or 20
                            end
                        end
                    elseif not improvements.expandedHitbox and originalValues.ranges then
                        for name, value in pairs(originalValues.ranges) do
                            local range = config.Attacking.Ranges:FindFirstChild(name)
                            if range and range:IsA("NumberValue") then
                                range.Value = value
                            end
                        end
                    end
                    
                    -- Stamina Infinita
                    if improvements.autoStamina then
                        -- Reduzir custo de stamina
                        if config:FindFirstChild("Stamina") and config.Stamina:FindFirstChild("AttackStaminaCost") then
                            config.Stamina.AttackStaminaCost.Value = 0
                        end
                        -- Remover diminuição de stamina
                        if config:FindFirstChild("Stamina") and config.Stamina:FindFirstChild("StaminaDecreaseRate") then
                            config.Stamina.StaminaDecreaseRate.Value = 0
                        end
                        -- Aumentar regeneração
                        if config:FindFirstChild("Stamina") and config.Stamina:FindFirstChild("StaminaIncreaseRate") then
                            config.Stamina.StaminaIncreaseRate.Value = 1000
                        end
                    else
                        -- Restaurar valores originais
                        if originalValues.staminaCost and config:FindFirstChild("Stamina") and config.Stamina:FindFirstChild("AttackStaminaCost") then
                            config.Stamina.AttackStaminaCost.Value = originalValues.staminaCost
                        end
                        if originalValues.staminaDecrease and config:FindFirstChild("Stamina") and config.Stamina:FindFirstChild("StaminaDecreaseRate") then
                            config.Stamina.StaminaDecreaseRate.Value = originalValues.staminaDecrease
                        end
                    end
                    
                    -- Remover Stun
                    if improvements.removeStun and config:FindFirstChild("Stunned") and config.Stunned:FindFirstChild("StunDurations") then
                        for _, stun in pairs(config.Stunned.StunDurations:GetChildren()) do
                            if stun:IsA("NumberValue") then
                                stun.Value = 0
                            end
                        end
                    elseif not improvements.removeStun and originalValues.stunDurations then
                        for name, value in pairs(originalValues.stunDurations) do
                            local stun = config.Stunned.StunDurations:FindFirstChild(name)
                            if stun and stun:IsA("NumberValue") then
                                stun.Value = value
                            end
                        end
                    end
                    
                    -- Ataques Otimizados - Modificar dash
                    if improvements.optimizedAttack and config:FindFirstChild("Attacking") and config.Attacking:FindFirstChild("Dash") then
                        for _, dash in pairs(config.Attacking.Dash:GetChildren()) do
                            if dash:IsA("NumberValue") then
                                dash.Value = math.max(dash.Value * 1.5, 25)
                            end
                        end
                    end
                end)
                task.wait(0.1)
            end
        end)
    end
    
    -- Interface melhorada
    local function createUI()
        local existingUI = player.PlayerGui:FindFirstChild("EnhancedCombatUI")
        if existingUI then existingUI:Destroy() end
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "EnhancedCombatUI"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = player.PlayerGui
        
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0, 350, 0, 400)
        mainFrame.Position = UDim2.new(0, 20, 0.5, -200)
        mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        mainFrame.BorderSizePixel = 0
        mainFrame.Active = true
        mainFrame.Draggable = true
        mainFrame.Parent = screenGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = mainFrame
        
        local header = Instance.new("Frame")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0, 50)
        header.Position = UDim2.new(0, 0, 0, 0)
        header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        header.BorderSizePixel = 0
        header.Parent = mainFrame
        
        local headerCorner = Instance.new("UICorner")
        headerCorner.CornerRadius = UDim.new(0, 12)
        headerCorner.Parent = header
        
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, -20, 1, 0)
        title.Position = UDim2.new(0, 10, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = "⚔️ ENHANCED COMBAT SYSTEM"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 16
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Font = Enum.Font.GothamBold
        title.Parent = header
        
        local contentFrame = Instance.new("ScrollingFrame")
        contentFrame.Name = "Content"
        contentFrame.Size = UDim2.new(1, 0, 1, -60)
        contentFrame.Position = UDim2.new(0, 0, 0, 60)
        contentFrame.BackgroundTransparency = 1
        contentFrame.BorderSizePixel = 0
        contentFrame.ScrollBarThickness = 4
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, 350)
        contentFrame.Parent = mainFrame
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 8)
        contentLayout.Parent = contentFrame
        
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingAll = UDim.new(0, 15)
        contentPadding.Parent = contentFrame
        
        local function createToggleButton(name, displayName, description, improvement, layoutOrder)
            local buttonFrame = Instance.new("Frame")
            buttonFrame.Name = name .. "Frame"
            buttonFrame.Size = UDim2.new(1, 0, 0, 60)
            buttonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            buttonFrame.BorderSizePixel = 0
            buttonFrame.LayoutOrder = layoutOrder
            buttonFrame.Parent = contentFrame
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 8)
            buttonCorner.Parent = buttonFrame
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -80, 0, 20)
            nameLabel.Position = UDim2.new(0, 10, 0, 8)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = displayName
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextSize = 13
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.Parent = buttonFrame
            
            local descLabel = Instance.new("TextLabel")
            descLabel.Size = UDim2.new(1, -80, 0, 18)
            descLabel.Position = UDim2.new(0, 10, 0, 28)
            descLabel.BackgroundTransparency = 1
            descLabel.Text = description
            descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
            descLabel.TextSize = 10
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Font = Enum.Font.Gotham
            descLabel.Parent = buttonFrame
            
            local toggleButton = Instance.new("TextButton")
            toggleButton.Size = UDim2.new(0, 55, 0, 25)
            toggleButton.Position = UDim2.new(1, -65, 0.5, -12.5)
            toggleButton.BackgroundColor3 = improvements[improvement] and Color3.fromRGB(40, 167, 69) or Color3.fromRGB(220, 53, 69)
            toggleButton.BorderSizePixel = 0
            toggleButton.Text = improvements[improvement] and "ON" or "OFF"
            toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            toggleButton.TextSize = 11
            toggleButton.Font = Enum.Font.GothamBold
            toggleButton.Parent = buttonFrame
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 12)
            toggleCorner.Parent = toggleButton
            
            toggleButton.MouseButton1Click:Connect(function()
                improvements[improvement] = not improvements[improvement]
                
                local newColor = improvements[improvement] and Color3.fromRGB(40, 167, 69) or Color3.fromRGB(220, 53, 69)
                local newText = improvements[improvement] and "ON" or "OFF"
                
                TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = newColor
                }):Play()
                
                toggleButton.Text = newText
                
                local statusText = improvements[improvement] and "ATIVADO" or "DESATIVADO"
                print("🔧 [MELHORIA] " .. displayName .. " " .. statusText)
            end)
        end
        
        createToggleButton("nocooldown", "🚀 Sem Cooldown", "Remove tempo de espera entre ataques", "noCooldown", 1)
        createToggleButton("hitbox", "🎯 Hitbox Expandida", "2.5x maior alcance dos ataques", "expandedHitbox", 2)
        createToggleButton("attack", "⚡ Ataque Otimizado", "Dash e velocidade aumentados", "optimizedAttack", 3)
        createToggleButton("stamina", "♾️ Stamina Infinita", "Stamina sempre no máximo", "autoStamina", 4)
        createToggleButton("speed", "💨 Movimento Rápido", "Velocidade e pulo aumentados", "fastMovement", 5)
        createToggleButton("stun", "🛡️ Sem Stun", "Remove tempo de atordoamento", "removeStun", 6)
        
        return screenGui
    end
    
    -- Sistema de chat commands
    local function handleChatCommand(message)
        local args = string.split(string.lower(message), " ")
        
        if args[1] == "!combat" or args[1] == "!melhoria" then
            if args[2] == "nocooldown" then
                improvements.noCooldown = not improvements.noCooldown
                print("🚀 Sem Cooldown: " .. (improvements.noCooldown and "ATIVADO" or "DESATIVADO"))
            elseif args[2] == "hitbox" then
                improvements.expandedHitbox = not improvements.expandedHitbox
                print("🎯 Hitbox Expandida: " .. (improvements.expandedHitbox and "ATIVADA" or "DESATIVADA"))
            elseif args[2] == "attack" then
                improvements.optimizedAttack = not improvements.optimizedAttack
                print("⚡ Ataque Otimizado: " .. (improvements.optimizedAttack and "ATIVADO" or "DESATIVADO"))
            elseif args[2] == "stamina" then
                improvements.autoStamina = not improvements.autoStamina
                print("♾️ Stamina Infinita: " .. (improvements.autoStamina and "ATIVADA" or "DESATIVADA"))
            elseif args[2] == "speed" then
                improvements.fastMovement = not improvements.fastMovement
                print("💨 Movimento Rápido: " .. (improvements.fastMovement and "ATIVADO" or "DESATIVADO"))
            elseif args[2] == "stun" then
                improvements.removeStun = not improvements.removeStun
                print("🛡️ Sem Stun: " .. (improvements.removeStun and "ATIVADO" or "DESATIVADO"))
            elseif args[2] == "all" then
                local state = not improvements.noCooldown
                for key, _ in pairs(improvements) do
                    improvements[key] = state
                end
                print("🔧 Todas as melhorias: " .. (state and "ATIVADAS" or "DESATIVADAS"))
            elseif args[2] == "help" or args[2] == "ajuda" then
                print("=== 🎮 COMANDOS DE COMBATE ===")
                print("!combat nocooldown - Remove cooldown dos ataques")
                print("!combat hitbox - Expande hitbox 2.5x")
                print("!combat attack - Otimiza ataques")
                print("!combat stamina - Ativa stamina infinita")
                print("!combat speed - Aumenta velocidade")
                print("!combat stun - Remove stun")
                print("!combat all - Liga/desliga tudo")
                print("!combat status - Mostra status")
            elseif args[2] == "status" then
                print("=== 📊 STATUS DAS MELHORIAS ===")
                for key, value in pairs(improvements) do
                    local emoji = value and "✅" or "❌"
                    print(emoji .. " " .. key .. ": " .. (value and "ATIVO" or "INATIVO"))
                end
            end
        end
    end
    
    -- Sistema de movimento rápido para cada personagem
    local function setupCharacterEnhancements(character)
        local humanoid = character:WaitForChild("Humanoid")
        local rootPart = character:WaitForChild("HumanoidRootPart")
        
        -- Sistema de stamina infinita individual
        local staminaConnection
        staminaConnection = RunService.Heartbeat:Connect(function()
            if not character.Parent then
                staminaConnection:Disconnect()
                return
            end
            
            local combatState = humanoid:FindFirstChild("CombatState")
            if combatState then
                -- Stamina infinita
                if improvements.autoStamina then
                    local stamina = combatState:FindFirstChild("Stamina")
                    if stamina and stamina:IsA("NumberValue") then
                        stamina.Value = config.Stamina.MaxStamina.Value
                    end
                end
                
                -- Remover stun instantaneamente
                if improvements.removeStun then
                    local stunned = combatState:FindFirstChild("Stunned")
                    if stunned and stunned:IsA("BoolValue") and stunned.Value then
                        stunned.Value = false
                    end
                end
            end
            
            -- Movimento rápido
            if improvements.fastMovement then
                humanoid.WalkSpeed = 50
                humanoid.JumpHeight = 25
            else
                -- Restaurar valores normais baseados na configuração
                if config:FindFirstChild("Walking") and config.Walking:FindFirstChild("Speed") then
                    humanoid.WalkSpeed = config.Walking.Speed.Value
                end
            end
        end)
    end
    
    -- Inicialização
    local function initialize()
        -- Salvar valores originais primeiro
        saveOriginalValues()
        
        -- Criar interface
        createUI()
        
        -- Aplicar melhorias contínuas nas configurações
        applyImprovements()
        
        -- Setup para personagem atual
        if player.Character then
            setupCharacterEnhancements(player.Character)
        end
        
        -- Setup para novos personagens
        player.CharacterAdded:Connect(function(character)
            setupCharacterEnhancements(character)
        end)
        
        -- Conectar comandos de chat
        player.Chatted:Connect(handleChatCommand)
        
        print("⚔️ ===== ENHANCED COMBAT SYSTEM LOADED ===== ⚔️")
        print("🎮 Sistema carregado e modificando configurações do jogo!")
        print("💬 Digite !combat help para ver comandos")
        print("🔧 Interface gráfica disponível!")
    end
    
    -- Limpeza ao sair
    game.Players.PlayerRemoving:Connect(function(plr)
        if plr == player then
            _G.CombatSystemLoaded = false
        end
    end)
    
    initialize()
    return true
end)

if not success then
    warn("❌ Erro ao carregar sistema: " .. tostring(result))
else
    print("✅ Sistema carregado com sucesso!")
end

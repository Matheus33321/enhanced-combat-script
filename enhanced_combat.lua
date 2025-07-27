-- Enhanced Combat System - UI Corrigida
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
    
    -- Destruir UI antiga se existir
    local function destroyOldUI()
        local existingUI = player.PlayerGui:FindFirstChild("EnhancedCombatUI")
        if existingUI then 
            existingUI:Destroy()
            print("🗑️ UI antiga removida")
        end
    end
    
    -- Aguardar PlayerGui estar pronto
    local function waitForPlayerGui()
        local attempts = 0
        while not player.PlayerGui and attempts < 50 do
            task.wait(0.1)
            attempts = attempts + 1
        end
        
        if not player.PlayerGui then
            error("PlayerGui não carregou!")
        end
        
        print("✅ PlayerGui carregado")
        return player.PlayerGui
    end
    
    -- Aguardar configurações do jogo
    local config = ReplicatedStorage:WaitForChild("CombatConfiguration", 10)
    if not config then
        warn("❌ CombatConfiguration não encontrada!")
        return
    end
    print("✅ CombatConfiguration encontrada")
    
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
                print("💾 Cooldowns salvos:", #config.Attacking.Cooldowns:GetChildren())
            end
            
            -- Salvar ranges originais
            if config:FindFirstChild("Attacking") and config.Attacking:FindFirstChild("Ranges") then
                originalValues.ranges = {}
                for _, range in pairs(config.Attacking.Ranges:GetChildren()) do
                    if range:IsA("NumberValue") then
                        originalValues.ranges[range.Name] = range.Value
                    end
                end
                print("💾 Ranges salvos:", #config.Attacking.Ranges:GetChildren())
            end
            
            -- Salvar stamina originais
            if config:FindFirstChild("Stamina") then
                if config.Stamina:FindFirstChild("AttackStaminaCost") then
                    originalValues.staminaCost = config.Stamina.AttackStaminaCost.Value
                end
                if config.Stamina:FindFirstChild("StaminaDecreaseRate") then
                    originalValues.staminaDecrease = config.Stamina.StaminaDecreaseRate.Value
                end
                print("💾 Stamina salva")
            end
            
            -- Salvar stun durations originais
            if config:FindFirstChild("Stunned") and config.Stunned:FindFirstChild("StunDurations") then
                originalValues.stunDurations = {}
                for _, stun in pairs(config.Stunned.StunDurations:GetChildren()) do
                    if stun:IsA("NumberValue") then
                        originalValues.stunDurations[stun.Name] = stun.Value
                    end
                end
                print("💾 Stun durations salvos:", #config.Stunned.StunDurations:GetChildren())
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
                        if config:FindFirstChild("Stamina") and config.Stamina:FindFirstChild("AttackStaminaCost") then
                            config.Stamina.AttackStaminaCost.Value = 0
                        end
                        if config:FindFirstChild("Stamina") and config.Stamina:FindFirstChild("StaminaDecreaseRate") then
                            config.Stamina.StaminaDecreaseRate.Value = 0
                        end
                        if config:FindFirstChild("Stamina") and config.Stamina:FindFirstChild("StaminaIncreaseRate") then
                            config.Stamina.StaminaIncreaseRate.Value = 1000
                        end
                    else
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
                    
                    -- Ataques Otimizados
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
    
    -- Interface corrigida e melhorada
    local function createUI()
        local playerGui = waitForPlayerGui()
        destroyOldUI()
        
        print("🎨 Criando interface...")
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "EnhancedCombatUI"
        screenGui.ResetOnSpawn = false
        screenGui.DisplayOrder = 999999 -- Prioridade alta
        screenGui.IgnoreGuiInset = false
        
        -- Aguardar 1 frame antes de parentar
        task.wait()
        screenGui.Parent = playerGui
        
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0, 380, 0, 450)
        mainFrame.Position = UDim2.new(0, 50, 0, 50) -- Posição mais visível
        mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        mainFrame.BorderSizePixel = 0
        mainFrame.Active = true
        mainFrame.Draggable = true
        mainFrame.Visible = true
        mainFrame.Parent = screenGui
        
        -- Efeito de borda brilhante
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(0, 255, 127)
        stroke.Thickness = 2
        stroke.Parent = mainFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 15)
        corner.Parent = mainFrame
        
        -- Header com gradiente
        local header = Instance.new("Frame")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0, 60)
        header.Position = UDim2.new(0, 0, 0, 0)
        header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        header.BorderSizePixel = 0
        header.Parent = mainFrame
        
        local headerGradient = Instance.new("UIGradient")
        headerGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 50)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
        }
        headerGradient.Rotation = 90
        headerGradient.Parent = header
        
        local headerCorner = Instance.new("UICorner")
        headerCorner.CornerRadius = UDim.new(0, 15)
        headerCorner.Parent = header
        
        -- Título animado
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, -100, 1, 0)
        title.Position = UDim2.new(0, 15, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = "⚔️ ENHANCED COMBAT SYSTEM"
        title.TextColor3 = Color3.fromRGB(0, 255, 127)
        title.TextSize = 18
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Font = Enum.Font.GothamBold
        title.Parent = header
        
        -- Botão de fechar
        local closeButton = Instance.new("TextButton")
        closeButton.Size = UDim2.new(0, 40, 0, 40)
        closeButton.Position = UDim2.new(1, -50, 0, 10)
        closeButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
        closeButton.BorderSizePixel = 0
        closeButton.Text = "✕"
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.TextSize = 20
        closeButton.Font = Enum.Font.GothamBold
        closeButton.Parent = header
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 8)
        closeCorner.Parent = closeButton
        
        closeButton.MouseButton1Click:Connect(function()
            screenGui.Enabled = not screenGui.Enabled
        end)
        
        -- Status indicator
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(1, -20, 0, 25)
        statusLabel.Position = UDim2.new(0, 10, 1, -30)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = "🟢 Sistema Ativo - Pressione os botões para ativar melhorias"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
        statusLabel.TextSize = 12
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusLabel.Font = Enum.Font.Gotham
        statusLabel.Parent = header
        
        -- Content frame com scroll
        local contentFrame = Instance.new("ScrollingFrame")
        contentFrame.Name = "Content"
        contentFrame.Size = UDim2.new(1, 0, 1, -70)
        contentFrame.Position = UDim2.new(0, 0, 0, 70)
        contentFrame.BackgroundTransparency = 1
        contentFrame.BorderSizePixel = 0
        contentFrame.ScrollBarThickness = 6
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
        contentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
        contentFrame.Parent = mainFrame
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 10)
        contentLayout.Parent = contentFrame
        
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingAll = UDim.new(0, 15)
        contentPadding.Parent = contentFrame
        
        -- Função para criar botões melhorados
        local function createToggleButton(name, displayName, description, improvement, layoutOrder)
            local buttonFrame = Instance.new("Frame")
            buttonFrame.Name = name .. "Frame"
            buttonFrame.Size = UDim2.new(1, 0, 0, 70)
            buttonFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            buttonFrame.BorderSizePixel = 0
            buttonFrame.LayoutOrder = layoutOrder
            buttonFrame.Parent = contentFrame
            
            local buttonGradient = Instance.new("UIGradient")
            buttonGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 55)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
            }
            buttonGradient.Rotation = 45
            buttonGradient.Parent = buttonFrame
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 10)
            buttonCorner.Parent = buttonFrame
            
            local buttonStroke = Instance.new("UIStroke")
            buttonStroke.Color = Color3.fromRGB(60, 60, 70)
            buttonStroke.Thickness = 1
            buttonStroke.Parent = buttonFrame
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -90, 0, 25)
            nameLabel.Position = UDim2.new(0, 15, 0, 10)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = displayName
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextSize = 15
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.Parent = buttonFrame
            
            local descLabel = Instance.new("TextLabel")
            descLabel.Size = UDim2.new(1, -90, 0, 20)
            descLabel.Position = UDim2.new(0, 15, 0, 35)
            descLabel.BackgroundTransparency = 1
            descLabel.Text = description
            descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            descLabel.TextSize = 11
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Font = Enum.Font.Gotham
            descLabel.Parent = buttonFrame
            
            local toggleButton = Instance.new("TextButton")
            toggleButton.Size = UDim2.new(0, 60, 0, 30)
            toggleButton.Position = UDim2.new(1, -75, 0.5, -15)
            toggleButton.BackgroundColor3 = improvements[improvement] and Color3.fromRGB(40, 167, 69) or Color3.fromRGB(220, 53, 69)
            toggleButton.BorderSizePixel = 0
            toggleButton.Text = improvements[improvement] and "ON" or "OFF"
            toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            toggleButton.TextSize = 12
            toggleButton.Font = Enum.Font.GothamBold
            toggleButton.Parent = buttonFrame
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 15)
            toggleCorner.Parent = toggleButton
            
            -- Efeito hover
            toggleButton.MouseEnter:Connect(function()
                TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                    Size = UDim2.new(0, 65, 0, 32)
                }):Play()
            end)
            
            toggleButton.MouseLeave:Connect(function()
                TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                    Size = UDim2.new(0, 60, 0, 30)
                }):Play()
            end)
            
            toggleButton.MouseButton1Click:Connect(function()
                improvements[improvement] = not improvements[improvement]
                
                local newColor = improvements[improvement] and Color3.fromRGB(40, 167, 69) or Color3.fromRGB(220, 53, 69)
                local newText = improvements[improvement] and "ON" or "OFF"
                
                -- Animação do botão
                TweenService:Create(toggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                    BackgroundColor3 = newColor
                }):Play()
                
                toggleButton.Text = newText
                
                -- Feedback visual
                local statusText = improvements[improvement] and "ATIVADO" or "DESATIVADO"
                statusLabel.Text = "🔧 " .. displayName .. " " .. statusText
                statusLabel.TextColor3 = improvements[improvement] and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(255, 100, 100)
                
                print("🔧 [MELHORIA] " .. displayName .. " " .. statusText)
                
                -- Piscar o botão
                local originalSize = toggleButton.Size
                TweenService:Create(toggleButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 70, 0, 35)}):Play()
                task.wait(0.1)
                TweenService:Create(toggleButton, TweenInfo.new(0.1), {Size = originalSize}):Play()
            end)
            
            return buttonFrame
        end
        
        -- Criar todos os botões
        createToggleButton("nocooldown", "🚀 Sem Cooldown", "Remove tempo de espera entre ataques", "noCooldown", 1)
        createToggleButton("hitbox", "🎯 Hitbox Expandida", "2.5x maior alcance dos ataques", "expandedHitbox", 2)
        createToggleButton("attack", "⚡ Ataque Otimizado", "Dash e velocidade aumentados", "optimizedAttack", 3)
        createToggleButton("stamina", "♾️ Stamina Infinita", "Stamina sempre no máximo", "autoStamina", 4)
        createToggleButton("speed", "💨 Movimento Rápido", "Velocidade e pulo aumentados", "fastMovement", 5)
        createToggleButton("stun", "🛡️ Sem Stun", "Remove tempo de atordoamento", "removeStun", 6)
        
        -- Animação de entrada
        mainFrame.Position = UDim2.new(0, -400, 0, 50)
        TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
            Position = UDim2.new(0, 50, 0, 50)
        }):Play()
        
        print("✅ Interface criada com sucesso!")
        print("📍 Posição:", mainFrame.Position)
        print("👁️ Visível:", mainFrame.Visible)
        
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
            elseif args[2] == "ui" then
                local ui = player.PlayerGui:FindFirstChild("EnhancedCombatUI")
                if ui then
                    ui.Enabled = not ui.Enabled
                    print("👁️ Interface: " .. (ui.Enabled and "MOSTRADA" or "OCULTADA"))
                else
                    createUI()
                    print("🎨 Interface recriada!")
                end
            elseif args[2] == "help" or args[2] == "ajuda" then
                print("=== 🎮 COMANDOS DE COMBATE ===")
                print("!combat nocooldown - Remove cooldown dos ataques")
                print("!combat hitbox - Expande hitbox 2.5x")
                print("!combat attack - Otimiza ataques")
                print("!combat stamina - Ativa stamina infinita")
                print("!combat speed - Aumenta velocidade")
                print("!combat stun - Remove stun")
                print("!combat all - Liga/desliga tudo")
                print("!combat ui - Mostra/oculta interface")
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
                if config:FindFirstChild("Walking") and config.Walking:FindFirstChild("Speed") then
                    humanoid.WalkSpeed = config.Walking.Speed.Value
                end
            end
        end)
    end
    
    -- Inicialização com verificações extras
    local function initialize()
        print("🚀 Iniciando Enhanced Combat System...")
        
        -- Aguardar um pouco para garantir que tudo carregou
        task.wait(1)
        
        -- Salvar valores originais primeiro
        saveOriginalValues()
        print("💾 Valores originais salvos")
        
        -- Criar interface com retry
        local uiAttempts = 0
        local ui = nil
        
        repeat
            ui = createUI()
            uiAttempts = uiAttempts + 1
            if not ui then
                print("⚠️ Tentativa " .. uiAttempts .. " de criar UI falhou, tentando novamente...")
                task.wait(0.5)
            end
        until ui or uiAttempts >= 3
        
        if not ui then
            warn("❌ Falha ao criar interface após 3 tentativas!")
        end
        
        -- Aplicar melhorias contínuas nas configurações
        applyImprovements()
        print("🔧 Sistema de melhorias ativo")
        
        -- Setup para personagem atual
        if player.Character then
            setupCharacterEnhancements(player.Character)
            print("👤 Melhorias aplicadas ao personagem atual")
        end
        
        -- Setup para novos personagens
        player.CharacterAdded:Connect(function(character)
            setupCharacterEnhancements(character)
            print("👤 Melhorias aplicadas ao novo personagem")
        end)
        
        -- Conectar comandos de chat
        player.Chatted:Connect(handleChatCommand)
        
        print("⚔️ ===== ENHANCED COMBAT SYSTEM LOADED ===== ⚔️")
        print("🎮 Sistema carregado e modificando configurações do jogo!")
        print("💬 Digite !combat help para ver comandos")
        print("🔧 Interface gráfica disponível!")
        print("💡 Se a interface não aparecer, digite: !combat ui")
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
    print("🔧 Tentando diagnóstico...")
    print("PlayerGui exists:", game.Players.LocalPlayer.PlayerGui ~= nil)
    print("ReplicatedStorage exists:", game:GetService("ReplicatedStorage") ~= nil)
else
    print("✅ Sistema carregado com sucesso!")
end

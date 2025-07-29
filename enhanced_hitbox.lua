-- Sistema de Detecção de Combate Melhorado - VERSÃO CORRIGIDA E FUNCIONAL
-- Executável via loadstring

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Aguarda o jogador carregar completamente
repeat task.wait() until player.Character
repeat task.wait() until player.Character:FindFirstChild("HumanoidRootPart")
repeat task.wait() until player.Character:FindFirstChild("Humanoid")

local character = player.Character
local humanoidRootPart = character.HumanoidRootPart
local humanoid = character.Humanoid

-- Configurações de detecção
local DetectionConfig = {
    Width = 8,
    Height = 6,
    Depth = 10,
    MaxRange = 20,
    ShowHitbox = true,
    HitboxTransparency = 0.7,
    HitboxColor = Color3.fromRGB(255, 0, 0),
    FilterSelf = true,
    FilterNonHumanoids = true,
    AttackCooldown = 0.5,
    Damage = 25,
}

-- Variáveis de controle
local lastAttackTime = 0
local isMenuOpen = false
local hitboxPart = nil
local menuGui = nil
local connections = {}

-- Função para debug/log
local function debugPrint(message)
    print("[COMBAT DEBUG] " .. tostring(message))
end

-- Função para limpar conexões
local function cleanupConnections()
    for _, connection in pairs(connections) do
        if connection then
            connection:Disconnect()
        end
    end
    connections = {}
end

-- Função para criar hitbox visual melhorada
local function createHitbox(position, direction, size)
    if hitboxPart and hitboxPart.Parent then
        hitboxPart:Destroy()
    end
    
    if not DetectionConfig.ShowHitbox then
        return
    end
    
    local hitbox = Instance.new("Part")
    hitbox.Name = "AttackHitbox"
    hitbox.Size = size
    hitbox.Material = Enum.Material.ForceField
    hitbox.Anchored = true
    hitbox.CanCollide = false
    hitbox.CanQuery = false
    hitbox.CanTouch = false
    hitbox.Color = DetectionConfig.HitboxColor
    hitbox.Transparency = DetectionConfig.HitboxTransparency
    hitbox.TopSurface = Enum.SurfaceType.Smooth
    hitbox.BottomSurface = Enum.SurfaceType.Smooth
    
    -- Posiciona a hitbox na frente do jogador
    local offsetPosition = position + (direction * (size.Z / 2))
    hitbox.CFrame = CFrame.lookAt(offsetPosition, offsetPosition + direction)
    hitbox.Parent = workspace
    
    hitboxPart = hitbox
    
    -- Efeito de pulsação
    local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 1, true)
    local tween = TweenService:Create(hitbox, tweenInfo, {
        Transparency = DetectionConfig.HitboxTransparency + 0.3,
        Size = size * 1.1
    })
    tween:Play()
    
    -- Remove depois de um tempo
    Debris:AddItem(hitbox, 0.3)
    
    debugPrint("Hitbox criada em: " .. tostring(offsetPosition))
end

-- Função melhorada para detectar alvos usando região espacial
local function detectTargetsInArea(attackerCharacter, attackDirection)
    local attackerRoot = attackerCharacter:FindFirstChild("HumanoidRootPart")
    if not attackerRoot then
        debugPrint("Atacante não tem HumanoidRootPart")
        return {}
    end
    
    local attackerPosition = attackerRoot.Position
    local hitboxSize = Vector3.new(DetectionConfig.Width, DetectionConfig.Height, DetectionConfig.Depth)
    local centerPosition = attackerPosition + (attackDirection * (DetectionConfig.Depth / 2))
    
    -- Cria hitbox visual
    createHitbox(attackerPosition, attackDirection, hitboxSize)
    
    local foundTargets = {}
    
    -- Cria região para detecção mais precisa
    local region = Region3.new(
        centerPosition - hitboxSize/2,
        centerPosition + hitboxSize/2
    )
    
    -- Expande a região para garantir que não seja muito pequena
    region = region:ExpandToGrid(4)
    
    -- Busca todos os jogadores na área
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherCharacter = otherPlayer.Character
            local otherRoot = otherCharacter:FindFirstChild("HumanoidRootPart")
            local otherHumanoid = otherCharacter:FindFirstChild("Humanoid")
            
            if otherRoot and otherHumanoid and otherHumanoid.Health > 0 then
                local targetPosition = otherRoot.Position
                local distance = (targetPosition - attackerPosition).Magnitude
                
                -- Verifica se está dentro do alcance máximo
                if distance <= DetectionConfig.MaxRange then
                    -- Verifica se está dentro da hitbox usando método mais preciso
                    local relativePosition = targetPosition - centerPosition
                    local localPosition = attackerRoot.CFrame:PointToObjectSpace(targetPosition)
                    
                    -- Verifica se está na frente e dentro da área
                    if localPosition.Z < 0 and -- Está na frente
                       math.abs(localPosition.X) <= DetectionConfig.Width / 2 and
                       math.abs(localPosition.Y) <= DetectionConfig.Height / 2 and
                       math.abs(localPosition.Z) <= DetectionConfig.Depth / 2 then
                        
                        table.insert(foundTargets, {
                            Character = otherCharacter,
                            Player = otherPlayer,
                            Distance = distance,
                            Position = targetPosition,
                            Humanoid = otherHumanoid,
                            Root = otherRoot
                        })
                        
                        debugPrint("Alvo encontrado: " .. otherPlayer.Name .. " (Distância: " .. math.floor(distance) .. ")")
                    end
                end
            end
        end
    end
    
    -- Ordena por distância (mais próximo primeiro)
    table.sort(foundTargets, function(a, b)
        return a.Distance < b.Distance
    end)
    
    debugPrint("Total de alvos encontrados: " .. #foundTargets)
    return foundTargets
end

-- Função para aplicar dano melhorada
local function applyDamage(target, damage, knockbackDirection)
    local humanoid = target.Humanoid
    local root = target.Root
    
    if not humanoid or not root or humanoid.Health <= 0 then
        return false
    end
    
    -- Aplica dano
    humanoid.Health = math.max(0, humanoid.Health - damage)
    
    -- Efeito visual de hit
    local hitEffect = Instance.new("Explosion")
    hitEffect.Position = target.Position + Vector3.new(0, 2, 0)
    hitEffect.BlastRadius = 5
    hitEffect.BlastPressure = 0
    hitEffect.Visible = false
    hitEffect.Parent = workspace
    
    -- Efeito de partícula
    local attachment = Instance.new("Attachment")
    attachment.Parent = root
    
    local particles = Instance.new("ParticleEmitter")
    particles.Parent = attachment
    particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particles.Color = ColorSequence.new(Color3.fromRGB(255, 100, 100))
    particles.Lifetime = NumberRange.new(0.3, 0.6)
    particles.Rate = 50
    particles.SpreadAngle = Vector2.new(45, 45)
    particles.Speed = NumberRange.new(5, 15)
    
    particles:Emit(20)
    
    -- Remove partículas depois
    Debris:AddItem(attachment, 2)
    
    -- Knockback melhorado
    local bodyVelocity = root:FindFirstChild("BodyVelocity")
    if bodyVelocity then
        bodyVelocity:Destroy()
    end
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)
    bodyVelocity.Velocity = knockbackDirection * 30
    bodyVelocity.Parent = root
    
    Debris:AddItem(bodyVelocity, 0.3)
    
    return true
end

-- Função para executar ataque
local function performAttack()
    local currentCharacter = player.Character
    if not currentCharacter or not currentCharacter:FindFirstChild("HumanoidRootPart") then
        debugPrint("Personagem não encontrado")
        return
    end
    
    -- Verifica cooldown
    local currentTime = tick()
    if currentTime - lastAttackTime < DetectionConfig.AttackCooldown then
        debugPrint("Ataque em cooldown (" .. math.ceil(DetectionConfig.AttackCooldown - (currentTime - lastAttackTime)) .. "s restantes)")
        return
    end
    lastAttackTime = currentTime
    
    -- Direção do ataque baseada na câmera
    local camera = workspace.CurrentCamera
    local attackDirection = camera.CFrame.LookVector
    
    debugPrint("🗡️ Executando ataque...")
    
    -- Detecta alvos
    local targets = detectTargetsInArea(currentCharacter, attackDirection)
    
    -- Processa alvos
    if #targets > 0 then
        debugPrint("🎯 Atacando " .. #targets .. " alvo(s)")
        
        local hitCount = 0
        for i, target in ipairs(targets) do
            local success = applyDamage(target, DetectionConfig.Damage, attackDirection)
            if success then
                hitCount = hitCount + 1
                debugPrint("💥 Dano aplicado: " .. target.Player.Name .. " (-" .. DetectionConfig.Damage .. " HP, " .. math.floor(target.Humanoid.Health) .. " HP restante)")
            end
        end
        
        if hitCount > 0 then
            debugPrint("✅ Ataque concluído! " .. hitCount .. " alvo(s) atingido(s)")
        end
    else
        debugPrint("❌ Nenhum alvo encontrado na área de ataque")
    end
end

-- Função para criar menu simplificado e funcional
local function createSimpleMenu()
    -- Remove menu anterior se existir
    if menuGui then
        menuGui:Destroy()
        menuGui = nil
    end
    
    -- Aguarda PlayerGui estar disponível
    local playerGui = player:WaitForChild("PlayerGui")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CombatMenu"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui
    
    -- Frame principal
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 450)
    frame.Position = UDim2.new(0, 20, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    -- Bordas arredondadas
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 0, 40)
    title.Position = UDim2.new(0, 5, 0, 5)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Text = "⚔️ CONFIGURAÇÕES DE COMBATE"
    title.Parent = frame
    
    local yPos = 55
    
    -- Função para criar controles
    local function createControl(name, configKey, minVal, maxVal, increment)
        increment = increment or 1
        
        local controlFrame = Instance.new("Frame")
        controlFrame.Size = UDim2.new(1, -20, 0, 70)
        controlFrame.Position = UDim2.new(0, 10, 0, yPos)
        controlFrame.BackgroundTransparency = 1
        controlFrame.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 25)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.Text = name .. ": " .. DetectionConfig[configKey]
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.Parent = controlFrame
        
        local buttonFrame = Instance.new("Frame")
        buttonFrame.Size = UDim2.new(1, 0, 0, 35)
        buttonFrame.Position = UDim2.new(0, 0, 0, 30)
        buttonFrame.BackgroundTransparency = 1
        buttonFrame.Parent = controlFrame
        
        local minusBtn = Instance.new("TextButton")
        minusBtn.Size = UDim2.new(0, 35, 1, 0)
        minusBtn.Position = UDim2.new(0, 0, 0, 0)
        minusBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        minusBtn.Text = "−"
        minusBtn.Font = Enum.Font.GothamBold
        minusBtn.TextSize = 18
        minusBtn.Parent = buttonFrame
        
        local minusCorner = Instance.new("UICorner")
        minusCorner.CornerRadius = UDim.new(0, 4)
        minusCorner.Parent = minusBtn
        
        local valueDisplay = Instance.new("TextLabel")
        valueDisplay.Size = UDim2.new(1, -80, 1, 0)
        valueDisplay.Position = UDim2.new(0, 40, 0, 0)
        valueDisplay.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        valueDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
        valueDisplay.Text = tostring(DetectionConfig[configKey])
        valueDisplay.Font = Enum.Font.GothamBold
        valueDisplay.TextSize = 16
        valueDisplay.Parent = buttonFrame
        
        local valueCorner = Instance.new("UICorner")
        valueCorner.CornerRadius = UDim.new(0, 4)
        valueCorner.Parent = valueDisplay
        
        local plusBtn = Instance.new("TextButton")
        plusBtn.Size = UDim2.new(0, 35, 1, 0)
        plusBtn.Position = UDim2.new(1, -35, 0, 0)
        plusBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        plusBtn.Text = "+"
        plusBtn.Font = Enum.Font.GothamBold
        plusBtn.TextSize = 18
        plusBtn.Parent = buttonFrame
        
        local plusCorner = Instance.new("UICorner")
        plusCorner.CornerRadius = UDim.new(0, 4)
        plusCorner.Parent = plusBtn
        
        -- Conexões dos botões
        local minusConnection = minusBtn.MouseButton1Click:Connect(function()
            if DetectionConfig[configKey] > minVal then
                DetectionConfig[configKey] = DetectionConfig[configKey] - increment
                label.Text = name .. ": " .. DetectionConfig[configKey]
                valueDisplay.Text = tostring(DetectionConfig[configKey])
                debugPrint(name .. " alterado para: " .. DetectionConfig[configKey])
            end
        end)
        
        local plusConnection = plusBtn.MouseButton1Click:Connect(function()
            if DetectionConfig[configKey] < maxVal then
                DetectionConfig[configKey] = DetectionConfig[configKey] + increment
                label.Text = name .. ": " .. DetectionConfig[configKey]
                valueDisplay.Text = tostring(DetectionConfig[configKey])
                debugPrint(name .. " alterado para: " .. DetectionConfig[configKey])
            end
        end)
        
        table.insert(connections, minusConnection)
        table.insert(connections, plusConnection)
        
        yPos = yPos + 80
    end
    
    -- Criar controles
    createControl("Largura", "Width", 2, 30, 1)
    createControl("Altura", "Height", 2, 20, 1)
    createControl("Profundidade", "Depth", 2, 35, 1)
    createControl("Alcance Máximo", "MaxRange", 5, 100, 2)
    createControl("Dano", "Damage", 5, 100, 5)
    
    -- Toggle hitbox
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -20, 0, 35)
    toggleBtn.Position = UDim2.new(0, 10, 0, yPos)
    toggleBtn.BackgroundColor3 = DetectionConfig.ShowHitbox and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Text = "Mostrar Hitbox: " .. (DetectionConfig.ShowHitbox and "ATIVADO" or "DESATIVADO")
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleBtn
    
    local toggleConnection = toggleBtn.MouseButton1Click:Connect(function()
        DetectionConfig.ShowHitbox = not DetectionConfig.ShowHitbox
        toggleBtn.BackgroundColor3 = DetectionConfig.ShowHitbox and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
        toggleBtn.Text = "Mostrar Hitbox: " .. (DetectionConfig.ShowHitbox and "ATIVADO" or "DESATIVADO")
        debugPrint("Mostrar hitbox: " .. tostring(DetectionConfig.ShowHitbox))
    end)
    
    table.insert(connections, toggleConnection)
    
    -- Botão fechar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Text = "✕"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = frame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeBtn
    
    local closeConnection = closeBtn.MouseButton1Click:Connect(function()
        cleanupConnections()
        screenGui:Destroy()
        menuGui = nil
        isMenuOpen = false
        debugPrint("Menu fechado")
    end)
    
    table.insert(connections, closeConnection)
    
    menuGui = screenGui
    isMenuOpen = true
    debugPrint("Menu criado com sucesso!")
end

-- Configuração de controles
local function setupControls()
    debugPrint("Configurando controles...")
    
    -- Ataque com clique
    local mouseConnection = mouse.Button1Down:Connect(function()
        if not isMenuOpen then
            performAttack()
        end
    end)
    
    -- Menu com F
    local keyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F then
            if isMenuOpen then
                cleanupConnections()
                if menuGui then
                    menuGui:Destroy()
                    menuGui = nil
                end
                isMenuOpen = false
                debugPrint("Menu fechado via tecla F")
            else
                createSimpleMenu()
                debugPrint("Menu aberto via tecla F")
            end
        end
    end)
    
    table.insert(connections, mouseConnection)
    table.insert(connections, keyConnection)
    
    debugPrint("Controles configurados!")
end

-- Limpeza quando o personagem é removido
local function setupCleanup()
    local characterRemoving
    characterRemoving = player.CharacterRemoving:Connect(function()
        debugPrint("Limpando recursos...")
        cleanupConnections()
        if menuGui then
            menuGui:Destroy()
            menuGui = nil
        end
        if hitboxPart then
            hitboxPart:Destroy()
            hitboxPart = nil
        end
        characterRemoving:Disconnect()
    end)
end

-- Inicialização
debugPrint("🚀 Iniciando Sistema de Combate Melhorado...")
debugPrint("📋 Controles:")
debugPrint("   • Clique Esquerdo: Atacar")
debugPrint("   • F: Abrir/Fechar Menu de Configurações")
debugPrint("📊 Configurações iniciais:")
for key, value in pairs(DetectionConfig) do
    debugPrint("   • " .. key .. ": " .. tostring(value))
end

-- Configura tudo
setupControls()
setupCleanup()

-- Mostra menu automaticamente após 3 segundos
task.spawn(function()
    task.wait(3)
    if not isMenuOpen then
        createSimpleMenu()
        debugPrint("Menu aberto automaticamente")
    end
end)

debugPrint("✅ Sistema carregado com sucesso!")

-- Interface para outros scripts
return {
    Config = DetectionConfig,
    PerformAttack = performAttack,
    DetectTargets = detectTargetsInArea,
    OpenMenu = createSimpleMenu,
    CloseMenu = function()
        if menuGui then
            cleanupConnections()
            menuGui:Destroy()
            menuGui = nil
            isMenuOpen = false
        end
    end
}

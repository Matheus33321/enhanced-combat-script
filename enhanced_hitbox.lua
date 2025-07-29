-- Sistema de Detecção de Combate Melhorado - VERSÃO CORRIGIDA
-- Executável via loadstring

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Aguarda o jogador carregar completamente
if not player.Character then
    player.CharacterAdded:Wait()
end

local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

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
}

-- Variáveis de controle
local lastAttackTime = 0
local isMenuOpen = false
local hitboxPart = nil
local menuGui = nil

-- Função para debug/log
local function debugPrint(message)
    print("[COMBAT DEBUG] " .. tostring(message))
end

-- Função para criar hitbox visual melhorada
local function createHitbox(position, direction, size)
    if hitboxPart then
        hitboxPart:Destroy()
    end
    
    if not DetectionConfig.ShowHitbox then
        return
    end
    
    local hitbox = Instance.new("Part")
    hitbox.Name = "AttackHitbox"
    hitbox.Size = size
    hitbox.Material = Enum.Material.Neon
    hitbox.Anchored = true
    hitbox.CanCollide = false
    hitbox.Color = DetectionConfig.HitboxColor
    hitbox.Transparency = DetectionConfig.HitboxTransparency
    
    -- Posiciona a hitbox
    local cframe = CFrame.new(position, position + direction)
    hitbox.CFrame = cframe
    hitbox.Parent = workspace
    
    hitboxPart = hitbox
    
    -- Remove depois de um tempo
    task.spawn(function()
        task.wait(0.3)
        if hitbox and hitbox.Parent then
            hitbox:Destroy()
        end
    end)
    
    debugPrint("Hitbox criada em: " .. tostring(position))
end

-- Função melhorada para detectar alvos
local function detectTargetsInArea(attackerCharacter, attackDirection)
    local attackerRoot = attackerCharacter:FindFirstChild("HumanoidRootPart")
    if not attackerRoot then
        debugPrint("Atacante não tem HumanoidRootPart")
        return {}
    end
    
    local attackerPosition = attackerRoot.Position
    local centerPosition = attackerPosition + (attackDirection * (DetectionConfig.Depth / 2))
    
    -- Cria hitbox visual
    local hitboxSize = Vector3.new(DetectionConfig.Width, DetectionConfig.Height, DetectionConfig.Depth)
    createHitbox(centerPosition, attackDirection, hitboxSize)
    
    local foundTargets = {}
    
    -- Busca todos os jogadores
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherCharacter = otherPlayer.Character
            local otherRoot = otherCharacter:FindFirstChild("HumanoidRootPart")
            local otherHumanoid = otherCharacter:FindFirstChild("Humanoid")
            
            if otherRoot and otherHumanoid and otherHumanoid.Health > 0 then
                local targetPosition = otherRoot.Position
                local distance = (targetPosition - attackerPosition).Magnitude
                
                -- Verifica se está dentro do alcance
                if distance <= DetectionConfig.MaxRange then
                    -- Verifica se está dentro da área de ataque
                    local relativePosition = targetPosition - centerPosition
                    
                    if math.abs(relativePosition.X) <= DetectionConfig.Width / 2 and
                       math.abs(relativePosition.Y) <= DetectionConfig.Height / 2 and
                       math.abs(relativePosition.Z) <= DetectionConfig.Depth / 2 then
                        
                        table.insert(foundTargets, {
                            Character = otherCharacter,
                            Player = otherPlayer,
                            Distance = distance,
                            Position = targetPosition
                        })
                        
                        debugPrint("Alvo encontrado: " .. otherPlayer.Name .. " (Distância: " .. math.floor(distance) .. ")")
                    end
                end
            end
        end
    end
    
    -- Ordena por distância
    table.sort(foundTargets, function(a, b)
        return a.Distance < b.Distance
    end)
    
    debugPrint("Total de alvos encontrados: " .. #foundTargets)
    return foundTargets
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
        debugPrint("Ataque em cooldown")
        return
    end
    lastAttackTime = currentTime
    
    -- Direção do ataque
    local camera = workspace.CurrentCamera
    local attackDirection = camera.CFrame.LookVector
    
    debugPrint("Executando ataque...")
    
    -- Detecta alvos
    local targets = detectTargetsInArea(currentCharacter, attackDirection)
    
    -- Processa alvos
    if #targets > 0 then
        debugPrint("🎯 Atacando " .. #targets .. " alvo(s)")
        
        for i, target in ipairs(targets) do
            local targetCharacter = target.Character
            local humanoid = targetCharacter:FindFirstChild("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                -- Aplica dano
                local damage = 25
                humanoid:TakeDamage(damage)
                
                -- Efeito visual
                local explosion = Instance.new("Explosion")
                explosion.Position = target.Position
                explosion.BlastRadius = 8
                explosion.BlastPressure = 100000
                explosion.Parent = workspace
                
                debugPrint("💥 Dano aplicado: " .. target.Player.Name .. " (-" .. damage .. " HP)")
                
                -- Efeito de knockback simples
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)
                bodyVelocity.Velocity = attackDirection * 50
                bodyVelocity.Parent = targetCharacter.HumanoidRootPart
                
                game:GetService("Debris"):AddItem(bodyVelocity, 0.5)
            end
        end
    else
        debugPrint("❌ Nenhum alvo encontrado")
    end
end

-- Função SIMPLIFICADA para criar menu
local function createSimpleMenu()
    -- Remove menu anterior se existir
    if menuGui then
        menuGui:Destroy()
    end
    
    -- Aguarda PlayerGui estar disponível
    local playerGui = player:WaitForChild("PlayerGui")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CombatMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Frame principal SIMPLES
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 400)
    frame.Position = UDim2.new(0, 50, 0, 50)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(1, 1, 1)
    frame.Parent = screenGui
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Text = "⚔️ CONFIGURAÇÕES DE COMBATE"
    title.Parent = frame
    
    local yPos = 50
    
    -- Função para criar controles simples
    local function createControl(name, configKey, minVal, maxVal)
        local controlFrame = Instance.new("Frame")
        controlFrame.Size = UDim2.new(1, -20, 0, 60)
        controlFrame.Position = UDim2.new(0, 10, 0, yPos)
        controlFrame.BackgroundTransparency = 1
        controlFrame.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Text = name .. ": " .. DetectionConfig[configKey]
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.SourceSans
        label.TextSize = 14
        label.Parent = controlFrame
        
        local minusBtn = Instance.new("TextButton")
        minusBtn.Size = UDim2.new(0, 30, 0, 25)
        minusBtn.Position = UDim2.new(0, 0, 0, 30)
        minusBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
        minusBtn.TextColor3 = Color3.new(1, 1, 1)
        minusBtn.Text = "-"
        minusBtn.Font = Enum.Font.SourceSansBold
        minusBtn.TextSize = 18
        minusBtn.Parent = controlFrame
        
        local plusBtn = Instance.new("TextButton")
        plusBtn.Size = UDim2.new(0, 30, 0, 25)
        plusBtn.Position = UDim2.new(0, 40, 0, 30)
        plusBtn.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
        plusBtn.TextColor3 = Color3.new(1, 1, 1)
        plusBtn.Text = "+"
        plusBtn.Font = Enum.Font.SourceSansBold
        plusBtn.TextSize = 18
        plusBtn.Parent = controlFrame
        
        minusBtn.MouseButton1Click:Connect(function()
            if DetectionConfig[configKey] > minVal then
                DetectionConfig[configKey] = DetectionConfig[configKey] - 1
                label.Text = name .. ": " .. DetectionConfig[configKey]
                debugPrint(name .. " alterado para: " .. DetectionConfig[configKey])
            end
        end)
        
        plusBtn.MouseButton1Click:Connect(function()
            if DetectionConfig[configKey] < maxVal then
                DetectionConfig[configKey] = DetectionConfig[configKey] + 1
                label.Text = name .. ": " .. DetectionConfig[configKey]
                debugPrint(name .. " alterado para: " .. DetectionConfig[configKey])
            end
        end)
        
        yPos = yPos + 70
    end
    
    -- Criar controles
    createControl("Largura", "Width", 2, 20)
    createControl("Altura", "Height", 2, 15)
    createControl("Profundidade", "Depth", 2, 25)
    createControl("Alcance", "MaxRange", 5, 50)
    
    -- Toggle hitbox
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -20, 0, 30)
    toggleBtn.Position = UDim2.new(0, 10, 0, yPos)
    toggleBtn.BackgroundColor3 = DetectionConfig.ShowHitbox and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.8, 0.2, 0.2)
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.Text = "Mostrar Hitbox: " .. (DetectionConfig.ShowHitbox and "ON" or "OFF")
    toggleBtn.Font = Enum.Font.SourceSansBold
    toggleBtn.TextSize = 14
    toggleBtn.Parent = frame
    
    toggleBtn.MouseButton1Click:Connect(function()
        DetectionConfig.ShowHitbox = not DetectionConfig.ShowHitbox
        toggleBtn.BackgroundColor3 = DetectionConfig.ShowHitbox and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.8, 0.2, 0.2)
        toggleBtn.Text = "Mostrar Hitbox: " .. (DetectionConfig.ShowHitbox and "ON" or "OFF")
        debugPrint("Mostrar hitbox: " .. tostring(DetectionConfig.ShowHitbox))
    end)
    
    -- Botão fechar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 5)
    closeBtn.BackgroundColor3 = Color3.new(1, 0.3, 0.3)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 14
    closeBtn.Parent = frame
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        menuGui = nil
        isMenuOpen = false
        debugPrint("Menu fechado")
    end)
    
    menuGui = screenGui
    isMenuOpen = true
    debugPrint("Menu criado com sucesso!")
end

-- Configuração de controles
local function setupControls()
    debugPrint("Configurando controles...")
    
    -- Ataque com clique
    mouse.Button1Down:Connect(function()
        if not isMenuOpen then
            performAttack()
        end
    end)
    
    -- Menu com F
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F then
            if isMenuOpen then
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
    
    debugPrint("Controles configurados!")
end

-- Inicialização
debugPrint("🚀 Iniciando Sistema de Combate...")
debugPrint("📋 Controles:")
debugPrint("   • Clique Esquerdo: Atacar")
debugPrint("   • F: Menu de Configurações")

-- Aguarda um pouco antes de configurar controles
task.wait(1)
setupControls()

debugPrint("✅ Sistema carregado com sucesso!")

-- Mostra menu automaticamente na primeira execução
task.wait(2)
if not isMenuOpen then
    createSimpleMenu()
end

-- Interface para outros scripts
return {
    Config = DetectionConfig,
    PerformAttack = performAttack,
    DetectTargets = detectTargetsInArea,
    OpenMenu = createSimpleMenu
}

-- Sistema de Detecção de Combate Melhorado
-- Executável via loadstring

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Configurações de detecção
local DetectionConfig = {
    -- Configurações de área de detecção
    Width = 8,      -- Largura da área (X)
    Height = 6,     -- Altura da área (Y) 
    Depth = 10,     -- Profundidade da área (Z)
    
    -- Configurações de alcance
    MaxRange = 20,  -- Alcance máximo do ataque
    
    -- Configurações visuais
    ShowHitbox = true,
    HitboxTransparency = 0.7,
    HitboxColor = Color3.fromRGB(255, 0, 0),
    
    -- Configurações de filtro
    FilterSelf = true,
    FilterNonHumanoids = true,
    
    -- Configurações de cooldown
    AttackCooldown = 0.5,
}

-- Variáveis de controle
local lastAttackTime = 0
local isMenuOpen = false
local hitboxPart = nil
local menuGui = nil

-- Função para criar hitbox visual
local function createHitbox(cframe, size)
    if hitboxPart then
        hitboxPart:Destroy()
    end
    
    if not DetectionConfig.ShowHitbox then
        return
    end
    
    hitboxPart = Instance.new("Part")
    hitboxPart.Name = "AttackHitbox"
    hitboxPart.Anchored = true
    hitboxPart.CanCollide = false
    hitboxPart.Material = Enum.Material.ForceField
    hitboxPart.BrickColor = BrickColor.new("Really red")
    hitboxPart.Color = DetectionConfig.HitboxColor
    hitboxPart.Transparency = DetectionConfig.HitboxTransparency
    hitboxPart.Size = size
    hitboxPart.CFrame = cframe
    hitboxPart.Parent = workspace
    
    -- Remove hitbox após 0.2 segundos
    game:GetService("Debris"):AddItem(hitboxPart, 0.2)
end

-- Função para detectar alvos usando Region3
local function detectTargetsInRegion(character, attackDirection)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return {}
    end
    
    -- Calcula posição central da área de detecção
    local centerPosition = humanoidRootPart.Position + (attackDirection * (DetectionConfig.Depth / 2))
    
    -- Calcula o tamanho da região
    local regionSize = Vector3.new(
        DetectionConfig.Width,
        DetectionConfig.Height,
        DetectionConfig.Depth
    )
    
    -- Cria a região 3D
    local minPoint = centerPosition - (regionSize / 2)
    local maxPoint = centerPosition + (regionSize / 2)
    
    -- Ajusta pontos para garantir que min < max
    local adjustedMin = Vector3.new(
        math.min(minPoint.X, maxPoint.X),
        math.min(minPoint.Y, maxPoint.Y),
        math.min(minPoint.Z, maxPoint.Z)
    )
    local adjustedMax = Vector3.new(
        math.max(minPoint.X, maxPoint.X),
        math.max(minPoint.Y, maxPoint.Y),
        math.max(minPoint.Z, maxPoint.Z)
    )
    
    local region = Region3.new(adjustedMin, adjustedMax)
    
    -- Expande região para garantir precisão
    region = region:ExpandToGrid(4)
    
    -- Cria hitbox visual
    local hitboxCFrame = CFrame.new(centerPosition, centerPosition + attackDirection)
    createHitbox(hitboxCFrame, regionSize)
    
    -- Obtém partes na região
    local partsInRegion = workspace:ReadVoxels(region, 4)
    local foundTargets = {}
    
    -- Busca por personagens nas partes encontradas
    local checkedCharacters = {}
    
    for _, part in pairs(workspace:GetPartBoundsInRegion(region, math.huge, math.huge)) do
        local partCharacter = part.Parent
        
        -- Verifica se é um personagem válido
        if partCharacter:FindFirstChild("Humanoid") and partCharacter:FindFirstChild("HumanoidRootPart") then
            
            -- Evita duplicatas
            if not checkedCharacters[partCharacter] then
                checkedCharacters[partCharacter] = true
                
                -- Filtros
                local isValid = true
                
                -- Filtra o próprio jogador
                if DetectionConfig.FilterSelf and partCharacter == character then
                    isValid = false
                end
                
                -- Filtra non-humanoids
                if DetectionConfig.FilterNonHumanoids and not partCharacter:FindFirstChild("Humanoid") then
                    isValid = false
                end
                
                -- Verifica se está dentro do alcance máximo
                local distance = (partCharacter.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                if distance > DetectionConfig.MaxRange then
                    isValid = false
                end
                
                -- Verifica se o personagem está vivo
                if partCharacter.Humanoid.Health <= 0 then
                    isValid = false
                end
                
                if isValid then
                    table.insert(foundTargets, {
                        Character = partCharacter,
                        Distance = distance,
                        Part = part
                    })
                end
            end
        end
    end
    
    -- Ordena por distância (mais próximo primeiro)
    table.sort(foundTargets, function(a, b)
        return a.Distance < b.Distance
    end)
    
    return foundTargets
end

-- Função para executar ataque
local function performAttack()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    -- Verifica cooldown
    local currentTime = tick()
    if currentTime - lastAttackTime < DetectionConfig.AttackCooldown then
        return
    end
    lastAttackTime = currentTime
    
    -- Calcula direção do ataque baseada na câmera/mouse
    local camera = workspace.CurrentCamera
    local attackDirection = (mouse.Hit.Position - character.HumanoidRootPart.Position).Unit
    
    -- Se não conseguir direção do mouse, usa direção da câmera
    if attackDirection.Magnitude == 0 then
        attackDirection = camera.CFrame.LookVector
    end
    
    -- Detecta alvos
    local targets = detectTargetsInRegion(character, attackDirection)
    
    -- Processa alvos encontrados
    if #targets > 0 then
        print("🎯 Alvos detectados: " .. #targets)
        
        for i, target in ipairs(targets) do
            local targetCharacter = target.Character
            local humanoid = targetCharacter:FindFirstChild("Humanoid")
            
            if humanoid then
                -- Aplica dano (exemplo)
                local damage = 20
                humanoid:TakeDamage(damage)
                
                -- Efeito visual no alvo
                local effect = Instance.new("Explosion")
                effect.Position = targetCharacter.HumanoidRootPart.Position
                effect.BlastRadius = 5
                effect.BlastPressure = 0
                effect.Parent = workspace
                
                print("💥 Dano aplicado em: " .. targetCharacter.Name .. " (Dano: " .. damage .. ")")
            end
        end
    else
        print("❌ Nenhum alvo encontrado")
    end
end

-- Função para criar menu de configuração
local function createConfigMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CombatConfigMenu"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Adiciona cantos arredondados
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Text = "⚔️ Configurações de Combate"
    title.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = title
    
    -- ScrollFrame para configurações
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -100)
    scrollFrame.Position = UDim2.new(0, 10, 0, 60)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.Parent = mainFrame
    
    -- Layout
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scrollFrame
    
    local function createSlider(name, configKey, min, max, step)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 80)
        frame.BackgroundTransparency = 1
        frame.Parent = scrollFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 25)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.Font = Enum.Font.SourceSans
        label.Text = name .. ": " .. DetectionConfig[configKey]
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(1, 0, 0, 20)
        sliderFrame.Position = UDim2.new(0, 0, 0, 30)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        sliderFrame.Parent = frame
        
        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, 10)
        sliderCorner.Parent = sliderFrame
        
        local sliderButton = Instance.new("Frame")
        sliderButton.Size = UDim2.new(0, 20, 1, 0)
        sliderButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
        sliderButton.Parent = sliderFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 10)
        buttonCorner.Parent = sliderButton
        
        -- Funcionalidade do slider
        local dragging = false
        
        local function updateSlider(input)
            local relativeX = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * relativeX
            value = math.floor(value / step + 0.5) * step
            
            DetectionConfig[configKey] = value
            label.Text = name .. ": " .. value
            sliderButton.Position = UDim2.new(relativeX, -10, 0, 0)
        end
        
        sliderFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        -- Posição inicial do slider
        local initialPos = (DetectionConfig[configKey] - min) / (max - min)
        sliderButton.Position = UDim2.new(initialPos, -10, 0, 0)
    end
    
    -- Criar sliders
    createSlider("Largura", "Width", 2, 20, 1)
    createSlider("Altura", "Height", 2, 15, 1)
    createSlider("Profundidade", "Depth", 2, 25, 1)
    createSlider("Alcance Máximo", "MaxRange", 5, 50, 1)
    createSlider("Cooldown", "AttackCooldown", 0.1, 2.0, 0.1)
    
    -- Toggle para mostrar hitbox
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 50)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = scrollFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.BackgroundColor3 = DetectionConfig.ShowHitbox and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(100, 100, 100)
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextScaled = true
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.Text = "👁️ Mostrar Hitbox: " .. (DetectionConfig.ShowHitbox and "ON" or "OFF")
    toggleButton.Parent = toggleFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleButton
    
    toggleButton.MouseButton1Click:Connect(function()
        DetectionConfig.ShowHitbox = not DetectionConfig.ShowHitbox
        toggleButton.BackgroundColor3 = DetectionConfig.ShowHitbox and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(100, 100, 100)
        toggleButton.Text = "👁️ Mostrar Hitbox: " .. (DetectionConfig.ShowHitbox and "ON" or "OFF")
    end)
    
    -- Botão fechar
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Text = "✕"
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        isMenuOpen = false
        menuGui = nil
    end)
    
    -- Atualiza tamanho do scroll
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end)
    
    menuGui = screenGui
    isMenuOpen = true
end

-- Configuração de controles
local function setupControls()
    -- Ataque com clique esquerdo
    mouse.Button1Down:Connect(function()
        if not isMenuOpen then
            performAttack()
        end
    end)
    
    -- Menu com F (ou outra tecla de sua escolha)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F then
            if isMenuOpen then
                if menuGui then
                    menuGui:Destroy()
                    menuGui = nil
                end
                isMenuOpen = false
            else
                createConfigMenu()
            end
        end
    end)
end

-- Inicialização
print("🚀 Sistema de Detecção de Combate Carregado!")
print("📋 Controles:")
print("   • Clique Esquerdo: Atacar")
print("   • F: Abrir/Fechar Menu de Configurações")
print("💡 Use o menu para ajustar precisão da detecção!")

setupControls()

-- Interface para outros scripts
return {
    Config = DetectionConfig,
    PerformAttack = performAttack,
    DetectTargets = detectTargetsInRegion,
    OpenMenu = createConfigMenu
}

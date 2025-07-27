-- Enhanced Hitbox Script with GUI
-- Execute via: loadstring(game:HttpGet('https://github.com/Matheus33321/enhanced-combat-script/blob/main/enhanced_hitbox.lua'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configurações padrão
local config = {
    hitboxSize = 10,
    hitboxTransparency = 0.7,
    hitboxColor = Color3.fromRGB(255, 0, 0),
    visualizeHitbox = true,
    autoHit = true,
    hitboxMultiplier = 2,
    maxTargets = 3,
    hitboxRange = 25,
    bypassBlock = false
}

-- Variáveis globais
local hitboxGui
local hitboxPart
local originalHitDetection
local connections = {}

-- Função para criar a GUI
local function createGUI()
    -- Remover GUI existente se houver
    if hitboxGui then
        hitboxGui:Destroy()
    end
    
    -- Crear ScreenGui principal
    hitboxGui = Instance.new("ScreenGui")
    hitboxGui.Name = "EnhancedHitboxGUI"
    hitboxGui.ResetOnSpawn = false
    hitboxGui.Parent = playerGui
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = hitboxGui
    
    -- Cantos arredondados
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    titleLabel.Text = "Enhanced Hitbox GUI"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleLabel
    
    -- Botão fechar
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 5)
    closeCorner.Parent = closeButton
    
    -- ScrollingFrame para os controles
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -20, 1, -60)
    scrollFrame.Position = UDim2.new(0, 10, 0, 50)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
    scrollFrame.Parent = mainFrame
    
    -- Layout
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scrollFrame
    
    -- Função para criar controles
    local function createSlider(name, minValue, maxValue, currentValue, callback)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = name .. "Frame"
        sliderFrame.Size = UDim2.new(1, 0, 0, 80)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        sliderFrame.BorderSizePixel = 0
        sliderFrame.Parent = scrollFrame
        
        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, 8)
        sliderCorner.Parent = sliderFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 30)
        label.Position = UDim2.new(0, 0, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. tostring(currentValue)
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.Font = Enum.Font.Gotham
        label.Parent = sliderFrame
        
        local sliderBG = Instance.new("Frame")
        sliderBG.Size = UDim2.new(1, -20, 0, 20)
        sliderBG.Position = UDim2.new(0, 10, 0, 40)
        sliderBG.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        sliderBG.BorderSizePixel = 0
        sliderBG.Parent = sliderFrame
        
        local sliderBGCorner = Instance.new("UICorner")
        sliderBGCorner.CornerRadius = UDim.new(0, 10)
        sliderBGCorner.Parent = sliderBG
        
        local sliderButton = Instance.new("TextButton")
        sliderButton.Size = UDim2.new(0, 20, 1, 0)
        sliderButton.Position = UDim2.new((currentValue - minValue) / (maxValue - minValue), -10, 0, 0)
        sliderButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        sliderButton.Text = ""
        sliderButton.Parent = sliderBG
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(1, 0)
        buttonCorner.Parent = sliderButton
        
        local dragging = false
        
        sliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mouse = Players.LocalPlayer:GetMouse()
                local relativeX = mouse.X - sliderBG.AbsolutePosition.X
                local percentage = math.clamp(relativeX / sliderBG.AbsoluteSize.X, 0, 1)
                local value = minValue + (maxValue - minValue) * percentage
                
                sliderButton.Position = UDim2.new(percentage, -10, 0, 0)
                label.Text = name .. ": " .. string.format("%.1f", value)
                callback(value)
            end
        end)
        
        return sliderFrame
    end
    
    local function createToggle(name, currentValue, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = name .. "Frame"
        toggleFrame.Size = UDim2.new(1, 0, 0, 50)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        toggleFrame.BorderSizePixel = 0
        toggleFrame.Parent = scrollFrame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 8)
        toggleCorner.Parent = toggleFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggleFrame
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Size = UDim2.new(0, 80, 0, 30)
        toggleButton.Position = UDim2.new(1, -90, 0.5, -15)
        toggleButton.BackgroundColor3 = currentValue and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        toggleButton.Text = currentValue and "ON" or "OFF"
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.TextScaled = true
        toggleButton.Font = Enum.Font.GothamBold
        toggleButton.Parent = toggleFrame
        
        local toggleCorner2 = Instance.new("UICorner")
        toggleCorner2.CornerRadius = UDim.new(0, 15)
        toggleCorner2.Parent = toggleButton
        
        toggleButton.MouseButton1Click:Connect(function()
            currentValue = not currentValue
            toggleButton.BackgroundColor3 = currentValue and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            toggleButton.Text = currentValue and "ON" or "OFF"
            callback(currentValue)
        end)
        
        return toggleFrame
    end
    
    local function createColorPicker(name, currentColor, callback)
        local colorFrame = Instance.new("Frame")
        colorFrame.Name = name .. "Frame"
        colorFrame.Size = UDim2.new(1, 0, 0, 100)
        colorFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        colorFrame.BorderSizePixel = 0
        colorFrame.Parent = scrollFrame
        
        local colorCorner = Instance.new("UICorner")
        colorCorner.CornerRadius = UDim.new(0, 8)
        colorCorner.Parent = colorFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 30)
        label.Position = UDim2.new(0, 0, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.Font = Enum.Font.Gotham
        label.Parent = colorFrame
        
        local colorPreview = Instance.new("Frame")
        colorPreview.Size = UDim2.new(0, 60, 0, 30)
        colorPreview.Position = UDim2.new(0, 10, 0, 40)
        colorPreview.BackgroundColor3 = currentColor
        colorPreview.BorderSizePixel = 0
        colorPreview.Parent = colorFrame
        
        local previewCorner = Instance.new("UICorner")
        previewCorner.CornerRadius = UDim.new(0, 5)
        previewCorner.Parent = colorPreview
        
        -- Botões de cor predefinidas
        local colors = {
            Color3.fromRGB(255, 0, 0),   -- Vermelho
            Color3.fromRGB(0, 255, 0),   -- Verde
            Color3.fromRGB(0, 0, 255),   -- Azul
            Color3.fromRGB(255, 255, 0), -- Amarelo
            Color3.fromRGB(255, 0, 255), -- Magenta
            Color3.fromRGB(0, 255, 255)  -- Ciano
        }
        
        for i, color in ipairs(colors) do
            local colorButton = Instance.new("TextButton")
            colorButton.Size = UDim2.new(0, 25, 0, 25)
            colorButton.Position = UDim2.new(0, 80 + (i - 1) * 30, 0, 45)
            colorButton.BackgroundColor3 = color
            colorButton.Text = ""
            colorButton.BorderSizePixel = 0
            colorButton.Parent = colorFrame
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 5)
            buttonCorner.Parent = colorButton
            
            colorButton.MouseButton1Click:Connect(function()
                colorPreview.BackgroundColor3 = color
                callback(color)
            end)
        end
        
        return colorFrame
    end
    
    -- Criar controles
    createSlider("Tamanho da Hitbox", 5, 50, config.hitboxSize, function(value)
        config.hitboxSize = value
        updateHitbox()
    end)
    
    createSlider("Transparência", 0, 1, config.hitboxTransparency, function(value)
        config.hitboxTransparency = value
        updateHitbox()
    end)
    
    createSlider("Multiplicador de Range", 1, 5, config.hitboxMultiplier, function(value)
        config.hitboxMultiplier = value
    end)
    
    createSlider("Alcance Máximo", 10, 100, config.hitboxRange, function(value)
        config.hitboxRange = value
    end)
    
    createSlider("Máximo de Alvos", 1, 10, config.maxTargets, function(value)
        config.maxTargets = math.floor(value)
    end)
    
    createToggle("Visualizar Hitbox", config.visualizeHitbox, function(value)
        config.visualizeHitbox = value
        updateHitbox()
    end)
    
    createToggle("Auto Hit Ativado", config.autoHit, function(value)
        config.autoHit = value
        if value then
            setupHitboxHook()
        else
            removeHitboxHook()
        end
    end)
    
    createToggle("Bypass Block", config.bypassBlock, function(value)
        config.bypassBlock = value
    end)
    
    createColorPicker("Cor da Hitbox", config.hitboxColor, function(color)
        config.hitboxColor = color
        updateHitbox()
    end)
    
    -- Eventos do botão fechar
    closeButton.MouseButton1Click:Connect(function()
        hitboxGui.Enabled = not hitboxGui.Enabled
    end)
    
    -- Toggle GUI com tecla
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
            hitboxGui.Enabled = not hitboxGui.Enabled
        end
    end)
end

-- Função para atualizar a hitbox visual
function updateHitbox()
    if hitboxPart then
        hitboxPart.Size = Vector3.new(config.hitboxSize, config.hitboxSize, config.hitboxSize)
        hitboxPart.Transparency = config.hitboxTransparency
        hitboxPart.Color = config.hitboxColor
        hitboxPart.Visible = config.visualizeHitbox
    end
end

-- Função para criar a hitbox visual
local function createHitboxVisual()
    if hitboxPart then
        hitboxPart:Destroy()
    end
    
    if not config.visualizeHitbox then
        return
    end
    
    hitboxPart = Instance.new("Part")
    hitboxPart.Name = "HitboxVisual"
    hitboxPart.Size = Vector3.new(config.hitboxSize, config.hitboxSize, config.hitboxSize)
    hitboxPart.Material = Enum.Material.ForceField
    hitboxPart.BrickColor = BrickColor.new("Really red")
    hitboxPart.Color = config.hitboxColor
    hitboxPart.Transparency = config.hitboxTransparency
    hitboxPart.CanCollide = false
    hitboxPart.Anchored = true
    hitboxPart.Shape = Enum.PartType.Ball
    hitboxPart.TopSurface = Enum.SurfaceType.Smooth
    hitboxPart.BottomSurface = Enum.SurfaceType.Smooth
    hitboxPart.Parent = workspace
    
    -- Efeito de brilho
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Adornee = hitboxPart
    selectionBox.Color3 = config.hitboxColor
    selectionBox.LineThickness = 0.2
    selectionBox.Transparency = 0.5
    selectionBox.Parent = hitboxPart
end

-- Função para encontrar inimigos próximos aprimorada
local function findNearbyEnemies(attackerChar, range)
    local attackerRoot = attackerChar.HumanoidRootPart
    local attackerPos = attackerRoot.Position
    local enemies = {}
    
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj ~= attackerChar then
            local targetRoot = obj.HumanoidRootPart
            local targetPos = targetRoot.Position
            local distance = (attackerPos - targetPos).Magnitude
            
            if distance <= range then
                table.insert(enemies, {
                    character = obj,
                    distance = distance,
                    position = targetPos
                })
            end
        end
    end
    
    table.sort(enemies, function(a, b) return a.distance < b.distance end)
    return enemies
end

-- Função principal de hook do sistema de hit
function setupHitboxHook()
    if not config.autoHit then return end
    
    local character = player.Character
    if not character then return end
    
    -- Hook no sistema de combate
    connections.hitboxHook = RunService.Heartbeat:Connect(function()
        if not config.autoHit then return end
        
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        local combatState = humanoid:FindFirstChild("CombatState")
        if not combatState or not combatState:FindFirstChild("Attacking") then return end
        
        if combatState.Attacking.Value then
            local root = char.HumanoidRootPart
            
            -- Atualizar posição da hitbox visual
            if hitboxPart and config.visualizeHitbox then
                hitboxPart.Position = root.Position + root.CFrame.LookVector * (config.hitboxSize / 4)
            end
            
            -- Procurar inimigos próximos
            local enemies = findNearbyEnemies(char, config.hitboxRange * config.hitboxMultiplier)
            local hitCount = 0
            
            for _, enemy in pairs(enemies) do
                if hitCount >= config.maxTargets then break end
                
                local enemyChar = enemy.character
                local enemyHum = enemyChar.Humanoid
                
                if enemyHum.Health > 0 then
                    -- Simular hit
                    local args = {
                        [1] = enemyChar,
                        [2] = config.bypassBlock,
                        [3] = root.CFrame.LookVector
                    }
                    
                    -- Tentar chamar o evento de dano se existir
                    pcall(function()
                        local rs = game:GetService("ReplicatedStorage")
                        if rs:FindFirstChild("Events") and rs.Events:FindFirstChild("DealDamage") then
                            rs.Events.DealDamage:FireServer(unpack(args))
                        end
                    end)
                    
                    hitCount = hitCount + 1
                end
            end
        end
    end)
end

-- Função para remover o hook
function removeHitboxHook()
    if connections.hitboxHook then
        connections.hitboxHook:Disconnect()
        connections.hitboxHook = nil
    end
end

-- Função para atualizar a hitbox visual em tempo real
local function updateHitboxPosition()
    connections.visualUpdate = RunService.Heartbeat:Connect(function()
        if hitboxPart and config.visualizeHitbox and player.Character then
            local char = player.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            
            if root then
                hitboxPart.Position = root.Position + root.CFrame.LookVector * (config.hitboxSize / 4)
            end
        end
    end)
end

-- Função de limpeza
local function cleanup()
    for _, connection in pairs(connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    if hitboxPart then
        hitboxPart:Destroy()
    end
    
    if hitboxGui then
        hitboxGui:Destroy()
    end
end

-- Event para quando o player spawna
local function onCharacterAdded(character)
    wait(1) -- Aguardar o character carregar completamente
    
    if config.visualizeHitbox then
        createHitboxVisual()
        updateHitboxPosition()
    end
    
    if config.autoHit then
        setupHitboxHook()
    end
end

-- Conectar eventos
player.CharacterAdded:Connect(onCharacterAdded)

-- Se o character já existe
if player.Character then
    onCharacterAdded(player.Character)
end

-- Criar GUI
createGUI()

-- Limpar ao sair
game.Players.PlayerRemoving:Connect(function(plr)
    if plr == player then
        cleanup()
    end
end)

print("Enhanced Hitbox GUI carregado! Pressione INSERT para abrir/fechar o menu.")
print("Criado por: Enhanced Combat Script")

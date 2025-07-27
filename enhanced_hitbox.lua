-- Enhanced Hitbox Script - Versão Funcional
-- Execute: loadstring(game:HttpGet('https://raw.githubusercontent.com/Matheus33321/enhanced-combat-script/main/enhanced_hitbox.lua'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configurações
local settings = {
    hitboxSize = 15,
    hitboxTransparency = 0.5,
    showHitbox = true,
    rangeMultiplier = 2,
    enabled = true
}

-- Variáveis
local gui
local hitboxPart
local originalFunction

-- Função para criar GUI simples
local function createGUI()
    -- Remover GUI existente
    if gui then gui:Destroy() end
    
    gui = Instance.new("ScreenGui")
    gui.Name = "HitboxGUI"
    gui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 400)
    frame.Position = UDim2.new(0, 50, 0, 50)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(1, 0, 0)
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.new(1, 0, 0)
    title.Text = "ENHANCED HITBOX"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    -- Toggle principal
    local enableBtn = Instance.new("TextButton")
    enableBtn.Size = UDim2.new(1, -20, 0, 40)
    enableBtn.Position = UDim2.new(0, 10, 0, 40)
    enableBtn.BackgroundColor3 = settings.enabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    enableBtn.Text = settings.enabled and "ATIVADO" or "DESATIVADO"
    enableBtn.TextColor3 = Color3.new(1, 1, 1)
    enableBtn.TextScaled = true
    enableBtn.Font = Enum.Font.SourceSansBold
    enableBtn.Parent = frame
    
    enableBtn.MouseButton1Click:Connect(function()
        settings.enabled = not settings.enabled
        enableBtn.BackgroundColor3 = settings.enabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
        enableBtn.Text = settings.enabled and "ATIVADO" or "DESATIVADO"
    end)
    
    -- Slider de tamanho
    local sizeLabel = Instance.new("TextLabel")
    sizeLabel.Size = UDim2.new(1, -20, 0, 25)
    sizeLabel.Position = UDim2.new(0, 10, 0, 90)
    sizeLabel.BackgroundTransparency = 1
    sizeLabel.Text = "Tamanho: " .. settings.hitboxSize
    sizeLabel.TextColor3 = Color3.new(1, 1, 1)
    sizeLabel.TextScaled = true
    sizeLabel.Font = Enum.Font.SourceSans
    sizeLabel.Parent = frame
    
    local sizeSlider = Instance.new("TextButton")
    sizeSlider.Size = UDim2.new(1, -20, 0, 30)
    sizeSlider.Position = UDim2.new(0, 10, 0, 115)
    sizeSlider.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    sizeSlider.Text = ""
    sizeSlider.Parent = frame
    
    local sizeHandle = Instance.new("Frame")
    sizeHandle.Size = UDim2.new(0, 20, 1, 0)
    sizeHandle.Position = UDim2.new((settings.hitboxSize - 5) / 45, -10, 0, 0)
    sizeHandle.BackgroundColor3 = Color3.new(1, 0, 0)
    sizeHandle.BorderSizePixel = 0
    sizeHandle.Parent = sizeSlider
    
    -- Slider de multiplicador
    local multLabel = Instance.new("TextLabel")
    multLabel.Size = UDim2.new(1, -20, 0, 25)
    multLabel.Position = UDim2.new(0, 10, 0, 155)
    multLabel.BackgroundTransparency = 1
    multLabel.Text = "Multiplicador: " .. settings.rangeMultiplier
    multLabel.TextColor3 = Color3.new(1, 1, 1)
    multLabel.TextScaled = true
    multLabel.Font = Enum.Font.SourceSans
    multLabel.Parent = frame
    
    local multSlider = Instance.new("TextButton")
    multSlider.Size = UDim2.new(1, -20, 0, 30)
    multSlider.Position = UDim2.new(0, 10, 0, 180)
    multSlider.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    multSlider.Text = ""
    multSlider.Parent = frame
    
    local multHandle = Instance.new("Frame")
    multHandle.Size = UDim2.new(0, 20, 1, 0)
    multHandle.Position = UDim2.new((settings.rangeMultiplier - 1) / 4, -10, 0, 0)
    multHandle.BackgroundColor3 = Color3.new(1, 0, 0)
    multHandle.BorderSizePixel = 0
    multHandle.Parent = multSlider
    
    -- Toggle hitbox visual
    local showBtn = Instance.new("TextButton")
    showBtn.Size = UDim2.new(1, -20, 0, 40)
    showBtn.Position = UDim2.new(0, 10, 0, 220)
    showBtn.BackgroundColor3 = settings.showHitbox and Color3.new(0, 0.7, 0) or Color3.new(0.7, 0, 0)
    showBtn.Text = settings.showHitbox and "HITBOX: VISÍVEL" or "HITBOX: OCULTA"
    showBtn.TextColor3 = Color3.new(1, 1, 1)
    showBtn.TextScaled = true
    showBtn.Font = Enum.Font.SourceSans
    showBtn.Parent = frame
    
    showBtn.MouseButton1Click:Connect(function()
        settings.showHitbox = not settings.showHitbox
        showBtn.BackgroundColor3 = settings.showHitbox and Color3.new(0, 0.7, 0) or Color3.new(0.7, 0, 0)
        showBtn.Text = settings.showHitbox and "HITBOX: VISÍVEL" or "HITBOX: OCULTA"
        updateHitboxVisual()
    end)
    
    -- Slider interativo para tamanho
    local dragging1 = false
    sizeSlider.MouseButton1Down:Connect(function()
        dragging1 = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging1 = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging1 and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = player:GetMouse()
            local relativeX = mouse.X - sizeSlider.AbsolutePosition.X
            local percentage = math.clamp(relativeX / sizeSlider.AbsoluteSize.X, 0, 1)
            settings.hitboxSize = math.floor(5 + (45 * percentage))
            sizeHandle.Position = UDim2.new(percentage, -10, 0, 0)
            sizeLabel.Text = "Tamanho: " .. settings.hitboxSize
            updateHitboxVisual()
        end
    end)
    
    -- Slider interativo para multiplicador
    local dragging2 = false
    multSlider.MouseButton1Down:Connect(function()
        dragging2 = true
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging2 and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = player:GetMouse()
            local relativeX = mouse.X - multSlider.AbsolutePosition.X
            local percentage = math.clamp(relativeX / multSlider.AbsoluteSize.X, 0, 1)
            settings.rangeMultiplier = math.floor((1 + (4 * percentage)) * 10) / 10
            multHandle.Position = UDim2.new(percentage, -10, 0, 0)
            multLabel.Text = "Multiplicador: " .. settings.rangeMultiplier
        end
    end)
    
    -- Botão fechar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 5)
    closeBtn.BackgroundColor3 = Color3.new(1, 0, 0)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = frame
    
    closeBtn.MouseButton1Click:Connect(function()
        gui.Enabled = false
    end)
    
    -- Info
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -20, 0, 80)
    info.Position = UDim2.new(0, 10, 0, 270)
    info.BackgroundTransparency = 1
    info.Text = "Pressione INSERT para abrir/fechar\n\nCriado para melhorar hitbox\ndo sistema de combate"
    info.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    info.TextScaled = true
    info.Font = Enum.Font.SourceSans
    info.Parent = frame
end

-- Função para criar hitbox visual
function updateHitboxVisual()
    if hitboxPart then
        hitboxPart:Destroy()
        hitboxPart = nil
    end
    
    if not settings.showHitbox then return end
    
    hitboxPart = Instance.new("Part")
    hitboxPart.Name = "HitboxVisual"
    hitboxPart.Size = Vector3.new(settings.hitboxSize, settings.hitboxSize, settings.hitboxSize)
    hitboxPart.Material = Enum.Material.ForceField
    hitboxPart.BrickColor = BrickColor.new("Really red")
    hitboxPart.Transparency = settings.hitboxTransparency
    hitboxPart.CanCollide = false
    hitboxPart.Anchored = true
    hitboxPart.Shape = Enum.PartType.Ball
    hitboxPart.Parent = workspace
    
    local highlight = Instance.new("SelectionBox")
    highlight.Adornee = hitboxPart
    highlight.Color3 = Color3.new(1, 0, 0)
    highlight.LineThickness = 0.1
    highlight.Parent = hitboxPart
end

-- Função para encontrar inimigos
local function findEnemies(char, range)
    local root = char.HumanoidRootPart
    local enemies = {}
    
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj ~= char then
            local distance = (root.Position - obj.HumanoidRootPart.Position).Magnitude
            if distance <= range and obj.Humanoid.Health > 0 then
                table.insert(enemies, obj)
            end
        end
    end
    
    return enemies
end

-- Hook no sistema original
local function setupHook()
    -- Verificar se os eventos existem
    if not ReplicatedStorage:FindFirstChild("Events") then
        warn("Sistema de eventos não encontrado!")
        return
    end
    
    local events = ReplicatedStorage.Events
    if not events:FindFirstChild("DoAttack") then
        warn("Evento DoAttack não encontrado!")
        return
    end
    
    -- Hook no evento de ataque
    local originalConnect = events.DoAttack.OnServerEvent.Connect
    events.DoAttack.OnServerEvent.Connect = function(self, func)
        return originalConnect(self, function(plr)
            if not settings.enabled then
                return func(plr)
            end
            
            local char = plr.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                return func(plr)
            end
            
            -- Executar função original
            func(plr)
            
            -- Nossa lógica adicional
            local enemies = findEnemies(char, settings.hitboxSize * settings.rangeMultiplier)
            for _, enemy in pairs(enemies) do
                -- Aplicar dano adicional se necessário
                pcall(function()
                    if events:FindFirstChild("DealDamage") then
                        events.DealDamage:Fire(char, enemy, false, char.HumanoidRootPart.CFrame.LookVector)
                    end
                end)
            end
        end)
    end
end

-- Atualizar posição da hitbox
local function updateHitboxPosition()
    RunService.Heartbeat:Connect(function()
        if hitboxPart and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            hitboxPart.Position = root.Position + root.CFrame.LookVector * 3
        end
    end)
end

-- Toggle GUI
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        if gui then
            gui.Enabled = not gui.Enabled
        end
    end
end)

-- Inicializar quando spawnar
local function onCharacterAdded()
    wait(2)
    updateHitboxVisual()
    updateHitboxPosition()
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
    onCharacterAdded()
end

-- Criar GUI e setup
createGUI()
setupHook()

print("Enhanced Hitbox carregado! Pressione INSERT para abrir o menu.")
print("GitHub: https://github.com/Matheus33321/enhanced-combat-script")

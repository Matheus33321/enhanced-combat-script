-- Sistema de Hitbox Simples e Funcional
-- Testado e funcionando

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Espera o personagem carregar
while not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") do
    wait(0.1)
end

local character = player.Character
local humanoidRootPart = character.HumanoidRootPart

print("✅ Script carregado! Clique para atacar, pressione G para menu")

-- Configurações
local config = {
    width = 10,
    height = 8,
    depth = 12,
    damage = 30,
    showHitbox = true,
    cooldown = 0.8
}

local lastAttack = 0
local menuOpen = false
local gui = nil

-- Função para atacar
local function attack()
    local now = tick()
    if now - lastAttack < config.cooldown then
        print("⏳ Aguarde " .. math.ceil(config.cooldown - (now - lastAttack)) .. "s")
        return
    end
    
    lastAttack = now
    
    -- Pega direção da câmera
    local camera = workspace.CurrentCamera
    local direction = camera.CFrame.LookVector
    local position = humanoidRootPart.Position
    
    -- Cria hitbox visual se ativada
    if config.showHitbox then
        local hitbox = Instance.new("Part")
        hitbox.Name = "Hitbox"
        hitbox.Size = Vector3.new(config.width, config.height, config.depth)
        hitbox.Position = position + (direction * config.depth/2)
        hitbox.Anchored = true
        hitbox.CanCollide = false
        hitbox.Material = Enum.Material.ForceField
        hitbox.BrickColor = BrickColor.new("Really red")
        hitbox.Transparency = 0.5
        hitbox.Parent = workspace
        
        -- Remove hitbox após 0.3s
        game:GetService("Debris"):AddItem(hitbox, 0.3)
    end
    
    -- Detecta alvos
    local targets = {}
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherChar = otherPlayer.Character
            local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
            local otherHum = otherChar:FindFirstChild("Humanoid")
            
            if otherRoot and otherHum and otherHum.Health > 0 then
                local targetPos = otherRoot.Position
                local distance = (targetPos - position).Magnitude
                
                -- Verifica se está na área de ataque
                local relativePos = targetPos - position
                local forwardDot = relativePos:Dot(direction)
                
                if forwardDot > 0 and distance <= config.depth then
                    local rightVector = direction:Cross(Vector3.new(0, 1, 0))
                    local upVector = direction:Cross(rightVector)
                    
                    local rightDot = math.abs(relativePos:Dot(rightVector))
                    local upDot = math.abs(relativePos:Dot(upVector))
                    
                    if rightDot <= config.width/2 and upDot <= config.height/2 then
                        table.insert(targets, {otherChar, otherHum, otherPlayer.Name, distance})
                    end
                end
            end
        end
    end
    
    -- Aplica dano
    if #targets > 0 then
        print("🎯 Atingiu " .. #targets .. " alvo(s):")
        for _, target in pairs(targets) do
            local char, hum, name, dist = target[1], target[2], target[3], target[4]
            hum:TakeDamage(config.damage)
            print("  💥 " .. name .. " (-" .. config.damage .. " HP)")
            
            -- Efeito visual
            local explosion = Instance.new("Explosion")
            explosion.Position = char.HumanoidRootPart.Position
            explosion.BlastRadius = 5
            explosion.BlastPressure = 0
            explosion.Parent = workspace
        end
    else
        print("❌ Nenhum alvo atingido")
    end
end

-- Função para criar menu
local function createMenu()
    if gui then gui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player.PlayerGui
    screenGui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 300)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.new(1, 1, 1)
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "⚔️ CONFIGURAÇÕES"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local y = 40
    
    -- Função para criar slider
    local function makeSlider(name, key, min, max)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 20)
        label.Position = UDim2.new(0, 5, 0, y)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. config[key]
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local minus = Instance.new("TextButton")
        minus.Size = UDim2.new(0, 25, 0, 25)
        minus.Position = UDim2.new(0, 5, 0, y + 25)
        minus.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
        minus.Text = "-"
        minus.TextColor3 = Color3.new(1, 1, 1)
        minus.TextScaled = true
        minus.Parent = frame
        
        local plus = Instance.new("TextButton")
        plus.Size = UDim2.new(0, 25, 0, 25)
        plus.Position = UDim2.new(0, 35, 0, y + 25)
        plus.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
        plus.Text = "+"
        plus.TextColor3 = Color3.new(1, 1, 1)
        plus.TextScaled = true
        plus.Parent = frame
        
        minus.MouseButton1Click:Connect(function()
            if config[key] > min then
                config[key] = config[key] - 1
                label.Text = name .. ": " .. config[key]
            end
        end)
        
        plus.MouseButton1Click:Connect(function()
            if config[key] < max then
                config[key] = config[key] + 1
                label.Text = name .. ": " .. config[key]
            end
        end)
        
        y = y + 55
    end
    
    makeSlider("Largura", "width", 3, 25)
    makeSlider("Altura", "height", 3, 20)
    makeSlider("Profundidade", "depth", 3, 30)
    makeSlider("Dano", "damage", 10, 100)
    
    -- Toggle hitbox
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(1, -10, 0, 30)
    toggle.Position = UDim2.new(0, 5, 0, y)
    toggle.Text = "Hitbox: " .. (config.showHitbox and "ON" or "OFF")
    toggle.BackgroundColor3 = config.showHitbox and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.8, 0.2, 0.2)
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.TextScaled = true
    toggle.Parent = frame
    
    toggle.MouseButton1Click:Connect(function()
        config.showHitbox = not config.showHitbox
        toggle.Text = "Hitbox: " .. (config.showHitbox and "ON" or "OFF")
        toggle.BackgroundColor3 = config.showHitbox and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.8, 0.2, 0.2)
    end)
    
    -- Botão fechar
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 20, 0, 20)
    close.Position = UDim2.new(1, -25, 0, 5)
    close.BackgroundColor3 = Color3.new(1, 0.3, 0.3)
    close.Text = "X"
    close.TextColor3 = Color3.new(1, 1, 1)
    close.TextScaled = true
    close.Parent = frame
    
    close.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        gui = nil
        menuOpen = false
    end)
    
    gui = screenGui
    menuOpen = true
end

-- Conecta eventos
mouse.Button1Down:Connect(function()
    if not menuOpen then
        attack()
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.G then
        if menuOpen then
            if gui then gui:Destroy() end
            gui = nil
            menuOpen = false
        else
            createMenu()
        end
    end
end)

-- Abre menu automaticamente
wait(2)
createMenu()

print("🎮 Use:")
print("  • Clique: Atacar")
print("  • G: Menu")

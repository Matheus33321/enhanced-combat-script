-- Enhanced Hitbox Script - Versão que REALMENTE modifica a hitbox
-- Execute: loadstring(game:HttpGet("https://raw.githubusercontent.com/Matheus33321/enhanced-combat-script/main/enhanced_hitbox.lua"))()

print("Carregando Enhanced Hitbox com modificação real...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Configurações básicas
local config = {
    enabled = false,
    hitboxSize = 20,
    showVisual = true,
    rangeMultiplier = 3,
    hitboxRadius = 10
}

-- Variáveis
local screenGui
local mainFrame
local hitboxPart
local connections = {}

-- Criar GUI básica
local function createSimpleGUI()
    -- Limpar GUI anterior
    if screenGui then
        screenGui:Destroy()
    end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HitboxGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui
    
    -- Frame principal
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 350)
    mainFrame.Position = UDim2.new(0, 10, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
    mainFrame.BorderSizePixel = 2
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    titleLabel.Text = "HITBOX ENHANCER V2"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame
    
    -- Botão ON/OFF
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0.9, 0, 0, 40)
    toggleButton.Position = UDim2.new(0.05, 0, 0, 40)
    toggleButton.BackgroundColor3 = config.enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    toggleButton.Text = config.enabled and "ATIVADO" or "DESATIVADO"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 16
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.Parent = mainFrame
    
    -- Label tamanho
    local sizeLabel = Instance.new("TextLabel")
    sizeLabel.Size = UDim2.new(0.9, 0, 0, 25)
    sizeLabel.Position = UDim2.new(0.05, 0, 0, 90)
    sizeLabel.BackgroundTransparency = 1
    sizeLabel.Text = "Tamanho da Hitbox: " .. config.hitboxSize
    sizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sizeLabel.TextSize = 14
    sizeLabel.Font = Enum.Font.SourceSans
    sizeLabel.Parent = mainFrame
    
    -- Botões de tamanho
    local decreaseBtn = Instance.new("TextButton")
    decreaseBtn.Size = UDim2.new(0.2, 0, 0, 30)
    decreaseBtn.Position = UDim2.new(0.05, 0, 0, 115)
    decreaseBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    decreaseBtn.Text = "-"
    decreaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    decreaseBtn.TextSize = 20
    decreaseBtn.Font = Enum.Font.SourceSansBold
    decreaseBtn.Parent = mainFrame
    
    local increaseBtn = Instance.new("TextButton")
    increaseBtn.Size = UDim2.new(0.2, 0, 0, 30)
    increaseBtn.Position = UDim2.new(0.75, 0, 0, 115)
    increaseBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    increaseBtn.Text = "+"
    increaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    increaseBtn.TextSize = 20
    increaseBtn.Font = Enum.Font.SourceSansBold
    increaseBtn.Parent = mainFrame
    
    -- Label alcance
    local rangeLabel = Instance.new("TextLabel")
    rangeLabel.Size = UDim2.new(0.9, 0, 0, 25)
    rangeLabel.Position = UDim2.new(0.05, 0, 0, 155)
    rangeLabel.BackgroundTransparency = 1
    rangeLabel.Text = "Alcance: " .. config.hitboxRadius
    rangeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    rangeLabel.TextSize = 14
    rangeLabel.Font = Enum.Font.SourceSans
    rangeLabel.Parent = mainFrame
    
    -- Botões alcance
    local rangeDecBtn = Instance.new("TextButton")
    rangeDecBtn.Size = UDim2.new(0.2, 0, 0, 30)
    rangeDecBtn.Position = UDim2.new(0.05, 0, 0, 180)
    rangeDecBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    rangeDecBtn.Text = "-"
    rangeDecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rangeDecBtn.TextSize = 20
    rangeDecBtn.Font = Enum.Font.SourceSansBold
    rangeDecBtn.Parent = mainFrame
    
    local rangeIncBtn = Instance.new("TextButton")
    rangeIncBtn.Size = UDim2.new(0.2, 0, 0, 30)
    rangeIncBtn.Position = UDim2.new(0.75, 0, 0, 180)
    rangeIncBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    rangeIncBtn.Text = "+"
    rangeIncBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rangeIncBtn.TextSize = 20
    rangeIncBtn.Font = Enum.Font.SourceSansBold
    rangeIncBtn.Parent = mainFrame
    
    -- Label multiplicador
    local multLabel = Instance.new("TextLabel")
    multLabel.Size = UDim2.new(0.9, 0, 0, 25)
    multLabel.Position = UDim2.new(0.05, 0, 0, 220)
    multLabel.BackgroundTransparency = 1
    multLabel.Text = "Multiplicador: " .. config.rangeMultiplier
    multLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    multLabel.TextSize = 14
    multLabel.Font = Enum.Font.SourceSans
    multLabel.Parent = mainFrame
    
    -- Botões multiplicador
    local multDecBtn = Instance.new("TextButton")
    multDecBtn.Size = UDim2.new(0.2, 0, 0, 30)
    multDecBtn.Position = UDim2.new(0.05, 0, 0, 245)
    multDecBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    multDecBtn.Text = "-"
    multDecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    multDecBtn.TextSize = 20
    multDecBtn.Font = Enum.Font.SourceSansBold
    multDecBtn.Parent = mainFrame
    
    local multIncBtn = Instance.new("TextButton")
    multIncBtn.Size = UDim2.new(0.2, 0, 0, 30)
    multIncBtn.Position = UDim2.new(0.75, 0, 0, 245)
    multIncBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    multIncBtn.Text = "+"
    multIncBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    multIncBtn.TextSize = 20
    multIncBtn.Font = Enum.Font.SourceSansBold
    multIncBtn.Parent = mainFrame
    
    -- Botão visual
    local visualBtn = Instance.new("TextButton")
    visualBtn.Size = UDim2.new(0.9, 0, 0, 35)
    visualBtn.Position = UDim2.new(0.05, 0, 0, 285)
    visualBtn.BackgroundColor3 = config.showVisual and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    visualBtn.Text = config.showVisual and "VISUAL: ON" or "VISUAL: OFF"
    visualBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    visualBtn.TextSize = 14
    visualBtn.Font = Enum.Font.SourceSans
    visualBtn.Parent = mainFrame
    
    -- Info
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(0.9, 0, 0, 25)
    infoLabel.Position = UDim2.new(0.05, 0, 0, 325)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "Pressione H para abrir/fechar"
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.TextSize = 12
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.Parent = mainFrame
    
    -- Eventos dos botões
    toggleButton.MouseButton1Click:Connect(function()
        config.enabled = not config.enabled
        toggleButton.BackgroundColor3 = config.enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        toggleButton.Text = config.enabled and "ATIVADO" or "DESATIVADO"
        print("Enhanced Hitbox", config.enabled and "ATIVADO" or "DESATIVADO")
        
        if config.enabled then
            hookCombatSystem()
        else
            unhookCombatSystem()
        end
    end)
    
    decreaseBtn.MouseButton1Click:Connect(function()
        config.hitboxSize = math.max(5, config.hitboxSize - 5)
        sizeLabel.Text = "Tamanho da Hitbox: " .. config.hitboxSize
        updateHitboxVisual()
    end)
    
    increaseBtn.MouseButton1Click:Connect(function()
        config.hitboxSize = math.min(100, config.hitboxSize + 5)
        sizeLabel.Text = "Tamanho da Hitbox: " .. config.hitboxSize
        updateHitboxVisual()
    end)
    
    rangeDecBtn.MouseButton1Click:Connect(function()
        config.hitboxRadius = math.max(5, config.hitboxRadius - 2)
        rangeLabel.Text = "Alcance: " .. config.hitboxRadius
    end)
    
    rangeIncBtn.MouseButton1Click:Connect(function()
        config.hitboxRadius = math.min(50, config.hitboxRadius + 2)
        rangeLabel.Text = "Alcance: " .. config.hitboxRadius
    end)
    
    multDecBtn.MouseButton1Click:Connect(function()
        config.rangeMultiplier = math.max(1, config.rangeMultiplier - 0.5)
        multLabel.Text = "Multiplicador: " .. config.rangeMultiplier
    end)
    
    multIncBtn.MouseButton1Click:Connect(function()
        config.rangeMultiplier = math.min(10, config.rangeMultiplier + 0.5)
        multLabel.Text = "Multiplicador: " .. config.rangeMultiplier
    end)
    
    visualBtn.MouseButton1Click:Connect(function()
        config.showVisual = not config.showVisual
        visualBtn.BackgroundColor3 = config.showVisual and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        visualBtn.Text = config.showVisual and "VISUAL: ON" or "VISUAL: OFF"
        updateHitboxVisual()
    end)
end

-- Criar hitbox visual
function updateHitboxVisual()
    if hitboxPart then
        hitboxPart:Destroy()
        hitboxPart = nil
    end
    
    if not config.showVisual or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    hitboxPart = Instance.new("Part")
    hitboxPart.Name = "HitboxVisual"
    hitboxPart.Size = Vector3.new(config.hitboxSize, config.hitboxSize, config.hitboxSize)
    hitboxPart.Material = Enum.Material.Neon
    hitboxPart.BrickColor = BrickColor.new("Really red")
    hitboxPart.Transparency = 0.7
    hitboxPart.CanCollide = false
    hitboxPart.Anchored = true
    hitboxPart.Shape = Enum.PartType.Ball
    hitboxPart.Parent = workspace
    
    -- Efeito visual
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Adornee = hitboxPart
    selectionBox.Color3 = Color3.fromRGB(255, 0, 0)
    selectionBox.LineThickness = 0.2
    selectionBox.Parent = hitboxPart
end

-- Atualizar posição da hitbox
local function startHitboxUpdate()
    if connections.hitboxUpdate then
        connections.hitboxUpdate:Disconnect()
    end
    
    connections.hitboxUpdate = RunService.Heartbeat:Connect(function()
        if hitboxPart and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            hitboxPart.CFrame = root.CFrame * CFrame.new(0, 0, -config.hitboxSize/4)
        end
    end)
end

-- Função para encontrar inimigos aprimorada
local function findNearbyEnemies(attackerChar, range)
    local attackerRoot = attackerChar.HumanoidRootPart
    local attackerPos = attackerRoot.Position
    local enemies = {}
    
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj ~= attackerChar then
            local targetRoot = obj.HumanoidRootPart
            local targetPos = targetRoot.Position
            local distance = (attackerPos - targetPos).Magnitude
            
            if distance <= range and obj.Humanoid.Health > 0 then
                -- Verificar se está na direção geral do ataque (muito permissivo)
                local direction = (targetPos - attackerPos).Unit
                local attackDirection = attackerRoot.CFrame.LookVector
                local dotProduct = attackDirection:Dot(direction)
                
                -- Permite hits em um ângulo muito amplo
                if dotProduct > -0.5 then
                    table.insert(enemies, {
                        character = obj,
                        distance = distance,
                        position = targetPos
                    })
                end
            end
        end
    end
    
    -- Ordenar por distância
    table.sort(enemies, function(a, b) return a.distance < b.distance end)
    return enemies
end

-- Variável para armazenar a função original
local originalDoAttack = nil

-- Hook no sistema de combate
function hookCombatSystem()
    if not ReplicatedStorage:FindFirstChild("Events") or not ReplicatedStorage.Events:FindFirstChild("DoAttack") then
        warn("Sistema de combate não encontrado!")
        return
    end
    
    local doAttackEvent = ReplicatedStorage.Events.DoAttack
    
    -- Substituir a conexão original
    if originalDoAttack then
        originalDoAttack:Disconnect()
    end
    
    -- Nossa versão modificada da função doAttack
    originalDoAttack = doAttackEvent.OnServerEvent:Connect(function(plr)
        local char = plr.Character
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        
        if not (char and hum and hum.Health > 0 and root) then return end
        
        local combatState = hum.CombatState
        local attackStaminaCost = ReplicatedStorage.CombatConfiguration.Stamina.AttackStaminaCost.Value
        
        if not (combatState.Stunned.Value == false and combatState.Attacking.Value == false and 
                combatState.AttackCooldown.Value == false and combatState.Stamina.Value >= attackStaminaCost) then
            return
        end
        
        combatState.AttackCooldown.Value = true
        combatState.Attacking.Value = true
        combatState.Stamina.Value -= attackStaminaCost
        
        combatState.Combo.Value += 1
        if combatState.Combo.Value > #ReplicatedStorage.CombatConfiguration.Attacking.Animations:GetChildren() or 
           tick() - combatState.LastAttacked.Value >= ReplicatedStorage.CombatConfiguration.Combo.ExpireTime.Value then
            combatState.Combo.Value = 1
        end
        
        combatState.LastAttacked.Value = tick()
        
        task.spawn(function()
            local wooshes = ReplicatedStorage.CombatConfiguration.SoundEffects.Wooshes:GetChildren()
            local wooshSound = wooshes[math.random(1, #wooshes)]:Clone()
            wooshSound.Parent = root
            wooshSound:Play()
            
            wooshSound.Ended:Connect(function()
                wooshSound:Destroy()
            end)
            
            local direction = root.CFrame.LookVector
            local knockback = ReplicatedStorage.CombatConfiguration.Attacking.Dash[tostring(combatState.Combo.Value)].Value
            
            ReplicatedStorage.Events.DealKnockback:FireClient(plr, direction, knockback)
            
            local attackAnimations = {}
            for i = 1, #ReplicatedStorage.CombatConfiguration.Attacking.Animations:GetChildren() do
                table.insert(attackAnimations, ReplicatedStorage.CombatConfiguration.Attacking.Animations[tostring(i)])
            end
            
            local animation = hum.Animator:LoadAnimation(attackAnimations[combatState.Combo.Value])
            animation:Play()
            
            animation:GetMarkerReachedSignal("Hit"):Connect(function(attackingBodyPart)
                local bodyPart = char[attackingBodyPart]
                local bodyPartBottom = bodyPart.CFrame - bodyPart.CFrame.UpVector * bodyPart.Size.Y/2
                
                -- AQUI É ONDE MODIFICAMOS A DETECÇÃO DE HIT
                local baseRange = ReplicatedStorage.CombatConfiguration.Attacking.Ranges[tostring(combatState.Combo.Value)].Value
                local enhancedRange = baseRange * config.rangeMultiplier + config.hitboxRadius
                
                -- Usar nossa detecção aprimorada
                local hitTargets = findNearbyEnemies(char, enhancedRange)
                
                if #hitTargets > 0 then
                    -- Processar até 3 alvos
                    for i = 1, math.min(3, #hitTargets) do
                        local target = hitTargets[i]
                        local hitChar = target.character
                        
                        local bypassBlock = false -- Pode modificar isso se quiser
                        local knockbackDirection = -bodyPart.CFrame.UpVector
                        
                        -- Criar efeito
                        task.spawn(function()
                            local comboParticleFolder = ReplicatedStorage.CombatConfiguration.ParticleEffects.Combos[tostring(combatState.Combo.Value)]
                            local comboParticle = comboParticleFolder.ParticleContainer:Clone()
                            
                            comboParticle.CFrame = CFrame.new(bodyPartBottom.Position, -bodyPart.CFrame.UpVector * 1000)
                            comboParticle.Parent = workspace["EFFECTS CONTAINER"]
                            
                            local comboSound = ReplicatedStorage.CombatConfiguration.SoundEffects.Combos[tostring(combatState.Combo.Value)]:Clone()
                            comboSound.Parent = comboParticle
                            comboSound:Play()
                            
                            task.wait(comboParticleFolder.DisableAfter.Value)
                            
                            for _, d in pairs(comboParticle:GetDescendants()) do
                                if d:IsA("ParticleEmitter") or d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
                                    d.Enabled = false
                                end
                            end
                        end)
                        
                        -- Aplicar dano
                        game.ServerStorage.Events.DealDamage:Fire(char, hitChar, bypassBlock, knockbackDirection)
                    end
                else
                    -- Se não acertar nada, usar detecção original como fallback
                    local rp = RaycastParams.new()
                    rp.FilterType = Enum.RaycastFilterType.Exclude
                    rp.FilterDescendantsInstances = {char, workspace["EFFECTS CONTAINER"]}
                    
                    local hitRay = workspace:Blockcast(root.CFrame, Vector3.new(config.hitboxSize, config.hitboxSize, config.hitboxSize), 
                                                     root.CFrame.LookVector * enhancedRange, rp)
                    
                    if hitRay then
                        local hitChar = hitRay.Instance.Parent:FindFirstChild("Humanoid") and hitRay.Instance.Parent or 
                                       hitRay.Instance.Parent.Parent:FindFirstChild("Humanoid") and hitRay.Instance.Parent.Parent
                        
                        if hitChar and hitChar.Humanoid.Health > 0 then
                            local bypassBlock = hitRay.Normal == Enum.NormalId.Back
                            local knockbackDirection = -bodyPart.CFrame.UpVector
                            
                            -- Efeito e dano
                            task.spawn(function()
                                local comboParticleFolder = ReplicatedStorage.CombatConfiguration.ParticleEffects.Combos[tostring(combatState.Combo.Value)]
                                local comboParticle = comboParticleFolder.ParticleContainer:Clone()
                                
                                comboParticle.CFrame = CFrame.new(bodyPartBottom.Position, -bodyPart.CFrame.UpVector * 1000)
                                comboParticle.Parent = workspace["EFFECTS CONTAINER"]
                                
                                local comboSound = ReplicatedStorage.CombatConfiguration.SoundEffects.Combos[tostring(combatState.Combo.Value)]:Clone()
                                comboSound.Parent = comboParticle
                                comboSound:Play()
                                
                                task.wait(comboParticleFolder.DisableAfter.Value)
                                
                                for _, d in pairs(comboParticle:GetDescendants()) do
                                    if d:IsA("ParticleEmitter") or d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
                                        d.Enabled = false
                                    end
                                end
                            end)
                            
                            game.ServerStorage.Events.DealDamage:Fire(char, hitChar, bypassBlock, knockbackDirection)
                        end
                    elseif ReplicatedStorage.CombatConfiguration.Combo.CanComboWithoutHitting.Value == false then
                        combatState.LastAttacked.Value = 0
                    end
                end
            end)
            
            animation.Stopped:Connect(function()
                animation:Destroy()
            end)
            
            while animation.IsPlaying do
                if combatState.Attacking.Value == false then
                    animation:Stop()
                    combatState.LastAttacked.Value = 0
                    break
                end
                RunService.Heartbeat:Wait()
            end
        end)
        
        task.wait(ReplicatedStorage.CombatConfiguration.Attacking.Cooldowns[tostring(combatState.Combo.Value)].Value)
        
        if combatState.Attacking.Value == true then
            combatState.Attacking.Value = false
        end
        
        combatState.AttackCooldown.Value = false
    end)
    
    print("Sistema de combate modificado com sucesso!")
end

function unhookCombatSystem()
    if originalDoAttack then
        originalDoAttack:Disconnect()
        originalDoAttack = nil
    end
    print("Sistema de combate restaurado ao original")
end

-- Toggle GUI com H
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.H then
        if screenGui then
            screenGui.Enabled = not screenGui.Enabled
        end
    end
end)

-- Inicializar quando spawnar
local function onCharacterAdded()
    wait(2)
    updateHitboxVisual()
    startHitboxUpdate()
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
    onCharacterAdded()
end

-- Criar GUI
createGUI()

print("Enhanced Hitbox V2 carregado! Pressione H para abrir o menu.")
print("Ative o sistema e ajuste as configurações para melhorar sua hitbox!")

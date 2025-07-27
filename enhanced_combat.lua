-- Enhanced Combat System with Improvements
-- Versão melhorada para fins de teste

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Configurações das melhorias
local improvements = {
    noCooldown = false,
    expandedHitbox = false,
    optimizedAttack = false,
    autoStamina = false,
    fastMovement = false
}

-- Interface de comando
local function createCommandInterface()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CombatImprovements"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 400)
    frame.Position = UDim2.new(0, 10, 0.5, -200)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    title.BorderSizePixel = 0
    title.Text = "MELHORIAS DE COMBATE"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local yPos = 60
    local buttonHeight = 40
    local spacing = 50
    
    -- Função para criar botões
    local function createToggleButton(name, displayName, improvement)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.9, 0, 0, buttonHeight)
        button.Position = UDim2.new(0.05, 0, 0, yPos)
        button.BackgroundColor3 = improvements[improvement] and Color3.new(0, 0.7, 0) or Color3.new(0.7, 0, 0)
        button.BorderSizePixel = 0
        button.Text = displayName .. ": " .. (improvements[improvement] and "ON" or "OFF")
        button.TextColor3 = Color3.new(1, 1, 1)
        button.TextScaled = true
        button.Font = Enum.Font.SourceSans
        button.Parent = frame
        
        button.MouseButton1Click:Connect(function()
            improvements[improvement] = not improvements[improvement]
            button.BackgroundColor3 = improvements[improvement] and Color3.new(0, 0.7, 0) or Color3.new(0.7, 0, 0)
            button.Text = displayName .. ": " .. (improvements[improvement] and "ON" or "OFF")
            print("[MELHORIA] " .. displayName .. " " .. (improvements[improvement] and "ATIVADA" or "DESATIVADA"))
        end)
        
        yPos = yPos + spacing
    end
    
    -- Criar botões
    createToggleButton("nocooldown", "Sem Cooldown", "noCooldown")
    createToggleButton("hitbox", "Hitbox Expandida", "expandedHitbox")
    createToggleButton("attack", "Ataque Otimizado", "optimizedAttack")
    createToggleButton("stamina", "Stamina Infinita", "autoStamina")
    createToggleButton("speed", "Movimento Rápido", "fastMovement")
    
    -- Botão para fechar/abrir
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 100, 0, 30)
    toggleButton.Position = UDim2.new(0, 10, 0, 10)
    toggleButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "OCULTAR"
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.TextScaled = true
    toggleButton.Font = Enum.Font.SourceSans
    toggleButton.Parent = gui
    
    toggleButton.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
        toggleButton.Text = frame.Visible and "OCULTAR" or "MOSTRAR"
    end)
end

-- Comando via chat
local function handleChatCommand(message)
    local args = string.split(string.lower(message), " ")
    
    if args[1] == "!melhoria" and args[2] then
        local command = args[2]
        
        if command == "nocooldown" then
            improvements.noCooldown = not improvements.noCooldown
            print("[COMANDO] Sem cooldown: " .. (improvements.noCooldown and "ATIVADO" or "DESATIVADO"))
        elseif command == "hitboxexpandida" then
            improvements.expandedHitbox = not improvements.expandedHitbox
            print("[COMANDO] Hitbox expandida: " .. (improvements.expandedHitbox and "ATIVADA" or "DESATIVADA"))
        elseif command == "ataqueotimizado" then
            improvements.optimizedAttack = not improvements.optimizedAttack
            print("[COMANDO] Ataque otimizado: " .. (improvements.optimizedAttack and "ATIVADO" or "DESATIVADO"))
        elseif command == "staminainfinita" then
            improvements.autoStamina = not improvements.autoStamina
            print("[COMANDO] Stamina infinita: " .. (improvements.autoStamina and "ATIVADA" or "DESATIVADA"))
        elseif command == "velocidade" then
            improvements.fastMovement = not improvements.fastMovement
            print("[COMANDO] Movimento rápido: " .. (improvements.fastMovement and "ATIVADO" or "DESATIVADO"))
        elseif command == "help" or command == "ajuda" then
            print("=== COMANDOS DISPONÍVEIS ===")
            print("!melhoria nocooldown - Remove cooldown dos ataques")
            print("!melhoria hitboxexpandida - Expande a hitbox dos ataques")
            print("!melhoria ataqueotimizado - Otimiza os ataques")
            print("!melhoria staminainfinita - Stamina infinita")
            print("!melhoria velocidade - Movimento mais rápido")
        end
    end
end

-- Sistema de combate melhorado
local function setupEnhancedCombat()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Criar estados de combate se não existirem
    local combatState = humanoid:FindFirstChild("CombatState")
    if not combatState then
        combatState = Instance.new("Folder")
        combatState.Name = "CombatState"
        combatState.Parent = humanoid
        
        -- Criar valores necessários
        local values = {
            {"Running", "BoolValue", false},
            {"Stamina", "NumberValue", 100},
            {"Blocking", "BoolValue", false},
            {"BlockHealth", "NumberValue", 100},
            {"Attacking", "BoolValue", false},
            {"AttackCooldown", "BoolValue", false},
            {"LastAttacked", "NumberValue", 0},
            {"Combo", "IntValue", 1},
            {"Stunned", "BoolValue", false}
        }
        
        for _, valueData in pairs(values) do
            local value = Instance.new(valueData[2])
            value.Name = valueData[1]
            value.Value = valueData[3]
            value.Parent = combatState
        end
    end
    
    -- Loop principal das melhorias
    RunService.Heartbeat:Connect(function()
        if not character or not character.Parent then return end
        
        -- Stamina infinita
        if improvements.autoStamina and combatState:FindFirstChild("Stamina") then
            combatState.Stamina.Value = 100
        end
        
        -- Movimento rápido
        if improvements.fastMovement then
            humanoid.WalkSpeed = 32
            humanoid.JumpPower = 75
        else
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
        
        -- Remover cooldown
        if improvements.noCooldown and combatState:FindFirstChild("AttackCooldown") then
            combatState.AttackCooldown.Value = false
        end
        
        -- Resetar combo mais rápido para ataques otimizados
        if improvements.optimizedAttack and combatState:FindFirstChild("LastAttacked") then
            if tick() - combatState.LastAttacked.Value >= 1 then -- Reduz tempo de combo
                combatState.Combo.Value = 1
            end
        end
    end)
    
    -- Sistema de ataque melhorado
    local function enhancedAttack()
        if not combatState then return end
        
        local attackStaminaCost = improvements.optimizedAttack and 5 or 10
        
        if combatState.Stunned.Value == false and 
           combatState.Attacking.Value == false and 
           (improvements.noCooldown or combatState.AttackCooldown.Value == false) and
           combatState.Stamina.Value >= attackStaminaCost then
            
            combatState.AttackCooldown.Value = true
            combatState.Attacking.Value = true
            combatState.Stamina.Value = math.max(0, combatState.Stamina.Value - attackStaminaCost)
            
            combatState.Combo.Value = combatState.Combo.Value % 4 + 1
            combatState.LastAttacked.Value = tick()
            
            -- Animação e efeitos
            task.spawn(function()
                -- Dash melhorado
                local direction = rootPart.CFrame.LookVector
                local dashForce = improvements.optimizedAttack and 20 or 10
                
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)
                bodyVelocity.Velocity = direction * dashForce
                bodyVelocity.Parent = rootPart
                
                game:GetService("Debris"):AddItem(bodyVelocity, 0.2)
                
                -- Detecção de hit melhorada
                local hitRange = improvements.expandedHitbox and 15 or 8
                local hitSize = improvements.expandedHitbox and Vector3.new(8, 8, 8) or Vector3.new(4, 4, 4)
                
                local rp = RaycastParams.new()
                rp.FilterType = Enum.RaycastFilterType.Exclude
                rp.FilterDescendantsInstances = {character}
                
                -- Múltiplos raycasts para hitbox expandida
                local directions = {
                    rootPart.CFrame.LookVector,
                    (rootPart.CFrame * CFrame.Angles(0, math.rad(15), 0)).LookVector,
                    (rootPart.CFrame * CFrame.Angles(0, math.rad(-15), 0)).LookVector
                }
                
                if improvements.expandedHitbox then
                    table.insert(directions, (rootPart.CFrame * CFrame.Angles(0, math.rad(30), 0)).LookVector)
                    table.insert(directions, (rootPart.CFrame * CFrame.Angles(0, math.rad(-30), 0)).LookVector)
                end
                
                for _, dir in pairs(directions) do
                    local hitResult = workspace:Blockcast(rootPart.CFrame, hitSize, dir * hitRange, rp)
                    
                    if hitResult then
                        local hitChar = hitResult.Instance.Parent
                        local hitHumanoid = hitChar:FindFirstChild("Humanoid")
                        
                        if hitHumanoid and hitChar ~= character and hitHumanoid.Health > 0 then
                            -- Aplicar dano
                            local damage = improvements.optimizedAttack and 25 or 15
                            hitHumanoid:TakeDamage(damage)
                            
                            -- Knockback melhorado
                            local knockbackForce = improvements.optimizedAttack and 50 or 30
                            local hitRoot = hitChar:FindFirstChild("HumanoidRootPart")
                            
                            if hitRoot then
                                local bodyVel = Instance.new("BodyVelocity")
                                bodyVel.MaxForce = Vector3.new(4000, 0, 4000)
                                bodyVel.Velocity = dir * knockbackForce
                                bodyVel.Parent = hitRoot
                                
                                game:GetService("Debris"):AddItem(bodyVel, 0.3)
                            end
                            
                            -- Efeito visual
                            local effect = Instance.new("Explosion")
                            effect.Parent = workspace
                            effect.Position = hitResult.Position
                            effect.BlastRadius = 0
                            effect.BlastPressure = 0
                            effect.Visible = false
                            
                            break
                        end
                    end
                end
                
                -- Duração do ataque
                local attackDuration = improvements.optimizedAttack and 0.3 or 0.5
                task.wait(attackDuration)
                
                combatState.Attacking.Value = false
                
                -- Cooldown
                if not improvements.noCooldown then
                    local cooldownTime = improvements.optimizedAttack and 0.2 or 0.5
                    task.wait(cooldownTime)
                end
                
                combatState.AttackCooldown.Value = false
            end)
        end
    end
    
    -- Input handling
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F then
            enhancedAttack()
        elseif input.KeyCode == Enum.KeyCode.G then
            if combatState:FindFirstChild("Blocking") then
                combatState.Blocking.Value = not combatState.Blocking.Value
            end
        end
    end)
end

-- Conectar eventos
player.Chatted:Connect(handleChatCommand)

player.CharacterAdded:Connect(function()
    wait(1) -- Aguardar carregamento completo
    setupEnhancedCombat()
end)

-- Setup inicial
if player.Character then
    setupEnhancedCombat()
end

-- Criar interface
createCommandInterface()

print("=== SISTEMA DE COMBATE MELHORADO CARREGADO ===")
print("Pressione F para atacar, G para bloquear")
print("Use !melhoria help para ver todos os comandos")
print("Interface gráfica disponível no canto superior esquerdo")

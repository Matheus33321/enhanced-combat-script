-- Combat System Admin Menu
-- Carregue via: loadstring(game:HttpGet("https://raw.githubusercontent.com/seu-usuario/seu-repo/main/admin-menu.lua"))()

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Verificar se é o dono/admin (adicione seu UserID aqui)
local ADMIN_USERIDS = {
    19017521, -- Substitua pelo seu UserID
    -- Adicione outros UserIDs de admins aqui se necessário
}

local function isAdmin(player)
    for _, id in pairs(ADMIN_USERIDS) do
        if player.UserId == id then
            return true
        end
    end
    return false
end

if not isAdmin(LocalPlayer) then
    warn("Acesso negado: Você não é um administrador.")
    return
end

-- Aguardar configuração carregar
local config = ReplicatedStorage:WaitForChild("CombatConfiguration")

-- Remover menu existente se houver
if CoreGui:FindFirstChild("CombatAdminMenu") then
    CoreGui.CombatAdminMenu:Destroy()
end

-- Criar GUI principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CombatAdminMenu"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 800, 0, 600)
mainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Adicionar borda arredondada
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Adicionar sombra
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxasset://textures/ui/InGameMenu/Dropshadow.png"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Parent = mainFrame
shadow.ZIndex = mainFrame.ZIndex - 1

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -40, 0, 50)
titleLabel.Position = UDim2.new(0, 20, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🛠️ Combat System Admin Panel"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- Botão fechar
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -40, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.BorderSizePixel = 0
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

-- ScrollingFrame para conteúdo
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -40, 1, -80)
scrollFrame.Position = UDim2.new(0, 20, 0, 60)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollFrame.Parent = mainFrame

-- Layout para scroll
local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 10)
listLayout.Parent = scrollFrame

-- Função para criar seção
local function createSection(name, order)
    local section = Instance.new("Frame")
    section.Name = name .. "Section"
    section.Size = UDim2.new(1, 0, 0, 40)
    section.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    section.BorderSizePixel = 0
    section.LayoutOrder = order
    section.Parent = scrollFrame
    
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 8)
    sectionCorner.Parent = section
    
    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Size = UDim2.new(1, -20, 1, 0)
    sectionTitle.Position = UDim2.new(0, 10, 0, 0)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Text = name
    sectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    sectionTitle.TextScaled = true
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.Parent = section
    
    return section
end

-- Função para criar controle de valor
local function createValueControl(parent, labelText, configPath, minValue, maxValue, step, order)
    local container = Instance.new("Frame")
    container.Name = labelText .. "Container"
    container.Size = UDim2.new(1, 0, 0, 60)
    container.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    container.BorderSizePixel = 0
    container.LayoutOrder = order
    container.Parent = scrollFrame
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 6)
    containerCorner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Campo de input
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.25, 0, 0.6, 0)
    textBox.Position = UDim2.new(0.45, 0, 0.2, 0)
    textBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextScaled = true
    textBox.Font = Enum.Font.Gotham
    textBox.BorderSizePixel = 0
    textBox.PlaceholderText = "Valor"
    textBox.Parent = container
    
    local textBoxCorner = Instance.new("UICorner")
    textBoxCorner.CornerRadius = UDim.new(0, 4)
    textBoxCorner.Parent = textBox
    
    -- Botão aplicar
    local applyButton = Instance.new("TextButton")
    applyButton.Size = UDim2.new(0.25, 0, 0.6, 0)
    applyButton.Position = UDim2.new(0.72, 0, 0.2, 0)
    applyButton.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
    applyButton.Text = "Aplicar"
    applyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    applyButton.TextScaled = true
    applyButton.Font = Enum.Font.GothamBold
    applyButton.BorderSizePixel = 0
    applyButton.Parent = container
    
    local applyCorner = Instance.new("UICorner")
    applyCorner.CornerRadius = UDim.new(0, 4)
    applyCorner.Parent = applyButton
    
    -- Função para obter valor atual
    local function getCurrentValue()
        local current = config
        local path = string.split(configPath, ".")
        
        for i, part in ipairs(path) do
            if current:FindFirstChild(part) then
                current = current[part]
            else
                return nil
            end
        end
        
        if current:IsA("NumberValue") or current:IsA("IntValue") then
            return current.Value
        end
        return nil
    end
    
    -- Função para definir valor
    local function setValue(value)
        local current = config
        local path = string.split(configPath, ".")
        
        for i, part in ipairs(path) do
            if current:FindFirstChild(part) then
                current = current[part]
            else
                return false
            end
        end
        
        if current:IsA("NumberValue") or current:IsA("IntValue") then
            current.Value = value
            return true
        end
        return false
    end
    
    -- Atualizar valor inicial
    local currentValue = getCurrentValue()
    if currentValue then
        textBox.Text = tostring(currentValue)
    end
    
    -- Conectar botão
    applyButton.MouseButton1Click:Connect(function()
        local inputValue = tonumber(textBox.Text)
        if inputValue then
            if minValue and inputValue < minValue then
                inputValue = minValue
            elseif maxValue and inputValue > maxValue then
                inputValue = maxValue
            end
            
            if setValue(inputValue) then
                textBox.Text = tostring(inputValue)
                -- Feedback visual
                local originalColor = applyButton.BackgroundColor3
                applyButton.BackgroundColor3 = Color3.fromRGB(25, 135, 84)
                wait(0.2)
                applyButton.BackgroundColor3 = originalColor
            end
        else
            -- Erro - feedback visual
            local originalColor = applyButton.BackgroundColor3
            applyButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
            wait(0.2)
            applyButton.BackgroundColor3 = originalColor
        end
    end)
    
    return container
end

-- Função para criar controle de range (para ataques)
local function createRangeControl(parent, labelText, basePath, comboCount, order)
    local container = Instance.new("Frame")
    container.Name = labelText .. "Container"
    container.Size = UDim2.new(1, 0, 0, 120)
    container.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    container.BorderSizePixel = 0
    container.LayoutOrder = order
    container.Parent = scrollFrame
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 6)
    containerCorner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 30)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Criar controles para cada combo
    for i = 1, comboCount do
        local comboContainer = Instance.new("Frame")
        comboContainer.Size = UDim2.new(1, -20, 0, 25)
        comboContainer.Position = UDim2.new(0, 10, 0, 30 + (i-1) * 30)
        comboContainer.BackgroundTransparency = 1
        comboContainer.Parent = container
        
        local comboLabel = Instance.new("TextLabel")
        comboLabel.Size = UDim2.new(0.3, 0, 1, 0)
        comboLabel.Position = UDim2.new(0, 0, 0, 0)
        comboLabel.BackgroundTransparency = 1
        comboLabel.Text = "Combo " .. i .. ":"
        comboLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        comboLabel.TextScaled = true
        comboLabel.Font = Enum.Font.Gotham
        comboLabel.TextXAlignment = Enum.TextXAlignment.Left
        comboLabel.Parent = comboContainer
        
        local comboTextBox = Instance.new("TextBox")
        comboTextBox.Size = UDim2.new(0.35, 0, 0.8, 0)
        comboTextBox.Position = UDim2.new(0.35, 0, 0.1, 0)
        comboTextBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        comboTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        comboTextBox.TextScaled = true
        comboTextBox.Font = Enum.Font.Gotham
        comboTextBox.BorderSizePixel = 0
        comboTextBox.Parent = comboContainer
        
        local comboTextBoxCorner = Instance.new("UICorner")
        comboTextBoxCorner.CornerRadius = UDim.new(0, 3)
        comboTextBoxCorner.Parent = comboTextBox
        
        local comboApplyButton = Instance.new("TextButton")
        comboApplyButton.Size = UDim2.new(0.25, 0, 0.8, 0)
        comboApplyButton.Position = UDim2.new(0.72, 0, 0.1, 0)
        comboApplyButton.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
        comboApplyButton.Text = "Aplicar"
        comboApplyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        comboApplyButton.TextScaled = true
        comboApplyButton.Font = Enum.Font.Gotham
        comboApplyButton.BorderSizePixel = 0
        comboApplyButton.Parent = comboContainer
        
        local comboApplyCorner = Instance.new("UICorner")
        comboApplyCorner.CornerRadius = UDim.new(0, 3)
        comboApplyCorner.Parent = comboApplyButton
        
        -- Funções para este combo específico
        local function getCurrentComboValue()
            local path = config[basePath][tostring(i)]
            if path and path:IsA("NumberValue") then
                return path.Value
            end
            return nil
        end
        
        local function setComboValue(value)
            local path = config[basePath][tostring(i)]
            if path and path:IsA("NumberValue") then
                path.Value = value
                return true
            end
            return false
        end
        
        -- Definir valor inicial
        local currentValue = getCurrentComboValue()
        if currentValue then
            comboTextBox.Text = tostring(currentValue)
        end
        
        -- Conectar botão
        comboApplyButton.MouseButton1Click:Connect(function()
            local inputValue = tonumber(comboTextBox.Text)
            if inputValue and inputValue >= 0 then
                if setComboValue(inputValue) then
                    comboTextBox.Text = tostring(inputValue)
                    -- Feedback visual
                    local originalColor = comboApplyButton.BackgroundColor3
                    comboApplyButton.BackgroundColor3 = Color3.fromRGB(25, 135, 84)
                    wait(0.2)
                    comboApplyButton.BackgroundColor3 = originalColor
                end
            else
                -- Erro - feedback visual
                local originalColor = comboApplyButton.BackgroundColor3
                comboApplyButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
                wait(0.2)
                comboApplyButton.BackgroundColor3 = originalColor
            end
        end)
    end
    
    return container
end

-- Criar seções e controles
local orderCounter = 0

-- Seção de Ataque
createSection("⚔️ Sistema de Ataque", orderCounter)
orderCounter = orderCounter + 1

createRangeControl(scrollFrame, "🎯 Alcance dos Ataques (Studs)", "Attacking.Ranges", 4, orderCounter)
orderCounter = orderCounter + 1

createRangeControl(scrollFrame, "💥 Dano por Combo", "Damage.ComboDamage", 4, orderCounter)
orderCounter = orderCounter + 1

createRangeControl(scrollFrame, "⏱️ Cooldown dos Ataques (Segundos)", "Attacking.Cooldowns", 4, orderCounter)
orderCounter = orderCounter + 1

createValueControl(scrollFrame, "⚡ Custo de Stamina por Ataque", "Stamina.AttackStaminaCost", 0, 100, 1, orderCounter)
orderCounter = orderCounter + 1

createValueControl(scrollFrame, "🎲 Chance de Crítico (%)", "Damage.CriticalHitChance", 0, 100, 1, orderCounter)
orderCounter = orderCounter + 1

createValueControl(scrollFrame, "💀 Multiplicador de Crítico", "Damage.CriticalHitMultiplier", 1, 10, 0.1, orderCounter)
orderCounter = orderCounter + 1

-- Seção de Defesa
createSection("🛡️ Sistema de Defesa", orderCounter)
orderCounter = orderCounter + 1

createValueControl(scrollFrame, "❤️ Vida Máxima do Bloqueio", "Blocking.MaxHealth", 1, 1000, 1, orderCounter)
orderCounter = orderCounter + 1

createValueControl(scrollFrame, "🔄 Taxa de Regeneração do Bloqueio", "Blocking.HealRate", 0.1, 50, 0.1, orderCounter)
orderCounter = orderCounter + 1

createValueControl(scrollFrame, "🛡️ Absorção de Dano (%)", "Blocking.DamageAbsorption", 0, 1, 0.01, orderCounter)
orderCounter = orderCounter + 1

createValueControl(scrollFrame, "👟 Velocidade Caminhando (Bloqueando)", "Blocking.WalkSpeed", 0, 50, 1, orderCounter)
orderCounter = orderCounter + 1

createValueControl(scrollFrame, "🏃 Velocidade Correndo (Bloqueando)", "Blocking.RunSpeed", 0, 50, 1, orderCounter)
orderCounter = orderCounter + 1

-- Seção de Movimento
createSection("🏃 Sistema de Movimento", orderCounter)
orderCounter = orderCounter + 1

createValueControl(scrollFrame, "🚶 Velocidade de Caminhada", "Walking.Speed", 0, 50, 1, orderCounter)
orderCounter = orderCounter + 1

createValueControl(scrollFrame, "💨 Velocidade de Corrida", "Running.Speed", 0, 100, 1, orderCounter)
orderCounter = orderCounter + 1

createValueControl(scrollFrame, "⚡ Stamina Máxima", "Stamina.MaxStamina", 1, 1000, 1, orderCounter)
orderCounter = orderCounter + 1

createValueControl(scrollFrame, "📉 Taxa de Diminuição de Stamina", "Stamina.StaminaDecreaseRate", 0.1, 100, 0.1, orderCounter)
orderCounter = orderCounter + 1

createValueControl(scrollFrame, "📈 Taxa de Aumento de Stamina", "Stamina.StaminaIncreaseRate", 0.1, 100, 0.1, orderCounter)
orderCounter = orderCounter + 1

-- Seção de Combo
createSection("🔥 Sistema de Combo", orderCounter)
orderCounter = orderCounter + 1

createValueControl(scrollFrame, "⏰ Tempo de Expiração do Combo", "Combo.ExpireTime", 0.1, 10, 0.1, orderCounter)
orderCounter = orderCounter + 1

-- Seção de Knockback
createSection("💢 Sistema de Knockback", orderCounter)
orderCounter = orderCounter + 1

createRangeControl(scrollFrame, "🌊 Força do Knockback por Combo", "Knockback.ComboKnockback", 4, orderCounter)
orderCounter = orderCounter + 1

-- Seção de Stun
createSection("😵 Sistema de Stun", orderCounter)
orderCounter = orderCounter + 1

createRangeControl(scrollFrame, "⏱️ Duração do Stun por Combo", "Stunned.StunDurations", 4, orderCounter)
orderCounter = orderCounter + 1

-- Botão de Reset Geral
local resetButton = Instance.new("TextButton")
resetButton.Name = "ResetButton"
resetButton.Size = UDim2.new(1, 0, 0, 50)
resetButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
resetButton.Text = "🔄 RESETAR TODAS AS CONFIGURAÇÕES"
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.TextScaled = true
resetButton.Font = Enum.Font.GothamBold
resetButton.BorderSizePixel = 0
resetButton.LayoutOrder = orderCounter
resetButton.Parent = scrollFrame

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 6)
resetCorner.Parent = resetButton

-- Funcionalidade do botão reset (implementar conforme necessário)
resetButton.MouseButton1Click:Connect(function()
    warn("Função de reset não implementada - adicione os valores padrão aqui")
end)

-- Atualizar tamanho do canvas
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
end)

-- Funcionalidade de fechar
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Drag functionality
local dragging = false
local dragStart = nil
local startPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Animação de entrada
mainFrame.Position = UDim2.new(0.5, -400, 1.5, 0)
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tween = TweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(0.5, -400, 0.5, -300)})
tween:Play()

print("✅ Combat Admin Menu carregado com sucesso!")
print("📝 Substitua o UserID na linha 15 pelo seu UserID real")
print("🔧 Menu disponível apenas para administadores autorizados")

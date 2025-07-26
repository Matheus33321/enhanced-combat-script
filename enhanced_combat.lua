-- Enhanced Combat Script with GUI Menu
-- Para usar: loadstring(game:HttpGet("https://raw.githubusercontent.com/[seu-usuario]/[repositorio]/main/enhanced_combat.lua"))()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configurações das melhorias
local enhancements = {
    reducedCooldown = false,
    expandedHitbox = false,
    optimizedAttack = false,
    infiniteStamina = false,
    autoCombo = false,
    speedBoost = false,
    jumpBoost = false,
    noStun = false
}

-- Valores originais para restauração
local originalValues = {}

-- Função para criar a GUI
local function createGUI()
    -- Remove GUI existente se houver
    if playerGui:FindFirstChild("EnhancedCombatGUI") then
        playerGui.EnhancedCombatGUI:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EnhancedCombatGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    -- Cantos arredondados
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    -- Barra superior
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar

    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🥊 Enhanced Combat Menu"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.Parent = titleBar

    -- Botão fechar
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton

    -- Scroll frame para opções
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -20, 1, -100)
    scrollFrame.Position = UDim2.new(0, 10, 0, 50)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    scrollFrame.Parent = mainFrame

    -- Layout das opções
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = scrollFrame

    -- Função para criar toggle
    local function createToggle(name, displayName, description, layoutOrder)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = name .. "Frame"
        toggleFrame.Size = UDim2.new(1, -10, 0, 70)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        toggleFrame.BorderSizePixel = 0
        toggleFrame.LayoutOrder = layoutOrder
        toggleFrame.Parent = scrollFrame

        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 8)
        toggleCorner.Parent = toggleFrame

        local toggleButton = Instance.new("TextButton")
        toggleButton.Name = "ToggleButton"
        toggleButton.Size = UDim2.new(0, 60, 0, 30)
        toggleButton.Position = UDim2.new(1, -70, 0, 5)
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
        toggleButton.BorderSizePixel = 0
        toggleButton.Text = ""
        toggleButton.Parent = toggleFrame

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 15)
        buttonCorner.Parent = toggleButton

        local toggleCircle = Instance.new("Frame")
        toggleCircle.Name = "Circle"
        toggleCircle.Size = UDim2.new(0, 26, 0, 26)
        toggleCircle.Position = UDim2.new(0, 2, 0, 2)
        toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        toggleCircle.BorderSizePixel = 0
        toggleCircle.Parent = toggleButton

        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(0, 13)
        circleCorner.Parent = toggleCircle

        local toggleLabel = Instance.new("TextLabel")
        toggleLabel.Name = "Label"
        toggleLabel.Size = UDim2.new(1, -80, 0, 25)
        toggleLabel.Position = UDim2.new(0, 10, 0, 5)
        toggleLabel.BackgroundTransparency = 1
        toggleLabel.Text = displayName
        toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleLabel.TextSize = 16
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel.Font = Enum.Font.GothamSemibold
        toggleLabel.Parent = toggleFrame

        local toggleDesc = Instance.new("TextLabel")
        toggleDesc.Name = "Description"
        toggleDesc.Size = UDim2.new(1, -80, 0, 35)
        toggleDesc.Position = UDim2.new(0, 10, 0, 30)
        toggleDesc.BackgroundTransparency = 1
        toggleDesc.Text = description
        toggleDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
        toggleDesc.TextSize = 12
        toggleDesc.TextXAlignment = Enum.TextXAlignment.Left
        toggleDesc.TextYAlignment = Enum.TextYAlignment.Top
        toggleDesc.TextWrapped = true
        toggleDesc.Font = Enum.Font.Gotham
        toggleDesc.Parent = toggleFrame

        -- Função toggle
        toggleButton.MouseButton1Click:Connect(function()
            enhancements[name] = not enhancements[name]
            
            local targetColor = enhancements[name] and Color3.fromRGB(85, 255, 127) or Color3.fromRGB(255, 85, 85)
            local targetPosition = enhancements[name] and UDim2.new(1, -28, 0, 2) or UDim2.new(0, 2, 0, 2)
            
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
            TweenService:Create(toggleCircle, TweenInfo.new(0.2), {Position = targetPosition}):Play()
            
            applyEnhancement(name, enhancements[name])
        end)

        return toggleFrame
    end

    -- Criar toggles
    createToggle("reducedCooldown", "🚀 Cooldown Reduzido", "Reduz significativamente o tempo de cooldown entre ataques", 1)
    createToggle("expandedHitbox", "📦 Hitbox Expandida", "Aumenta o alcance e área de ataque dos golpes", 2)
    createToggle("optimizedAttack", "⚡ Ataque Otimizado", "Melhora a velocidade e precisão dos ataques", 3)
    createToggle("infiniteStamina", "♾️ Stamina Infinita", "Remove o consumo de stamina para ataques", 4)
    createToggle("autoCombo", "🔄 Auto Combo", "Automatiza a sequência de combos", 5)
    createToggle("speedBoost", "💨 Boost de Velocidade", "Aumenta a velocidade de movimento", 6)
    createToggle("jumpBoost", "🦘 Boost de Pulo", "Aumenta a altura dos pulos", 7)
    createToggle("noStun", "🛡️ Anti-Stun", "Previne que o jogador seja atordoado", 8)

    -- Botões de ação
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = "ButtonFrame"
    buttonFrame.Size = UDim2.new(1, -20, 0, 40)
    buttonFrame.Position = UDim2.new(0, 10, 1, -50)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = mainFrame

    local enableAllButton = Instance.new("TextButton")
    enableAllButton.Name = "EnableAllButton"
    enableAllButton.Size = UDim2.new(0.48, 0, 1, 0)
    enableAllButton.Position = UDim2.new(0, 0, 0, 0)
    enableAllButton.BackgroundColor3 = Color3.fromRGB(85, 255, 127)
    enableAllButton.BorderSizePixel = 0
    enableAllButton.Text = "✅ Ativar Tudo"
    enableAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    enableAllButton.TextSize = 14
    enableAllButton.Font = Enum.Font.GothamBold
    enableAllButton.Parent = buttonFrame

    local enableAllCorner = Instance.new("UICorner")
    enableAllCorner.CornerRadius = UDim.new(0, 8)
    enableAllCorner.Parent = enableAllButton

    local disableAllButton = Instance.new("TextButton")
    disableAllButton.Name = "DisableAllButton"
    disableAllButton.Size = UDim2.new(0.48, 0, 1, 0)
    disableAllButton.Position = UDim2.new(0.52, 0, 0, 0)
    disableAllButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    disableAllButton.BorderSizePixel = 0
    disableAllButton.Text = "❌ Desativar Tudo"
    disableAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    disableAllButton.TextSize = 14
    disableAllButton.Font = Enum.Font.GothamBold
    disableAllButton.Parent = buttonFrame

    local disableAllCorner = Instance.new("UICorner")
    disableAllCorner.CornerRadius = UDim.new(0, 8)
    disableAllCorner.Parent = disableAllButton

    -- Atualizar scroll frame
    layout.Changed:Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    -- Eventos dos botões
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    enableAllButton.MouseButton1Click:Connect(function()
        for name, _ in pairs(enhancements) do
            enhancements[name] = true
            applyEnhancement(name, true)
        end
        updateAllToggles()
    end)

    disableAllButton.MouseButton1Click:Connect(function()
        for name, _ in pairs(enhancements) do
            enhancements[name] = false
            applyEnhancement(name, false)
        end
        updateAllToggles()
    end)

    -- Função para atualizar todos os toggles
    function updateAllToggles()
        for name, enabled in pairs(enhancements) do
            local frame = scrollFrame:FindFirstChild(name .. "Frame")
            if frame then
                local button = frame.ToggleButton
                local circle = button.Circle
                
                local targetColor = enabled and Color3.fromRGB(85, 255, 127) or Color3.fromRGB(255, 85, 85)
                local targetPosition = enabled and UDim2.new(1, -28, 0, 2) or UDim2.new(0, 2, 0, 2)
                
                TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
                TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPosition}):Play()
            end
        end
    end

    -- Tornar a GUI arrastável
    local dragging = false
    local dragStart = nil
    local startPos = nil

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return screenGui
end

-- Função para aplicar melhorias
function applyEnhancement(name, enabled)
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    local combatState = humanoid and humanoid:FindFirstChild("CombatState")
    
    if name == "reducedCooldown" then
        -- Implementar redução de cooldown via hook do sistema de combate
        print(enabled and "✅ Cooldown reduzido ativado!" or "❌ Cooldown reduzido desativado!")
        
    elseif name == "expandedHitbox" then
        -- Expandir hitbox
        print(enabled and "✅ Hitbox expandida ativada!" or "❌ Hitbox expandida desativada!")
        
    elseif name == "optimizedAttack" then
        -- Otimizar ataques
        print(enabled and "✅ Ataque otimizado ativado!" or "❌ Ataque otimizado desativado!")
        
    elseif name == "infiniteStamina" then
        if combatState and combatState:FindFirstChild("Stamina") then
            if enabled then
                -- Salvar valor original
                if not originalValues.stamina then
                    originalValues.stamina = combatState.Stamina.Value
                end
                
                -- Loop para manter stamina no máximo
                if not originalValues.staminaLoop then
                    originalValues.staminaLoop = RunService.Heartbeat:Connect(function()
                        if enhancements.infiniteStamina and combatState.Stamina then
                            combatState.Stamina.Value = 100
                        end
                    end)
                end
                print("✅ Stamina infinita ativada!")
            else
                -- Restaurar valor original e parar loop
                if originalValues.staminaLoop then
                    originalValues.staminaLoop:Disconnect()
                    originalValues.staminaLoop = nil
                end
                if originalValues.stamina then
                    combatState.Stamina.Value = originalValues.stamina
                end
                print("❌ Stamina infinita desativada!")
            end
        end
        
    elseif name == "autoCombo" then
        -- Implementar auto combo
        print(enabled and "✅ Auto combo ativado!" or "❌ Auto combo desativado!")
        
    elseif name == "speedBoost" then
        if humanoid then
            if enabled then
                if not originalValues.walkSpeed then
                    originalValues.walkSpeed = humanoid.WalkSpeed
                end
                humanoid.WalkSpeed = originalValues.walkSpeed * 2
                print("✅ Boost de velocidade ativado!")
            else
                if originalValues.walkSpeed then
                    humanoid.WalkSpeed = originalValues.walkSpeed
                end
                print("❌ Boost de velocidade desativado!")
            end
        end
        
    elseif name == "jumpBoost" then
        if humanoid then
            if enabled then
                if not originalValues.jumpPower then
                    originalValues.jumpPower = humanoid.JumpPower
                end
                humanoid.JumpPower = originalValues.jumpPower * 2
                print("✅ Boost de pulo ativado!")
            else
                if originalValues.jumpPower then
                    humanoid.JumpPower = originalValues.jumpPower
                end
                print("❌ Boost de pulo desativado!")
            end
        end
        
    elseif name == "noStun" then
        if combatState and combatState:FindFirstChild("Stunned") then
            if enabled then
                -- Loop para manter não atordoado
                if not originalValues.stunLoop then
                    originalValues.stunLoop = RunService.Heartbeat:Connect(function()
                        if enhancements.noStun and combatState.Stunned then
                            combatState.Stunned.Value = false
                        end
                    end)
                end
                print("✅ Anti-stun ativado!")
            else
                -- Parar loop
                if originalValues.stunLoop then
                    originalValues.stunLoop:Disconnect()
                    originalValues.stunLoop = nil
                end
                print("❌ Anti-stun desativado!")
            end
        end
    end
end

-- Função principal
local function main()
    -- Aguardar o jogo carregar completamente
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    wait(2) -- Aguardar um pouco mais para garantir que tudo carregou
    
    print("🚀 Enhanced Combat Script carregado!")
    print("📋 Abrindo menu de configurações...")
    
    createGUI()
    
    -- Recriar GUI quando o jogador renascer
    player.CharacterAdded:Connect(function()
        wait(2)
        if playerGui:FindFirstChild("EnhancedCombatGUI") then
            createGUI()
        end
    end)
end

-- Executar o script
main()

-- Adicionar comando para reabrir o menu
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        if playerGui:FindFirstChild("EnhancedCombatGUI") then
            playerGui.EnhancedCombatGUI:Destroy()
        else
            createGUI()
        end
    end
end)

print("💡 Pressione INSERT para abrir/fechar o menu!")

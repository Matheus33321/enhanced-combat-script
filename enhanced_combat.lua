-- Enhanced Combat System - Versão Ultra Básica
-- Para executar: loadstring(game:HttpGet("https://raw.githubusercontent.com/Matheus33321/enhanced-combat-script/main/enhanced_combat.lua"))()

local success, result = pcall(function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    
    local player = Players.LocalPlayer
    
    -- Limpar qualquer UI existente
    for _, gui in pairs(player.PlayerGui:GetChildren()) do
        if gui.Name == "EnhancedCombatUI" then
            gui:Destroy()
        end
    end
    
    -- Verificar se já está carregado
    if _G.CombatSystemLoaded then
        _G.CombatSystemLoaded = false
        task.wait(0.5)
    end
    _G.CombatSystemLoaded = true
    
    print("🔥 CARREGANDO SISTEMA ULTRA BÁSICO...")
    
    -- Aguardar configurações
    local config = ReplicatedStorage:WaitForChild("CombatConfiguration", 10)
    if not config then
        warn("❌ CombatConfiguration não encontrada!")
        return
    end
    print("✅ CombatConfiguration encontrada")
    
    -- Configurações das melhorias
    local improvements = {
        noCooldown = false,
        expandedHitbox = false,
        autoStamina = false,
        removeStun = false
    }
    
    -- Valores originais
    local originalValues = {}
    
    -- Salvar valores originais
    local function saveOriginalValues()
        if config.Attacking and config.Attacking.Cooldowns then
            originalValues.cooldowns = {}
            for _, cooldown in pairs(config.Attacking.Cooldowns:GetChildren()) do
                if cooldown:IsA("NumberValue") then
                    originalValues.cooldowns[cooldown.Name] = cooldown.Value
                end
            end
        end
        
        if config.Attacking and config.Attacking.Ranges then
            originalValues.ranges = {}
            for _, range in pairs(config.Attacking.Ranges:GetChildren()) do
                if range:IsA("NumberValue") then
                    originalValues.ranges[range.Name] = range.Value
                end
            end
        end
        print("💾 Valores salvos")
    end
    
    -- Aplicar melhorias
    local function applyImprovements()
        task.spawn(function()
            while _G.CombatSystemLoaded do
                -- Sem Cooldown
                if improvements.noCooldown and config.Attacking and config.Attacking.Cooldowns then
                    for _, cooldown in pairs(config.Attacking.Cooldowns:GetChildren()) do
                        if cooldown:IsA("NumberValue") then
                            cooldown.Value = 0
                        end
                    end
                end
                
                -- Hitbox Expandida
                if improvements.expandedHitbox and config.Attacking and config.Attacking.Ranges then
                    for _, range in pairs(config.Attacking.Ranges:GetChildren()) do
                        if range:IsA("NumberValue") and originalValues.ranges then
                            range.Value = originalValues.ranges[range.Name] * 3 or 25
                        end
                    end
                end
                
                -- Stamina Infinita
                if improvements.autoStamina and config.Stamina then
                    if config.Stamina.AttackStaminaCost then
                        config.Stamina.AttackStaminaCost.Value = 0
                    end
                    if config.Stamina.StaminaDecreaseRate then
                        config.Stamina.StaminaDecreaseRate.Value = 0
                    end
                end
                
                -- Sem Stun
                if improvements.removeStun and config.Stunned and config.Stunned.StunDurations then
                    for _, stun in pairs(config.Stunned.StunDurations:GetChildren()) do
                        if stun:IsA("NumberValue") then
                            stun.Value = 0
                        end
                    end
                end
                
                task.wait(0.2)
            end
        end)
    end
    
    -- Interface MINIMALISTA (sem erros)
    local function createBasicUI()
        print("🎨 Criando UI básica...")
        
        -- ScreenGui simples
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "EnhancedCombatUI"
        screenGui.ResetOnSpawn = false
        
        -- Frame principal sem elementos complicados
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 350, 0, 400)
        mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
        mainFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        mainFrame.BorderSizePixel = 3
        mainFrame.BorderColor3 = Color3.new(0, 1, 0)
        mainFrame.Active = true
        mainFrame.Draggable = true
        mainFrame.Parent = screenGui
        
        -- Título simples
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 40)
        title.Position = UDim2.new(0, 0, 0, 0)
        title.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
        title.BorderSizePixel = 0
        title.Text = "ENHANCED COMBAT SYSTEM"
        title.TextColor3 = Color3.new(0, 1, 0)
        title.TextScaled = true
        title.Font = Enum.Font.SourceSansBold
        title.Parent = mainFrame
        
        -- Função para criar botão básico
        local function createBasicButton(text, yPos, improvement)
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(0, 300, 0, 35)
            button.Position = UDim2.new(0, 25, 0, yPos)
            button.BackgroundColor3 = improvements[improvement] and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0)
            button.BorderSizePixel = 1
            button.BorderColor3 = Color3.new(1, 1, 1)
            button.Text = text .. " - " .. (improvements[improvement] and "ON" or "OFF")
            button.TextColor3 = Color3.new(1, 1, 1)
            button.TextScaled = true
            button.Font = Enum.Font.SourceSansBold
            button.Parent = mainFrame
            
            button.MouseButton1Click:Connect(function()
                improvements[improvement] = not improvements[improvement]
                button.BackgroundColor3 = improvements[improvement] and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0)
                button.Text = text .. " - " .. (improvements[improvement] and "ON" or "OFF")
                print("🔧 " .. text .. ": " .. (improvements[improvement] and "ATIVADO" or "DESATIVADO"))
            end)
            
            return button
        end
        
        -- Criar botões básicos
        createBasicButton("SEM COOLDOWN", 60, "noCooldown")
        createBasicButton("HITBOX 3X MAIOR", 110, "expandedHitbox")
        createBasicButton("STAMINA INFINITA", 160, "autoStamina")
        createBasicButton("SEM STUN", 210, "removeStun")
        
        -- Botão de teste
        local testBtn = Instance.new("TextButton")
        testBtn.Size = UDim2.new(0, 300, 0, 35)
        testBtn.Position = UDim2.new(0, 25, 0, 270)
        testBtn.BackgroundColor3 = Color3.new(0, 0, 1)
        testBtn.BorderSizePixel = 1
        testBtn.BorderColor3 = Color3.new(1, 1, 0)
        testBtn.Text = "CLIQUE PARA TESTAR UI"
        testBtn.TextColor3 = Color3.new(1, 1, 1)
        testBtn.TextScaled = true
        testBtn.Font = Enum.Font.SourceSansBold
        testBtn.Parent = mainFrame
        
        testBtn.MouseButton1Click:Connect(function()
            testBtn.Text = "UI FUNCIONANDO!"
            testBtn.BackgroundColor3 = Color3.new(0, 1, 0)
            print("✅ UI TESTE PASSOU!")
        end)
        
        -- Botão para ativar tudo
        local allBtn = Instance.new("TextButton")
        allBtn.Size = UDim2.new(0, 300, 0, 35)
        allBtn.Position = UDim2.new(0, 25, 0, 320)
        allBtn.BackgroundColor3 = Color3.new(1, 0.5, 0)
        allBtn.BorderSizePixel = 1
        allBtn.BorderColor3 = Color3.new(1, 1, 1)
        allBtn.Text = "ATIVAR TODAS AS MELHORIAS"
        allBtn.TextColor3 = Color3.new(1, 1, 1)
        allBtn.TextScaled = true
        allBtn.Font = Enum.Font.SourceSansBold
        allBtn.Parent = mainFrame
        
        allBtn.MouseButton1Click:Connect(function()
            local allActive = improvements.noCooldown and improvements.expandedHitbox and improvements.autoStamina and improvements.removeStun
            
            for key, _ in pairs(improvements) do
                improvements[key] = not allActive
            end
            
            -- Atualizar todos os botões
            for _, child in pairs(mainFrame:GetChildren()) do
                if child:IsA("TextButton") and child ~= testBtn and child ~= allBtn then
                    local improvement = child.Name:match("noCooldown") and "noCooldown" or
                                      child.Name:match("expandedHitbox") and "expandedHitbox" or
                                      child.Name:match("autoStamina") and "autoStamina" or
                                      child.Name:match("removeStun") and "removeStun"
                    
                    if improvement then
                        child.BackgroundColor3 = improvements[improvement] and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0)
                    end
                end
            end
            
            allBtn.Text = (not allActive) and "DESATIVAR TODAS" or "ATIVAR TODAS AS MELHORIAS"
            print("🔧 TODAS AS MELHORIAS: " .. ((not allActive) and "ATIVADAS" or "DESATIVADAS"))
        end)
        
        -- Adicionar ao PlayerGui
        screenGui.Parent = player.PlayerGui
        
        task.wait(0.1)
        print("✅ UI criada no centro da tela!")
        return screenGui
    end
    
    -- Comandos de chat simples
    player.Chatted:Connect(function(message)
        local msg = string.lower(message)
        if msg == "!ui" or msg == "!combat" then
            createBasicUI()
            print("🎨 UI recriada!")
        elseif msg == "!test" then
            print("=== TESTE ===")
            print("UI existe:", player.PlayerGui:FindFirstChild("EnhancedCombatUI") ~= nil)
            for key, value in pairs(improvements) do
                print(key .. ":", value and "ATIVO" or "INATIVO")
            end
        end
    end)
    
    -- Inicializar
    task.wait(1)
    saveOriginalValues()
    createBasicUI()
    applyImprovements()
    
    print("⚔️ SISTEMA CARREGADO!")
    print("💬 Digite !ui para recriar interface")
    print("💬 Digite !test para verificar status")
    
    return true
end)

if not success then
    warn("❌ ERRO:", tostring(result))
else
    print("✅ SUCESSO TOTAL!")
end

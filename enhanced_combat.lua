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
        pcall(function()
            if config:FindFirstChild("Attacking") and config.Attacking:FindFirstChild("Cooldowns") then
                originalValues.cooldowns = {}
                for _, cooldown in pairs(config.Attacking.Cooldowns:GetChildren()) do
                    if cooldown:IsA("NumberValue") then
                        originalValues.cooldowns[cooldown.Name] = cooldown.Value
                        print("💾 Salvou cooldown:", cooldown.Name, "=", cooldown.Value)
                    end
                end
            end
            
            if config:FindFirstChild("Attacking") and config.Attacking:FindFirstChild("Ranges") then
                originalValues.ranges = {}
                for _, range in pairs(config.Attacking.Ranges:GetChildren()) do
                    if range:IsA("NumberValue") then
                        originalValues.ranges[range.Name] = range.Value
                        print("💾 Salvou range:", range.Name, "=", range.Value)
                    end
                end
            end
            
            if config:FindFirstChild("Stamina") then
                if config.Stamina:FindFirstChild("AttackStaminaCost") then
                    originalValues.staminaCost = config.Stamina.AttackStaminaCost.Value
                    print("💾 Salvou stamina cost:", originalValues.staminaCost)
                end
            end
            
            if config:FindFirstChild("Stunned") and config.Stunned:FindFirstChild("StunDurations") then
                originalValues.stunDurations = {}
                for _, stun in pairs(config.Stunned.StunDurations:GetChildren()) do
                    if stun:IsA("NumberValue") then
                        originalValues.stunDurations[stun.Name] = stun.Value
                        print("💾 Salvou stun:", stun.Name, "=", stun.Value)
                    end
                end
            end
        end)
        print("💾 Valores originais salvos!")
    end
    
    -- Aplicar melhorias
    local function applyImprovements()
        task.spawn(function()
            while _G.CombatSystemLoaded do
                pcall(function()
                    -- Sem Cooldown
                    if improvements.noCooldown then
                        if config:FindFirstChild("Attacking") and config.Attacking:FindFirstChild("Cooldowns") then
                            for _, cooldown in pairs(config.Attacking.Cooldowns:GetChildren()) do
                                if cooldown:IsA("NumberValue") then
                                    cooldown.Value = 0.01 -- Quase zero
                                    print("🚀 Cooldown zerado:", cooldown.Name)
                                end
                            end
                        end
                    else
                        -- Restaurar cooldowns originais
                        if originalValues.cooldowns then
                            for name, value in pairs(originalValues.cooldowns) do
                                local cooldown = config.Attacking.Cooldowns:FindFirstChild(name)
                                if cooldown and cooldown:IsA("NumberValue") then
                                    cooldown.Value = value
                                end
                            end
                        end
                    end
                    
                    -- Hitbox Expandida
                    if improvements.expandedHitbox then
                        if config:FindFirstChild("Attacking") and config.Attacking:FindFirstChild("Ranges") then
                            for _, range in pairs(config.Attacking.Ranges:GetChildren()) do
                                if range:IsA("NumberValue") and originalValues.ranges and originalValues.ranges[range.Name] then
                                    range.Value = originalValues.ranges[range.Name] * 3
                                    print("🎯 Range expandido:", range.Name, "para", range.Value)
                                end
                            end
                        end
                    else
                        -- Restaurar ranges originais
                        if originalValues.ranges then
                            for name, value in pairs(originalValues.ranges) do
                                local range = config.Attacking.Ranges:FindFirstChild(name)
                                if range and range:IsA("NumberValue") then
                                    range.Value = value
                                end
                            end
                        end
                    end
                    
                    -- Stamina Infinita
                    if improvements.autoStamina then
                        if config:FindFirstChild("Stamina") then
                            if config.Stamina:FindFirstChild("AttackStaminaCost") then
                                config.Stamina.AttackStaminaCost.Value = 0
                                print("♾️ Stamina cost zerado")
                            end
                            if config.Stamina:FindFirstChild("StaminaDecreaseRate") then
                                config.Stamina.StaminaDecreaseRate.Value = 0
                                print("♾️ Stamina decrease zerado")
                            end
                            if config.Stamina:FindFirstChild("StaminaIncreaseRate") then
                                config.Stamina.StaminaIncreaseRate.Value = 1000
                                print("♾️ Stamina regen aumentado")
                            end
                        end
                    else
                        -- Restaurar stamina original
                        if originalValues.staminaCost and config.Stamina and config.Stamina:FindFirstChild("AttackStaminaCost") then
                            config.Stamina.AttackStaminaCost.Value = originalValues.staminaCost
                        end
                    end
                    
                    -- Sem Stun
                    if improvements.removeStun then
                        if config:FindFirstChild("Stunned") and config.Stunned:FindFirstChild("StunDurations") then
                            for _, stun in pairs(config.Stunned.StunDurations:GetChildren()) do
                                if stun:IsA("NumberValue") then
                                    stun.Value = 0.01 -- Quase zero
                                    print("🛡️ Stun removido:", stun.Name)
                                end
                            end
                        end
                    else
                        -- Restaurar stuns originais
                        if originalValues.stunDurations then
                            for name, value in pairs(originalValues.stunDurations) do
                                local stun = config.Stunned.StunDurations:FindFirstChild(name)
                                if stun and stun:IsA("NumberValue") then
                                    stun.Value = value
                                end
                            end
                        end
                    end
                end)
                
                task.wait(0.1) -- Verificar mais frequentemente
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
    
        -- Comandos de chat com debug
        player.Chatted:Connect(function(message)
            local msg = string.lower(message)
            if msg == "!ui" or msg == "!combat" then
                createBasicUI()
                print("🎨 UI recriada!")
            elseif msg == "!test" then
                print("=== TESTE COMPLETO ===")
                print("UI existe:", player.PlayerGui:FindFirstChild("EnhancedCombatUI") ~= nil)
                print("Config existe:", config ~= nil)
                
                -- Testar estrutura
                if config:FindFirstChild("Attacking") then
                    print("✅ Attacking encontrado")
                    if config.Attacking:FindFirstChild("Cooldowns") then
                        print("✅ Cooldowns encontrado, itens:", #config.Attacking.Cooldowns:GetChildren())
                    end
                    if config.Attacking:FindFirstChild("Ranges") then
                        print("✅ Ranges encontrado, itens:", #config.Attacking.Ranges:GetChildren())
                    end
                end
                
                if config:FindFirstChild("Stamina") then
                    print("✅ Stamina encontrado")
                end
                
                if config:FindFirstChild("Stunned") then
                    print("✅ Stunned encontrado")
                end
                
                print("--- STATUS DAS MELHORIAS ---")
                for key, value in pairs(improvements) do
                    print(key .. ":", value and "ATIVO" or "INATIVO")
                end
            elseif msg == "!debug" then
                print("=== DEBUG VALORES ===")
                if originalValues.cooldowns then
                    for name, value in pairs(originalValues.cooldowns) do
                        local current = config.Attacking.Cooldowns:FindFirstChild(name)
                        print("Cooldown", name .. ":", "Original =", value, "Atual =", current and current.Value or "N/A")
                    end
                end
                if originalValues.ranges then
                    for name, value in pairs(originalValues.ranges) do
                        local current = config.Attacking.Ranges:FindFirstChild(name)
                        print("Range", name .. ":", "Original =", value, "Atual =", current and current.Value or "N/A")
                    end
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

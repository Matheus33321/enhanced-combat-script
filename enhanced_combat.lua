-- Enhanced Combat System - UI Super Corrigida
-- Para executar: loadstring(game:HttpGet("https://raw.githubusercontent.com/Matheus33321/enhanced-combat-script/main/enhanced_combat.lua"))()

local success, result = pcall(function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    
    local player = Players.LocalPlayer
    
    -- Força destruir qualquer UI existente
    local function forceDestroyUI()
        for _, gui in pairs(player.PlayerGui:GetChildren()) do
            if gui.Name == "EnhancedCombatUI" then
                gui:Destroy()
                print("🗑️ UI antiga destruída:", gui.Name)
            end
        end
        task.wait(0.2)
    end
    
    -- Verificar se já está carregado
    if _G.CombatSystemLoaded then
        warn("Sistema de combate já está carregado!")
        forceDestroyUI()
        _G.CombatSystemLoaded = false
        task.wait(1)
    end
    _G.CombatSystemLoaded = true
    
    print("🔥 FORÇANDO CARREGAMENTO DO SISTEMA...")
    
    -- Aguardar configurações do jogo
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
        optimizedAttack = false,
        autoStamina = false,
        fastMovement = false,
        removeStun = false
    }
    
    -- Valores originais para restauração
    local originalValues = {}
    
    -- Função para salvar valores originais
    local function saveOriginalValues()
        pcall(function()
            if config:FindFirstChild("Attacking") and config.Attacking:FindFirstChild("Cooldowns") then
                originalValues.cooldowns = {}
                for _, cooldown in pairs(config.Attacking.Cooldowns:GetChildren()) do
                    if cooldown:IsA("NumberValue") then
                        originalValues.cooldowns[cooldown.Name] = cooldown.Value
                    end
                end
                print("💾 Cooldowns salvos:", #config.Attacking.Cooldowns:GetChildren())
            end
            
            if config:FindFirstChild("Attacking") and config.Attacking:FindFirstChild("Ranges") then
                originalValues.ranges = {}
                for _, range in pairs(config.Attacking.Ranges:GetChildren()) do
                    if range:IsA("NumberValue") then
                        originalValues.ranges[range.Name] = range.Value
                    end
                end
                print("💾 Ranges salvos:", #config.Attacking.Ranges:GetChildren())
            end
        end)
    end
    
    -- Aplicar melhorias (simplificado para debug)
    local function applyImprovements()
        task.spawn(function()
            while _G.CombatSystemLoaded do
                pcall(function()
                    if improvements.noCooldown and config:FindFirstChild("Attacking") and config.Attacking:FindFirstChild("Cooldowns") then
                        for _, cooldown in pairs(config.Attacking.Cooldowns:GetChildren()) do
                            if cooldown:IsA("NumberValue") then
                                cooldown.Value = 0
                            end
                        end
                    end
                    
                    if improvements.expandedHitbox and config:FindFirstChild("Attacking") and config.Attacking:FindFirstChild("Ranges") then
                        for _, range in pairs(config.Attacking.Ranges:GetChildren()) do
                            if range:IsA("NumberValue") then
                                range.Value = originalValues.ranges and originalValues.ranges[range.Name] and originalValues.ranges[range.Name] * 2.5 or 20
                            end
                        end
                    end
                end)
                task.wait(0.1)
            end
        end)
    end
    
    -- Interface SUPER SIMPLIFICADA para garantir que funcione
    local function createSimpleUI()
        print("🎨 CRIANDO UI SIMPLES...")
        
        -- Aguardar PlayerGui
        local playerGui = player:WaitForChild("PlayerGui")
        print("✅ PlayerGui encontrado")
        
        -- Destruir antiga
        forceDestroyUI()
        
        -- Criar ScreenGui básico
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "EnhancedCombatUI"
        screenGui.ResetOnSpawn = false
        screenGui.Enabled = true
        
        print("📱 ScreenGui criado")
        
        -- Frame principal GRANDE e VISÍVEL
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0, 400, 0, 500)
        mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250) -- CENTRO DA TELA
        mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        mainFrame.BorderSizePixel = 2
        mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
        mainFrame.Active = true
        mainFrame.Draggable = true
        mainFrame.Visible = true
        
        print("🖼️ MainFrame criado")
        
        -- Título GRANDE
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 50)
        title.Position = UDim2.new(0, 0, 0, 0)
        title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        title.BorderSizePixel = 0
        title.Text = "⚔️ ENHANCED COMBAT SYSTEM ⚔️"
        title.TextColor3 = Color3.fromRGB(0, 255, 0)
        title.TextSize = 20
        title.Font = Enum.Font.SourceSansBold
        title.Parent = mainFrame
        
        print("📝 Título criado")
        
        -- Função para criar botão SIMPLES
        local function createButton(name, text, yPos, improvement)
            local button = Instance.new("TextButton")
            button.Name = name
            button.Size = UDim2.new(0, 350, 0, 40)
            button.Position = UDim2.new(0, 25, 0, yPos)
            button.BackgroundColor3 = improvements[improvement] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
            button.BorderSizePixel = 2
            button.BorderColor3 = Color3.fromRGB(255, 255, 255)
            button.Text = text .. " - " .. (improvements[improvement] and "ATIVADO" or "DESATIVADO")
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.TextSize = 16
            button.Font = Enum.Font.SourceSansBold
            button.Parent = mainFrame
            
            button.MouseButton1Click:Connect(function()
                improvements[improvement] = not improvements[improvement]
                button.BackgroundColor3 = improvements[improvement] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
                button.Text = text .. " - " .. (improvements[improvement] and "ATIVADO" or "DESATIVADO")
                print("🔧 " .. text .. ": " .. (improvements[improvement] and "ATIVADO" or "DESATIVADO"))
            end)
            
            print("🔘 Botão criado:", name)
            return button
        end
        
        -- Criar TODOS os botões
        createButton("NoCooldownBtn", "🚀 SEM COOLDOWN", 70, "noCooldown")
        createButton("HitboxBtn", "🎯 HITBOX EXPANDIDA", 120, "expandedHitbox")
        createButton("AttackBtn", "⚡ ATAQUE OTIMIZADO", 170, "optimizedAttack")
        createButton("StaminaBtn", "♾️ STAMINA INFINITA", 220, "autoStamina")
        createButton("SpeedBtn", "💨 MOVIMENTO RÁPIDO", 270, "fastMovement")
        createButton("StunBtn", "🛡️ SEM STUN", 320, "removeStun")
        
        -- Botão de teste
        local testButton = Instance.new("TextButton")
        testButton.Size = UDim2.new(0, 350, 0, 40)
        testButton.Position = UDim2.new(0, 25, 0, 380)
        testButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        testButton.BorderSizePixel = 2
        testButton.BorderColor3 = Color3.fromRGB(255, 255, 0)
        testButton.Text = "🧪 TESTE - CLIQUE AQUI"
        testButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        testButton.TextSize = 16
        testButton.Font = Enum.Font.SourceSansBold
        testButton.Parent = mainFrame
        
        testButton.MouseButton1Click:Connect(function()
            print("🧪 BOTÃO DE TESTE CLICADO! UI ESTÁ FUNCIONANDO!")
            testButton.Text = "✅ FUNCIONANDO!"
            testButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        end)
        
        -- Status
        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(1, 0, 0, 30)
        status.Position = UDim2.new(0, 0, 1, -30)
        status.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        status.BorderSizePixel = 0
        status.Text = "🟢 Sistema Ativo - Clique nos botões para ativar melhorias"
        status.TextColor3 = Color3.fromRGB(0, 255, 0)
        status.TextSize = 14
        status.Font = Enum.Font.SourceSans
        status.Parent = mainFrame
        
        print("📊 Status criado")
        
        -- PARENTAR POR ÚLTIMO
        screenGui.Parent = playerGui
        print("🎯 ScreenGui adicionado ao PlayerGui")
        
        -- Verificar se foi criado
        task.wait(0.1)
        local check = playerGui:FindFirstChild("EnhancedCombatUI")
        if check then
            print("✅ UI CONFIRMADA NO PLAYERGUI!")
            print("📍 Posição:", mainFrame.AbsolutePosition)
            print("📏 Tamanho:", mainFrame.AbsoluteSize)
            print("👁️ Visível:", mainFrame.Visible)
        else
            warn("❌ UI NÃO ENCONTRADA NO PLAYERGUI!")
        end
        
        return screenGui
    end
    
    -- Comandos de chat
    local function handleChatCommand(message)
        local args = string.split(string.lower(message), " ")
        
        if args[1] == "!combat" then
            if args[2] == "ui" or args[2] == "interface" then
                createSimpleUI()
                print("🎨 Interface recriada por comando!")
            elseif args[2] == "test" or args[2] == "teste" then
                print("🧪 === TESTE DO SISTEMA ===")
                print("PlayerGui existe:", player.PlayerGui ~= nil)
                print("UI existe:", player.PlayerGui:FindFirstChild("EnhancedCombatUI") ~= nil)
                local ui = player.PlayerGui:FindFirstChild("EnhancedCombatUI")
                if ui then
                    print("UI Enabled:", ui.Enabled)
                    print("MainFrame existe:", ui:FindFirstChild("MainFrame") ~= nil)
                    if ui:FindFirstChild("MainFrame") then
                        print("MainFrame Visible:", ui.MainFrame.Visible)
                    end
                end
            elseif args[2] == "help" then
                print("=== 🎮 COMANDOS ===")
                print("!combat ui - Recriar interface")
                print("!combat test - Testar sistema")  
                print("!combat nocooldown - Toggle sem cooldown")
                print("!combat hitbox - Toggle hitbox expandida")
            elseif args[2] == "nocooldown" then
                improvements.noCooldown = not improvements.noCooldown
                print("🚀 Sem Cooldown:", improvements.noCooldown and "ATIVADO" or "DESATIVADO")
            elseif args[2] == "hitbox" then
                improvements.expandedHitbox = not improvements.expandedHitbox
                print("🎯 Hitbox Expandida:", improvements.expandedHitbox and "ATIVADA" or "DESATIVADA")
            end
        end
    end
    
    -- Inicialização FORÇADA
    local function initialize()
        print("🚀 === INICIALIZANDO SISTEMA FORÇADO ===")
        
        -- Aguardar um pouco
        task.wait(2)
        
        -- Salvar valores
        saveOriginalValues()
        
        -- FORÇAR criação da UI múltiplas vezes se necessário
        for i = 1, 3 do
            print("🎨 Tentativa", i, "de criar UI...")
            local ui = createSimpleUI()
            
            task.wait(1)
            
            local check = player.PlayerGui:FindFirstChild("EnhancedCombatUI")
            if check then
                print("✅ UI CRIADA COM SUCESSO NA TENTATIVA", i)
                break
            else
                print("❌ Tentativa", i, "falhou, tentando novamente...")
            end
        end
        
        -- Aplicar melhorias
        applyImprovements()
        
        -- Conectar chat
        player.Chatted:Connect(handleChatCommand)
        
        print("⚔️ === SISTEMA CARREGADO ===")
        print("💬 Digite !combat ui se a interface não aparecer")
        print("💬 Digite !combat test para testar")
        print("🎯 A interface deve estar NO CENTRO DA TELA!")
    end
    
    initialize()
    return true
end)

if not success then
    warn("❌ ERRO CRÍTICO:", tostring(result))
else
    print("✅ SISTEMA CARREGADO COM SUCESSO!")
end

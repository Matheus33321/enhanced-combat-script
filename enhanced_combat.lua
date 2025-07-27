
-- Enhanced Hitbox Script for Roblox - Menu Configuration
-- Menu interativo para configurar hitbox e visibilidade

local ENHANCED_CONFIG = {
    -- Multiplicadores de range para cada combo
    rangeMultipliers = {
        [1] = 3.0,  -- Primeiro ataque: 3x o range original
        [2] = 3.5,  -- Segundo ataque: 3.5x o range original
        [3] = 4.0,  -- Terceiro ataque: 4x o range original
        [4] = 4.5,  -- Quarto ataque: 4.5x o range original
    },
    
    -- Range máximo garantido (em studs)
    maxGuaranteedRange = 20,
    
    -- Ângulo de detecção (em graus) - 360 = detecção completa ao redor
    detectionAngle = 180,
    
    -- Altura de detecção (para cima e para baixo)
    verticalRange = 10,
    
    -- Se deve ignorar paredes/obstáculos
    ignoreObstacles = true,
    
    -- Priorizar alvos mais próximos
    prioritizeClosest = true,
    
    -- Auto-hit (sempre acerta independente da distância)
    autoHit = true,
    
    -- Visibilidade da hitbox
    showHitbox = false,
    
    -- Cor da hitbox visual
    hitboxColor = {r = 1, g = 0, b = 0}, -- Vermelho
    
    -- Transparência da hitbox (0 = opaco, 1 = transparente)
    hitboxTransparency = 0.5
}

-- Sistema de Menu
local Menu = {}

function Menu:new()
    local menu = {
        isVisible = false,
        options = {
            "1. Configurar Range Multiplier",
            "2. Configurar Range Máximo",
            "3. Configurar Ângulo de Detecção",
            "4. Toggle Auto-Hit",
            "5. Toggle Visibilidade da Hitbox",
            "6. Configurar Cor da Hitbox",
            "7. Configurar Transparência",
            "8. Mostrar Configurações Atuais",
            "9. Resetar Configurações",
            "0. Sair"
        }
    }
    setmetatable(menu, {__index = self})
    return menu
end

function Menu:show()
    print("\n" .. "="*50)
    print("🎯 ENHANCED HITBOX - MENU DE CONFIGURAÇÃO")
    print("="*50)
    
    for _, option in ipairs(self.options) do
        print(option)
    end
    
    print("="*50)
    print("Digite o número da opção desejada:")
end

function Menu:showCurrentConfig()
    print("\n📊 CONFIGURAÇÕES ATUAIS:")
    print("------------------------")
    print("Range Multipliers:")
    for combo, mult in pairs(ENHANCED_CONFIG.rangeMultipliers) do
        print(string.format("  Combo %d: %.1fx", combo, mult))
    end
    print(string.format("Range Máximo: %d studs", ENHANCED_CONFIG.maxGuaranteedRange))
    print(string.format("Ângulo de Detecção: %d°", ENHANCED_CONFIG.detectionAngle))
    print(string.format("Auto-Hit: %s", ENHANCED_CONFIG.autoHit and "ATIVADO" or "DESATIVADO"))
    print(string.format("Hitbox Visível: %s", ENHANCED_CONFIG.showHitbox and "SIM" or "NÃO"))
    print(string.format("Cor da Hitbox: R=%.1f G=%.1f B=%.1f", 
          ENHANCED_CONFIG.hitboxColor.r, 
          ENHANCED_CONFIG.hitboxColor.g, 
          ENHANCED_CONFIG.hitboxColor.b))
    print(string.format("Transparência: %.1f", ENHANCED_CONFIG.hitboxTransparency))
end

function Menu:configureRangeMultiplier()
    print("\n🎯 CONFIGURAR RANGE MULTIPLIER")
    print("Qual combo você quer alterar? (1-4):")
    local combo = tonumber(io.read())
    
    if combo and combo >= 1 and combo <= 4 then
        print(string.format("Multiplicador atual para combo %d: %.1fx", combo, ENHANCED_CONFIG.rangeMultipliers[combo]))
        print("Digite o novo multiplicador (ex: 5.0):")
        local multiplier = tonumber(io.read())
        
        if multiplier and multiplier > 0 then
            ENHANCED_CONFIG.rangeMultipliers[combo] = multiplier
            print(string.format("✅ Multiplicador do combo %d alterado para %.1fx", combo, multiplier))
        else
            print("❌ Valor inválido!")
        end
    else
        print("❌ Combo inválido!")
    end
end

function Menu:configureMaxRange()
    print("\n📏 CONFIGURAR RANGE MÁXIMO")
    print(string.format("Range máximo atual: %d studs", ENHANCED_CONFIG.maxGuaranteedRange))
    print("Digite o novo range máximo:")
    local range = tonumber(io.read())
    
    if range and range > 0 then
        ENHANCED_CONFIG.maxGuaranteedRange = range
        print(string.format("✅ Range máximo alterado para %d studs", range))
    else
        print("❌ Valor inválido!")
    end
end

function Menu:configureAngle()
    print("\n🔄 CONFIGURAR ÂNGULO DE DETECÇÃO")
    print(string.format("Ângulo atual: %d°", ENHANCED_CONFIG.detectionAngle))
    print("Digite o novo ângulo (0-360):")
    local angle = tonumber(io.read())
    
    if angle and angle >= 0 and angle <= 360 then
        ENHANCED_CONFIG.detectionAngle = angle
        print(string.format("✅ Ângulo alterado para %d°", angle))
    else
        print("❌ Ângulo inválido! Digite um valor entre 0 e 360.")
    end
end

function Menu:toggleAutoHit()
    ENHANCED_CONFIG.autoHit = not ENHANCED_CONFIG.autoHit
    print(string.format("✅ Auto-Hit %s", ENHANCED_CONFIG.autoHit and "ATIVADO" or "DESATIVADO"))
end

function Menu:toggleHitboxVisibility()
    ENHANCED_CONFIG.showHitbox = not ENHANCED_CONFIG.showHitbox
    print(string.format("✅ Visibilidade da Hitbox %s", ENHANCED_CONFIG.showHitbox and "ATIVADA" or "DESATIVADA"))
end

function Menu:configureHitboxColor()
    print("\n🎨 CONFIGURAR COR DA HITBOX")
    print("Digite os valores RGB (0-1):")
    
    print("Vermelho (R):")
    local r = tonumber(io.read())
    print("Verde (G):")
    local g = tonumber(io.read())
    print("Azul (B):")
    local b = tonumber(io.read())
    
    if r and g and b and r >= 0 and r <= 1 and g >= 0 and g <= 1 and b >= 0 and b <= 1 then
        ENHANCED_CONFIG.hitboxColor = {r = r, g = g, b = b}
        print(string.format("✅ Cor alterada para R=%.1f G=%.1f B=%.1f", r, g, b))
    else
        print("❌ Valores inválidos! Use valores entre 0 e 1.")
    end
end

function Menu:configureTransparency()
    print("\n👻 CONFIGURAR TRANSPARÊNCIA")
    print(string.format("Transparência atual: %.1f", ENHANCED_CONFIG.hitboxTransparency))
    print("Digite a nova transparência (0-1, onde 0=opaco e 1=transparente):")
    local transparency = tonumber(io.read())
    
    if transparency and transparency >= 0 and transparency <= 1 then
        ENHANCED_CONFIG.hitboxTransparency = transparency
        print(string.format("✅ Transparência alterada para %.1f", transparency))
    else
        print("❌ Valor inválido! Use um valor entre 0 e 1.")
    end
end

function Menu:resetConfig()
    print("\n🔄 RESETAR CONFIGURAÇÕES")
    print("Tem certeza que deseja resetar todas as configurações? (s/n)")
    local confirm = io.read():lower()
    
    if confirm == "s" or confirm == "sim" then
        ENHANCED_CONFIG.rangeMultipliers = {[1] = 3.0, [2] = 3.5, [3] = 4.0, [4] = 4.5}
        ENHANCED_CONFIG.maxGuaranteedRange = 20
        ENHANCED_CONFIG.detectionAngle = 180
        ENHANCED_CONFIG.autoHit = true
        ENHANCED_CONFIG.showHitbox = false
        ENHANCED_CONFIG.hitboxColor = {r = 1, g = 0, b = 0}
        ENHANCED_CONFIG.hitboxTransparency = 0.5
        print("✅ Configurações resetadas para os valores padrão!")
    else
        print("❌ Operação cancelada.")
    end
end

function Menu:handleOption(option)
    if option == "1" then
        self:configureRangeMultiplier()
    elseif option == "2" then
        self:configureMaxRange()
    elseif option == "3" then
        self:configureAngle()
    elseif option == "4" then
        self:toggleAutoHit()
    elseif option == "5" then
        self:toggleHitboxVisibility()
    elseif option == "6" then
        self:configureHitboxColor()
    elseif option == "7" then
        self:configureTransparency()
    elseif option == "8" then
        self:showCurrentConfig()
    elseif option == "9" then
        self:resetConfig()
    elseif option == "0" then
        return false
    else
        print("❌ Opção inválida!")
    end
    return true
end

-- Função para gerar código Roblox com as configurações atuais
function generateRobloxScript()
    local script = string.format([[
-- Enhanced Hitbox Script - Configurado via Menu
-- Configurações atuais aplicadas

local ENHANCED_CONFIG = {
    rangeMultipliers = {
        [1] = %.1f,
        [2] = %.1f,
        [3] = %.1f,
        [4] = %.1f,
    },
    maxGuaranteedRange = %d,
    detectionAngle = %d,
    verticalRange = 10,
    ignoreObstacles = true,
    prioritizeClosest = true,
    autoHit = %s,
    showHitbox = %s,
    hitboxColor = Color3.fromRGB(%d, %d, %d),
    hitboxTransparency = %.1f
}

-- [Resto do código do Enhanced Hitbox seria inserido aqui]
-- Para usar no Roblox: loadstring(game:HttpGet("URL_DO_SCRIPT"))()

print("🎯 Enhanced Hitbox Configurado!")
print("📊 Configurações aplicadas:")
for combo, mult in pairs(ENHANCED_CONFIG.rangeMultipliers) do
    print("   Combo " .. combo .. ": " .. mult .. "x")
end
print("   Range máximo: " .. ENHANCED_CONFIG.maxGuaranteedRange .. " studs")
print("   Auto-hit: " .. (ENHANCED_CONFIG.autoHit and "ATIVADO" or "DESATIVADO"))
print("   Hitbox visível: " .. (ENHANCED_CONFIG.showHitbox and "SIM" or "NÃO"))
]], 
    ENHANCED_CONFIG.rangeMultipliers[1],
    ENHANCED_CONFIG.rangeMultipliers[2], 
    ENHANCED_CONFIG.rangeMultipliers[3],
    ENHANCED_CONFIG.rangeMultipliers[4],
    ENHANCED_CONFIG.maxGuaranteedRange,
    ENHANCED_CONFIG.detectionAngle,
    ENHANCED_CONFIG.autoHit and "true" or "false",
    ENHANCED_CONFIG.showHitbox and "true" or "false",
    math.floor(ENHANCED_CONFIG.hitboxColor.r * 255),
    math.floor(ENHANCED_CONFIG.hitboxColor.g * 255),
    math.floor(ENHANCED_CONFIG.hitboxColor.b * 255),
    ENHANCED_CONFIG.hitboxTransparency)
    
    return script
end

-- Loop principal do menu
function runMenu()
    local menu = Menu:new()
    
    print("🎯 ENHANCED HITBOX - CONFIGURADOR")
    print("Bem-vindo ao configurador de hitbox!")
    
    while true do
        menu:show()
        local option = io.read()
        
        if not menu:handleOption(option) then
            break
        end
        
        print("\nPressione Enter para continuar...")
        io.read()
    end
    
    print("\n💾 SCRIPT GERADO:")
    print("="*60)
    print(generateRobloxScript())
    print("="*60)
    print("✅ Configuração concluída! Copie o script acima para usar no Roblox.")
end

-- Executar o menu
runMenu()

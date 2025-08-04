-- INÍCIO DO ARQUIVO enhanced_scripts.lua
local Players = game:GetService("Players")
local rs = game.ReplicatedStorage
local ss = game.ServerStorage

-- Configurações exclusivas (ocultas dos colaboradores)
local ENHANCED_CONFIG = {
    USER_ID = 19017521,
    
    -- Configurações de Ataque
    ATTACK = {
        RANGES = {
            ["1"] = 15,  -- Range normal é ~8, seu será 15
            ["2"] = 18,  -- Aumenta progressivamente
            ["3"] = 20,
            ["4"] = 22,
        },
        
        COOLDOWNS = {
            ["1"] = 0.3,  -- Cooldown normal é ~0.8, seu será 0.3
            ["2"] = 0.4,
            ["3"] = 0.5,
            ["4"] = 0.6,
        },
        
        HITBOX_SIZE = Vector3.new(12, 8, 12), -- Hitbox maior que o padrão
        USE_AREA_DAMAGE = true, -- Dano em área ao invés de raycast
    },
    
    -- Configurações de Dano
    DAMAGE = {
        CUSTOM_DAMAGE = 7, -- Seu dano fixo
        IGNORE_BLOCK_CHANCE = 0.3, -- 30% de chance de ignorar bloqueio
    },
    
    -- Outras melhorias
    FEATURES = {
        INFINITE_STAMINA = false, -- Ativar/desativar stamina infinita
        AUTO_COMBO_RESET = true,  -- Reset automático de combo em miss
        ENHANCED_PARTICLES = true, -- Efeitos visuais aprimorados
    }
}

-- Função para verificar se é o usuário autorizado
local function isEnhancedUser(player)
    return player and player.UserId == ENHANCED_CONFIG.USER_ID
end

-- ===== SISTEMA DE ATAQUE APRIMORADO =====
local function setupEnhancedAttack()
    local config = rs.CombatConfiguration
    local rsEvents = rs.Events
    local ssEvents = ss.Events
    local rnd = Random.new()

    -- Carrega animações
    local attackAnimations = {}
    for i = 1, #config:WaitForChild("Attacking"):WaitForChild("Animations"):GetChildren() do
        table.insert(attackAnimations, config.Attacking.Animations[tostring(i)])
    end

    -- Função de efeitos aprimorados
    local function createEnhancedEffect(effectPos, effectDir, combo, blocked)
        local comboParticleFolder = config.ParticleEffects.Combos[tostring(combo)]
        local comboParticle = comboParticleFolder.ParticleContainer:Clone()
        
        -- Efeitos visuais aprimorados
        if ENHANCED_CONFIG.FEATURES.ENHANCED_PARTICLES then
            for _, effect in pairs(comboParticle:GetDescendants()) do
                if effect:IsA("ParticleEmitter") then
                    effect.Rate = effect.Rate * 1.5 -- Mais partículas
                    effect.Speed = NumberRange.new(effect.Speed.Min * 1.2, effect.Speed.Max * 1.2)
                elseif effect:IsA("PointLight") then
                    effect.Brightness = effect.Brightness * 1.3
                    effect.Range = effect.Range * 1.2
                end
            end
        end
        
        comboParticle.CFrame = CFrame.new(effectPos, effectDir * 1000)
        comboParticle.Parent = workspace["EFFECTS CONTAINER"]
        
        local comboSound = config.SoundEffects.Combos[tostring(combo)]:Clone()
        comboSound.Volume = comboSound.Volume * 1.2 -- Som mais alto
        
        if blocked then
            comboSound.Volume *= config.SoundEffects.BlockNoiseMultiplier.Value
            local pitchShift = Instance.new("PitchShiftSoundEffect")
            pitchShift.Octave = config.SoundEffects.BlockPitchMultiplier.Value
            pitchShift.Parent = comboSound
        end
        
        comboSound.Parent = comboParticle
        comboSound:Play()
        
        spawn(function()
            wait(comboParticleFolder.DisableAfter.Value)
            for _, d in pairs(comboParticle:GetDescendants()) do
                if d:IsA("ParticleEmitter") or d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
                    d.Enabled = false
                end
            end
        end)
    end

    -- Função de ataque customizada
    local function enhancedDoAttack(plr)
        if not isEnhancedUser(plr) then
            return -- Não interfere com outros jogadores
        end
        
        local char = plr.Character
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")

        if not (char and hum and hum.Health > 0 and root) then
            return
        end

        local combatState = hum:FindFirstChild("CombatState")
        if not combatState then
            return
        end

        -- Stamina infinita (opcional)
        if ENHANCED_CONFIG.FEATURES.INFINITE_STAMINA then
            combatState.Stamina.Value = 100
        end

        local attackStaminaCost = config.Stamina.AttackStaminaCost.Value
        if combatState.Stunned.Value == false and combatState.Attacking.Value == false and 
           combatState.AttackCooldown.Value == false and combatState.Stamina.Value >= attackStaminaCost then

            combatState.AttackCooldown.Value = true
            combatState.Attacking.Value = true
            combatState.Stamina.Value -= attackStaminaCost

            combatState.Combo.Value += 1
            if combatState.Combo.Value > #attackAnimations or 
               tick() - combatState.LastAttacked.Value >= config.Combo.ExpireTime.Value then
                combatState.Combo.Value = 1
            end
            combatState.LastAttacked.Value = tick()

            spawn(function()
                -- Som de whoosh
                local wooshes = config.SoundEffects.Wooshes:GetChildren()
                local wooshSound = wooshes[rnd:NextInteger(1, #wooshes)]:Clone()
                wooshSound.Parent = root
                wooshSound.Volume = wooshSound.Volume * 1.3 -- Som mais alto
                wooshSound:Play()
                wooshSound.Ended:Connect(function()
                    wooshSound:Destroy()
                end)

                -- Dash customizado
                local direction = root.CFrame.LookVector
                local knockback = config.Attacking.Dash[tostring(combatState.Combo.Value)].Value
                rsEvents.DealKnockback:FireClient(plr, direction, knockback)

                -- Animação
                local animation = hum.Animator:LoadAnimation(attackAnimations[combatState.Combo.Value])
                animation:Play()

                animation:GetMarkerReachedSignal("Hit"):Connect(function(attackingBodyPart)
                    local bodyPart = char[attackingBodyPart]
                    local bodyPartBottom = bodyPart.CFrame - bodyPart.CFrame.UpVector * bodyPart.Size.Y/2

                    -- Sistema de detecção aprimorado
                    local customRange = ENHANCED_CONFIG.ATTACK.RANGES[tostring(combatState.Combo.Value)]
                    local customHitbox = ENHANCED_CONFIG.ATTACK.HITBOX_SIZE

                    if ENHANCED_CONFIG.ATTACK.USE_AREA_DAMAGE then
                        -- Dano em área
                        local overlapParams = OverlapParams.new()
                        overlapParams.FilterType = Enum.RaycastFilterType.Exclude
                        overlapParams.FilterDescendantsInstances = {char, workspace["EFFECTS CONTAINER"]}

                        local hitParts = workspace:GetPartBoundsInBox(
                            root.CFrame * CFrame.new(0, 0, -customRange/2), 
                            customHitbox, 
                            overlapParams
                        )

                        local hitTargets = {}
                        for _, part in pairs(hitParts) do
                            local hitChar = part.Parent
                            if hitChar:FindFirstChild("Humanoid") and hitChar ~= char and hitChar.Humanoid.Health > 0 then
                                if not hitTargets[hitChar] then
                                    hitTargets[hitChar] = true
                                    local bypassBlock = math.random() < ENHANCED_CONFIG.DAMAGE.IGNORE_BLOCK_CHANCE
                                    local knockbackDirection = (hitChar.HumanoidRootPart.Position - root.Position).Unit
                                    spawn(createEnhancedEffect, bodyPartBottom.Position, -bodyPart.CFrame.UpVector, combatState.Combo.Value, not bypassBlock)
                                    ssEvents.DealDamage:Fire(char, hitChar, bypassBlock, knockbackDirection)
                                end
                            end
                        end

                        if next(hitTargets) == nil and config.Combo.CanComboWithoutHitting.Value == false then
                            combatState.LastAttacked.Value = 0
                        end
                    else
                        -- Sistema raycast aprimorado
                        local rp = RaycastParams.new()
                        rp.FilterType = Enum.RaycastFilterType.Exclude
                        rp.FilterDescendantsInstances = {char, workspace["EFFECTS CONTAINER"]}

                        local hitRay = workspace:Blockcast(root.CFrame, customHitbox, root.CFrame.LookVector * customRange, rp)

                        if hitRay then
                            local hitChar = hitRay.Instance.Parent:FindFirstChild("Humanoid") and hitRay.Instance.Parent or 
                                           hitRay.Instance.Parent.Parent:FindFirstChild("Humanoid") and hitRay.Instance.Parent.Parent

                            if hitChar and hitChar.Humanoid.Health > 0 then
                                local bypassBlock = hitRay.Normal == Enum.NormalId.Back or 
                                                  math.random() < ENHANCED_CONFIG.DAMAGE.IGNORE_BLOCK_CHANCE
                                local knockbackDirection = -bodyPart.CFrame.UpVector
                                spawn(createEnhancedEffect, bodyPartBottom.Position, -bodyPart.CFrame.UpVector, combatState.Combo.Value, not bypassBlock)
                                ssEvents.DealDamage:Fire(char, hitChar, bypassBlock, knockbackDirection)
                            end
                        elseif hitRay and hitRay.Instance.CanCollide == true then
                            spawn(createEnhancedEffect, bodyPartBottom.Position, -bodyPart.CFrame.UpVector, combatState.Combo.Value, false)
                        elseif config.Combo.CanComboWithoutHitting.Value == false then
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
                    game:GetService("RunService").Heartbeat:Wait()
                end
            end)

            -- Cooldown customizado
            local customCooldown = ENHANCED_CONFIG.ATTACK.COOLDOWNS[tostring(combatState.Combo.Value)]
            wait(customCooldown)

            if combatState.Attacking.Value == true then
                combatState.Attacking.Value = false
            end
            combatState.AttackCooldown.Value = false
        end
    end

    -- Conecta o evento (vai executar junto com o original)
    rsEvents.DoAttack.OnServerEvent:Connect(enhancedDoAttack)
end

-- ===== SISTEMA DE DANO APRIMORADO =====
local function setupEnhancedDamage()
    local config = rs.CombatConfiguration
    local rsEvents = rs.Events
    local modules = rs.Modules
    local dealKnockback = require(modules.DealKnockback)
    local ssEvents = ss.Events

    local function enhancedDealDamage(sourceChar, char, bypassBlock, knockbackDirection)
        local sourcePlayer = Players:GetPlayerFromCharacter(sourceChar)
        if not isEnhancedUser(sourcePlayer) then
            return -- Só aplica para seus ataques
        end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        -- Dano customizado
        local dmg = ENHANCED_CONFIG.DAMAGE.CUSTOM_DAMAGE

        -- Chance de crítico
        local critChance = math.random(0, 100)
        if critChance <= config.Damage.CriticalHitChance.Value then
            dmg = dmg * config.Damage.CriticalHitMultiplier.Value
        end

        local combatState = hum:FindFirstChild("CombatState")

        if combatState and config.Attacking.CanStopAttack.Value == true then
            combatState.Attacking.Value = false
        end

        local knockback = config.Knockback.ComboKnockback[tostring(sourceChar.Humanoid.CombatState.Combo.Value)].Value

        -- Sistema de bloqueio aprimorado
        if not bypassBlock and combatState and combatState.Blocking.Value == true then
            local dmgAbsorbed = math.clamp(dmg * config.Blocking.DamageAbsorption.Value, 0, combatState.BlockHealth.Value)
            local dmgDealt = dmg - dmgAbsorbed
            dmg = dmgDealt

            hum:TakeDamage(dmgDealt)
            combatState.BlockHealth.Value = math.clamp(combatState.BlockHealth.Value - dmgAbsorbed, 0, config.Blocking.MaxHealth.Value)

            if combatState.BlockHealth.Value <= 0 then
                combatState.Blocking.Value = false
            end

            knockback = knockback * config.Blocking.KnockbackMultiplier.Value
        else
            hum:TakeDamage(dmg)

            if combatState then
                combatState.Stunned.Value = true
                local stunnedParticles = {}

                for _, child in pairs(config.ParticleEffects.Stunned.ParticleContainer:GetChildren()) do
                    local particleAttachment = child:Clone()
                    particleAttachment.Parent = char.Head
                    table.insert(stunnedParticles, particleAttachment)
                end

                spawn(function()
                    wait(config.Stunned.StunDurations[tostring(sourceChar.Humanoid.CombatState.Combo.Value)].Value)
                    combatState.Stunned.Value = false

                    for _, particleAttachment in pairs(stunnedParticles) do
                        particleAttachment:Destroy()
                    end
                end)
            end
        end

        local plr = Players:GetPlayerFromCharacter(char)

        if plr then
            rsEvents.DealKnockback:FireClient(plr, knockbackDirection, knockback)
        else
            dealKnockback(char, knockbackDirection, knockback)
        end

        if config.Damage.Counters.ShowCounters.Value == true then
            rsEvents.ShowDamageCounter:FireAllClients(char, dmg)
        end
    end

    -- Conecta o evento
    ssEvents.DealDamage.Event:Connect(enhancedDealDamage)
end

-- ===== INICIALIZAÇÃO =====
spawn(function()
    wait(1) -- Aguarda os sistemas carregarem
    setupEnhancedAttack()
    setupEnhancedDamage()
    print("[ENHANCED] Todos os sistemas aprimorados foram inicializados!")
end)

-- FIM DO ARQUIVO enhanced_scripts.lua

-- Combat System Explorer - Mapeia a estrutura real do jogo
-- Este script vai mostrar EXATAMENTE como seu sistema funciona

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Limpar GUIs existentes
for _, gui in pairs(playerGui:GetChildren()) do
    if gui.Name:find("Combat") then
        gui:Destroy()
    end
end

print("🔍 EXPLORING COMBAT SYSTEM...")

-- Função para mapear recursivamente
local function exploreFolder(folder, indent, maxDepth)
    indent = indent or ""
    maxDepth = maxDepth or 3
    
    if maxDepth <= 0 then return end
    
    local results = {}
    
    for _, child in pairs(folder:GetChildren()) do
        local info = indent .. "├─ " .. child.Name .. " (" .. child.ClassName .. ")"
        
        if child:IsA("NumberValue") or child:IsA("BoolValue") or child:IsA("IntValue") then
            info = info .. " = " .. tostring(child.Value)
        elseif child:IsA("StringValue") then
            info = info .. " = '" .. child.Value .. "'"
        end
        
        table.insert(results, info)
        
        if #child:GetChildren() > 0 and maxDepth > 1 then
            local subResults = exploreFolder(child, indent .. "│  ", maxDepth - 1)
            for _, subResult in pairs(subResults) do
                table.insert(results, subResult)
            end
        end
    end
    
    return results
end

-- Criar GUI Explorer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CombatSystemExplorer"
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Parent = screenGui
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0
frame.Position = UDim2.new(0.05, 0, 0.05, 0)
frame.Size = UDim2.new(0.9, 0, 0.9, 0)
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- Header
local header = Instance.new("Frame")
header.Parent = frame
header.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
header.BorderSizePixel = 0
header.Size = UDim2.new(1, 0, 0, 40)

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

local headerFix = Instance.new("Frame")
headerFix.Parent = header
headerFix.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
headerFix.BorderSizePixel = 0
headerFix.Position = UDim2.new(0, 0, 0.5, 0)
headerFix.Size = UDim2.new(1, 0, 0.5, 0)

local title = Instance.new("TextLabel")
title.Parent = header
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 10, 0, 0)
title.Size = UDim2.new(1, -50, 1, 0)
title.Font = Enum.Font.GothamBold
title.Text = "🔍 COMBAT SYSTEM EXPLORER"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local refreshBtn = Instance.new("TextButton")
refreshBtn.Parent = header
refreshBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
refreshBtn.BorderSizePixel = 0
refreshBtn.Position = UDim2.new(1, -80, 0.5, -12)
refreshBtn.Size = UDim2.new(0, 35, 0, 24)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.Text = "🔄"
refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshBtn.TextSize = 14

local refreshCorner = Instance.new("UICorner")
refreshCorner.CornerRadius = UDim.new(0, 4)
refreshCorner.Parent = refreshBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = header
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.BorderSizePixel = 0
closeBtn.Position = UDim2.new(1, -40, 0.5, -12)
closeBtn.Size = UDim2.new(0, 30, 0, 24)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 14

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 4)
closeBtnCorner.Parent = closeBtn

-- Scroll frame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Parent = frame
scrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
scrollFrame.BorderSizePixel = 0
scrollFrame.Position = UDim2.new(0, 5, 0, 45)
scrollFrame.Size = UDim2.new(1, -10, 1, -50)
scrollFrame.ScrollBarThickness = 8
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 6)
scrollCorner.Parent = scrollFrame

local textLabel = Instance.new("TextLabel")
textLabel.Parent = scrollFrame
textLabel.BackgroundTransparency = 1
textLabel.Position = UDim2.new(0, 10, 0, 10)
textLabel.Size = UDim2.new(1, -20, 0, 5000)
textLabel.Font = Enum.Font.Code
textLabel.Text = "Scanning..."
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextSize = 12
textLabel.TextYAlignment = Enum.TextYAlignment.Top
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.TextWrapped = true

-- Função para escanear o sistema
local function scanSystem()
    local results = {}
    
    table.insert(results, "🔍 COMBAT SYSTEM SCAN RESULTS")
    table.insert(results, "=" .. string.rep("=", 50))
    table.insert(results, "")
    
    -- 1. ReplicatedStorage
    table.insert(results, "📁 REPLICATEDSTORAGE:")
    if ReplicatedStorage then
        local rsResults = exploreFolder(ReplicatedStorage, "", 2)
        for _, result in pairs(rsResults) do
            table.insert(results, result)
        end
    else
        table.insert(results, "❌ ReplicatedStorage not found!")
    end
    
    table.insert(results, "")
    
    -- 2. Character
    table.insert(results, "👤 PLAYER CHARACTER:")
    if player.Character then
        table.insert(results, "✅ Character found: " .. player.Character.Name)
        
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            table.insert(results, "✅ Humanoid found")
            
            local charResults = exploreFolder(humanoid, "", 2)
            for _, result in pairs(charResults) do
                table.insert(results, result)
            end
        else
            table.insert(results, "❌ Humanoid not found")
        end
    else
        table.insert(results, "❌ Character not spawned")
    end
    
    table.insert(results, "")
    table.insert(results, "🔧 ANALYSIS COMPLETE!")
    table.insert(results, "Copy this information to help debug the script.")
    
    return table.concat(results, "\n")
end

-- Função para atualizar display
local function updateDisplay()
    textLabel.Text = scanSystem()
    
    -- Auto-resize
    local textBounds = textLabel.TextBounds
    textLabel.Size = UDim2.new(1, -20, 0, math.max(textBounds.Y + 20, scrollFrame.AbsoluteSize.Y))
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textBounds.Y + 40)
end

-- Event handlers
refreshBtn.MouseButton1Click:Connect(updateDisplay)
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Hotkey
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F5 then
        updateDisplay()
    elseif input.KeyCode == Enum.KeyCode.F6 then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

-- Scan inicial
spawn(function()
    wait(1)
    updateDisplay()
end)

print("🔍 Combat System Explorer loaded!")
print("📋 Press F5 to refresh scan")
print("📋 Press F6 to toggle window")
print("📋 Use this information to fix the combat enhancer!")

-- Função adicional para testar modificações em tempo real
local function createTestPanel()
    local testFrame = Instance.new("Frame")
    testFrame.Parent = frame
    testFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    testFrame.BorderSizePixel = 0
    testFrame.Position = UDim2.new(0, 5, 1, -120)
    testFrame.Size = UDim2.new(1, -10, 0, 110)
    
    local testCorner = Instance.new("UICorner")
    testCorner.CornerRadius = UDim.new(0, 6)
    testCorner.Parent = testFrame
    
    local testTitle = Instance.new("TextLabel")
    testTitle.Parent = testFrame
    testTitle.BackgroundTransparency = 1
    testTitle.Size = UDim2.new(1, 0, 0, 25)
    testTitle.Font = Enum.Font.GothamBold
    testTitle.Text = "🧪 LIVE TESTING"
    testTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
    testTitle.TextSize = 14
    
    -- Test buttons
    local btnY = 30
    local testButtons = {
        {name = "Test Stamina", func = function()
            pcall(function()
                if player.Character and player.Character.Humanoid then
                    local combatState = player.Character.Humanoid:FindFirstChild("CombatState")
                    if combatState and combatState:FindFirstChild("Stamina") then
                        combatState.Stamina.Value = 999
                        print("✅ Stamina set to 999")
                    else
                        print("❌ Stamina not found")
                    end
                end
            end)
        end},
        
        {name = "Test Stun", func = function()
            pcall(function()
                if player.Character and player.Character.Humanoid then
                    local combatState = player.Character.Humanoid:FindFirstChild("CombatState")
                    if combatState and combatState:FindFirstChild("Stunned") then
                        combatState.Stunned.Value = false
                        print("✅ Stun removed")
                    else
                        print("❌ Stunned not found")
                    end
                end
            end)
        end}
    }
    
    for i, btn in ipairs(testButtons) do
        local testBtn = Instance.new("TextButton")
        testBtn.Parent = testFrame
        testBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
        testBtn.BorderSizePixel = 0
        testBtn.Position = UDim2.new(0, 10 + (i-1) * 120, 0, btnY)
        testBtn.Size = UDim2.new(0, 110, 0, 30)
        testBtn.Font = Enum.Font.Gotham
        testBtn.Text = btn.name
        testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        testBtn.TextSize = 12
        
        local testBtnCorner = Instance.new("UICorner")
        testBtnCorner.CornerRadius = UDim.new(0, 4)
        testBtnCorner.Parent = testBtn
        
        testBtn.MouseButton1Click:Connect(btn.func)
    end
    
    -- Status display
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Parent = testFrame
    statusLabel.BackgroundTransparency = 1
    statusLabel.Position = UDim2.new(0, 10, 0, 70)
    statusLabel.Size = UDim2.new(1, -20, 0, 30)
    statusLabel.Font = Enum.Font.Code
    statusLabel.Text = "Ready for testing..."
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextSize = 10
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
end

createTestPanel()

return {explorer = true}

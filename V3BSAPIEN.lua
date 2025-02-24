--[[
    SAPIEN V1 Ultimate Script (Modificado)
    
    Funciones:
      • Menú móvil y arrastrable (260×400) para iPhone.
      • Speed (1–50) y Jump (1–115) con sliders y botones toggle.
      • PERFECTSHOT (Auto-Aim):
            - Se muestra un AimCircle de radio 30 (más preciso).
            - Solo se activa cuando detecta que "estás atacando" (touch fuera del menú).
            - La potencia (slider 1–30) define la rapidez del lock.
      • Unlimited Ammo, Heal Player, Damage Multipliers (con toggle de activación).
      • AntiBan (dummy, con intención de ofuscar el script).
      • Radar (mini mapa) se mantiene igual.
      
    NOTA: Algunas funciones son experimentales y dependen de la estructura del juego.
--]]

-- Servicios y variables iniciales
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configuración para Radar y AimCircle
local RADAR_RANGE = 300
local RADAR_SIZE = 150  -- Tamaño reducido para mobile
local AIM_RADIUS = 30   -- Radio del círculo de auto-aim, más preciso

-- Variables globales
_G.damageMultiplier = 1

-- Variables de control para toggles
local damageEnabled = false
local antiBanEnabled = false
local perfectShotEnabled = false
local isAttacking = false  -- Se activa cuando tocas la pantalla fuera del menú

-- ScreenGui principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SapienMenuGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

------------------------------------------------
-- Capturar toques para detectar "ataque" fuera del menú
------------------------------------------------
ScreenGui.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        if not input.Target or not input.Target:IsDescendantOf(ScreenGui:FindFirstChild("MenuFrame") or {}) then
            isAttacking = true
        end
    end
end)
ScreenGui.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        isAttacking = false
    end
end)

------------------------------------------------
-- Ícono Toggle (siempre visible)
------------------------------------------------
local ToggleIcon = Instance.new("TextButton")
ToggleIcon.Name = "ToggleIcon"
ToggleIcon.Size = UDim2.new(0, 45, 0, 45)
ToggleIcon.Position = UDim2.new(0, 10, 1, -55)
ToggleIcon.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
ToggleIcon.Text = "Menu"
ToggleIcon.TextScaled = true
ToggleIcon.Font = Enum.Font.GothamBold
ToggleIcon.Parent = ScreenGui

local menuVisible = false

------------------------------------------------
-- Menú Principal Arrastrable (260×400)
------------------------------------------------
local MenuFrame = Instance.new("Frame")
MenuFrame.Name = "MenuFrame"
MenuFrame.Size = UDim2.new(0, 260, 0, 400)
MenuFrame.Position = UDim2.new(0.5, -130, 0.3, 0)
MenuFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
MenuFrame.BorderSizePixel = 2
MenuFrame.Visible = false
MenuFrame.Parent = ScreenGui

-- Título y Subtítulo
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.08, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SAPIEN V1 Script"
Title.TextColor3 = Color3.new(1, 0, 0)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MenuFrame

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0.04, 0)
Subtitle.Position = UDim2.new(0, 0, 0.08, 0)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "made by BART00"
Subtitle.TextColor3 = Color3.new(1,1,1)
Subtitle.TextScaled = true
Subtitle.Font = Enum.Font.Gotham
Subtitle.Parent = MenuFrame

------------------------------------------------
-- SECCIÓN: Speed Control (1–50)
------------------------------------------------
local speedEnabled = true
local defaultSpeed = 16
local currentSpeed = defaultSpeed

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 0.05, 0)
SpeedLabel.Position = UDim2.new(0, 0, 0.15, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: " .. defaultSpeed
SpeedLabel.TextColor3 = Color3.new(1,1,1)
SpeedLabel.TextScaled = true
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.Parent = MenuFrame

local SpeedSliderTrack = Instance.new("Frame")
SpeedSliderTrack.Size = UDim2.new(0.8, 0, 0.05, 0)
SpeedSliderTrack.Position = UDim2.new(0.1, 0, 0.21, 0)
SpeedSliderTrack.BackgroundColor3 = Color3.new(0.5,0.5,0.5)
SpeedSliderTrack.Parent = MenuFrame

local SpeedSliderKnob = Instance.new("TextButton")
SpeedSliderKnob.Size = UDim2.new(0, 20, 1, 0)
local speedDefaultPercent = (defaultSpeed - 1) / (50 - 1)
SpeedSliderKnob.Position = UDim2.new(speedDefaultPercent, -10, 0, 0)
SpeedSliderKnob.BackgroundColor3 = Color3.new(1,0,0)
SpeedSliderKnob.Text = ""
SpeedSliderKnob.Parent = SpeedSliderTrack

local draggingSpeed = false
SpeedSliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSpeed = true
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingSpeed and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local sliderPos = SpeedSliderTrack.AbsolutePosition.X
        local sliderWidth = SpeedSliderTrack.AbsoluteSize.X
        local inputX = input.Position.X
        local relativePos = math.clamp(inputX - sliderPos, 0, sliderWidth)
        local percent = relativePos / sliderWidth
        local newSpeed = math.floor(percent * (50 - 1) + 1)
        SpeedSliderKnob.Position = UDim2.new(percent, -10, 0, 0)
        SpeedLabel.Text = "Speed: " .. newSpeed
        currentSpeed = newSpeed
        if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = newSpeed
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        draggingSpeed = false
    end
end)
local SpeedToggleButton = Instance.new("TextButton")
SpeedToggleButton.Size = UDim2.new(0.5, 0, 0.05, 0)
SpeedToggleButton.Position = UDim2.new(0.25, 0, 0.27, 0)
SpeedToggleButton.BackgroundColor3 = Color3.new(0,0.8,0)
SpeedToggleButton.Text = "Speed: ON"
SpeedToggleButton.TextScaled = true
SpeedToggleButton.Font = Enum.Font.GothamBold
SpeedToggleButton.TextColor3 = Color3.new(1,1,1)
SpeedToggleButton.Parent = MenuFrame
SpeedToggleButton.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        SpeedToggleButton.Text = "Speed: ON"
        SpeedToggleButton.BackgroundColor3 = Color3.new(0,0.8,0)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = currentSpeed
        end
    else
        SpeedToggleButton.Text = "Speed: OFF"
        SpeedToggleButton.BackgroundColor3 = Color3.new(0.8,0,0)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = defaultSpeed
        end
    end
end)

------------------------------------------------
-- SECCIÓN: Jump Control (1–115)
------------------------------------------------
local jumpEnabled = true
local defaultJump = 50
local currentJump = defaultJump

local JumpLabel = Instance.new("TextLabel")
JumpLabel.Size = UDim2.new(1, 0, 0.05, 0)
JumpLabel.Position = UDim2.new(0, 0, 0.33, 0)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Text = "Jump: " .. defaultJump
JumpLabel.TextColor3 = Color3.new(1,1,1)
JumpLabel.TextScaled = true
JumpLabel.Font = Enum.Font.Gotham
JumpLabel.Parent = MenuFrame

local JumpSliderTrack = Instance.new("Frame")
JumpSliderTrack.Size = UDim2.new(0.8, 0, 0.05, 0)
JumpSliderTrack.Position = UDim2.new(0.1, 0, 0.39, 0)
JumpSliderTrack.BackgroundColor3 = Color3.new(0.5,0.5,0.5)
JumpSliderTrack.Parent = MenuFrame

local JumpSliderKnob = Instance.new("TextButton")
JumpSliderKnob.Size = UDim2.new(0, 20, 1, 0)
local jumpDefaultPercent = (defaultJump - 1) / (115 - 1)
JumpSliderKnob.Position = UDim2.new(jumpDefaultPercent, -10, 0, 0)
JumpSliderKnob.BackgroundColor3 = Color3.new(1,0,0)
JumpSliderKnob.Text = ""
JumpSliderKnob.Parent = JumpSliderTrack

local draggingJump = false
JumpSliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingJump = true
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingJump and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local sliderPos = JumpSliderTrack.AbsolutePosition.X
        local sliderWidth = JumpSliderTrack.AbsoluteSize.X
        local inputX = input.Position.X
        local relativePos = math.clamp(inputX - sliderPos, 0, sliderWidth)
        local percent = relativePos / sliderWidth
        local newJump = math.floor(percent * (115 - 1) + 1)
        JumpSliderKnob.Position = UDim2.new(percent, -10, 0, 0)
        JumpLabel.Text = "Jump: " .. newJump
        currentJump = newJump
        if jumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = newJump
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        draggingJump = false
    end
end)
local JumpToggleButton = Instance.new("TextButton")
JumpToggleButton.Size = UDim2.new(0.5, 0, 0.05, 0)
JumpToggleButton.Position = UDim2.new(0.25, 0, 0.45, 0)
JumpToggleButton.BackgroundColor3 = Color3.new(0,0.8,0)
JumpToggleButton.Text = "Jump: ON"
JumpToggleButton.TextScaled = true
JumpToggleButton.Font = Enum.Font.GothamBold
JumpToggleButton.TextColor3 = Color3.new(1,1,1)
JumpToggleButton.Parent = MenuFrame
JumpToggleButton.MouseButton1Click:Connect(function()
    jumpEnabled = not jumpEnabled
    if jumpEnabled then
        JumpToggleButton.Text = "Jump: ON"
        JumpToggleButton.BackgroundColor3 = Color3.new(0,0.8,0)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = currentJump
        end
    else
        JumpToggleButton.Text = "Jump: OFF"
        JumpToggleButton.BackgroundColor3 = Color3.new(0.8,0,0)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = defaultJump
        end
    end
end)

------------------------------------------------
-- SECCIÓN: PERFECTSHOT (Auto-Aim mejorado)
------------------------------------------------
local perfectShotPotency = 1  -- de 1 a 30
local PerfectShotLabel = Instance.new("TextLabel")
PerfectShotLabel.Size = UDim2.new(1, 0, 0.05, 0)
PerfectShotLabel.Position = UDim2.new(0, 0, 0.53, 0)
PerfectShotLabel.BackgroundTransparency = 1
PerfectShotLabel.Text = "Aim Potency: " .. perfectShotPotency
PerfectShotLabel.TextColor3 = Color3.new(1,1,1)
PerfectShotLabel.TextScaled = true
PerfectShotLabel.Font = Enum.Font.Gotham
PerfectShotLabel.Parent = MenuFrame

local PerfectShotSliderTrack = Instance.new("Frame")
PerfectShotSliderTrack.Size = UDim2.new(0.8, 0, 0.05, 0)
PerfectShotSliderTrack.Position = UDim2.new(0.1, 0, 0.59, 0)
PerfectShotSliderTrack.BackgroundColor3 = Color3.new(0.5,0.5,0.5)
PerfectShotSliderTrack.Parent = MenuFrame

local PerfectShotSliderKnob = Instance.new("TextButton")
PerfectShotSliderKnob.Size = UDim2.new(0, 20, 1, 0)
local psDefaultPercent = (perfectShotPotency - 1) / (30 - 1)
PerfectShotSliderKnob.Position = UDim2.new(psDefaultPercent, -10, 0, 0)
PerfectShotSliderKnob.BackgroundColor3 = Color3.new(1,0,0)
PerfectShotSliderKnob.Text = ""
PerfectShotSliderKnob.Parent = PerfectShotSliderTrack

local draggingPS = false
PerfectShotSliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingPS = true
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingPS and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local sliderPos = PerfectShotSliderTrack.AbsolutePosition.X
        local sliderWidth = PerfectShotSliderTrack.AbsoluteSize.X
        local inputX = input.Position.X
        local relativePos = math.clamp(inputX - sliderPos, 0, sliderWidth)
        local percent = relativePos / sliderWidth
        local newPotency = math.floor(percent * (30 - 1) + 1)
        PerfectShotSliderKnob.Position = UDim2.new(percent, -10, 0, 0)
        PerfectShotLabel.Text = "Aim Potency: " .. newPotency
        perfectShotPotency = newPotency
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        draggingPS = false
    end
end)
local PerfectShotToggleButton = Instance.new("TextButton")
PerfectShotToggleButton.Size = UDim2.new(0.5, 0, 0.05, 0)
PerfectShotToggleButton.Position = UDim2.new(0.25, 0, 0.65, 0)
PerfectShotToggleButton.BackgroundColor3 = Color3.new(0.8,0,0)
PerfectShotToggleButton.Text = "PerfectShot: OFF"
PerfectShotToggleButton.TextScaled = true
PerfectShotToggleButton.Font = Enum.Font.GothamBold
PerfectShotToggleButton.TextColor3 = Color3.new(1,1,1)
PerfectShotToggleButton.Parent = MenuFrame
PerfectShotToggleButton.MouseButton1Click:Connect(function()
    perfectShotEnabled = not perfectShotEnabled
    if perfectShotEnabled then
        PerfectShotToggleButton.Text = "PerfectShot: ON"
        PerfectShotToggleButton.BackgroundColor3 = Color3.new(0,0.8,0)
    else
        PerfectShotToggleButton.Text = "PerfectShot: OFF"
        PerfectShotToggleButton.BackgroundColor3 = Color3.new(0.8,0,0)
    end
end)
-- AimCircle para visualizar el área de auto-aim (centrado en la pantalla)
local AimCircle = Instance.new("Frame")
AimCircle.Name = "AimCircle"
AimCircle.Size = UDim2.new(0, AIM_RADIUS*2, 0, AIM_RADIUS*2)
AimCircle.AnchorPoint = Vector2.new(0.5, 0.5)
AimCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
AimCircle.BackgroundTransparency = 1
AimCircle.BorderSizePixel = 0
AimCircle.Parent = ScreenGui

local AimCircleCorner = Instance.new("UICorner")
AimCircleCorner.CornerRadius = UDim.new(1,0)
AimCircleCorner.Parent = AimCircle

local AimCircleOutline = Instance.new("Frame")
AimCircleOutline.Size = UDim2.new(1,0,1,0)
AimCircleOutline.Position = UDim2.new(0,0,0,0)
AimCircleOutline.BackgroundTransparency = 1
AimCircleOutline.BorderSizePixel = 3
AimCircleOutline.BorderColor3 = Color3.new(1,1,1)
AimCircleOutline.Parent = AimCircle

-- Auto-Aim: solo se activa si PerfectShot está ON y se detecta que estás atacando.
RunService.Heartbeat:Connect(function()
    if perfectShotEnabled and isAttacking and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local bestTarget, bestDist = nil, math.huge
        for _,player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local pos2d = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (pos2d - center).Magnitude
                    if dist <= AIM_RADIUS and dist < bestDist then
                        bestDist = dist
                        bestTarget = head
                    end
                end
            end
        end
        if bestTarget then
            local tweenInfo = TweenInfo.new(1/perfectShotPotency, Enum.EasingStyle.Linear)
            local goal = {CFrame = CFrame.new(Camera.CFrame.Position, bestTarget.Position)}
            local tween = TweenService:Create(Camera, tweenInfo, goal)
            tween:Play()
        end
    end
end)

------------------------------------------------
-- SECCIÓN: Unlimited Ammo
------------------------------------------------
local unlimitedAmmoEnabled = false
local AmmoToggleButton = Instance.new("TextButton")
AmmoToggleButton.Size = UDim2.new(0.5, 0, 0.05, 0)
AmmoToggleButton.Position = UDim2.new(0.25, 0, 0.71, 0)
AmmoToggleButton.BackgroundColor3 = Color3.new(0.8,0,0)
AmmoToggleButton.Text = "Unlimited Ammo: OFF"
AmmoToggleButton.TextScaled = true
AmmoToggleButton.Font = Enum.Font.GothamBold
AmmoToggleButton.TextColor3 = Color3.new(1,1,1)
AmmoToggleButton.Parent = MenuFrame
AmmoToggleButton.MouseButton1Click:Connect(function()
    unlimitedAmmoEnabled = not unlimitedAmmoEnabled
    if unlimitedAmmoEnabled then
        AmmoToggleButton.Text = "Unlimited Ammo: ON"
        AmmoToggleButton.BackgroundColor3 = Color3.new(0,0.8,0)
    else
        AmmoToggleButton.Text = "Unlimited Ammo: OFF"
        AmmoToggleButton.BackgroundColor3 = Color3.new(0.8,0,0)
    end
end)
spawn(function()
    while wait(0.1) do
        if unlimitedAmmoEnabled and LocalPlayer.Character then
            for _,tool in pairs(LocalPlayer.Character:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("Ammo") and tool.Ammo:IsA("NumberValue") then
                    tool.Ammo.Value = 9999
                end
            end
        end
    end
end)

------------------------------------------------
-- SECCIÓN: Heal Player
------------------------------------------------
local HealButton = Instance.new("TextButton")
HealButton.Size = UDim2.new(0.5, 0, 0.05, 0)
HealButton.Position = UDim2.new(0.25, 0, 0.77, 0)
HealButton.BackgroundColor3 = Color3.new(0,0.8,0)
HealButton.Text = "Heal Player"
HealButton.TextScaled = true
HealButton.Font = Enum.Font.GothamBold
HealButton.TextColor3 = Color3.new(1,1,1)
HealButton.Parent = MenuFrame
HealButton.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
    end
end)

------------------------------------------------
-- SECCIÓN: Damage Multipliers (Toggle + botones)
------------------------------------------------
local DamageToggleButton = Instance.new("TextButton")
DamageToggleButton.Size = UDim2.new(0.5, 0, 0.05, 0)
DamageToggleButton.Position = UDim2.new(0.25, 0, 0.83, 0)
DamageToggleButton.BackgroundColor3 = Color3.new(0.8,0,0)
DamageToggleButton.Text = "Damage: OFF"
DamageToggleButton.TextScaled = true
DamageToggleButton.Font = Enum.Font.GothamBold
DamageToggleButton.TextColor3 = Color3.new(1,1,1)
DamageToggleButton.Parent = MenuFrame
DamageToggleButton.MouseButton1Click:Connect(function()
    damageEnabled = not damageEnabled
    if damageEnabled then
        DamageToggleButton.Text = "Damage: ON"
        DamageToggleButton.BackgroundColor3 = Color3.new(0,0.8,0)
    else
        DamageToggleButton.Text = "Damage: OFF"
        DamageToggleButton.BackgroundColor3 = Color3.new(0.8,0,0)
        _G.damageMultiplier = 1
    end
end)
-- Botones para establecer multiplicadores (solo afectan si damageEnabled está activo)
local Damage2Button = Instance.new("TextButton")
Damage2Button.Size = UDim2.new(0.22, 0, 0.05, 0)
Damage2Button.Position = UDim2.new(0.05, 0, 0.89, 0)
Damage2Button.BackgroundColor3 = Color3.new(0,0.8,0)
Damage2Button.Text = "DAMAGEx2"
Damage2Button.TextScaled = true
Damage2Button.Font = Enum.Font.GothamBold
Damage2Button.TextColor3 = Color3.new(1,1,1)
Damage2Button.Parent = MenuFrame
Damage2Button.MouseButton1Click:Connect(function() if damageEnabled then _G.damageMultiplier = 2 end end)

local Damage3Button = Instance.new("TextButton")
Damage3Button.Size = UDim2.new(0.22, 0, 0.05, 0)
Damage3Button.Position = UDim2.new(0.4, 0, 0.89, 0)
Damage3Button.BackgroundColor3 = Color3.new(0,0.8,0)
Damage3Button.Text = "DAMAGEx3"
Damage3Button.TextScaled = true
Damage3Button.Font = Enum.Font.GothamBold
Damage3Button.TextColor3 = Color3.new(1,1,1)
Damage3Button.Parent = MenuFrame
Damage3Button.MouseButton1Click:Connect(function() if damageEnabled then _G.damageMultiplier = 3 end end)

local Damage4Button = Instance.new("TextButton")
Damage4Button.Size = UDim2.new(0.22, 0, 0.05, 0)
Damage4Button.Position = UDim2.new(0.05, 0, 0.95, 0)
Damage4Button.BackgroundColor3 = Color3.new(0,0.8,0)
Damage4Button.Text = "DAMAGEx4"
Damage4Button.TextScaled = true
Damage4Button.Font = Enum.Font.GothamBold
Damage4Button.TextColor3 = Color3.new(1,1,1)
Damage4Button.Parent = MenuFrame
Damage4Button.MouseButton1Click:Connect(function() if damageEnabled then _G.damageMultiplier = 4 end end)

local Damage5Button = Instance.new("TextButton")
Damage5Button.Size = UDim2.new(0.22, 0, 0.05, 0)
Damage5Button.Position = UDim2.new(0.4, 0, 0.95, 0)
Damage5Button.BackgroundColor3 = Color3.new(0,0.8,0)
Damage5Button.Text = "DAMAGEx5"
Damage5Button.TextScaled = true
Damage5Button.Font = Enum.Font.GothamBold
Damage5Button.TextColor3 = Color3.new(1,1,1)
Damage5Button.Parent = MenuFrame
Damage5Button.MouseButton1Click:Connect(function() if damageEnabled then _G.damageMultiplier = 5 end end)

------------------------------------------------
-- SECCIÓN: AntiBan (Dummy Realista)
------------------------------------------------
local AntiDetectButton = Instance.new("TextButton")
AntiDetectButton.Size = UDim2.new(0.5, 0, 0.05, 0)
AntiDetectButton.Position = UDim2.new(0.25, 0, 0.77, 0)  -- Se ubica justo debajo de Heal
AntiDetectButton.BackgroundColor3 = Color3.new(0.8,0,0)
AntiDetectButton.Text = "AntiBan: OFF"
AntiDetectButton.TextScaled = true
AntiDetectButton.Font = Enum.Font.GothamBold
AntiDetectButton.TextColor3 = Color3.new(1,1,1)
AntiDetectButton.Parent = MenuFrame
AntiDetectButton.MouseButton1Click:Connect(function()
    antiBanEnabled = not antiBanEnabled
    if antiBanEnabled then
        AntiDetectButton.Text = "AntiBan: ON"
        AntiDetectButton.BackgroundColor3 = Color3.new(0,0.8,0)
        -- Aquí podrías agregar ofuscación o llamadas a funciones del executor si estuvieran disponibles.
        print("AntiBan activated (dummy)")
    else
        AntiDetectButton.Text = "AntiBan: OFF"
        AntiDetectButton.BackgroundColor3 = Color3.new(0.8,0,0)
    end
end)

------------------------------------------------
-- SECCIÓN: Radar / Mini Mapa (sin cambios)
------------------------------------------------
local RadarFrame = Instance.new("Frame")
RadarFrame.Name = "RadarFrame"
RadarFrame.Size = UDim2.new(0, RADAR_SIZE, 0, RADAR_SIZE)
RadarFrame.Position = UDim2.new(1, -RADAR_SIZE - 10, 0, 10)
RadarFrame.BackgroundTransparency = 0.5
RadarFrame.BackgroundColor3 = Color3.new(0,0,0)
RadarFrame.BorderSizePixel = 2
RadarFrame.Visible = false
RadarFrame.Parent = ScreenGui

local RadarCenter = Instance.new("Frame")
RadarCenter.Size = UDim2.new(0, 6, 0, 6)
RadarCenter.AnchorPoint = Vector2.new(0.5,0.5)
RadarCenter.Position = UDim2.new(0.5,0,0.5,0)
RadarCenter.BackgroundColor3 = Color3.new(1,1,1)
RadarCenter.BorderSizePixel = 0
RadarCenter.Parent = RadarFrame

local radarMarkers = {}
local function updateRadar()
    if not RadarFrame.Visible then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local enemyHRP = player.Character.HumanoidRootPart
            local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if localHRP then
                local diff = enemyHRP.Position - localHRP.Position
                local dist = diff.Magnitude
                if dist <= RADAR_RANGE then
                    local relativePos = Vector2.new(diff.X, diff.Z) / RADAR_RANGE
                    local markerPos = Vector2.new(RADAR_SIZE/2, RADAR_SIZE/2) + relativePos * (RADAR_SIZE/2)
                    if not radarMarkers[player] then
                        local marker = Instance.new("TextLabel")
                        marker.Size = UDim2.new(0, 20, 0, 20)
                        marker.BackgroundTransparency = 1
                        marker.Text = "●"
                        marker.TextColor3 = Color3.new(1,0,0)
                        marker.TextScaled = true
                        marker.Parent = RadarFrame
                        radarMarkers[player] = marker
                    end
                    local marker = radarMarkers[player]
                    local clampedX = math.clamp(markerPos.X, 0, RADAR_SIZE)
                    local clampedY = math.clamp(markerPos.Y, 0, RADAR_SIZE)
                    marker.Position = UDim2.new(0, clampedX - 10, 0, clampedY - 10)
                    if markerPos.X ~= clampedX or markerPos.Y ~= clampedY then
                        marker.Text = "►"
                    else
                        marker.Text = "●"
                    end
                else
                    if radarMarkers[player] then
                        radarMarkers[player]:Destroy()
                        radarMarkers[player] = nil
                    end
                end
            end
        end
    end
end
RunService.Heartbeat:Connect(function() updateRadar() end)
local RadarToggleButton = Instance.new("TextButton")
RadarToggleButton.Size = UDim2.new(0.5, 0, 0.05, 0)
RadarToggleButton.Position = UDim2.new(0.25, 0, 0.53, 0)
RadarToggleButton.BackgroundColor3 = Color3.new(0.8,0,0)
RadarToggleButton.Text = "Radar: OFF"
RadarToggleButton.TextScaled = true
RadarToggleButton.Font = Enum.Font.GothamBold
RadarToggleButton.TextColor3 = Color3.new(1,1,1)
RadarToggleButton.Parent = MenuFrame
RadarToggleButton.MouseButton1Click:Connect(function()
    if RadarFrame.Visible then
        RadarFrame.Visible = false
        RadarToggleButton.Text = "Radar: OFF"
        RadarToggleButton.BackgroundColor3 = Color3.new(0.8,0,0)
    else
        RadarFrame.Visible = true
        RadarToggleButton.Text = "Radar: ON"
        RadarToggleButton.BackgroundColor3 = Color3.new(0,0.8,0)
    end
end)

------------------------------------------------
-- Hacer el menú arrastrable
------------------------------------------------
local dragging = false
local dragStart, startPos
MenuFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MenuFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
MenuFrame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        MenuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Toggle del menú mediante el ícono
ToggleIcon.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    MenuFrame.Visible = menuVisible
end)

-- Establecer valores iniciales si el personaje existe
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    LocalPlayer.Character.Humanoid.WalkSpeed = defaultSpeed
    LocalPlayer.Character.Humanoid.JumpPower = defaultJump
end

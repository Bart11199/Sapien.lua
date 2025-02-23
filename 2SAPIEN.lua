-- Crear ScreenGui principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

-- Crear frame principal (aumentamos la altura para acomodar el toggle)
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 300)
Frame.Position = UDim2.new(0.5, -150, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 2
Frame.Parent = ScreenGui

-- Título "SAPIEN V1 Script" en rojo
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.2, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SAPIEN V1 Script"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

-- Mensaje de bienvenida
local WelcomeText = Instance.new("TextLabel")
WelcomeText.Size = UDim2.new(1, 0, 0.15, 0)
WelcomeText.Position = UDim2.new(0, 0, 0.22, 0)
WelcomeText.BackgroundTransparency = 1
WelcomeText.Text = "Welcome, user!"
WelcomeText.TextColor3 = Color3.fromRGB(255, 255, 255)
WelcomeText.TextScaled = true
WelcomeText.Font = Enum.Font.Gotham
WelcomeText.Parent = Frame

---------------------------
-- SLIDER PARA VELOCIDAD --
---------------------------
local sliderMin = 1
local sliderMax = 50
local defaultSpeed = 16
local speedEnabled = true  -- Variable para saber si la velocidad modificada está activada

-- Label que muestra la velocidad actual
local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(1, 0, 0.15, 0)
sliderLabel.Position = UDim2.new(0, 0, 0.4, 0)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "Velocidad: " .. defaultSpeed
sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
sliderLabel.TextScaled = true
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.Parent = Frame

-- Crear la pista del slider
local sliderTrack = Instance.new("Frame")
sliderTrack.Size = UDim2.new(0.8, 0, 0.1, 0)
sliderTrack.Position = UDim2.new(0.1, 0, 0.55, 0)
sliderTrack.BackgroundColor3 = Color3.fromRGB(128, 128, 128)
sliderTrack.Parent = Frame

-- Crear el "knob" del slider (botón deslizante)
local sliderKnob = Instance.new("TextButton")
sliderKnob.Size = UDim2.new(0, 20, 1, 0)  -- Ancho de 20 píxeles, altura completa de la pista
local defaultPercent = (defaultSpeed - sliderMin) / (sliderMax - sliderMin)
sliderKnob.Position = UDim2.new(defaultPercent, -10, 0, 0) -- -10 para centrar el knob
sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
sliderKnob.Text = ""
sliderKnob.Parent = sliderTrack

-- Variable para saber si se está arrastrando el knob
local dragging = false

sliderKnob.MouseButton1Down:Connect(function()
    dragging = true
end)

local UserInputService = game:GetService("UserInputService")
UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local sliderPos = sliderTrack.AbsolutePosition.X
        local sliderWidth = sliderTrack.AbsoluteSize.X
        local inputX = input.Position.X
        local relativePos = math.clamp(inputX - sliderPos, 0, sliderWidth)
        local percent = relativePos / sliderWidth
        local newSpeed = math.floor(percent * (sliderMax - sliderMin) + sliderMin)
        sliderKnob.Position = UDim2.new(percent, -10, 0, 0)
        sliderLabel.Text = "Velocidad: " .. newSpeed
        if speedEnabled then
            local player = game.Players.LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = newSpeed
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragging = false
    end
end)

--------------------------------
-- BOTÓN TOGGLE DE VELOCIDAD --
--------------------------------
local SpeedToggleButton = Instance.new("TextButton")
SpeedToggleButton.Size = UDim2.new(0.6, 0, 0.15, 0)
SpeedToggleButton.Position = UDim2.new(0.2, 0, 0.70, 0)
SpeedToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0) -- Verde cuando está activado
SpeedToggleButton.Text = "Speed: ON"
SpeedToggleButton.TextScaled = true
SpeedToggleButton.Font = Enum.Font.GothamBold
SpeedToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedToggleButton.Parent = Frame

SpeedToggleButton.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        SpeedToggleButton.Text = "Speed: ON"
        SpeedToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        -- Aplicar el valor actual del slider
        local currentSpeed = tonumber(string.match(sliderLabel.Text, "%d+")) or defaultSpeed
        if game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = currentSpeed
        end
    else
        SpeedToggleButton.Text = "Speed: OFF"
        SpeedToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        -- Restablecer la velocidad a la predeterminada
        if game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = defaultSpeed
        end
    end
end)

----------------------------
-- BOTÓN PARA CERRAR EL MENÚ
----------------------------
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0.3, 0, 0.15, 0)
CloseButton.Position = UDim2.new(0.35, 0, 0.85, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseButton.Text = "Close"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Frame

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Establecer la velocidad predeterminada al cargar el script
local player = game.Players.LocalPlayer
if player and player.Character and player.Character:FindFirstChild("Humanoid") then
    player.Character.Humanoid.WalkSpeed = defaultSpeed
end

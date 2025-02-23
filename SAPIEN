-- Crear pantalla GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

-- Crear frame principal
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 150)
Frame.Position = UDim2.new(0.5, -150, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 2
Frame.Parent = ScreenGui

-- Crear título "SAPIEN V1 Script"
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.4, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SAPIEN V1 Script"
Title.TextColor3 = Color3.fromRGB(255, 0, 0) -- Rojo
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

-- Crear mensaje de bienvenida
local WelcomeText = Instance.new("TextLabel")
WelcomeText.Size = UDim2.new(1, 0, 0.3, 0)
WelcomeText.Position = UDim2.new(0, 0, 0.5, 0)
WelcomeText.BackgroundTransparency = 1
WelcomeText.Text = "Welcome, user!"
WelcomeText.TextColor3 = Color3.fromRGB(255, 255, 255) -- Blanco
WelcomeText.TextScaled = true
WelcomeText.Font = Enum.Font.Gotham
WelcomeText.Parent = Frame

-- Botón para cerrar el menú
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0.3, 0, 0.2, 0)
CloseButton.Position = UDim2.new(0.35, 0, 0.8, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseButton.Text = "Close"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Frame

-- Función para cerrar el menú
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

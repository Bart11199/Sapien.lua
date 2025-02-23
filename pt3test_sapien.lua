--[[ 
	Script completo:
	- Menú principal arrastrable con toggle icon.
	- Controles de velocidad: slider + toggle.
	- Radar: botón toggle + mini mapa que detecta jugadores a 300m y muestra marcadores/flechas.
	
	Recuerda que algunas funciones dependen de la estructura del juego y pueden necesitar ajustes.
--]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables de configuración
local RADAR_RANGE = 300
local RADAR_SIZE = 200 -- tamaño en pixeles del radar

-- ScreenGui principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SapienMenuGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

----------------------------
-- Ícono Toggle (siempre visible)
----------------------------
local ToggleIcon = Instance.new("TextButton")
ToggleIcon.Name = "ToggleIcon"
ToggleIcon.Size = UDim2.new(0, 50, 0, 50)
ToggleIcon.Position = UDim2.new(0, 10, 1, -60)
ToggleIcon.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ToggleIcon.Text = "Menu"
ToggleIcon.TextScaled = true
ToggleIcon.Parent = ScreenGui

-- Variable para saber si el menú está visible
local menuVisible = false

----------------------------
-- Menú Principal (arrastrable)
----------------------------
local MenuFrame = Instance.new("Frame")
MenuFrame.Name = "MenuFrame"
MenuFrame.Size = UDim2.new(0, 300, 0, 350)
MenuFrame.Position = UDim2.new(0.5, -150, 0.3, 0)
MenuFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
MenuFrame.BorderSizePixel = 2
MenuFrame.Visible = false -- inicialmente cerrado
MenuFrame.Parent = ScreenGui

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.15, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SAPIEN V1 Script"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MenuFrame

-- Subtítulo
local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0.1, 0)
Subtitle.Position = UDim2.new(0, 0, 0.15, 0)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "made by BART00"
Subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
Subtitle.TextScaled = true
Subtitle.Font = Enum.Font.Gotham
Subtitle.Parent = MenuFrame

--------------------------------------
-- Sección de Control de Velocidad
--------------------------------------
local speedEnabled = true
local defaultSpeed = 16

-- Label para mostrar velocidad actual
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 0.1, 0)
SpeedLabel.Position = UDim2.new(0, 0, 0.27, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Velocidad: " .. defaultSpeed
SpeedLabel.TextColor3 = Color3.fromRGB(255,255,255)
SpeedLabel.TextScaled = true
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.Parent = MenuFrame

-- Pista del slider
local SpeedSliderTrack = Instance.new("Frame")
SpeedSliderTrack.Size = UDim2.new(0.8, 0, 0.08, 0)
SpeedSliderTrack.Position = UDim2.new(0.1, 0, 0.38, 0)
SpeedSliderTrack.BackgroundColor3 = Color3.fromRGB(128,128,128)
SpeedSliderTrack.Parent = MenuFrame

-- Knob del slider
local SpeedSliderKnob = Instance.new("TextButton")
SpeedSliderKnob.Size = UDim2.new(0, 20, 1, 0)
local defaultPercent = (defaultSpeed - 1) / (50 - 1)
SpeedSliderKnob.Position = UDim2.new(defaultPercent, -10, 0, 0)
SpeedSliderKnob.BackgroundColor3 = Color3.fromRGB(255,0,0)
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
		SpeedLabel.Text = "Velocidad: " .. newSpeed
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

-- Botón Toggle de Speed
local SpeedToggleButton = Instance.new("TextButton")
SpeedToggleButton.Size = UDim2.new(0.6,0,0.1,0)
SpeedToggleButton.Position = UDim2.new(0.2,0,0.48,0)
	-- Inicialmente activo: verde
SpeedToggleButton.BackgroundColor3 = Color3.fromRGB(0,200,0)
SpeedToggleButton.Text = "Speed: ON"
SpeedToggleButton.TextScaled = true
SpeedToggleButton.Font = Enum.Font.GothamBold
SpeedToggleButton.TextColor3 = Color3.fromRGB(255,255,255)
SpeedToggleButton.Parent = MenuFrame

SpeedToggleButton.MouseButton1Click:Connect(function()
	speedEnabled = not speedEnabled
	if speedEnabled then
		SpeedToggleButton.Text = "Speed: ON"
		SpeedToggleButton.BackgroundColor3 = Color3.fromRGB(0,200,0)
		-- Aplicar valor actual del slider
		local currentSpeed = tonumber(string.match(SpeedLabel.Text, "%d+")) or defaultSpeed
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.WalkSpeed = currentSpeed
		end
	else
		SpeedToggleButton.Text = "Speed: OFF"
		SpeedToggleButton.BackgroundColor3 = Color3.fromRGB(200,0,0)
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.WalkSpeed = defaultSpeed
		end
	end
end)

--------------------------------------
-- Sección de Radar
--------------------------------------
local radarEnabled = false

-- Botón Toggle de Radar en el menú
local RadarToggleButton = Instance.new("TextButton")
RadarToggleButton.Size = UDim2.new(0.6,0,0.1,0)
RadarToggleButton.Position = UDim2.new(0.2,0,0.60,0)
RadarToggleButton.BackgroundColor3 = Color3.fromRGB(200,0,0) -- rojo = desactivado
RadarToggleButton.Text = "RADAR: OFF"
RadarToggleButton.TextScaled = true
RadarToggleButton.Font = Enum.Font.GothamBold
RadarToggleButton.TextColor3 = Color3.fromRGB(255,255,255)
RadarToggleButton.Parent = MenuFrame

RadarToggleButton.MouseButton1Click:Connect(function()
	radarEnabled = not radarEnabled
	if radarEnabled then
		RadarToggleButton.Text = "RADAR: ON"
		RadarToggleButton.BackgroundColor3 = Color3.fromRGB(0,200,0)
		RadarFrame.Visible = true
	else
		RadarToggleButton.Text = "RADAR: OFF"
		RadarToggleButton.BackgroundColor3 = Color3.fromRGB(200,0,0)
		RadarFrame.Visible = false
	end
end)

--------------------------------------
-- Botón para cerrar el menú (dentro del menú)
--------------------------------------
local MenuCloseButton = Instance.new("TextButton")
MenuCloseButton.Size = UDim2.new(0.3,0,0.1,0)
MenuCloseButton.Position = UDim2.new(0.35,0,0.75,0)
MenuCloseButton.BackgroundColor3 = Color3.fromRGB(200,0,0)
MenuCloseButton.Text = "Close"
MenuCloseButton.TextScaled = true
MenuCloseButton.Font = Enum.Font.GothamBold
MenuCloseButton.TextColor3 = Color3.fromRGB(255,255,255)
MenuCloseButton.Parent = MenuFrame

MenuCloseButton.MouseButton1Click:Connect(function()
	MenuFrame.Visible = false
	menuVisible = false
end)

--------------------------------------
-- Función para hacer arrastrable el menú
--------------------------------------
local dragging = false
local dragInput, dragStart, startPos

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

--------------------------------------
-- Radar: mini mapa en la parte superior derecha
--------------------------------------
local RadarFrame = Instance.new("Frame")
RadarFrame.Name = "RadarFrame"
RadarFrame.Size = UDim2.new(0, RADAR_SIZE, 0, RADAR_SIZE)
RadarFrame.Position = UDim2.new(1, -RADAR_SIZE - 10, 0, 10)
RadarFrame.BackgroundTransparency = 0.5
RadarFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
RadarFrame.BorderSizePixel = 2
RadarFrame.Visible = false
RadarFrame.Parent = ScreenGui

-- Centro del radar (posición del jugador)
local RadarCenter = Instance.new("Frame")
RadarCenter.Size = UDim2.new(0, 6, 0, 6)
RadarCenter.AnchorPoint = Vector2.new(0.5,0.5)
RadarCenter.Position = UDim2.new(0.5,0,0.5,0)
RadarCenter.BackgroundColor3 = Color3.fromRGB(255,255,255)
RadarCenter.BorderSizePixel = 0
RadarCenter.Parent = RadarFrame

-- Tabla para almacenar marcadores de jugadores
local radarMarkers = {}

-- Función para actualizar el radar
local function updateRadar()
	if not radarEnabled then return end
	-- Iterar sobre todos los jugadores (excluyendo el local)
	for _,player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = player.Character.HumanoidRootPart
			local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if localHRP then
				local diff = hrp.Position - localHRP.Position
				local dist = diff.Magnitude
				-- Solo mostrar si está dentro del rango (o si queremos mostrar flechas aunque esté afuera, se puede clampear)
				if dist <= RADAR_RANGE then
					-- Escalar la posición para el radar
					local relativePos = Vector2.new(diff.X, diff.Z) / RADAR_RANGE
					local markerPos = Vector2.new(RADAR_SIZE/2, RADAR_SIZE/2) + relativePos * (RADAR_SIZE/2)
					-- Si ya existe el marcador, actualizarlo; si no, crearlo.
					if not radarMarkers[player] then
						local marker = Instance.new("TextLabel")
						marker.Size = UDim2.new(0, 20, 0, 20)
						marker.BackgroundTransparency = 1
						marker.Text = "●" -- punto
						marker.TextColor3 = Color3.fromRGB(255,0,0)
						marker.TextScaled = true
						marker.Parent = RadarFrame
						radarMarkers[player] = marker
					end
					-- Actualizar la posición y, si el marcador está en el borde, cambiar a flecha
					local marker = radarMarkers[player]
					-- Clampeo para que no salga del radar
					local clampedX = math.clamp(markerPos.X, 0, RADAR_SIZE)
					local clampedY = math.clamp(markerPos.Y, 0, RADAR_SIZE)
					marker.Position = UDim2.new(0, clampedX - 10, 0, clampedY - 10)
					-- Si el punto está en el borde, cambiar el texto a una flecha (simple aproximación)
					if markerPos.X ~= clampedX or markerPos.Y ~= clampedY then
						-- Calcular ángulo para la flecha
						local angle = math.deg(math.atan2(relativePos.Y, relativePos.X))
						-- Usamos un carácter de flecha y no es posible rotarlo directamente en TextLabel sin imagen, 
						-- así que simplemente dejamos el punto rojo (se podría mejorar usando imágenes rotadas).
						marker.Text = "●"
					else
						marker.Text = "●"
					end
				else
					-- Si el jugador está fuera del rango, eliminar marcador si existe
					if radarMarkers[player] then
						radarMarkers[player]:Destroy()
						radarMarkers[player] = nil
					end
				end
			end
		end
	end
	-- Eliminar marcadores de jugadores que se hayan salido (por desconexión, etc.)
	for player, marker in pairs(radarMarkers) do
		if not player or not player.Character then
			if marker then marker:Destroy() end
			radarMarkers[player] = nil
		end
	end
end

-- Actualizar radar cada frame si está activado
RunService.Heartbeat:Connect(function()
	if radarEnabled then
		updateRadar()
	end
end)

--------------------------------------
-- Toggle del menú con el ícono
--------------------------------------
ToggleIcon.MouseButton1Click:Connect(function()
	menuVisible = not menuVisible
	MenuFrame.Visible = menuVisible
end)

-- Establecer velocidad predeterminada al cargar
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
	LocalPlayer.Character.Humanoid.WalkSpeed = defaultSpeed
end

return function(ctx)

local players = ctx.PlayersService
local player = ctx.Player
local runService = ctx.RunService
local userInputService = ctx.UserInputService
local lighting = ctx.Lighting
local teleportService = ctx.TeleportService
local virtualUser = ctx.VirtualUser
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local function getCamera()
    camera = workspace.CurrentCamera or camera
    return camera
end

local function getCharacter()
    return player.Character
end

local function getHumanoid(character)
    character = character or getCharacter()
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function getRoot(character)
    character = character or getCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function createToggleButton(text, container, yPos)
    return ctx.UI:CreateToggle(text, container, yPos)
end

local function createSlider(...)
    return ctx.UI:CreateSlider(...)
end

local funContainer = ctx.Containers.fun

local xrayEnabled = false
local cameraNoclipEnabled = false
local cameraDistance = 12
local minCamDistance = 2
local maxCamDistance = 50
local zoomSpeed = 5
local lastPinchDistance = nil
local cameraNoclipConnection = nil
local xrayPlayerConnections = {}

local yOffsetFun = 10

-- X-Ray
local xrayBtn = createToggleButton("X-Ray", funContainer, yOffsetFun)
yOffsetFun = yOffsetFun + 46

local function applyXray(p)
    if p == player or not p.Character then return end
    if not p.Character:FindFirstChild("XrayHighlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "XrayHighlight"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.3 
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.Adornee = p.Character
        highlight.Parent = p.Character
    end
    
    local head = p.Character:FindFirstChild("Head")
    if head and not head:FindFirstChild("XrayNameTag") then
        local bGui = Instance.new("BillboardGui")
        bGui.Name = "XrayNameTag"
        bGui.AlwaysOnTop = true
        bGui.Size = UDim2.new(0, 200, 0, 50)
        bGui.ExtentsOffset = Vector3.new(0, 3, 0)
        bGui.Adornee = head
        bGui.Parent = head
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = p.Name
        textLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
        textLabel.TextSize = 13
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextStrokeTransparency = 0
        textLabel.Parent = bGui
    end
end

local function removeXray(p)
    if p.Character then
        if p.Character:FindFirstChild("XrayHighlight") then p.Character.XrayHighlight:Destroy() end
        local head = p.Character:FindFirstChild("Head")
        if head and head:FindFirstChild("XrayNameTag") then head.XrayNameTag:Destroy() end
    end
end

local function refreshXray()
    if not xrayEnabled then return end
    for _, p in ipairs(players:GetPlayers()) do
        if p ~= player and p.Character then applyXray(p) end
    end
end

local xrayPlayerConnections = {}
local function watchXrayPlayer(p)
    if p == player then return end
    if xrayPlayerConnections[p] then xrayPlayerConnections[p]:Disconnect() end
    xrayPlayerConnections[p] = p.CharacterAdded:Connect(function()
        task.wait(0.1)
        refreshXray()
    end)
end

local function toggleXray()
    xrayEnabled = not xrayEnabled
    if xrayEnabled then
        xrayBtn.Text = "X-Ray [ON]"
        xrayBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        for _, p in ipairs(players:GetPlayers()) do watchXrayPlayer(p) end
        refreshXray()
    else
        xrayBtn.Text = "X-Ray [OFF]"
        xrayBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        for p, connection in pairs(xrayPlayerConnections) do
            connection:Disconnect()
            xrayPlayerConnections[p] = nil
        end
        for _, p in ipairs(players:GetPlayers()) do removeXray(p) end
    end
end
xrayBtn.MouseButton1Click:Connect(toggleXray)

-- Camera noclip
local cameraNoclipBtn = createToggleButton("Camera Noclip", funContainer, yOffsetFun)
yOffsetFun = yOffsetFun + 46

local camDistSlider = createSlider("Cam Distance", funContainer, yOffsetFun, 2, 30, cameraDistance, function(val)
    cameraDistance = val
    if not cameraNoclipEnabled then
        player.CameraMinZoomDistance = cameraDistance
        player.CameraMaxZoomDistance = cameraDistance
    end
end)
yOffsetFun = yOffsetFun + 46

userInputService.InputChanged:Connect(function(input)
    if not cameraNoclipEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        cameraDistance = math.clamp(cameraDistance - (input.Position.Z * zoomSpeed), minCamDistance, maxCamDistance)
        local label = camDistSlider:FindFirstChildOfClass("TextLabel")
        if label then label.Text = "Cam Distance: " .. tostring(math.floor(cameraDistance * 10) / 10) end
    end
end)

userInputService.TouchPinch:Connect(function(touches, scale, velocity, state)
    if not cameraNoclipEnabled then return end
    if state == Enum.UserInputState.Begin then
        lastPinchDistance = cameraDistance
    elseif state == Enum.UserInputState.Change and lastPinchDistance then
        local factor = (scale - 1) * (zoomSpeed / 5) + 1
        cameraDistance = math.clamp(lastPinchDistance / factor, minCamDistance, maxCamDistance)
        local label = camDistSlider:FindFirstChildOfClass("TextLabel")
        if label then label.Text = "Cam Distance: " .. tostring(math.floor(cameraDistance * 10) / 10) end
    elseif state == Enum.UserInputState.End then
        lastPinchDistance = nil
    end
end)

local function toggleCameraNoclip()
    cameraNoclipEnabled = not cameraNoclipEnabled
    if cameraNoclipEnabled then
        cameraNoclipBtn.Text = "Camera Noclip [ON]"
        cameraNoclipBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        player.CameraMinZoomDistance = minCamDistance
        player.CameraMaxZoomDistance = maxCamDistance
        local cam = getCamera()
        if cam then cam.CameraType = Enum.CameraType.Custom end
        
        cameraNoclipConnection = runService.RenderStepped:Connect(function()
            if not cameraNoclipEnabled then return end
            local cam = getCamera()
            if not cam then return end
            local cameraCFrame = cam.CFrame
            local cameraFocus = cam.Focus
            local lookVector = cameraCFrame.LookVector
            cam.CFrame = CFrame.new(cameraFocus.Position - (lookVector * cameraDistance), cameraFocus.Position)
        end)
    else
        cameraNoclipBtn.Text = "Camera Noclip [OFF]"
        cameraNoclipBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if cameraNoclipConnection then cameraNoclipConnection:Disconnect() cameraNoclipConnection = nil end
        player.CameraMinZoomDistance = originalCameraMinZoom
        player.CameraMaxZoomDistance = originalCameraMaxZoom
        local cam = getCamera()
        if cam then cam.CameraType = Enum.CameraType.Custom end
    end
end
cameraNoclipBtn.MouseButton1Click:Connect(toggleCameraNoclip)

return true
end

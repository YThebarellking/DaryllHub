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

local visualContainer = ctx.Containers.visual

local noFogEnabled = false
local timeOfDayVal = 12
local lightEnabled = false
local lightRangeVal = 5
local lightBrightnessVal = 3
local tracersEnabled = false
local boxEspEnabled = false
local fullbrightEnabled = false
local fovVal = 70
local origFogStart = lighting.FogStart
local origFogEnd = lighting.FogEnd
local savedEffects = {}
local origAmbient = lighting.Ambient
local origOutdoorAmbient = lighting.OutdoorAmbient
local originalFpsProperties = {}

local yOffsetVisual = 10

local function isVisualEffect(obj)
    return obj:IsA("PostEffect") or obj:IsA("Atmosphere") or obj:IsA("Sky")
end

local noFogBtn = createToggleButton("No Fog", visualContainer, yOffsetVisual)
yOffsetVisual = yOffsetVisual + 46

local function disableScreenEffects()
    savedEffects = {}
    local targets = {lighting, workspace, camera}
    for _, parent in ipairs(targets) do
        for _, descendant in ipairs(parent:GetDescendants()) do
            if isVisualEffect(descendant) then
                local hasEnabled = pcall(function() return descendant.Enabled end)
                if hasEnabled then
                    table.insert(savedEffects, {effect = descendant, originalState = descendant.Enabled})
                    descendant.Enabled = false
                end
            end
        end
    end
end

local function restoreScreenEffects()
    for _, data in ipairs(savedEffects) do
        if data.effect and data.effect.Parent then
            pcall(function() data.effect.Enabled = data.originalState end)
        end
    end
    savedEffects = {}
end

local function toggleNoFog()
    noFogEnabled = not noFogEnabled
    if noFogEnabled then
        noFogBtn.Text = "No Fog [ON]"
        noFogBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        disableScreenEffects()
        noFogLoop = runService.RenderStepped:Connect(function()
            lighting.FogStart = 0
            lighting.FogEnd = 1e9
        end)
    else
        noFogBtn.Text = "No Fog [OFF]"
        noFogBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if noFogLoop then noFogLoop:Disconnect() noFogLoop = nil end
        lighting.FogStart = origFogStart
        lighting.FogEnd = origFogEnd
        restoreScreenEffects()
    end
end
noFogBtn.MouseButton1Click:Connect(toggleNoFog)

-- Fullbright
local fullbrightBtn = createToggleButton("Fullbright", visualContainer, yOffsetVisual)
yOffsetVisual = yOffsetVisual + 46

local function toggleFullbright()
    fullbrightEnabled = not fullbrightEnabled
    if fullbrightEnabled then
        fullbrightBtn.Text = "Fullbright [ON]"
        fullbrightBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        fullbrightLoop = runService.RenderStepped:Connect(function()
            lighting.Ambient = Color3.fromRGB(255, 255, 255)
            lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        end)
    else
        fullbrightBtn.Text = "Fullbright [OFF]"
        fullbrightBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if fullbrightLoop then fullbrightLoop:Disconnect() fullbrightLoop = nil end
        lighting.Ambient = origAmbient
        lighting.OutdoorAmbient = origOutdoorAmbient
    end
end
fullbrightBtn.MouseButton1Click:Connect(toggleFullbright)

-- Tracers ESP
local tracersBtn = createToggleButton("Tracers ESP", visualContainer, yOffsetVisual)
yOffsetVisual = yOffsetVisual + 46

local tracerLines = {}
local function clearTracers()
    for _, line in pairs(tracerLines) do line:Remove() end
    tracerLines = {}
end

local function toggleTracers()
    if not Drawing or type(Drawing.new) ~= "function" then
        tracersEnabled = false
        tracersBtn.Text = "Tracers ESP (Drawing unavailable)"
        tracersBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        task.delay(1.5, function()
            if tracersBtn.Parent then tracersBtn.Text = "Tracers ESP [OFF]" end
        end)
        return
    end
    tracersEnabled = not tracersEnabled
    if tracersEnabled then
        tracersBtn.Text = "Tracers ESP [ON]"
        tracersBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        tracersLoop = runService.RenderStepped:Connect(function()
            clearTracers()
            if not tracersEnabled then return end
            for _, p in ipairs(players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local cam = getCamera()
                    if not cam then return end
                    local targetPos, onScreen = cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                    if onScreen then
                        local line = Drawing.new("Line")
                        line.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                        line.To = Vector2.new(targetPos.X, targetPos.Y)
                        line.Color = Color3.fromRGB(0, 255, 0)
                        line.Thickness = 1.5
                        line.Transparency = 1
                        line.Visible = true
                        table.insert(tracerLines, line)
                    end
                end
            end
        end)
    else
        tracersBtn.Text = "Tracers ESP [OFF]"
        tracersBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if tracersLoop then tracersLoop:Disconnect() tracersLoop = nil end
        clearTracers()
    end
end
tracersBtn.MouseButton1Click:Connect(toggleTracers)

-- FOV Changer
createSlider("Camera FOV", visualContainer, yOffsetVisual, 30, 120, fovVal, 1, function(val)
    fovVal = val
    camera.FieldOfView = fovVal
end)
yOffsetVisual = yOffsetVisual + 46

-- Time of Day
createSlider("Time of Day", visualContainer, yOffsetVisual, 0, 24, timeOfDayVal, 1, function(val)
    timeOfDayVal = val
    lighting.ClockTime = timeOfDayVal
end)
yOffsetVisual = yOffsetVisual + 46

local function updateLight()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local light = hrp:FindFirstChild("DaryllLight")
    if lightEnabled then
        if not light then
            light = Instance.new("PointLight")
            light.Name = "DaryllLight"
            light.Parent = hrp
        end
        light.Range = lightRangeVal
        light.Brightness = lightBrightnessVal
    else
        if light then light:Destroy() end
    end
end

local lightBtn = createToggleButton("Light", visualContainer, yOffsetVisual)
yOffsetVisual = yOffsetVisual + 46

lightBtn.MouseButton1Click:Connect(function()
    lightEnabled = not lightEnabled
    if lightEnabled then
        lightBtn.Text = "Light [ON]"
        lightBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
    else
        lightBtn.Text = "Light [OFF]"
        lightBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
    end
    updateLight()
end)

createSlider("Light Range", visualContainer, yOffsetVisual, 1, 100, lightRangeVal, 1, function(val)
    lightRangeVal = val
    updateLight()
end)
yOffsetVisual = yOffsetVisual + 46

createSlider("Light Strength", visualContainer, yOffsetVisual, 1, 10, lightBrightnessVal, 1, function(val)
    lightBrightnessVal = val
    updateLight()
end)
yOffsetVisual = yOffsetVisual + 46

return true
end

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

local utilityContainer = ctx.Containers.utility

local fpsBoostEnabled = false
local originalFpsProperties = {}

local yOffsetUtil = 10

-- Rejoin Server
local rejoinBtn = Instance.new("TextButton")
rejoinBtn.Size = UDim2.new(0.92, 0, 0, 36)
rejoinBtn.Position = UDim2.new(0.04, 0, 0, yOffsetUtil)
rejoinBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
rejoinBtn.Text = "Rejoin Server"
rejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rejoinBtn.TextSize = 12
rejoinBtn.Font = Enum.Font.GothamBold
rejoinBtn.Parent = utilityContainer
Instance.new("UICorner", rejoinBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", rejoinBtn).Color = Color3.fromRGB(45, 45, 48)

rejoinBtn.MouseButton1Click:Connect(function()
    teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
end)
yOffsetUtil = yOffsetUtil + 46

-- Server Hop
local serverHopBtn = Instance.new("TextButton")
serverHopBtn.Size = UDim2.new(0.92, 0, 0, 36)
serverHopBtn.Position = UDim2.new(0.04, 0, 0, yOffsetUtil)
serverHopBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
serverHopBtn.Text = "Server Hop"
serverHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
serverHopBtn.TextSize = 12
serverHopBtn.Font = Enum.Font.GothamBold
serverHopBtn.Parent = utilityContainer
Instance.new("UICorner", serverHopBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", serverHopBtn).Color = Color3.fromRGB(45, 45, 48)

serverHopBtn.MouseButton1Click:Connect(function()
    teleportService:Teleport(game.PlaceId, player)
end)
yOffsetUtil = yOffsetUtil + 46

-- FPS Booster
local fpsBoostEnabled = false
local fpsBoosterBtn = Instance.new("TextButton")
fpsBoosterBtn.Size = UDim2.new(0.92, 0, 0, 36)
fpsBoosterBtn.Position = UDim2.new(0.04, 0, 0, yOffsetUtil)
fpsBoosterBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
fpsBoosterBtn.Text = "FPS Booster"
fpsBoosterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsBoosterBtn.TextSize = 12
fpsBoosterBtn.Font = Enum.Font.GothamBold
fpsBoosterBtn.Parent = utilityContainer
Instance.new("UICorner", fpsBoosterBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", fpsBoosterBtn).Color = Color3.fromRGB(45, 45, 48)

fpsBoosterBtn.MouseButton1Click:Connect(function()
    fpsBoostEnabled = not fpsBoostEnabled
    if fpsBoostEnabled then
        originalFpsProperties = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                originalFpsProperties[obj] = {material = obj.Material}
                obj.Material = Enum.Material.SmoothPlastic
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                originalFpsProperties[obj] = {enabled = obj.Enabled}
                obj.Enabled = false
            end
        end
        fpsBoosterBtn.Text = "FPS Booster [ON]"
        fpsBoosterBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
    else
        for obj, data in pairs(originalFpsProperties) do
            if obj and obj.Parent then
                pcall(function()
                    if data.material then obj.Material = data.material end
                    if data.enabled ~= nil then obj.Enabled = data.enabled end
                end)
            end
        end
        originalFpsProperties = {}
        fpsBoosterBtn.Text = "FPS Booster [OFF]"
        fpsBoosterBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
    end
end)
yOffsetUtil = yOffsetUtil + 46

return true
end

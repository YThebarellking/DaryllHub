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

local teleportContainer = ctx.Containers.teleport

local teleportPoint = nil
local autoTeleportEnabled = false
local autoTeleportDelay = 1.0
local autoTeleportToken = 0

local yOffsetTeleport = 10

local setTpBtn = Instance.new("TextButton")
setTpBtn.Size = UDim2.new(0.92, 0, 0, 38)
setTpBtn.Position = UDim2.new(0.04, 0, 0, yOffsetTeleport)
setTpBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
setTpBtn.Text = "Set Teleport"
setTpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
setTpBtn.TextSize = 13
setTpBtn.Font = Enum.Font.GothamBold
setTpBtn.Parent = teleportContainer
Instance.new("UICorner", setTpBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", setTpBtn).Color = Color3.fromRGB(45, 45, 48)

setTpBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        teleportPoint = hrp.CFrame
        setTpBtn.Text = "Location Saved!"
        setTpBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        task.delay(1.5, function()
            setTpBtn.Text = "Set Teleport"
            setTpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
    end
end)
yOffsetTeleport = yOffsetTeleport + 46

local tpToBtn = Instance.new("TextButton")
tpToBtn.Size = UDim2.new(0.92, 0, 0, 38)
tpToBtn.Position = UDim2.new(0.04, 0, 0, yOffsetTeleport)
tpToBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
tpToBtn.Text = "Teleport to Location"
tpToBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpToBtn.TextSize = 13
tpToBtn.Font = Enum.Font.GothamBold
tpToBtn.Parent = teleportContainer
Instance.new("UICorner", tpToBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", tpToBtn).Color = Color3.fromRGB(45, 45, 48)

tpToBtn.MouseButton1Click:Connect(function()
    if teleportPoint then
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = teleportPoint end
    else
        tpToBtn.Text = "No Location Saved!"
        tpToBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        task.delay(1.5, function()
            tpToBtn.Text = "Teleport to Location"
            tpToBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
    end
end)
yOffsetTeleport = yOffsetTeleport + 46

local autoTpName = "Auto Teleport"
local autoTeleportBtn = createToggleButton(autoTpName, teleportContainer, yOffsetTeleport)
yOffsetTeleport = yOffsetTeleport + 46

autoTeleportBtn.MouseButton1Click:Connect(function()
    autoTeleportEnabled = not autoTeleportEnabled
    autoTeleportToken = autoTeleportToken + 1
    local token = autoTeleportToken
    if autoTeleportEnabled then
        autoTeleportBtn.Text = autoTpName .. " [ON]"
        autoTeleportBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        task.spawn(function()
            while autoTeleportEnabled and token == autoTeleportToken do
                if teleportPoint then
                    local hrp = getRoot()
                    if hrp then hrp.CFrame = teleportPoint end
                end
                task.wait(autoTeleportDelay)
            end
        end)
    else
        autoTeleportBtn.Text = autoTpName .. " [OFF]"
        autoTeleportBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

createSlider("Auto TP Delay", teleportContainer, yOffsetTeleport, 0.1, 5.0, autoTeleportDelay, 0.1, function(val)
    autoTeleportDelay = val
end)
yOffsetTeleport = yOffsetTeleport + 46

return true
end

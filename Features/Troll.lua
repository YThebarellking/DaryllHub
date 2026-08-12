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

local trollContainer = ctx.Containers.troll

local spectatingPlayer = nil
local selectedPlayer = nil
local playerButtons = {}
local touchFlingStartPos = nil
local touchFlingActive = false
local touchFlingConnection = nil

local yOffsetTroll = 10

local playerListFrame = Instance.new("Frame")
playerListFrame.Size = UDim2.new(0.92, 0, 0, 150)
playerListFrame.Position = UDim2.new(0.04, 0, 0, yOffsetTroll)
playerListFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
playerListFrame.Parent = trollContainer
Instance.new("UICorner", playerListFrame).CornerRadius = UDim.new(0, 6)

local listStroke = Instance.new("UIStroke")
listStroke.Color = Color3.fromRGB(45, 45, 48)
listStroke.Thickness = 1
listStroke.Parent = playerListFrame

local playerListScroll = Instance.new("ScrollingFrame")
playerListScroll.Size = UDim2.new(1, 0, 1, 0)
playerListScroll.BackgroundTransparency = 1
playerListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerListScroll.ScrollBarThickness = 2
playerListScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65)
playerListScroll.Parent = playerListFrame

local playerListLabel = Instance.new("TextLabel")
playerListLabel.Size = UDim2.new(1, 0, 0, 20)
playerListLabel.BackgroundTransparency = 1
playerListLabel.Text = "Select player:"
playerListLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
playerListLabel.TextSize = 11
playerListLabel.Font = Enum.Font.GothamMedium
playerListLabel.Parent = playerListScroll

local selectedPlayer = nil
local playerButtons = {}

local function updatePlayerList()
    for _, child in ipairs(playerListScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    playerButtons = {}
    local y = 25
    
    local noneBtn = Instance.new("TextButton")
    noneBtn.Size = UDim2.new(0.96, 0, 0, 30)
    noneBtn.Position = UDim2.new(0.02, 0, 0, y)
    noneBtn.BackgroundColor3 = selectedPlayer == nil and Color3.fromRGB(50, 50, 55) or Color3.fromRGB(32, 32, 35)
    noneBtn.Text = "None (No Target)"
    noneBtn.TextColor3 = Color3.fromRGB(239, 68, 68)
    noneBtn.TextSize = 12
    noneBtn.Font = Enum.Font.GothamBold
    noneBtn.Parent = playerListScroll
    Instance.new("UICorner", noneBtn).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", noneBtn).Color = Color3.fromRGB(45, 45, 48)
    
    noneBtn.MouseButton1Click:Connect(function()
        for _, b in ipairs(playerButtons) do b.BackgroundColor3 = Color3.fromRGB(32, 32, 35) end
        noneBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        selectedPlayer = nil
    end)
    table.insert(playerButtons, noneBtn)
    y = y + 35

    for _, p in ipairs(players:GetPlayers()) do
        if p ~= player then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.96, 0, 0, 30)
            btn.Position = UDim2.new(0.02, 0, 0, y)
            btn.BackgroundColor3 = selectedPlayer == p and Color3.fromRGB(50, 50, 55) or Color3.fromRGB(32, 32, 35)
            btn.Text = p.Name
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 12
            btn.Font = Enum.Font.GothamMedium
            btn.Parent = playerListScroll
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            Instance.new("UIStroke", btn).Color = Color3.fromRGB(45, 45, 48)

            btn.MouseButton1Click:Connect(function()
                for _, b in ipairs(playerButtons) do b.BackgroundColor3 = Color3.fromRGB(32, 32, 35) end
                btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                selectedPlayer = p
            end)
            table.insert(playerButtons, btn)
            y = y + 35
        end
    end
    playerListScroll.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

updatePlayerList()
players.PlayerAdded:Connect(updatePlayerList)
players.PlayerRemoving:Connect(function(p)
    if selectedPlayer == p then selectedPlayer = nil end
    if xrayPlayerConnections[p] then
        xrayPlayerConnections[p]:Disconnect()
        xrayPlayerConnections[p] = nil
    end
    removeXray(p)
    updatePlayerList()
end)

yOffsetTroll = yOffsetTroll + 160

-- TP to Target
local tpTargetBtn = Instance.new("TextButton")
tpTargetBtn.Size = UDim2.new(0.92, 0, 0, 36)
tpTargetBtn.Position = UDim2.new(0.04, 0, 0, yOffsetTroll)
tpTargetBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
tpTargetBtn.Text = "Teleport to Target"
tpTargetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpTargetBtn.TextSize = 12
tpTargetBtn.Font = Enum.Font.GothamBold
tpTargetBtn.Parent = trollContainer
Instance.new("UICorner", tpTargetBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", tpTargetBtn).Color = Color3.fromRGB(45, 45, 48)

tpTargetBtn.MouseButton1Click:Connect(function()
    if selectedPlayer and selectedPlayer.Character then
        local targetHrp = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myChar = player.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if targetHrp and myHrp then myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3) end
    end
end)
yOffsetTroll = yOffsetTroll + 46

-- Spectate Target
local spectateBtn = createToggleButton("Spectate Target", trollContainer, yOffsetTroll)
yOffsetTroll = yOffsetTroll + 46

spectateBtn.MouseButton1Click:Connect(function()
    if spectatingPlayer then
        spectatingPlayer = nil
        spectateBtn.Text = "Spectate Target [OFF]"
        spectateBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = player.Character.Humanoid
        end
    else
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
            spectatingPlayer = selectedPlayer
            spectateBtn.Text = "Spectate Target [ON]"
            spectateBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
            camera.CameraSubject = selectedPlayer.Character.Humanoid
        end
    end
end)

local function applyFlingVelocity(hrp)
    local multiplier = 50000
    local currentVelocity = hrp.Velocity
    hrp.Velocity = currentVelocity * multiplier + Vector3.new(0, multiplier, 0)
    runService.RenderStepped:Wait()
    hrp.Velocity = currentVelocity
    runService.Stepped:Wait()
    hrp.Velocity = currentVelocity + Vector3.new(0, 0.1, 0)
end

-- Touch Fling
local touchFlingBtn = createToggleButton("Touch Fling", trollContainer, yOffsetTroll)
yOffsetTroll = yOffsetTroll + 46

local touchFlingActive = false
local touchFlingConnection = nil

touchFlingBtn.MouseButton1Click:Connect(function()
    touchFlingActive = not touchFlingActive
    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

    if touchFlingActive then
        if myHRP and selectedPlayer ~= nil then
            touchFlingStartPos = myHRP.CFrame
        else
            touchFlingStartPos = nil 
        end
        
        touchFlingBtn.Text = "Touch Fling [ON]"
        touchFlingBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        
        touchFlingConnection = runService.Heartbeat:Connect(function()
            if not touchFlingActive then return end
            local target = selectedPlayer
            if target and target.Character then
                local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP and myHRP then
                    myHRP.CFrame = targetHRP.CFrame * CFrame.new(math.random(-1, 1), 0, math.random(-1, 1))
                end
            end
            if myHRP then applyFlingVelocity(myHRP) end
        end)
    else
        touchFlingBtn.Text = "Touch Fling [OFF]"
        touchFlingBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if touchFlingConnection then
            touchFlingConnection:Disconnect()
            touchFlingConnection = nil
        end
        if myHRP then
            myHRP.Velocity = Vector3.new(0, 0, 0)
            myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            myHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            if touchFlingStartPos then
                task.defer(function()
                    myHRP.CFrame = touchFlingStartPos
                    touchFlingStartPos = nil
                end)
            end
        end
    end
end)

-- Fling All
local flingAllBtn = Instance.new("TextButton")
flingAllBtn.Size = UDim2.new(0.92, 0, 0, 36)
flingAllBtn.Position = UDim2.new(0.04, 0, 0, yOffsetTroll)
flingAllBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
flingAllBtn.Text = "Fling All Players"
flingAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flingAllBtn.TextSize = 12
flingAllBtn.Font = Enum.Font.GothamBold
flingAllBtn.Parent = trollContainer
Instance.new("UICorner", flingAllBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", flingAllBtn).Color = Color3.fromRGB(45, 45, 48)

flingAllBtn.MouseButton1Click:Connect(function()
    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local startPos = myHRP.CFrame
    
    task.spawn(function()
        for _, p in ipairs(players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local targetHrp = p.Character.HumanoidRootPart
                for i = 1, 10 do
                    myHRP.CFrame = targetHrp.CFrame * CFrame.new(math.random(-1, 1), 0, math.random(-1, 1))
                    applyFlingVelocity(myHRP)
                    task.wait()
                end
            end
        end
        myHRP.CFrame = startPos
    end)
end)
yOffsetTroll = yOffsetTroll + 46

return true
end

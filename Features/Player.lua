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

local playerContainer = ctx.Containers.player

local flyConnection, flyInputBegan, flyInputEnded
local bg, bv
local originalCanCollide = {}
local originalHumanoidStates = {}
local godSaved = {}
local originalTransparency = {}
local invisChair = nil
local invisConnection = nil
local godModeEnabled = false
local noclipEnabled = false
local flyEnabled = false
local infiniteJumpEnabled = false
local clickTpEnabled = false
local autoBhopEnabled = false
local spinbotEnabled = false
local invisibleEnabled = false
local flySpeed = 1
local walkSpeed = 16
local jumpPower = 50
local hipHeightVal = 2
local spinSpeed = 20
local lastPinchDistance = nil

local yOffset = 10

createSlider("Walk Speed", playerContainer, yOffset, 16, 200, walkSpeed, function(val)
    walkSpeed = val
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = walkSpeed
    end
end)
yOffset = yOffset + 46

createSlider("Jump Power", playerContainer, yOffset, 50, 300, jumpPower, function(val)
    jumpPower = val
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.UseJumpPower = true 
        char.Humanoid.JumpPower = jumpPower
    end
end)
yOffset = yOffset + 46

createSlider("Gravity", playerContainer, yOffset, 0, 196.2, 196.2, 5, function(val)
    workspace.Gravity = val
end)
yOffset = yOffset + 46

createSlider("Hip Height", playerContainer, yOffset, 0, 50, hipHeightVal, 1, function(val)
    hipHeightVal = val
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.HipHeight = hipHeightVal
    end
end)
yOffset = yOffset + 46

-- Infinite jump
local infiniteJumpBtn = createToggleButton("Infinite Jump", playerContainer, yOffset)
yOffset = yOffset + 46
local function toggleInfiniteJump()
    infiniteJumpEnabled = not infiniteJumpEnabled
    if infiniteJumpEnabled then
        infiniteJumpBtn.Text = "Infinite Jump [ON]"
        infiniteJumpBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        infiniteJumpConnection = userInputService.JumpRequest:Connect(function()
            if not infiniteJumpEnabled then return end
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    hum.Jump = true
                    if hum.GetState and hum:GetState() == Enum.HumanoidStateType.Freefall then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end)
    else
        infiniteJumpBtn.Text = "Infinite Jump [OFF]"
        infiniteJumpBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if infiniteJumpConnection then
            infiniteJumpConnection:Disconnect()
            infiniteJumpConnection = nil
        end
    end
end
infiniteJumpBtn.MouseButton1Click:Connect(toggleInfiniteJump)

-- Click TP
local clickTpBtn = createToggleButton("Click TP (Tap / Ctrl+Click)", playerContainer, yOffset)
yOffset = yOffset + 46

local function toggleClickTp()
    clickTpEnabled = not clickTpEnabled
    if clickTpEnabled then
        clickTpBtn.Text = "Click TP [ON]"
        clickTpBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        
        clickTpConnection = userInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed or not clickTpEnabled then return end
            
            local isClick = (input.UserInputType == Enum.UserInputType.MouseButton1 and userInputService:IsKeyDown(Enum.KeyCode.LeftControl)) or (input.UserInputType == Enum.UserInputType.Touch)
            
            if isClick then
                local unitRay = camera:ScreenPointToRay(input.Position.X, input.Position.Y)
                local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000)
                local targetPos = raycastResult and raycastResult.Position or mouse.Hit.Position
                
                local char = player.Character
                if char and targetPos then
                    char:MoveTo(targetPos)
                end
            end
        end)
    else
        clickTpBtn.Text = "Click TP [OFF]"
        clickTpBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if clickTpConnection then
            clickTpConnection:Disconnect()
            clickTpConnection = nil
        end
    end
end
clickTpBtn.MouseButton1Click:Connect(toggleClickTp)

-- Auto Bhop
local bhopBtn = createToggleButton("Auto-Bhop", playerContainer, yOffset)
yOffset = yOffset + 46

local function toggleBhop()
    autoBhopEnabled = not autoBhopEnabled
    if autoBhopEnabled then
        bhopBtn.Text = "Auto-Bhop [ON]"
        bhopBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        
        bhopConnection = runService.Heartbeat:Connect(function()
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.FloorMaterial ~= Enum.Material.Air and hum.MoveDirection.Magnitude > 0 then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    else
        bhopBtn.Text = "Auto-Bhop [OFF]"
        bhopBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if bhopConnection then bhopConnection:Disconnect() bhopConnection = nil end
    end
end
bhopBtn.MouseButton1Click:Connect(toggleBhop)

-- Spinbot
local spinbotBtn = createToggleButton("Spinbot", playerContainer, yOffset)
yOffset = yOffset + 46

local function toggleSpinbot()
    spinbotEnabled = not spinbotEnabled
    if spinbotEnabled then
        spinbotBtn.Text = "Spinbot [ON]"
        spinbotBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        
        spinbotLoop = runService.Heartbeat:Connect(function()
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
            end
        end)
    else
        spinbotBtn.Text = "Spinbot [OFF]"
        spinbotBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if spinbotLoop then spinbotLoop:Disconnect() spinbotLoop = nil end
    end
end
spinbotBtn.MouseButton1Click:Connect(toggleSpinbot)

createSlider("Spin Speed", playerContainer, yOffset, 5, 100, spinSpeed, 5, function(val)
    spinSpeed = val
end)
yOffset = yOffset + 46

-- Reset Character Button
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0.92, 0, 0, 36)
resetBtn.Position = UDim2.new(0.04, 0, 0, yOffset)
resetBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
resetBtn.Text = "Reset Character"
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.TextSize = 12
resetBtn.Font = Enum.Font.GothamBold
resetBtn.Parent = playerContainer
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", resetBtn).Color = Color3.fromRGB(45, 45, 48)

resetBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then hum.Health = 0 end
end)
yOffset = yOffset + 46

-- Noclip
local noclipBtn = createToggleButton("Noclip", playerContainer, yOffset)
yOffset = yOffset + 46
local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    if noclipEnabled then
        noclipBtn.Text = "Noclip [ON]"
        noclipBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        local char = getCharacter()
        originalCanCollide = {}
        if char then
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    originalCanCollide[part] = part.CanCollide
                    part.CanCollide = false
                end
            end
        end
        noclipLoop = char and char.ChildAdded:Connect(function(part)
            if noclipEnabled and part:IsA("BasePart") then
                originalCanCollide[part] = part.CanCollide
                part.CanCollide = false
            end
        end)
    else
        noclipBtn.Text = "Noclip [OFF]"
        noclipBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if noclipLoop then noclipLoop:Disconnect() noclipLoop = nil end
        for part, canCollide in pairs(originalCanCollide) do
            if part and part.Parent then part.CanCollide = canCollide end
        end
        originalCanCollide = {}
    end
end
noclipBtn.MouseButton1Click:Connect(toggleNoclip)

-- God mode
local godBtn = createToggleButton("God Mode (Not all games)", playerContainer, yOffset)
yOffset = yOffset + 46

local function setupGodMode(character)
    if not character or not godModeEnabled then return end
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then return end

    godSaved = {
        humanoid = humanoid,
        maxHealth = humanoid.MaxHealth,
        health = humanoid.Health,
        deadEnabled = humanoid:GetStateEnabled(Enum.HumanoidStateType.Dead),
        canTouch = {}
    }

    humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    humanoid.MaxHealth = math.max(humanoid.MaxHealth, 1e9)
    humanoid.Health = humanoid.MaxHealth

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            godSaved.canTouch[part] = part.CanTouch
        end
    end
end

local function restoreGodMode()
    local saved = godSaved
    godSaved = {}
    local humanoid = saved.humanoid
    if humanoid and humanoid.Parent then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, saved.deadEnabled ~= false)
        humanoid.MaxHealth = saved.maxHealth or 100
        humanoid.Health = math.min(saved.health or humanoid.MaxHealth, humanoid.MaxHealth)
    end
    for part, canTouch in pairs(saved.canTouch or {}) do
        if part and part.Parent then part.CanTouch = canTouch end
    end
end

local function toggleGodMode()
    godModeEnabled = not godModeEnabled
    if godModeEnabled then
        godBtn.Text = "God Mode (Not all games) [ON]"
        godBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        if player.Character then setupGodMode(player.Character) end
        godLoop = runService.Heartbeat:Connect(function()
            local char = getCharacter()
            local hum = getHumanoid(char)
            if char and hum and godModeEnabled then
                if hum.MaxHealth < 1e9 then hum.MaxHealth = 1e9 end
                if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
            end
        end)
    else
        godBtn.Text = "God Mode (Not all games) [OFF]"
        godBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if godLoop then godLoop:Disconnect() godLoop = nil end
        restoreGodMode()
    end
end
godBtn.MouseButton1Click:Connect(toggleGodMode)

-- Fly
local flyBtn = createToggleButton("Fly", playerContainer, yOffset)
yOffset = yOffset + 46
local flyConnection = nil
local flyInputBegan = nil
local flyInputEnded = nil
local flyKeyState = {W = false, A = false, S = false, D = false, Space = false, LeftControl = false}
local flyOldPlatformStand = false
local flyOldAnimateDisabled = false

local function stopFly()
    flyEnabled = false

    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if flyInputBegan then flyInputBegan:Disconnect() flyInputBegan = nil end
    if flyInputEnded then flyInputEnded:Disconnect() flyInputEnded = nil end
    if bg then bg:Destroy() bg = nil end
    if bv then bv:Destroy() bv = nil end

    table.clear(flyKeyState)
    flyKeyState = {W = false, A = false, S = false, D = false, Space = false, LeftControl = false}

    local char = getCharacter()
    local hum = getHumanoid(char)
    if hum then
        hum.PlatformStand = flyOldPlatformStand
        for state, enabled in pairs(originalHumanoidStates) do
            pcall(function() hum:SetStateEnabled(state, enabled) end)
        end
    end

    local animate = char and char:FindFirstChild("Animate")
    if animate and flyOldAnimateDisabled ~= nil then
        animate.Disabled = flyOldAnimateDisabled
    end
end

local function toggleFly()
    if flyEnabled then
        flyBtn.Text = "Fly [OFF]"
        flyBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        stopFly()
        return
    end

    local char = getCharacter()
    local hum = getHumanoid(char)
    local root = getRoot(char)
    if not char or not hum or not root then
        flyBtn.Text = "Fly (No Character)"
        flyBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        task.delay(1.2, function()
            if flyBtn.Parent then
                flyBtn.Text = "Fly [OFF]"
                flyBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
            end
        end)
        return
    end

    flyEnabled = true
    flyBtn.Text = "Fly [ON]"
    flyBtn.TextColor3 = Color3.fromRGB(50, 200, 50)

    flyOldPlatformStand = hum.PlatformStand
    local animate = char:FindFirstChild("Animate")
    flyOldAnimateDisabled = animate and animate.Disabled or false

    originalHumanoidStates = {}
    for _, state in ipairs({
        Enum.HumanoidStateType.Climbing,
        Enum.HumanoidStateType.FallingDown,
        Enum.HumanoidStateType.Freefall,
        Enum.HumanoidStateType.Jumping,
        Enum.HumanoidStateType.Landed,
        Enum.HumanoidStateType.Physics,
        Enum.HumanoidStateType.PlatformStanding,
        Enum.HumanoidStateType.Ragdoll,
        Enum.HumanoidStateType.Running,
        Enum.HumanoidStateType.RunningNoPhysics,
        Enum.HumanoidStateType.Seated,
        Enum.HumanoidStateType.StrafingNoPhysics,
        Enum.HumanoidStateType.Swimming
    }) do
        originalHumanoidStates[state] = hum:GetStateEnabled(state)
        hum:SetStateEnabled(state, false)
    end

    hum.PlatformStand = true
    if animate then animate.Disabled = true end

    bg = Instance.new("BodyGyro")
    bg.Name = "DaryllFlyGyro"
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = root.CFrame
    bg.Parent = root

    bv = Instance.new("BodyVelocity")
    bv.Name = "DaryllFlyVelocity"
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = root

    flyInputBegan = userInputService.InputBegan:Connect(function(input, processed)
        if processed or not flyEnabled then return end
        local key = ({
            [Enum.KeyCode.W] = "W", [Enum.KeyCode.A] = "A", [Enum.KeyCode.S] = "S",
            [Enum.KeyCode.D] = "D", [Enum.KeyCode.Space] = "Space", [Enum.KeyCode.LeftControl] = "LeftControl"
        })[input.KeyCode]
        if key then flyKeyState[key] = true end
    end)

    flyInputEnded = userInputService.InputEnded:Connect(function(input)
        local key = ({
            [Enum.KeyCode.W] = "W", [Enum.KeyCode.A] = "A", [Enum.KeyCode.S] = "S",
            [Enum.KeyCode.D] = "D", [Enum.KeyCode.Space] = "Space", [Enum.KeyCode.LeftControl] = "LeftControl"
        })[input.KeyCode]
        if key then flyKeyState[key] = false end
    end)

    flyConnection = runService.RenderStepped:Connect(function()
        if not flyEnabled then return end
        local currentChar = getCharacter()
        local currentHum = getHumanoid(currentChar)
        local currentRoot = getRoot(currentChar)
        local cam = getCamera()
        if not currentChar or not currentHum or not currentRoot or not cam or not bv or not bg then
            stopFly()
            return
        end

        local move = Vector3.new(0, 0, 0)
        local look = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector
        local flatLook = Vector3.new(look.X, 0, look.Z)
        local flatRight = Vector3.new(right.X, 0, right.Z)

        if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
        if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end

        if flyKeyState.W then move = move + flatLook end
        if flyKeyState.S then move = move - flatLook end
        if flyKeyState.D then move = move + flatRight end
        if flyKeyState.A then move = move - flatRight end
        if flyKeyState.Space then move = move + Vector3.new(0, 1, 0) end
        if flyKeyState.LeftControl then move = move - Vector3.new(0, 1, 0) end

        if move.Magnitude > 0 then move = move.Unit end
        bv.Velocity = move * (flySpeed * 50)
        bg.CFrame = cam.CFrame
    end)
end

flyBtn.MouseButton1Click:Connect(toggleFly)

createSlider("Fly Speed", playerContainer, yOffset, 1, 10, flySpeed, function(val)
    flySpeed = val
end)
yOffset = yOffset + 46

-- Invisible
local function saveCharacterTransparency(character)
    originalTransparency = {}
    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture") then
            originalTransparency[descendant] = descendant.Transparency
        end
    end
end

local function setCharacterTransparency(character, transparency)
    if not character then return end
    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture") then
            descendant.Transparency = transparency
        end
    end
end

local function restoreCharacterTransparency(character)
    if not character then return end
    for object, transparency in pairs(originalTransparency) do
        if object and object.Parent then
            pcall(function() object.Transparency = transparency end)
        end
    end
    originalTransparency = {}
end

local function applyInvisibility(character, enabled)
    if not character then return end

    if invisChair then invisChair:Destroy() invisChair = nil end
    if invisConnection then invisConnection:Disconnect() invisConnection = nil end

    if enabled then
        saveCharacterTransparency(character)
        setCharacterTransparency(character, 1)
        invisConnection = character.DescendantAdded:Connect(function(child)
            if not invisibleEnabled then return end
            if child:IsA("BasePart") or child:IsA("Decal") or child:IsA("Texture") then
                child.Transparency = 1
            end
        end)
    else
        restoreCharacterTransparency(character)
    end
end

local invisibleBtn = createToggleButton("Invisible", playerContainer, yOffset)
yOffset = yOffset + 46

local function toggleInvisible()
    invisibleEnabled = not invisibleEnabled
    local char = getCharacter()
    if invisibleEnabled then
        invisibleBtn.Text = "Invisible [ON]"
        invisibleBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        if char then applyInvisibility(char, true) end
    else
        invisibleBtn.Text = "Invisible [OFF]"
        invisibleBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if char then applyInvisibility(char, false) end
    end
end
invisibleBtn.MouseButton1Click:Connect(toggleInvisible)

return true
end

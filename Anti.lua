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

local antiContainer = ctx.Containers.anti

local antiSwimEnabled = false
local antiVoidEnabled = false
local antiRagdollEnabled = false
local antiKnockbackEnabled = false
local antiSitEnabled = false
local antiFreezeEnabled = false
local antiStunEnabled = false
local antiSlowEnabled = false
local antiFlingEnabled = false
local antiFallDamageEnabled = false
local antiExplosionEnabled = false
local antiRopeEnabled = false
local antiPushEnabled = false
local antiAfkEnabled = false
local antiFlingLoop, antiAfkConnection, antiSwimLoop, antiVoidLoop, antiRagdollLoop
local antiKnockbackLoop, antiSitLoop, antiFreezeLoop, antiStunLoop, antiSlowLoop
local antiFallDamageLoop, antiExplosionLoop, antiRopeLoop, antiPushLoop
local originalAnchored = {}
local originalPhysicalProperties = {}

local yOffsetAnti = 10

-- Anti Swim
local antiSwimBtn = createToggleButton("Anti Swim", antiContainer, yOffsetAnti)
yOffsetAnti = yOffsetAnti + 46
antiSwimBtn.MouseButton1Click:Connect(function()
    antiSwimEnabled = not antiSwimEnabled
    if antiSwimEnabled then
        antiSwimBtn.Text = "Anti Swim [ON]"
        antiSwimBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        antiSwimLoop = runService.Heartbeat:Connect(function()
            local char = player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
                if hum:GetState() == Enum.HumanoidStateType.Swimming then
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end
        end)
    else
        antiSwimBtn.Text = "Anti Swim [OFF]"
        antiSwimBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if antiSwimLoop then antiSwimLoop:Disconnect() antiSwimLoop = nil end
        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true) end
    end
end)

-- Anti Void
local antiVoidBtn = createToggleButton("Anti Void", antiContainer, yOffsetAnti)
yOffsetAnti = yOffsetAnti + 46
antiVoidBtn.MouseButton1Click:Connect(function()
    antiVoidEnabled = not antiVoidEnabled
    if antiVoidEnabled then
        antiVoidBtn.Text = "Anti Void [ON]"
        antiVoidBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        antiVoidLoop = runService.Heartbeat:Connect(function()
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Position.Y < (workspace.FallenPartsDestroyHeight + 20) then
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.CFrame = CFrame.new(hrp.Position.X, workspace.FallenPartsDestroyHeight + 100, hrp.Position.Z)
            end
        end)
    else
        antiVoidBtn.Text = "Anti Void [OFF]"
        antiVoidBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if antiVoidLoop then antiVoidLoop:Disconnect() antiVoidLoop = nil end
    end
end)

-- Anti Ragdoll
local antiRagdollBtn = createToggleButton("Anti Ragdoll", antiContainer, yOffsetAnti)
yOffsetAnti = yOffsetAnti + 46
antiRagdollBtn.MouseButton1Click:Connect(function()
    antiRagdollEnabled = not antiRagdollEnabled
    if antiRagdollEnabled then
        antiRagdollBtn.Text = "Anti Ragdoll [ON]"
        antiRagdollBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        antiRagdollLoop = runService.Heartbeat:Connect(function()
            local char = player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                if hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum:GetState() == Enum.HumanoidStateType.FallingDown then
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end
        end)
    else
        antiRagdollBtn.Text = "Anti Ragdoll [OFF]"
        antiRagdollBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if antiRagdollLoop then antiRagdollLoop:Disconnect() antiRagdollLoop = nil end
        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        end
    end
end)

-- Anti Knockback
local antiKnockbackBtn = createToggleButton("Anti Knockback", antiContainer, yOffsetAnti)
yOffsetAnti = yOffsetAnti + 46
antiKnockbackBtn.MouseButton1Click:Connect(function()
    antiKnockbackEnabled = not antiKnockbackEnabled
    if antiKnockbackEnabled then
        antiKnockbackBtn.Text = "Anti Knockback [ON]"
        antiKnockbackBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        antiKnockbackLoop = runService.Heartbeat:Connect(function()
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            end
        end)
    else
        antiKnockbackBtn.Text = "Anti Knockback [OFF]"
        antiKnockbackBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if antiKnockbackLoop then antiKnockbackLoop:Disconnect() antiKnockbackLoop = nil end
    end
end)

-- Anti Sit
local antiSitBtn = createToggleButton("Anti Sit", antiContainer, yOffsetAnti)
yOffsetAnti = yOffsetAnti + 46
antiSitBtn.MouseButton1Click:Connect(function()
    antiSitEnabled = not antiSitEnabled
    if antiSitEnabled then
        antiSitBtn.Text = "Anti Sit [ON]"
        antiSitBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        antiSitLoop = runService.Heartbeat:Connect(function()
            local char = player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                if hum.Sit then hum.Sit = false end
            end
        end)
    else
        antiSitBtn.Text = "Anti Sit [OFF]"
        antiSitBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if antiSitLoop then antiSitLoop:Disconnect() antiSitLoop = nil end
        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end
    end
end)

-- Anti Freeze
local antiFreezeBtn = createToggleButton("Anti Freeze", antiContainer, yOffsetAnti)
yOffsetAnti = yOffsetAnti + 46
antiFreezeBtn.MouseButton1Click:Connect(function()
    antiFreezeEnabled = not antiFreezeEnabled
    if antiFreezeEnabled then
        antiFreezeBtn.Text = "Anti Freeze [ON]"
        antiFreezeBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        local char = getCharacter()
        originalAnchored = {}
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    originalAnchored[part] = part.Anchored
                    if part.Anchored then part.Anchored = false end
                end
            end
        end
        antiFreezeLoop = char and char.DescendantAdded:Connect(function(part)
            if antiFreezeEnabled and part:IsA("BasePart") then
                originalAnchored[part] = part.Anchored
                if part.Anchored then part.Anchored = false end
            end
        end)
    else
        antiFreezeBtn.Text = "Anti Freeze [OFF]"
        antiFreezeBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if antiFreezeLoop then antiFreezeLoop:Disconnect() antiFreezeLoop = nil end
        for part, anchored in pairs(originalAnchored) do
            if part and part.Parent then part.Anchored = anchored end
        end
        originalAnchored = {}
    end
end)

-- Anti Stun
local antiStunBtn = createToggleButton("Anti Stun", antiContainer, yOffsetAnti)
yOffsetAnti = yOffsetAnti + 46
antiStunBtn.MouseButton1Click:Connect(function()
    antiStunEnabled = not antiStunEnabled
    if antiStunEnabled then
        antiStunBtn.Text = "Anti Stun [ON]"
        antiStunBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        antiStunLoop = runService.Heartbeat:Connect(function()
            local char = player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then
                if hum.PlatformStand then hum.PlatformStand = false end
                if hum.DisableJump then hum.DisableJump = false end
            end
        end)
    else
        antiStunBtn.Text = "Anti Stun [OFF]"
        antiStunBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if antiStunLoop then antiStunLoop:Disconnect() antiStunLoop = nil end
    end
end)

-- Anti Slow
local antiSlowBtn = createToggleButton("Anti Slow", antiContainer, yOffsetAnti)
yOffsetAnti = yOffsetAnti + 46
antiSlowBtn.MouseButton1Click:Connect(function()
    antiSlowEnabled = not antiSlowEnabled
    if antiSlowEnabled then
        antiSlowBtn.Text = "Anti Slow [ON]"
        antiSlowBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        antiSlowLoop = runService.Heartbeat:Connect(function()
            local char = player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum and hum.WalkSpeed < walkSpeed then
                hum.WalkSpeed = walkSpeed
            end
        end)
    else
        antiSlowBtn.Text = "Anti Slow [OFF]"
        antiSlowBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if antiSlowLoop then antiSlowLoop:Disconnect() antiSlowLoop = nil end
    end
end)

-- Anti Fling (перенесено из Fun)
local antiFlingBtn = createToggleButton("Anti Fling", antiContainer, yOffsetAnti)
yOffsetAnti = yOffsetAnti + 46
local function toggleAntiFling()
    antiFlingEnabled = not antiFlingEnabled
    if antiFlingEnabled then
        antiFlingBtn.Text = "Anti Fling [ON]"
        antiFlingBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        antiFlingLoop = runService.Heartbeat:Connect(function()
            if not antiFlingEnabled then return end
            local char = player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then root.AssemblyAngularVelocity = Vector3.new(0, 0, 0) end
            end
            for _, p in ipairs(players:GetPlayers()) do
                if p ~= player and p.Character then
                    for _, part in ipairs(p.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                            part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                        end
                    end
                end
            end
        end)
    else
        antiFlingBtn.Text = "Anti Fling [OFF]"
        antiFlingBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if antiFlingLoop then antiFlingLoop:Disconnect() antiFlingLoop = nil end
    end
end
antiFlingBtn.MouseButton1Click:Connect(toggleAntiFling)

-- Anti Fall Damage
local antiFallDamageBtn = createToggleButton("Anti Fall Damage", antiContainer, yOffsetAnti)
yOffsetAnti = yOffsetAnti + 46
antiFallDamageBtn.MouseButton1Click:Connect(function()
    antiFallDamageEnabled = not antiFallDamageEnabled
    if antiFallDamageEnabled then
        antiFallDamageBtn.Text = "Anti Fall Damage [ON]"
        antiFallDamageBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        antiFallDamageLoop = runService.Heartbeat:Connect(function()
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.AssemblyLinearVelocity.Y < -50 then
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -20, hrp.AssemblyLinearVelocity.Z)
            end
        end)
    else
        antiFallDamageBtn.Text = "Anti Fall Damage [OFF]"
        antiFallDamageBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if antiFallDamageLoop then antiFallDamageLoop:Disconnect() antiFallDamageLoop = nil end
    end
end)

-- Anti Explosion
local antiExplosionBtn = createToggleButton("Anti Explosion", antiContainer, yOffsetAnti)
yOffsetAnti = yOffsetAnti + 46
antiExplosionBtn.MouseButton1Click:Connect(function()
    antiExplosionEnabled = not antiExplosionEnabled
    if antiExplosionEnabled then
        antiExplosionBtn.Text = "Anti Explosion [ON]"
        antiExplosionBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        antiExplosionLoop = workspace.ChildAdded:Connect(function(child)
            if antiExplosionEnabled and child:IsA("Explosion") then
                child.Hit:Connect(function(part, distance)
                    if part and part:IsDescendantOf(player.Character) then
                        child.BlastPressure = 0
                    end
                end)
            end
        end)
    else
        antiExplosionBtn.Text = "Anti Explosion [OFF]"
        antiExplosionBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if antiExplosionLoop then antiExplosionLoop:Disconnect() antiExplosionLoop = nil end
    end
end)

-- Anti Rope
local antiRopeBtn = createToggleButton("Anti Rope", antiContainer, yOffsetAnti)
yOffsetAnti = yOffsetAnti + 46
antiRopeBtn.MouseButton1Click:Connect(function()
    antiRopeEnabled = not antiRopeEnabled
    if antiRopeEnabled then
        antiRopeBtn.Text = "Anti Rope [ON]"
        antiRopeBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        local char = getCharacter()
        if char then
            antiRopeLoop = char.DescendantAdded:Connect(function(obj)
                if not antiRopeEnabled then return end
                if obj:IsA("RopeConstraint") or obj:IsA("SpringConstraint") or obj:IsA("RodConstraint") or obj:IsA("CableConstraint") then
                    obj:Destroy()
                end
            end)
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("RopeConstraint") or obj:IsA("SpringConstraint") or obj:IsA("RodConstraint") or obj:IsA("CableConstraint") then
                    obj:Destroy()
                end
            end
        end
    else
        antiRopeBtn.Text = "Anti Rope [OFF]"
        antiRopeBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if antiRopeLoop then antiRopeLoop:Disconnect() antiRopeLoop = nil end
    end
end)

-- Anti Push
local antiPushBtn = createToggleButton("Anti Push", antiContainer, yOffsetAnti)
yOffsetAnti = yOffsetAnti + 46
antiPushBtn.MouseButton1Click:Connect(function()
    antiPushEnabled = not antiPushEnabled
    if antiPushEnabled then
        antiPushBtn.Text = "Anti Push [ON]"
        antiPushBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        local char = getCharacter()
        if char then
            originalPhysicalProperties = {}
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    originalPhysicalProperties[part] = part.CustomPhysicalProperties
                    part.CustomPhysicalProperties = PhysicalProperties.new(100, 1, 0, 1, 1)
                end
            end
        end
        antiPushLoop = char and char.ChildAdded:Connect(function(part)
            if antiPushEnabled and part:IsA("BasePart") then
                originalPhysicalProperties[part] = part.CustomPhysicalProperties
                part.CustomPhysicalProperties = PhysicalProperties.new(100, 1, 0, 1, 1)
            end
        end)
    else
        antiPushBtn.Text = "Anti Push [OFF]"
        antiPushBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if antiPushLoop then antiPushLoop:Disconnect() antiPushLoop = nil end
        local char = getCharacter()
        if char then
            for part, properties in pairs(originalPhysicalProperties) do
                if part and part.Parent then
                    part.CustomPhysicalProperties = properties
                end
            end
        end
        originalPhysicalProperties = {}
    end
end)

-- Anti AFK (перенесено из Utility)
local antiAfkBtn = createToggleButton("Anti-AFK", antiContainer, yOffsetAnti)
yOffsetAnti = yOffsetAnti + 46
local function toggleAntiAfk()
    antiAfkEnabled = not antiAfkEnabled
    if antiAfkEnabled then
        antiAfkBtn.Text = "Anti-AFK [ON]"
        antiAfkBtn.TextColor3 = Color3.fromRGB(50, 200, 50)
        antiAfkConnection = player.Idled:Connect(function()
            virtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            virtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    else
        antiAfkBtn.Text = "Anti-AFK [OFF]"
        antiAfkBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
        if antiAfkConnection then antiAfkConnection:Disconnect() antiAfkConnection = nil end
    end
end
antiAfkBtn.MouseButton1Click:Connect(toggleAntiAfk)

return true
end

-- DaryllHub modular loader
-- Put this file at:
-- https://raw.githubusercontent.com/YThebarellking/DaryllHub/refs/heads/main/Main.lua

local BASE = "https://raw.githubusercontent.com/YThebarellking/DaryllHub/refs/heads/main/"

local ctx = {
    PlayersService = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    Lighting = game:GetService("Lighting"),
    CoreGui = game:GetService("CoreGui"),
    TeleportService = game:GetService("TeleportService"),
    VirtualUser = game:GetService("VirtualUser")
}

ctx.Player = ctx.PlayersService.LocalPlayer

local function loadModule(path)
    local ok, source = pcall(function()
        return game:HttpGet(BASE .. path)
    end)

    if not ok then
        error("DaryllHub: HTTP failed for " .. path .. "\n" .. tostring(source))
    end

    local compiler = loadstring or load
    if not compiler then
        error("DaryllHub: loadstring/load is unavailable")
    end

    local chunk, err = compiler(source)
    if not chunk then
        error("DaryllHub: compile failed for " .. path .. "\n" .. tostring(err))
    end

    local okRun, result = pcall(chunk)
    if not okRun then
        error("DaryllHub: module failed " .. path .. "\n" .. tostring(result))
    end

    if type(result) ~= "function" then
        error("DaryllHub: module must return function(ctx): " .. path)
    end

    local okInit, moduleResult = pcall(result, ctx)
    if not okInit then
        error("DaryllHub: module init failed " .. path .. "\n" .. tostring(moduleResult))
    end

    return moduleResult
end

ctx.Features = {}

-- Services
loadModule("Services/Connections.lua")
loadModule("Services/Character.lua")
loadModule("Services/Players.lua")

-- UI
loadModule("UI/Components.lua")
loadModule("UI/Tabs.lua")
loadModule("UI/Notifications.lua")
loadModule("UI/Window.lua")

ctx.Window:Create()

local tabNames = {"Player", "Movement", "Anti", "Fun", "Troll", "Teleport", "Visual", "Utility"}
local tabContainers = {
    ctx.Containers.Player,
    nil,
    ctx.Containers.Anti,
    ctx.Containers.Fun,
    ctx.Containers.Troll,
    ctx.Containers.Teleport,
    ctx.Containers.Visual,
    ctx.Containers.Utility
}

-- Insert Movement container into the UI.
do
    local c = Instance.new("ScrollingFrame")
    c.Name = "MovementContainer"
    c.Size = UDim2.new(1, -95, 1, -50)
    c.Position = UDim2.new(0, 90, 0, 45)
    c.BackgroundTransparency = 1
    c.CanvasSize = UDim2.new(0, 0, 0, 300)
    c.ScrollBarThickness = 2
    c.Parent = ctx.MainFrame
    c.Visible = false
    ctx.Containers.Movement = c
    tabContainers[2] = c
end

ctx.Tabs:Create(ctx.TabPanel, tabNames, tabContainers)

-- Features. Each file builds its original tab immediately.
loadModule("Features/Player.lua")
loadModule("Features/Movement.lua")
loadModule("Features/Anti.lua")
loadModule("Features/Fun.lua")
loadModule("Features/Troll.lua")
loadModule("Features/Teleport.lua")
loadModule("Features/Visual.lua")
loadModule("Features/Utility.lua")

-- Character refresh shared by all modules.
ctx.Connections:Add("CharacterAddedMain", ctx.Player.CharacterAdded:Connect(function(character)
    task.wait(0.2)

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.UseJumpPower = true
    end
end))

ctx.Connections:Add("CameraChanged", workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if workspace.CurrentCamera then
        ctx.Camera = workspace.CurrentCamera
    end
end))

ctx.Notify:Show("DaryllHub loaded")
print("DaryllHub Loaded Successfully!")

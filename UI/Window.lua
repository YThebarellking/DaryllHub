return function(ctx)
    local Window = {}

    function Window:Create()
        local parent = ctx.CoreGui:FindFirstChild("RobloxGui") or ctx.CoreGui

        local old = parent:FindFirstChild("DaryllHub_Xeno")
        if old then old:Destroy() end

        local gui = Instance.new("ScreenGui")
        gui.Name = "DaryllHub_Xeno"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.Parent = parent
        ctx.ScreenGui = gui

        local main = Instance.new("Frame")
        main.Size = UDim2.new(0, 450, 0, 300)
        main.Position = UDim2.new(0.5, -225, 0.5, -150)
        main.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
        main.BorderSizePixel = 0
        main.Active = true
        main.Parent = gui

        local mainStroke = Instance.new("UIStroke")
        mainStroke.Color = Color3.fromRGB(45, 45, 48)
        mainStroke.Thickness = 1
        mainStroke.Parent = main

        local mainCorner = Instance.new("UICorner")
        mainCorner.CornerRadius = UDim.new(0, 8)
        mainCorner.Parent = main

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 40)
        title.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
        title.Text = "DaryllHub"
        title.TextColor3 = Color3.new(1, 1, 1)
        title.TextSize = 16
        title.Font = Enum.Font.GothamBold
        title.BorderSizePixel = 0
        title.Parent = main

        local titleCorner = Instance.new("UICorner")
        titleCorner.CornerRadius = UDim.new(0, 8)
        titleCorner.Parent = title

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 55, 0, 55)
        toggle.Position = UDim2.new(0.02, 0, 0.1, 0)
        toggle.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
        toggle.Text = "Daryll"
        toggle.TextColor3 = Color3.new(1, 1, 1)
        toggle.TextSize = 13
        toggle.Font = Enum.Font.GothamBold
        toggle.Parent = gui

        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 28)
        toggleCorner.Parent = toggle

        local toggleStroke = Instance.new("UIStroke")
        toggleStroke.Color = Color3.fromRGB(45, 45, 48)
        toggleStroke.Thickness = 1.5
        toggleStroke.Parent = toggle

        toggle.MouseButton1Click:Connect(function()
            main.Visible = not main.Visible
        end)

        local panel = Instance.new("Frame")
        panel.Size = UDim2.new(0, 85, 1, -40)
        panel.Position = UDim2.new(0, 0, 0, 40)
        panel.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
        panel.BorderSizePixel = 0
        panel.Parent = main

        local names = {"Player", "Anti", "Fun", "Troll", "Teleport", "Visual", "Utility"}
        local containers = {}
        for _, name in ipairs(names) do
            local c = Instance.new("ScrollingFrame")
            c.Name = name .. "Container"
            c.Size = UDim2.new(1, -95, 1, -50)
            c.Position = UDim2.new(0, 90, 0, 45)
            c.BackgroundTransparency = 1
            c.CanvasSize = UDim2.new(0, 0, 0, 1500)
            c.ScrollBarThickness = 2
            c.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65)
            c.Parent = main
            c.Visible = false
            containers[name] = c
        end

        do
            local dragging = false
            local dragStart
            local startPos

            title.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startPos = main.Position

                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end)
                end
            end)

            ctx.UserInputService.InputChanged:Connect(function(input)
                if not dragging then return end
                if input.UserInputType ~= Enum.UserInputType.MouseMovement
                    and input.UserInputType ~= Enum.UserInputType.Touch then
                    return
                end

                local delta = input.Position - dragStart
                main.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end)
        end

        ctx.MainFrame = main
        ctx.TabPanel = panel
        ctx.Containers = containers

        return main
    end

    ctx.Window = Window
    return Window
end

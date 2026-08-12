return function(ctx)
    local Movement = {}

    function Movement:Build()
        local container = ctx.Containers.Movement
        local y = 10

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(0.92, 0, 0, 30)
        title.Position = UDim2.new(0.04, 0, 0, y)
        title.BackgroundTransparency = 1
        title.Text = "Movement features are located in Player"
        title.TextColor3 = Color3.fromRGB(210, 210, 210)
        title.TextSize = 11
        title.Font = Enum.Font.GothamMedium
        title.Parent = container

        y = y + 40

        local note = Instance.new("TextLabel")
        note.Size = UDim2.new(0.92, 0, 0, 70)
        note.Position = UDim2.new(0.04, 0, 0, y)
        note.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
        note.TextColor3 = Color3.fromRGB(170, 170, 170)
        note.TextWrapped = true
        note.Text = "Walk Speed, Jump Power, Infinite Jump, Bhop, Spinbot, Noclip, Fly, Click TP and Invisible remain in the Player tab to preserve the original DaryllHub layout."
        note.TextSize = 11
        note.Font = Enum.Font.Gotham
        note.Parent = container

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = note

        container.CanvasSize = UDim2.new(0, 0, 0, y + 80)
    end

    ctx.Features = ctx.Features or {}
    ctx.Features.Movement = Movement
    return Movement
end

return function(ctx)
    local Notifications = {}
    local holder

    local function ensureHolder()
        if holder and holder.Parent then return holder end
        holder = Instance.new("Frame")
        holder.Size = UDim2.new(0, 280, 0, 300)
        holder.Position = UDim2.new(1, -300, 0, 20)
        holder.BackgroundTransparency = 1
        holder.Parent = ctx.ScreenGui

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 6)
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
        layout.Parent = holder
        return holder
    end

    function Notifications:Show(message, duration)
        local parent = ensureHolder()
        duration = duration or 2

        local item = Instance.new("TextLabel")
        item.Size = UDim2.new(1, 0, 0, 42)
        item.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
        item.TextColor3 = Color3.new(1, 1, 1)
        item.Text = "  " .. tostring(message)
        item.TextXAlignment = Enum.TextXAlignment.Left
        item.Font = Enum.Font.GothamMedium
        item.TextSize = 12
        item.BorderSizePixel = 0
        item.Parent = parent

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 7)
        corner.Parent = item

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(45, 45, 48)
        stroke.Parent = item

        task.delay(duration, function()
            if item and item.Parent then item:Destroy() end
        end)
    end

    ctx.Notify = Notifications
    return Notifications
end

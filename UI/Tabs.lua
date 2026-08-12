return function(ctx)
    local Tabs = {}

    function Tabs:Create(panel, names, containers)
        local buttons = {}

        for i, name in ipairs(names) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.Position = UDim2.new(0, 0, 0, (i - 1) * 32)
            btn.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
            btn.Text = name
            btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            btn.TextSize = 10
            btn.Font = Enum.Font.GothamBold
            btn.BorderSizePixel = 0
            btn.Parent = panel
            buttons[name] = btn

            btn.MouseButton1Click:Connect(function()
                for _, c in ipairs(containers) do
                    c.Visible = false
                end

                for _, b in pairs(buttons) do
                    b.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
                    b.TextColor3 = Color3.fromRGB(150, 150, 150)
                end

                containers[i].Visible = true
                btn.BackgroundColor3 = Color3.fromRGB(32, 32, 35)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            end)
        end

        if containers[1] then containers[1].Visible = true end
        if buttons[names[1]] then
            buttons[names[1]].BackgroundColor3 = Color3.fromRGB(32, 32, 35)
            buttons[names[1]].TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        return buttons
    end

    ctx.Tabs = Tabs
    return Tabs
end

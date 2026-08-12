return function(ctx)
    local Components = {}

    local function corner(instance, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 6)
        c.Parent = instance
        return c
    end

    local function stroke(instance, color, thickness)
        local s = Instance.new("UIStroke")
        s.Color = color or Color3.fromRGB(45, 45, 48)
        s.Thickness = thickness or 1
        s.Parent = instance
        return s
    end

    function Components:CreateToggle(text, container, yPos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.92, 0, 0, 36)
        btn.Position = UDim2.new(0.04, 0, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
        btn.Text = text .. " [OFF]"
        btn.TextColor3 = Color3.fromRGB(239, 68, 68)
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = container
        corner(btn)
        stroke(btn)
        return btn
    end

    function Components:CreateButton(text, container, yPos, callback)
        local btn = self:CreateToggle(text, container, yPos)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        if callback then
            btn.MouseButton1Click:Connect(callback)
        end
        return btn
    end

    function Components:CreateSlider(text, container, yPos, minVal, maxVal, defaultValue, step, onChanged)
        if type(step) == "function" then
            onChanged = step
            step = 1
        end
        step = step or 1

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.92, 0, 0, 38)
        frame.Position = UDim2.new(0.04, 0, 0, yPos)
        frame.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
        frame.BorderSizePixel = 0
        frame.Parent = container
        corner(frame)
        stroke(frame)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, 0, 1, 0)
        label.Position = UDim2.new(0.03, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. tostring(defaultValue)
        label.TextColor3 = Color3.fromRGB(230, 230, 230)
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.GothamMedium
        label.Parent = frame

        local plus = Instance.new("TextButton")
        plus.Size = UDim2.new(0.18, 0, 0.7, 0)
        plus.Position = UDim2.new(0.58, 0, 0.15, 0)
        plus.BackgroundColor3 = Color3.fromRGB(40, 40, 44)
        plus.Text = "+"
        plus.TextColor3 = Color3.new(1, 1, 1)
        plus.TextSize = 14
        plus.Font = Enum.Font.GothamBold
        plus.Parent = frame
        corner(plus, 4)

        local minus = plus:Clone()
        minus.Position = UDim2.new(0.78, 0, 0.15, 0)
        minus.Text = "-"
        minus.Parent = frame

        local currentValue = defaultValue

        local function updateValue(newVal)
            newVal = math.clamp(newVal, minVal, maxVal)
            newVal = math.round(newVal * 10) / 10
            currentValue = newVal
            label.Text = text .. ": " .. tostring(currentValue)
            if onChanged then
                onChanged(currentValue)
            end
        end

        plus.MouseButton1Click:Connect(function()
            updateValue(currentValue + step)
        end)

        minus.MouseButton1Click:Connect(function()
            updateValue(currentValue - step)
        end)

        updateValue(defaultValue)
        return frame, function() return currentValue end, updateValue
    end

    ctx.UI = Components
    return Components
end

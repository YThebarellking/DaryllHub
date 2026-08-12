return function(ctx)
    local Character = {}

    function Character:Get()
        return ctx.Player.Character
    end

    function Character:Humanoid(character)
        character = character or self:Get()
        return character and character:FindFirstChildOfClass("Humanoid")
    end

    function Character:Root(character)
        character = character or self:Get()
        return character and character:FindFirstChild("HumanoidRootPart")
    end

    function Character:OnSpawn(callback)
        return ctx.Connections:Add("CharacterAdded", ctx.Player.CharacterAdded:Connect(function(char)
            task.defer(callback, char)
        end))
    end

    ctx.Character = Character
    return Character
end

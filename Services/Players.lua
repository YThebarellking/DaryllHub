return function(ctx)
    local PlayerService = {}

    function PlayerService:GetAll()
        return ctx.PlayersService:GetPlayers()
    end

    function PlayerService:GetOthers()
        local out = {}
        for _, p in ipairs(self:GetAll()) do
            if p ~= ctx.Player then table.insert(out, p) end
        end
        return out
    end

    function PlayerService:GetRoot(p)
        local char = p and p.Character
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    ctx.PlayerManager = PlayerService
    return PlayerService
end

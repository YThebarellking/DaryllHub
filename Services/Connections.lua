return function(ctx)
    local Connections = {items = {}}

    function Connections:Add(name, connection)
        self:Remove(name)
        self.items[name] = connection
        return connection
    end

    function Connections:Remove(name)
        local connection = self.items[name]
        if connection then
            pcall(function() connection:Disconnect() end)
            self.items[name] = nil
        end
    end

    function Connections:Clear()
        for name in pairs(self.items) do
            self:Remove(name)
        end
    end

    ctx.Connections = Connections
    return Connections
end

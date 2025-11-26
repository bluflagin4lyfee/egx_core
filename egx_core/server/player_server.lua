-- egx_core/server/player_server.lua

EGX = EGX or {}
EGX.Players = EGX.Players or {}

-- Player object
local Player = {}
Player.__index = Player

function Player:new(src, identifiers)
    local self = setmetatable({}, Player)

    self.source      = src
    self.identifiers = identifiers or {}
    self.metadata    = {}
    self.session     = {
        connectedAt = os.time(),
        coords      = nil,
    }

    return self
end

function Player:GetSource()
    return self.source
end

function Player:GetIdentifiers()
    return self.identifiers
end

function Player:GetMeta(key)
    return self.metadata[key]
end

function Player:SetMeta(key, value)
    self.metadata[key] = value
end

function Player:SetSession(key, value)
    self.session[key] = value
end

function Player:GetSession(key)
    return self.session[key]
end

function Player:SetCoords(coords)
    self.session.coords = coords
end

-- EGX API

function EGX.CreatePlayer(src)
    local ids = GetPlayerIdentifiers(src)
    local identifiers = {}

    for _, id in ipairs(ids) do
        local prefix, value = id:match("([^:]+):(.+)")
        if prefix and value then
            identifiers[prefix] = value
        end
    end

    local player = Player:new(src, identifiers)
    EGX.Players[src] = player

    EGX:Debug(("Player %s connected (EGX Player created)"):format(src))
    return player
end

function EGX.GetPlayer(src)
    return EGX.Players[src]
end

function EGX.RemovePlayer(src)
    EGX.Players[src] = nil
    EGX:Debug(("Player %s removed from EGX cache"):format(src))
end

exports('GetPlayer', function(src)
    return EGX.GetPlayer(src)
end)

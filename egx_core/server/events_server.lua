-- egx_core/server/events_server.lua

EGX = EGX or {}

AddEventHandler('playerJoining', function()
    local src = source
    EGX.CreatePlayer(src)
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    EGX.RemovePlayer(src)
end)

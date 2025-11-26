-- egx_core/server/core_server.lua

EGX = EGX or {}

AddEventHandler('onResourceStart', function(resName)
    if resName ~= GetCurrentResourceName() then return end
    EGX:Log('info', ('EGX Core server initialized (v%s)'):format(EGX.Version or '?'))
end)

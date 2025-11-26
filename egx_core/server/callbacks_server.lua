-- egx_core/server/callbacks_server.lua

EGX = EGX or {}
EGX.Server = EGX.Server or {}
EGX.Server._callbacks = EGX.Server._callbacks or {}

local function debugPrint(msg)
    if EGX.Config and EGX.Config.Debug then
        print(("[EGX][CB][SERVER] %s"):format(msg))
    end
end

-- Register a server callback
function EGX.Server.RegisterCallback(name, cb)
    if type(name) ~= "string" or type(cb) ~= "function" then
        debugPrint("RegisterCallback called with invalid arguments")
        return
    end

    EGX.Server._callbacks[name] = cb
    debugPrint(("Registered callback: %s"):format(name))
end

-- Alias for convenience: EGX.RegisterCallback(...)
EGX.RegisterCallback = EGX.Server.RegisterCallback

-- Handle requests from clients
RegisterNetEvent('egx_core:triggerCallback', function(name, requestId, ...)
    local src = source
    local cbFn = EGX.Server._callbacks[name]

    if not cbFn then
        debugPrint(("⚠ unknown callback '%s' from %s"):format(tostring(name), src))
        TriggerClientEvent('egx_core:callbackResponse', src, requestId, false, nil)
        return
    end

    local ok, err = pcall(function()
        cbFn(src, function(result)
            TriggerClientEvent('egx_core:callbackResponse', src, requestId, true, result)
        end, ...)
    end)

    if not ok then
        debugPrint(("❌ error in callback '%s': %s"):format(tostring(name), err))
        TriggerClientEvent('egx_core:callbackResponse', src, requestId, false, nil)
    end
end)

-- Export for other resources
exports('CreateCallback', function(name, cb)
    EGX.Server.RegisterCallback(name, cb)
end)

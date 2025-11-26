-- egx_core/client/callbacks_client.lua

EGX = EGX or {}

local callbackRequestId = 0
local pendingCallbacks = {}

local function debugPrint(msg)
    if EGX.Config and EGX.Config.Debug then
        print(("[EGX][CB][CLIENT] %s"):format(msg))
    end
end

function EGX.TriggerCallback(name, cb, ...)
    callbackRequestId = callbackRequestId + 1
    local requestId = callbackRequestId

    pendingCallbacks[requestId] = {
        cb   = cb,
        name = name,
        at   = GetGameTimer(),
    }

    debugPrint(("→ %s (%s)"):format(name, requestId))
    TriggerServerEvent('egx_core:triggerCallback', name, requestId, ...)
end

RegisterNetEvent('egx_core:callbackResponse', function(requestId, ok, result)
    local entry = pendingCallbacks[requestId]
    if not entry then
        debugPrint(("⚠ unknown response %s"):format(requestId))
        return
    end

    pendingCallbacks[requestId] = nil
    debugPrint(("← %s (%s)"):format(entry.name, requestId))

    if entry.cb then
        entry.cb(ok and result or nil, ok)
    end
end)

-- Timeout watcher (prevents stuck callbacks)
CreateThread(function()
    while true do
        local now = GetGameTimer()
        local timeout = (EGX.Config and EGX.Config.CallbackTimeout) or 5000

        for id, entry in pairs(pendingCallbacks) do
            if now - entry.at > timeout then
                debugPrint(("⏱ timeout %s (%s)"):format(entry.name, id))
                local cb = entry.cb
                pendingCallbacks[id] = nil
                if cb then
                    cb(nil, false)
                end
            end
        end

        Wait(1000)
    end
end)

-- Export for other resources (Qbx-style)
exports('TriggerCallback', function(name, cb, ...)
    EGX.TriggerCallback(name, cb, ...)
end)

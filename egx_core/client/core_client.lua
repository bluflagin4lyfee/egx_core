-- egx_core/client/core_client.lua

EGX = EGX or {}

CreateThread(function()
    Wait(500) -- small delay to let shared init/config settle
    EGX:Debug('EGX Client core initialized')
end)

-- Examples for later (do not run anything heavy here)
-- You can add client-side boot logic or health checks in this file.

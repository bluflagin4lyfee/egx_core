-- egx_core/shared/init.lua

EGX = rawget(_G, 'EGX') or {}

EGX.Version      = EGX.Version      or '0.1.0'
EGX.Players      = EGX.Players      or {}
EGX.Config       = EGX.Config       or {}
EGX.Server       = EGX.Server       or {}
EGX.Interaction  = EGX.Interaction  or {}
EGX.Callbacks    = EGX.Callbacks    or {}

function EGX:Log(level, ...)
    local msg = table.concat({ ... }, " ")
    print(("[EGX][%s] %s"):format(tostring(level):upper(), msg))
end

function EGX:Debug(...)
    if self.Config and self.Config.Debug then
        self:Log('debug', ...)
    end
end

exports('GetCoreObject', function()
    return EGX
end)

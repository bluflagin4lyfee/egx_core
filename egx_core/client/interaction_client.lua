-- egx_core/client/interaction_client.lua
-- Look-at + press E interaction system

EGX = EGX or {}
EGX.Interaction = EGX.Interaction or {}

local function interactKey()
    return (EGX.Config and EGX.Config.InteractKey) or 38
end

local function maxDistance()
    return (EGX.Config and EGX.Config.InteractMaxDistance) or 3.0
end

EGX.Interaction._entities = EGX.Interaction._entities or {}
EGX.Interaction._current  = nil

local function debugPrint(msg)
    if EGX.Config and EGX.Config.Debug then
        print(("[EGX][INTERACT] %s"):format(msg))
    end
end

-- Convert camera rotation to direction vector
local function RotationToDirection(rot)
    local z = math.rad(rot.z)
    local x = math.rad(rot.x)

    local num = math.abs(math.cos(x))

    return vector3(
        -math.sin(z) * num,
        math.cos(z) * num,
        math.sin(x)
    )
end

-- Raycast from camera into world
local function RaycastFromCamera(distance, flags, ignoreEntity)
    local camPos = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)
    local dir = RotationToDirection(camRot)

    local dest = camPos + (dir * distance)

    local ray = StartShapeTestRay(
        camPos.x, camPos.y, camPos.z,
        dest.x, dest.y, dest.z,
        flags or 286,          -- 286: everything except peds and vehicles
        ignoreEntity or 0,
        7
    )

    local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(ray)
    return hit, endCoords, entityHit, surfaceNormal
end

-- Simple 3D text prompt
local function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if not onScreen then return end

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextCentre(1)
    SetTextOutline()

    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(_x, _y)
end

local function TriggerInteraction(entry, entity, coords)
    if not entry then return end

    debugPrint(("Triggering interaction: %s"):format(tostring(entry.label or "no_label")))

    -- Direct client function
    if entry.onInteract and type(entry.onInteract) == "function" then
        entry.onInteract(entity, coords, entry)
    end

    -- Client event
    if entry.clientEvent then
        TriggerEvent(entry.clientEvent, entity, coords, entry)
    end

    -- Server event
    if entry.serverEvent then
        TriggerServerEvent(entry.serverEvent, entity, coords, entry)
    end

    -- Server callback
    if entry.callback then
        EGX.TriggerCallback(entry.callback, function(result, ok)
            if entry.onResult and type(entry.onResult) == "function" then
                entry.onResult(result, ok, entity, coords, entry)
            end
        end, entity, coords, entry)
    end
end

-- Main interaction loop
CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        local hit, hitCoords, entity = RaycastFromCamera(maxDistance(), 286, ped)

        local found = false

        if hit == 1 and entity and entity ~= 0 then
            local model = GetEntityModel(entity)
            local data = EGX.Interaction._entities[model]

            if data then
                found = true
                sleep = 0

                EGX.Interaction._current = {
                    entity = entity,
                    coords = hitCoords,
                    data   = data
                }

                local label = data.label or "[E] Interact"
                Draw3DText(hitCoords.x, hitCoords.y, hitCoords.z + 0.1, label)

                if IsControlJustPressed(0, interactKey()) then
                    TriggerInteraction(data, entity, hitCoords)
                end
            end
        end

        if not found then
            EGX.Interaction._current = nil
        end

        Wait(sleep)
    end
end)

-- Register an interaction for a model
-- model: hash or model name string
-- data: table with optional fields:
--   label, clientEvent, serverEvent, callback, onInteract, onResult
function EGX.RegisterEntityInteraction(model, data)
    if type(model) == "string" then
        model = joaat(model)
    end

    if type(model) ~= "number" then
        debugPrint("RegisterEntityInteraction called with invalid model")
        return
    end

    EGX.Interaction._entities[model] = data or {}
    debugPrint(("Registered entity interaction for model: %s"):format(tostring(model)))
end

exports("RegisterEntityInteraction", function(model, data)
    EGX.RegisterEntityInteraction(model, data)
end)

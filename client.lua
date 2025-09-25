local KVP_KEY = "aura_blips"
local activeBlips = {}
local isAuthorized = false
Blips = {}

function Blips.SaveToKVP()
    local saveTable = {}
    for i, data in ipairs(activeBlips) do
        local copy = {}
        for k, v in pairs(data) do
            if k ~= "_blipHandle" then
                copy[k] = v
            end
        end
        saveTable[i] = copy
    end
    SetResourceKvp(KVP_KEY, json.encode(saveTable))
end

function Blips.LoadFromKVP()
    local data = GetResourceKvpString(KVP_KEY)
    if data then
        activeBlips = json.decode(data)
    else
        activeBlips = {}
    end
end

function Blips.Create(data)
    local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
    SetBlipSprite(blip, tonumber(data.sprite))
    SetBlipColour(blip, tonumber(data.color))
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.label)
    EndTextCommandSetBlipName(blip)
    local scale = tonumber(data.scale) or 1.0
    if scale > 1.0 then scale = 1.0 end
    scale = tonumber(string.format("%.1f", scale))
    SetBlipScale(blip, scale)
    if data.secondaryColor and tostring(data.secondaryColor) ~= "" then
        SetBlipSecondaryColour(blip, tonumber(data.secondaryColor))
    end
    if data.flashing ~= nil then
        SetBlipFlashes(blip, data.flashing)
    end
    if data.shortRange ~= nil then
        SetBlipAsShortRange(blip, data.shortRange)
    end
    data._blipHandle = blip
    return blip
end

function Blips.RemoveFromMap(blipHandle)
    if blipHandle and DoesBlipExist(blipHandle) then
        RemoveBlip(blipHandle)
    end
end

function Blips.UpdateAll()
    for _, data in ipairs(activeBlips) do
        if data._blipHandle and DoesBlipExist(data._blipHandle) then
            RemoveBlip(data._blipHandle)
            data._blipHandle = nil
        end
    end
    for _, data in ipairs(activeBlips) do
        data._blipHandle = Blips.Create(data)
    end
end

function Blips.LoadAndCreateAll()
    Blips.LoadFromKVP()
    Blips.UpdateAll()
end

RegisterNUICallback('createBlip', function(data, cb)
    table.insert(activeBlips, data)
    Blips.SaveToKVP()
    local idx = #activeBlips
    activeBlips[idx]._blipHandle = Blips.Create(activeBlips[idx])
    cb('ok')
end)

RegisterNUICallback('editBlip', function(data, cb)
    local idx = data.idx
    if activeBlips[idx] then
        Blips.RemoveFromMap(activeBlips[idx]._blipHandle)
        -- do NOT touch _blipHandle here 
        activeBlips[idx].label = data.label
        activeBlips[idx].coords = data.coords
        activeBlips[idx].sprite = data.sprite
        activeBlips[idx].color = data.color
        activeBlips[idx].scale = data.scale
        activeBlips[idx].secondaryColor = data.secondaryColor
        activeBlips[idx].flashing = data.flashing
        activeBlips[idx].shortRange = data.shortRange
        activeBlips[idx]._blipHandle = Blips.Create(activeBlips[idx])
        Blips.SaveToKVP()
    end
    cb('ok')
end)

RegisterNUICallback('removeBlip', function(data, cb)
    local idx = data.idx
    if activeBlips[idx] then
        Blips.RemoveFromMap(activeBlips[idx]._blipHandle)
        table.remove(activeBlips, idx)
        Blips.SaveToKVP()
    end
    cb('ok')
end)

RegisterNUICallback('getActiveBlips', function(_, cb)
    Blips.LoadFromKVP()
    cb(activeBlips)
end)


RegisterNetEvent('aura-blipscreator:authResult')
AddEventHandler('aura-blipscreator:authResult', function(authorized)
    isAuthorized = authorized
    if authorized then
        SetNuiFocus(true, true)
        Blips.LoadFromKVP()
        SendNUIMessage({ action = 'showUI', blips = activeBlips })
    else
        SendNUIMessage({
            action = 'showStatus',
            type = 'fail',
            message = 'You are not authorized to use this command.'
        })
    end
end)

RegisterCommand('blipscreator', function()
    TriggerServerEvent('aura-blipscreator:checkAuth')
end, false)

RegisterNUICallback('closeUI', function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hideUI' })
    cb('ok')
end)

RegisterNUICallback('getPlayerCoords', function(_, cb)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    SendNUIMessage({
        action = 'setCoords',
        coords = { x = coords.x, y = coords.y, z = coords.z }
    })
    cb('ok')
end)

CreateThread(function()
    Blips.LoadAndCreateAll()
end)

RegisterNetEvent('esx:playerLoaded', function()
    Blips.LoadAndCreateAll()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Blips.LoadAndCreateAll()
end)

AddEventHandler('playerSpawned', function()
    Blips.LoadAndCreateAll()
end)

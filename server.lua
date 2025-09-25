RegisterServerEvent('aura-blipscreator:checkAuth')
AddEventHandler('aura-blipscreator:checkAuth', function()
    local src = source
    local discordId = GetPlayerIdentifierByType(src, 'discord')
    local authorized = false
    
    if discordId then
        for _, authorizedId in ipairs(Config.AuthorizedDiscords) do
            if discordId == authorizedId then
                authorized = true
                break
            end
        end
    end
    
    TriggerClientEvent('aura-blipscreator:authResult', src, authorized)
end)

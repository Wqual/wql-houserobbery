ESX = exports.es_extended:getSharedObject()


RegisterServerEvent('WqlHouse:acquista')
AddEventHandler('WqlHouse:acquista', function(value)
    local xPlayer = ESX.GetPlayerFromId(source)
    local prezzoGrimaldello = 5830 -- Prezzo grimaldello

    if value == 'grimaldello' then
        if xPlayer.getMoney() >= prezzoGrimaldello then
            xPlayer.removeMoney(prezzoGrimaldello)
            xPlayer.addInventoryItem('grimaldello', 1)
            TriggerClientEvent('ox_lib:notify', xPlayer.source, {type = 'success', description = 'Hai comprato un grimaldello per: ' .. prezzoGrimaldello .. '$'})
        else
            TriggerClientEvent('ox_lib:notify', xPlayer.source, {type = 'error', description = 'Non hai abbastanza soldi!'})
        end
    end
end)

RegisterNetEvent("CercaDepositoCasa", function ()
    local item = {"collanaperle", "bracialetto", "felpanf", "trapstar", "jordan4", "69brand"}
    exports.ox_inventory:AddItem(source, item[math.random(#item)], math.random(1, 2))
end)

RegisterNetEvent("CercaDepositoCasa2", function ()
    local item = {"collanaperle", "bracialetto", "felpanf", "trapstar", "jordan4", "69brand"}
    exports.ox_inventory:AddItem(source, item[math.random(#item)], math.random(1, 2))
end)

RegisterNetEvent("CercaDepositoCasa3", function ()
    local item = {"collanaperle", "bracialetto", "felpanf", "trapstar", "jordan4", "69brand"}
    exports.ox_inventory:AddItem(source, item[math.random(#item)], math.random(1, 2))
end)

RegisterNetEvent("toglitem", function ()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem('grimaldello')
end)

RegisterServerEvent('entraincasa')
AddEventHandler('entraincasa', function()

    SetPlayerRoutingBucket(source, source)
end)

RegisterServerEvent('escidallacasa')
AddEventHandler('escidallacasa', function()

    SetPlayerRoutingBucket(source, 0)
end)

RegisterNetEvent("vendita_materialicasa", function(item, importo)
    
    exports.ox_inventory:RemoveItem(source, item, 1)
    exports.ox_inventory:AddItem(source, "money", importo)

end)

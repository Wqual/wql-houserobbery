ESX = exports.es_extended:getSharedObject()

-- BLIP START -- 
Wqualblip = AddBlipForCoord(-40.7615, -1674.7125, 29.4712)

SetBlipSprite(Wqualblip, 186)
SetBlipScale(Wqualblip, 1.0)
SetBlipColour(Wqualblip, 9)
BeginTextCommandSetBlipName("STRING")
AddTextComponentString("Miky")
EndTextCommandSetBlipName(Wqualblip)

Citizen.CreateThread(function()
    if not HasModelLoaded('a_m_y_soucent_02') then
       RequestModel('a_m_y_soucent_02')
       while not HasModelLoaded('a_m_y_soucent_02') do
          Citizen.Wait(5)
       end
    end

npc = CreatePed(4, 'a_m_y_soucent_02', -40.7923, -1674.7013, 28.4704, 132.8449, false, true)
FreezeEntityPosition(npc, true)
SetEntityInvincible(npc, true)
SetBlockingOfNonTemporaryEvents(npc, true)

local VenditaChiave = false
local StartHouseRobbery = true
local options = {
    {
        name = 'ox:option1',
        event = 'WqlHouse:acquista',
        icon = 'fa-solid fa-gun',
        label = '💸 Acquista Grimaldello',
        canInteract = function(entity)
            return not IsEntityDead(entity)
        end
    },
    {
        name = 'ox:option2',
        onSelect = function()
            if StartHouseRobbery == true then
                WqualMission() 
                StartHouseRobbery = false 
                Wait(1800000) 
                StartHouseRobbery = true
            elseif StartHouseRobbery == false then
                ESX.ShowNotification('Non ci sono case da rapinare al momento!')
            end
        end,
        icon = 'fa-solid fa-sack-dollar',
        label = '🏠 Civico Casa',
        canInteract = function(entity)
            return not IsEntityDead(entity) and StartHouseRobbery
        end
    }
}

exports.ox_target:addLocalEntity(npc,options)

end)

local VenditaChiave = nil

RegisterNetEvent('WqlHouse:acquista')
AddEventHandler('WqlHouse:acquista', function(value)
    VenditaChiave = value
end)

RegisterNetEvent('WqlHouse:acquista') 
AddEventHandler('WqlHouse:acquista', function()
    local Ped = PlayerPedId()
    local input = lib.inputDialog('Parla con Miky', {
        {type = 'select', label = 'Vendita di grimaldelli', options = {
            {label = "Grimaldello", value = "grimaldello"}
        }},
    })
    
    if input and #input > 0 then
        TriggerServerEvent('WqlHouse:acquista', input[1])
    end
end)

WqualMission = function()
    ESX.Game.SpawnVehicle('burrito3', vector3(-46.6498, -1678.5007, 29.3876), 85.29, function(v)
        SetPedIntoVehicle(PlayerPedId(), v, -1)
    end)
    ESX.ShowNotification('Raggiungi la casa da rapinare!')
    waypoint5 = SetNewWaypoint(-149.9468, 123.9495, 70.2254)
    Wql = AddBlipForCoord(-149.9468, 123.9495, 70.2254)
    SetBlipSprite (Wql, 40)
    SetBlipDisplay(Wql, 6)
    SetBlipScale  (Wql, 0.8)
    SetBlipColour (Wql, 2)
    SetBlipAsShortRange(Wql, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString("Casa da rapinare")
    EndTextCommandSetBlipName(Wql)
    
end 

local deposito1 = true
local casaPopolareEntrata = {
    coords = WQL.EntrataCasa,
    size = vec3(2, 2, 2),
    rotation = 45,
    debug = drawZones,
    options = {
        {
            name = 'casepopolari',
            icon = 'fa-solid fa-home',
            label = WQL.Traduzione["entra"],
            onSelect = function(data)
                -- Controlla se il giocatore ha il grimaldello per entrare nella casa da rapinare
                if HasKey("grimaldello") then -- Item

                    Citizen.Wait(1000*2)

                    DoScreenFadeOut(800)

                    Citizen.Wait(1000*3)

                    while not IsScreenFadedOut() do
                        Citizen.Wait(0)
                    end
                    TriggerServerEvent('entraincasa')
                    SetEntityCoords(PlayerPedId(), WQL.TeleportEntrata)
                    DoScreenFadeIn(800)
                else
                    -- Mostra un messaggio di errore se il giocatore non ha il grimaldello
					lib.notify({
						title = 'Casa da rapinare',
						description = 'Non hai la un grimaldello per forzare la serratura!',
						type = 'error'
					})
                    
                end
            end,
        },
    },
}


-- Definisci la zona di uscita dalla casa da rapinare
local casaPopolareUscita = {
    coords = WQL.UscitaCasa,
    size = vec3(2, 2, 2),
    rotation = 45,
    debug = drawZones,
    options = {
        {
            name = 'casepopolariuscita',
            icon = 'fa-solid fa-home',
            label = WQL.Traduzione["esci"],
            onSelect = function(data)
                -- Controlla se il giocatore ha il grimaldello per entrare nella casa da rapinare...
                if HasKey("grimaldello") then -- Item 
                    DoScreenFadeOut(800)
                    while not IsScreenFadedOut() do
                        Citizen.Wait(0)
                    end
                    TriggerServerEvent('escidallacasa')
                    SetEntityCoords(PlayerPedId(), WQL.TeleportUscita)

                    TriggerServerEvent('toglitem')

                    Citizen.Wait(1000*2)

                    DoScreenFadeIn(800)

                    Citizen.Wait(1000*3)
                    WqualVendita()
                else
                    -- Mostra un messaggio di errore se il giocatore non ha la chiave
					lib.notify({
						title = 'Casa da rapinare',
						description = 'Non hai la un grimaldello per forzare la serratura!',
						type = 'error'
					})
                    
                end
            end,
        },
    },
}


-- Aggiungi le zone al sistema di trigger della mappa
Citizen.CreateThread(function()
    exports.ox_target:addBoxZone(casaPopolareEntrata)
    exports.ox_target:addBoxZone(casaPopolareUscita)
end)

-- Controlla se il giocatore ha il grimaldello nell'inventario
function HasKey(keyName)
    local player = GetPlayerPed(-1)
    local inventory = ESX.GetPlayerData().inventory
    for i = 1, #inventory do
        local item = inventory[i]
        if item and item.name == keyName then
            return true
        end
    end
    return false
end

local cercadeposito1 = true
exports.ox_target:addBoxZone({
	coords = WQL.DepositoCasa,
	size = vec3(2, 2, 2),
	rotation = 45,
	debug = drawZones,
	options = {
		{
			name = 'casepopolari',
			icon = 'fa-solid fa-sack-dollar',
			label = WQL.Traduzione["frigobar"],
			onSelect = function(data)
                if lib.progressBar({
                    duration = 5000,
                    label = 'Cercando nei cassetti...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                    },
                    anim = {
                        dict = 'mini@repair',
                        clip = 'fixing_a_ped'
                    }
                }) then
                    ESX.ShowNotification('Non fare troppo rumore, altrimenti ti scopriranno...')

                    TriggerServerEvent("CercaDepositoCasa")
                    cercadeposito1 = false
    
                end
            end,
            canInteract = function(entity)
                return cercadeposito1
            end
		}
	}
})

local cercadeposito2 = true
exports.ox_target:addBoxZone({
	coords = WQL.DepositoCasa2,
	size = vec3(2, 2, 2),
	rotation = 45,
	debug = drawZones,
	options = {
		{
			name = 'casepopolari',
			icon = 'fa-solid fa-sack-dollar',
			label = WQL.Traduzione["deposito1"],
			onSelect = function(data)
                if lib.progressBar({
                    duration = 5000,
                    label = 'Cercando nel mobile...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                    },
                    anim = {
                        dict = 'mini@repair',
                        clip = 'fixing_a_ped'
                    }
                }) then
                    ESX.ShowNotification('Non fare troppo rumore, altrimenti ti scopriranno...')

                    TriggerServerEvent("CercaDepositoCasa2")
                    cercadeposito2 = false
    
                end
            end,
            canInteract = function(entity)
                return cercadeposito2
            end
		}
	}
})

local cercadeposito3 = true
exports.ox_target:addBoxZone({
	coords = WQL.DepositoCasa3,
	size = vec3(2, 2, 2),
	rotation = 45,
	debug = drawZones,
	options = {
		{
			name = 'casepopolari',
			icon = 'fa-solid fa-sack-dollar',
			label = WQL.Traduzione["deposito2"],
			onSelect = function(data)
                if lib.progressBar({
                    duration = 5000,
                    label = 'Cercando nel cassetto...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                    },
                    anim = {
                        dict = 'mini@repair',
                        clip = 'fixing_a_ped'
                    }
                }) then
                    ESX.ShowNotification('Non fare troppo rumore, altrimenti ti scopriranno...')

                    TriggerServerEvent("CercaDepositoCasa3")
                    cercadeposito3 = false
    
                end
            end,
            canInteract = function(entity)
                return cercadeposito3
            end
		}
	}
})

WqualVendita = function ()
    
    ESX.ShowNotification('Raggiungi il gps per vendere i materiali ricavati!')

    waypoint5 = SetNewWaypoint(1225.7233, -3234.1934, 6.0288)
    local Wqlv = AddBlipForCoord(1225.7233, -3234.1934, 6.0288)
    SetBlipSprite (Wqlv, 500)
    SetBlipDisplay(Wqlv, 6)
    SetBlipScale  (Wqlv, 0.9)
    SetBlipColour (Wqlv, 36)
    SetBlipAsShortRange(Wqlv, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString("Punto di vendita")
    EndTextCommandSetBlipName(Wqlv)
end



Citizen.CreateThread(function()
    if not HasModelLoaded('mp_m_g_vagfun_01') then
       RequestModel('mp_m_g_vagfun_01')
       while not HasModelLoaded('mp_m_g_vagfun_01') do
          Citizen.Wait(5)
       end
    end

local npc = CreatePed(4, 'mp_m_g_vagfun_01', 1225.9908, -3234.4290, 5.0288, 1.1545, false, true)
FreezeEntityPosition(npc, true)
SetEntityInvincible(npc, true)
SetBlockingOfNonTemporaryEvents(npc, true)


local venditamaterialicasa = {
    {
        name = 'ox:vendita',
        icon = 'fa-solid fa-money-bill',
        label = 'Vendi oggetti trovati',
        onSelect = function()
            local chechitem = exports.ox_inventory:Search('count', {"jordan4", "trapstar", "collanaperle", "bracialetto", "felpanf", "69brand"})
            if chechitem.jordan4 >= 1 then
                TriggerServerEvent("vendita_materialicasa", "jordan4", 5861)
            elseif chechitem.trapstar >= 1 then
                TriggerServerEvent("vendita_materialicasa", "trapstar", 7356)
            elseif chechitem.collanaperle >= 1 then
                TriggerServerEvent("vendita_materialicasa", "collanaperle", 2398)
            elseif chechitem.bracialetto >= 1 then
                TriggerServerEvent("vendita_materialicasa", "bracialetto", 4135)
            elseif chechitem.felpanf >= 1 then
                TriggerServerEvent("vendita_materialicasa", "felpanf", 4860)
            end
        end,
        canInteract = function(entity)
            return not IsEntityDead(entity)
        end
    }
}

exports.ox_target:addLocalEntity(npc,venditamaterialicasa)

end)

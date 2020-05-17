Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil
currentPos = nil
menuOpen = false

Citizen.CreateThread(function ()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
    ESX.TriggerServerCallback('esx_moneywash:getCurrentPos', function(pos)
        currentPos = pos
        showPed()
        ESX.UI.Menu.CloseAll()
    end)
    Citizen.Wait(5000)
    while ESX.PlayerData == nil do
        Citizen.Wait(5000)
        ESX.PlayerData = ESX.GetPlayerData()
    end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job

	Citizen.Wait(5000)
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
	ESX.PlayerData = ESX.GetPlayerData()
end)

function OpenWashingMenu()
	ESX.UI.Menu.CloseAll()
	local elements = {}
    menuOpen = true
    
    table.insert(elements, {
        label = _U('washing'),
        value = 'washing'
    })

    table.insert(elements, {
        label = _U('getmoney'),
        value = 'get_money'
    })

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'washer', {
		title    = _U('washer_title'),
		align    = 'top-left',
		elements = elements
    }, function(data, menu)
        if data.current.value == 'washing' then
            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'inventory_item_count_give', { 
                title = _U('quantity')
            }, function(data2, menu2)
                local quantity = tonumber(data2.value)
                TriggerServerEvent('esx_moneywash:sendMoney', quantity)
                menu2.close()
                menu.close()
                menuOpen = false
            end)
        elseif data.current.value == 'get_money' then
            TriggerServerEvent('esx_moneywash:getMoney')
            menu.close()
            menuOpen = false
        end
    end)
end

function OpenPoliceMenu()
	ESX.UI.Menu.CloseAll()
	local elements = {}
	menuOpen = true

    table.insert(elements, {
        label = _U('take'),
        value = 'take'
    })

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'washer', {
		title    = _U('washer_title'),
		align    = 'top-left',
		elements = elements
    }, function(data, menu)
        if data.current.value == 'take' then
            TriggerServerEvent('esx_moneywash:policeMoney')
            menu.close()
            menuOpen = false
        end
    end)
end

-- [WASHER NPC]
function showPed()
	RequestModel(GetHashKey("a_m_y_business_01"))
    while not HasModelLoaded(GetHashKey("a_m_y_business_01")) do
      Wait(1)
    end
  
    RequestAnimDict("mini@strip_club@idles@bouncer@base")
    while not HasAnimDictLoaded("mini@strip_club@idles@bouncer@base") do
      Wait(1)
    end
  
    washingped =  CreatePed(4, 0xc99f21c4, currentPos.x, currentPos.y, currentPos.z, 3374176, false, true)
    SetEntityHeading(washingped, currentPos.h)
    FreezeEntityPosition(washingped, true)
    SetEntityInvincible(washingped, true)
    SetBlockingOfNonTemporaryEvents(washingped, true)
    TaskPlayAnim(washingped,"mini@strip_club@idles@bouncer@base","base", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
end
  
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        if currentPos ~= nil then
            local vector = vector3(currentPos.x, currentPos.y, currentPos.z)
            if GetDistanceBetweenCoords(coords, vector, true) < 2 then
                if menuOpen == false then
                    ESX.ShowHelpNotification(_U('washer_prompt'))

                    if IsControlJustReleased(0, Keys['E']) then
                        if ESX.PlayerData.job.name == 'police' then
                            OpenPoliceMenu()
                        else
                            OpenWashingMenu()
                        end
                    end
                end
            else
                if menuOpen == true then
                    ESX.UI.Menu.CloseAll()
                    menuOpen = false
                end
            end
        else
            Citizen.Wait(500)
        end
    end
end)

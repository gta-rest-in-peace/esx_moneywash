-- [INIT] -------------
-- 
ESX = nil
currentPos = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- [LOADPOSITION] ----------
-- 
index = math.random(1,#Config.position)
currentPos = Config.position[index]

ESX.RegisterServerCallback('esx_moneywash:getCurrentPos', function(source, cb)
    while currentPos == nil do
        Citizen.Wait(500)
    end
    cb(currentPos)
end)

-- [MONEYWASH INTERACTION] --
-- Function to deposit black money
--
RegisterServerEvent('esx_moneywash:sendMoney')
AddEventHandler('esx_moneywash:sendMoney', function(amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if amount < Config.washminamount then
		TriggerClientEvent('esx:showNotification', source, _U('notenough_work', Config.washminamount))
		return
    end
    
    if amount > xPlayer.getAccount('black_money').money then
		TriggerClientEvent('esx:showNotification', source, _U('notenough_black'))
		return
    end

    if Config.washmult ~= 0 then
        timer = math.floor(amount/Config.washmult)
    else
        timer = Config.washtime
    end
    
    MySQL.Async.execute('INSERT INTO auto_moneywash (identifier, amount, get_date) VALUES (@identifier, @amount, NOW() + INTERVAL @get_date HOUR)', {
        ['@identifier'] = xPlayer.identifier,
        ['@amount']     = amount,
        ['@get_date']   = timer
    }, function(rowsChanged)
        xPlayer.removeAccountMoney('black_money', amount)
    end)
end)

-- Function to get back money when washing is finished
RegisterServerEvent('esx_moneywash:getMoney')
AddEventHandler('esx_moneywash:getMoney', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local _source = source
    
    MySQL.Async.fetchAll('SELECT * FROM auto_moneywash WHERE get_date < now() and identifier = @identifier', { -----TODO
        ['@identifier'] = xPlayer.identifier,
    }, function(results)
        if #results == 0 then
            TriggerClientEvent('esx:showNotification', _source, _U('no_wash'))
            return
        end
        for i=1, #results, 1 do
            MySQL.Async.execute('DELETE FROM auto_moneywash WHERE id = @id', { -----TODO
                ['@id'] = results[i].id
            }, function(rowsChanged)
                local famount = results[i].amount / 100 * Config.rate
                TriggerClientEvent('esx:showNotification', _source, _U('washed_amount', famount))
                xPlayer.addMoney(famount)
            end)
        end
    end)
end)

-- Function for police to grab blackmoney
RegisterServerEvent('esx_moneywash:policeMoney')
AddEventHandler('esx_moneywash:policeMoney', function(amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local copamount = 0
	
    if xPlayer.job.name == 'police' then
        MySQL.Async.fetchAll('SELECT * FROM auto_moneywash', {}, function(results)
            local _results = results
            if #_results == 0 then
                TriggerClientEvent('esx:showNotification', _source, _U('cop_no_wash'))
                return
            end
            
            for i=1, #_results, 1 do
                MySQL.Async.execute('DELETE FROM auto_moneywash WHERE id = @id', { -----TODO
                    ['@id'] = _results[i].id
                }, function(rowsChanged)
                end)
                copamount = copamount + _results[i].amount
            end
            TriggerClientEvent('esx:showNotification', _source, _U('cop_surrender', copamount))
            xPlayer.addAccountMoney('black_money', copamount)
        end)
    end	
end)

-- [MONEYWASH ROUTINE] --
-- Each x Time check if you need to notify the customers
Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(Config.washrefresh)
        MySQL.Async.fetchAll('SELECT * FROM auto_moneywash WHERE get_date < NOW() AND notified IS false', {}, function(results)
            if results ~= nil and #results > 0 then
                for i=1, #results, 1 do
                    MySQL.Async.execute('UPDATE auto_moneywash SET notified = true WHERE id = @id', {
                        ['@id']   = results[i].id
                    }, function(results2)
                        if results2 > 0 then
                            getPhoneNumberIdentifier(results[i].identifier, function(phone)
                                TriggerEvent('gcPhone:_internalAddMessage', "###-####", phone, 'Appelez moi au numero habituel, votre livraison est prete', 0, function (smsMess)
                                    xPlayer = ESX.GetPlayerFromIdentifier(results[i].identifier)
                                    if xPlayer ~= nil then
                                        TriggerClientEvent("gcPhone:receiveMessage", xPlayer.source, smsMess)
                                    end
                                end)
                            end)
                        end
                    end)
                end
            end
        end)
    end
end)

-- [PHONE] --
-- Retrive phone number from source
--
function getPhoneNumber(source, callback) 
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer == nil then
		callback(nil)
		return
	end
	MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier',{
		['@identifier'] = xPlayer.identifier
	}, function(result)
		callback(result[1].phone_number)
	end)
end

-- retrive Phone Number from identifier
--
function getPhoneNumberIdentifier(identifier, callback) 
	MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier',{
		['@identifier'] = identifier
	}, function(result)
		callback(result[1].phone_number)
	end)
end

-- When a message is sent to the right number 
--
RegisterServerEvent('gcPhone:sendMessage')
AddEventHandler('gcPhone:sendMessage', function(phoneNumber, message)
    local sourcePlayer = tonumber(source)
    if phoneNumber == Config.number then
        getPhoneNumber(sourcePlayer, function(phone)
            Citizen.Wait(10000)
            TriggerEvent('gcPhone:_internalAddMessage', Config.number, phone, 'Rejoignez moi ici :', 0, function (smsMess)
                TriggerClientEvent("gcPhone:receiveMessage", sourcePlayer, smsMess)
            end)
            Citizen.Wait(1000)
            TriggerEvent('gcPhone:_internalAddMessage', Config.number, phone, 'GPS: '.. currentPos.x ..', '.. currentPos.y, 0, function (smsMess)
                TriggerClientEvent("gcPhone:receiveMessage", sourcePlayer, smsMess)
            end)
        end)
    end
end)
--[[ ===================================================== ]] --
--[[     MH Framework (QBCore/ESX) Script by MaDHouSe79    ]] --
--[[ ===================================================== ]] --
Framework = nil
CreateCallback = nil

if Config.Framework == 'esx' then
    Framework = exports['es_extended']:getSharedObject()
    CreateCallback = Framework.RegisterServerCallback

    --- Get Players
    ---@param source number
    function GetPlayers()
        return Framework.GetPlayers()
    end

    --- Get Player
    ---@param source number
    function GetPlayer(source)
        return Framework.GetPlayerFromId(source)
    end

    function GetVehivicles()
        local vehicles = {}
        MySQL.Async.fetchAll("SELECT * FROM vehicles", {}, function(rs)
            for k, v in pairs(rs) do
                vehicles[#vehicles + 1] = {name = v.name, model = v.model}
            end
            cb(vehicles)
        end)
    end

    --- Get Money
    ---@param source number
    ---@param account string
    function GetMoney(source, account)
        local xPlayer = GetPlayer(source)
        return xPlayer.getAccount(account).money
    end


    --- Remove Money
    ---@param source number
    ---@param account string
    ---@param amount number
    function RemoveMoney(source, account, amount, reason)
        local xPlayer = GetPlayer(source)
        local last = GetMoney(source, account)
        xPlayer.removeAccountMoney(account, amount, reason)
        local current = GetMoney(source, account)
        if current < last then
            return true
        else
            return false
        end
    end

    --- Notify
    ---@param source any
    ---@param message any
    ---@param type any
    ---@param length any
    function Notify(source, message, type, length)
        TriggerClientEvent("mh-trailers:client:notify", source, message, type, length)
    end


elseif Config.Framework == 'qb' then

    Framework = exports['qb-core']:GetCoreObject()
    CreateCallback = Framework.Functions.CreateCallback

    --- Get Players
    ---@param source number
    function GetPlayers()
        return Framework.Functions.GetPlayers()
    end

    --- Get Player
    ---@param source number
    function GetPlayer(source)
        return Framework.Functions.GetPlayer(source)
    end

    function GetVehivicles()
        return Framework.Shared.Vehicles
    end
    
    --- Get Money
    ---@param source number
    ---@param account string
    function GetMoney(source, account)
        local xPlayer = GetPlayer(source)
        if account == 'bank' then
            return xPlayer.PlayerData.money.bank
        elseif account == 'cash' then
            return xPlayer.PlayerData.money.cash
        elseif account == 'blackmoney' then
            return xPlayer.PlayerData.money.blackmoney
        end
    end

    --- Remove Money
    ---@param source number
    ---@param account string
    ---@param amount number
    function RemoveMoney(source, account, amount, reason)
        local xPlayer = GetPlayer(source)
        if account == 'bank' then
            return xPlayer.Functions.RemoveMoney('bank', amount, reason)
        elseif account == 'cash' then
            return xPlayer.Functions.RemoveMoney('cash', amount, reason)
        elseif account == 'blackmoney' then
            return xPlayer.Functions.RemoveMoney('blackmoney', amount, reason)
        end
    end

    --- Notify
    ---@param src any
    ---@param message any
    ---@param type any
    ---@param length any
    function Notify(src, message, type, length)
        Framework.Functions.Notify(src, {text = Config.NotifyTitle,caption = message}, type, length)
    end
end

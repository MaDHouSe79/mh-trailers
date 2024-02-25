--[[ ===================================================== ]] --
--[[     MH Framework (QBCore/ESX) Script by MaDHouSe79    ]] --
--[[ ===================================================== ]] --
Framework = nil
PlayerData = {}
TriggerCallback = nil
OnPlayerLoaded = nil
OnPlayerUnload = nil
IsLoggedIn = false

function LoadModel(model)
    if not HasModelLoaded(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(1)
        end
    end
end

if Config.Framework == 'esx' then
    Framework = exports['es_extended']:getSharedObject()
    TriggerCallback = Framework.TriggerServerCallback
    OnPlayerLoaded = 'esx:playerLoaded'
    OnPlayerUnload = 'esx:playerUnLoaded'

    --- GetPlayerData
    function GetPlayerData()
        TriggerCallback('esx:getPlayerData', function(data)
            PlayerData = data
        end)
        return PlayerData
    end

    function GetMoney()
        TriggerCallback('esx:getPlayerData', function(data)
            return data.money
        end)
    end

    function DeleteVehicle(vehicle)
        Framework.Game.DeleteVehicle(vehicle)
    end

    function GetPlate(vehicle)
        return GetVehicleNumberPlateTextIndex(vehicle)
    end

    function SpawnTruck(model, position, heading)
        LoadModel(model)
        local vehicle = CreateVehicle(model, position, heading, true, true)
        local plate = 'T_RT_' .. string.format('%06d', math.random(100, 999))
        SetVehicleNumberPlateText(vehicle, plate)
        SetEntityHeading(vehicle, heading)
        exports[Config.FuelScript]:SetFuel(vehicle, 100.0)
        SetVehicleOnGroundProperly(vehicle)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        SetVehicleCustomPrimaryColour(vehicle, 0, 0, 0)
        SetVehicleDirtLevel(vehicle, 0)
        WashDecalsFromVehicle(vehicle, 1.0)
        SetVehRadioStation(vehicle, 'OFF')
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehicleBodyHealth(vehicle, 1000.0)
        if Config.Framework == 'qb' then
            TriggerServerEvent("qb-vehiclekeys:server:AcquireVehicleKeys", Framework.Functions.GetPlate(vehicle))
            TriggerEvent('mh-vehiclekeyitem:client:CreateTempKey', vehicle)
        end
        SetModelAsNoLongerNeeded(model)
        return vehicle, plate, heading
    end
    
    function SpawnTrailer(model, position, heading)
        LoadModel(model)
        local vehicle = CreateVehicle(model, position, heading, true, true)
        local plate = 'TR_RT_' .. string.format('%06d', math.random(100, 999))
        SetVehicleNumberPlateText(vehicle, plate)
        SetEntityHeading(vehicle, heading)
        SetVehicleOnGroundProperly(vehicle)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        SetVehicleCustomPrimaryColour(vehicle, 0, 0, 0)
        SetVehicleDirtLevel(vehicle, 0)
        WashDecalsFromVehicle(vehicle, 1.0)
        SetVehRadioStation(vehicle, 'OFF')
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehicleBodyHealth(vehicle, 1000.0)
        return vehicle, plate
    end

    function Notify(message, type, time)
        Framework.ShowNotification(message, type, time)
    end

elseif Config.Framework == 'qb' then
    Framework = exports['qb-core']:GetCoreObject()
    TriggerCallback = Framework.Functions.TriggerCallback
    OnPlayerLoaded = 'QBCore:Client:OnPlayerLoaded'
    OnPlayerUnload = 'QBCore:Client:OnPlayerUnload'
    
    function GetPlayerData()
        return Framework.Functions.GetPlayerData()
    end

    function GetMoney()
        local Player = GetPlayerData()
        return Player.PlayerData.money['cash']
    end

    function DeleteVehicle(vehicle)
        Framework.Functions.DeleteVehicle(vehicle)
    end

    function GetPlate(vehicle)
        return GetVehicleNumberPlateTextIndex(vehicle)
    end

    function GetVehicles()
        SharedVehicles = Framework.Shared.Vehicles
        return SharedVehicles
    end

    function SpawnTruck(model, position, heading)
        LoadModel(model)
        local vehicle = CreateVehicle(model, position, heading, true, false)
        local plate = 'T_RT_' .. string.format('%06d', math.random(100, 999))
        SetVehicleNumberPlateText(vehicle, plate)
        SetEntityHeading(vehicle, heading)
        exports[Config.FuelScript]:SetFuel(vehicle, 100.0)
        SetVehicleOnGroundProperly(vehicle)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        SetVehicleCustomPrimaryColour(vehicle, 0, 0, 0)
        SetVehicleDirtLevel(vehicle, 0)
        WashDecalsFromVehicle(vehicle, 1.0)
        SetVehRadioStation(vehicle, 'OFF')
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehicleBodyHealth(vehicle, 1000.0)
        TriggerServerEvent("qb-vehiclekeys:server:AcquireVehicleKeys", GetPlate(vehicle))
        TriggerEvent('mh-vehiclekeyitem:client:CreateTempKey', vehicle)
        SetModelAsNoLongerNeeded(model)
        return vehicle, plate
    end
    
    function SpawnTrailer(model, position, heading)
        LoadModel(model)
        local vehicle = CreateVehicle(model, position, heading, true, false)
        local plate = 'TR_RT_' .. string.format('%06d', math.random(100, 999))
        SetVehicleNumberPlateText(vehicle, plate)
        SetEntityHeading(vehicle, heading)
        SetVehicleOnGroundProperly(vehicle)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        SetVehicleCustomPrimaryColour(vehicle, 0, 0, 0)
        SetVehicleDirtLevel(vehicle, 0)
        WashDecalsFromVehicle(vehicle, 1.0)
        SetVehRadioStation(vehicle, 'OFF')
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehicleBodyHealth(vehicle, 1000.0)
        return vehicle, plate
    end

    function Notify(message, type, length)
        Framework.Functions.Notify({text = Config.NotifyTitle, caption = message}, type, length)
    end
end

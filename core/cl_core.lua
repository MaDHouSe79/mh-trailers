--[[ ===================================================== ]] --
--[[     MH Framework (QBCore/ESX) Script by MaDHouSe79    ]] --
--[[ ===================================================== ]] --
Framework = nil
PlayerData = {}
TriggerCallback = nil
OnPlayerLoaded = nil
OnPlayerUnload = nil
IsLoggedIn = false

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
    
    function GetVehicles()
        SharedVehicles = Framework.Shared.Vehicles
        return SharedVehicles
    end

    function Notify(message, type, length)
        Framework.Functions.Notify({text = Config.NotifyTitle, caption = message}, type, length)
    end
end

local entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
        end
        enum.destructor = nil
        enum.handle = nil
    end
}

function GetPlate(vehicle)
    return GetVehicleNumberPlateTextIndex(vehicle)
end

function LoadModel(model)
    if not HasModelLoaded(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(1)
        end
    end
end

function DisplayHelpText(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function SpawnTruck(model, position, heading)
    LoadModel(model)
    local vehicle = CreateVehicle(model, position, heading, true, false)
    local plate = 'TRUCK' .. math.random(10, 99)
    SetEntityAsMissionEntity(vehicle, true, true)
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
    if GetResourceState("qb-vehiclekeys") ~= 'missing' then
        if Config.UseServerTrigger then
            TriggerServerEvent(Config.ServerVehicleKeyTrigger, plate)
        elseif Config.UseClientTrigger then
            TriggerEvent(Config.ClientVehicleKeyTrigger, plate)
        end
    end
    if GetResourceState("mh-vehiclekeyitem") ~= 'missing' then
        TriggerEvent('mh-vehiclekeyitem:client:CreateTempKey', vehicle)
    end
    SetModelAsNoLongerNeeded(model)
    return vehicle, plate
end

function SpawnTrailer(model, position, heading)
    LoadModel(model)
    local vehicle = CreateVehicle(model, position, heading, true, false)
    local plate = 'TRAILER' .. math.random(10, 99)
    SetEntityAsMissionEntity(vehicle, true, true)
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

function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter)
            return
        end
        local enum = { handle = iter, destructor = disposeFunc }
        setmetatable(enum, entityEnumerator)
        local next = true
        repeat
            coroutine.yield(id)
            next, id = moveFunc(iter)
        until not next
        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end

function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

--[[ ===================================================== ]] --
--[[             MH Trailers Script by MaDHouSe            ]] --
--[[ ===================================================== ]] --
local trailers = {}

local function isVehicleLoaded(trailerNetId, vehicleNetId)
    if trailers[trailerNetId] then
        for i = 1, #trailers[trailerNetId] do
            if trailers[trailerNetId][i] then
                if trailers[trailerNetId][i] == vehicleNetId then
                    return true
                end
            end
        end
    end
    return false
end

local function AddVehicleToTrailer(trailerNetId, vehicleNetId)
    if trailers[trailerNetId] == nil then trailers[trailerNetId] = {} end
    if isVehicleLoaded(trailerNetId, vehicleNetId) then return end
    trailers[trailerNetId][#trailers[trailerNetId] + 1] = vehicleNetId
    TriggerClientEvent('mh-trailers:client:updateTrailers', -1, trailerNetId, trailers)
end

local function RemoveVehicleFromTrailer(trailerNetId, vehicleNetId)
    if not isVehicleLoaded(trailerNetId, vehicleNetId) then return end
    for i = 1, #trailers do
        if trailers[trailerNetId][i] == vehicleNetId then
            trailers[trailerNetId][i] = nil
        end
    end
    TriggerClientEvent('mh-trailers:client:updateTrailers', -1, trailerNetId, trailers)
end

CreateCallback("mh-trailers:server:pay", function(source, cb)
    local src = source
    local player = GetPlayer(src)
    if GetMoney(src, Config.MoneyType[Config.Framework]) >= Config.Rent.shop.cost then
        RemoveMoney(src, Config.MoneyType[Config.Framework], Config.Rent.shop.cost, "rent-trailer-paid")
        cb(true)
    else
        if GetMoney(src,'bank') >= Config.Rent.shop.cost then
            RemoveMoney(src, Config.MoneyType[Config.Framework], Config.Rent.shop.cost, "rent-trailer-paid")
            cb(true)
        else
            cb(false)
        end
    end
end)

CreateCallback("mh-trailers:server:GetTrailerData", function(source, cb, trailerNetId)
    if trailers[trailerNetId] ~= nil then
        cb(trailers)
    else
        cb(nil)
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        trailers = {}
    end
end)

-- sync system
RegisterNetEvent('mh-trailers:server:onjoin')
AddEventHandler('mh-trailers:server:onjoin', function()
    local src = source
    TriggerClientEvent('mh-trailers:client:onjoin', src, trailers)
end)

RegisterNetEvent('mh-trailers:server:SpawnRamp')
AddEventHandler('mh-trailers:server:SpawnRamp', function(source, _trailerNetID, _rampNetID)
    local data = {trailer = _trailerNetID, ramp = _rampNetID}
    if isVehicleLoaded(_trailerNetID, _rampNetID) then return end
    TriggerClientEvent('mh-trailers:client:SpawnRamp', -1, data)
end)

RegisterNetEvent('mh-trailers:server:updateDoor')
AddEventHandler('mh-trailers:server:updateDoor', function(_trailer, _door)
    local data = {trailer = _trailer, door = _door}
    TriggerClientEvent('mh-trailers:client:updateDoor', -1, data)
end)

RegisterNetEvent('mh-trailers:server:updatePlatform')
AddEventHandler('mh-trailers:server:updatePlatform', function(_trailer, _door)
    local data = {trailer = _trailer, door = _door}
    TriggerClientEvent('mh-trailers:client:updatePlatform', -1, data)
end)

RegisterNetEvent('mh-trailers:server:addvehicle')
AddEventHandler('mh-trailers:server:addvehicle', function(trailerNetId, vehicleNetId)
    if isVehicleLoaded(trailerNetId, vehicleNetId) then return end
    AddVehicleToTrailer(trailerNetId, vehicleNetId)
end)

RegisterNetEvent('mh-trailers:server:removevehicle')
AddEventHandler('mh-trailers:server:removevehicle', function(trailerNetId, vehicleNetId)
    if not isVehicleLoaded(trailerNetId, vehicleNetId) then return end
    RemoveVehicleFromTrailer(trailerNetId, vehicleNetId)
end)

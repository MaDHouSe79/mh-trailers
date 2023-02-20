local QBCore = exports['qb-core']:GetCoreObject()

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
    if Config.DebugTrailers then print(json.encode(trailers, {indent = true})) end
    TriggerClientEvent('mh-trailers:client:updateTrailers', -1, trailerNetId, trailers)
end

local function RemoveVehicleFromTrailer(trailerNetId, vehicleNetId)
    if not isVehicleLoaded(trailerNetId, vehicleNetId) then return end
    for i = 1, #trailers do
        if trailers[trailerNetId][i] == vehicleNetId then
            trailers[trailerNetId][i] = nil
        end
    end
    if Config.DebugTrailers then print(json.encode(trailers, {indent = true})) end
    TriggerClientEvent('mh-trailers:client:updateTrailers', -1, trailerNetId, trailers)
end

QBCore.Functions.CreateCallback("mh-trailers:server:pay", function(source, cb)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if player.Functions.GetMoney('cash') >= Config.Rent.shop.cost then
        player.Functions.RemoveMoney("cash", Config.Rent.shop.cost, "rent-trailer-paid")
        cb(true)
    else
        if player.Functions.GetMoney('bank') >= Config.Rent.shop.cost then
            player.Functions.RemoveMoney("cash", Config.Rent.shop.cost, "rent-trailer-paid")
            cb(true)
        else
            cb(false)
        end
    end
end)


QBCore.Functions.CreateCallback("mh-trailers:server:GetTrailerData", function(source, cb, trailerNetId)
    if trailers[trailerNetId] ~= nil then
        cb(trailers)
    else
        cb(nil)
    end
end)

QBCore.Commands.Add('spawnramp', "Spawn Ramp", {}, true, function(source)
    local src = source
    TriggerClientEvent('mh-trailers:client:toggleBackRamp', src)
end, 'admin')

QBCore.Commands.Add('trailertest', "Spawn Ramp", {}, true, function(source)
    local src = source
    TriggerClientEvent('mh-trailers:client:onjoin', src, trailers)
end, 'admin')

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
    local data = {trailer = _trailer, ramp = _ramp}
    if Config.DebugRamp then print(json.encode(data, {indent = true})) end
    if isVehicleLoaded(_trailerNetID, _rampNetID) then return end
    TriggerClientEvent('mh-trailers:client:SpawnRamp', -1, data)
    --AddRamoToTrailer(_trailerNetID, _rampNetID)
end)

RegisterNetEvent('mh-trailers:server:updateDoor')
AddEventHandler('mh-trailers:server:updateDoor', function(_trailer, _door)
    local data = {trailer = _trailer, door = _door}
    if Config.DebugDoor then print(json.encode(data, {indent = true})) end
    TriggerClientEvent('mh-trailers:client:updateDoor', -1, data)
end)

RegisterNetEvent('mh-trailers:server:updatePlatform')
AddEventHandler('mh-trailers:server:updatePlatform', function(_trailer, _door)
    local data = {trailer = _trailer, door = _door}
    if Config.DebugPlatform then print(json.encode(data, {indent = true})) end
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
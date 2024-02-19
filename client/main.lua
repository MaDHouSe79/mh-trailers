--[[ ===================================================== ]] --
--[[             MH Trailers Script by MaDHouSe            ]] --
--[[ ===================================================== ]] --
local QBCore = exports['qb-core']:GetCoreObject()
local rampDoornumber = nil -- 5 ramp
local platformDoorNumber = nil -- 4 platform
local currentTruck = nil
local currentTrailer = nil
local currentTruckPlate = nil
local currentTrailerPlate = nil
local rampIsOpen = false
local platformIsDown = false
local rampPlaced = false
local isInArea = false
local hasNotify = false
local trailers = {}
local zone = {}
local blip = nil

local function DisplayHelpText(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local function  DeleteZone()
    if zone ~= nil then zone:destroy() end
end

local function CreateZone(data)
    zone = CircleZone:Create(data.coords, data.size, {name = "zones_" .. #data, heading = data.heading, debugPoly = false, useZ = true})
    zone:onPlayerInOut(function(isPointInside)
        if isPointInside then
            isInArea = true
            if IsPedSittingInAnyVehicle(PlayerPedId()) and not hasNotify then
                exports['qb-core']:DrawText("[E] - Menu")
            else
                exports['qb-core']:DrawText('not in vehicle')
            end
        else
            if isInArea then
                isInArea = false
                hasNotify = false
                exports['qb-core']:HideText('hide')
            end
        end
    end)
end

local function loadModel(model)
    if not HasModelLoaded(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(1)
        end
    end
end

local function SetFuel(vehicle, fuel)
    if type(fuel) == 'number' and fuel >= 0 and fuel <= 100 then
        SetVehicleFuelLevel(vehicle, fuel + 0.0)
        DecorSetFloat(vehicle, "_FUEL_LEVEL", GetVehicleFuelLevel(vehicle))
    end
end

local function Park()
    if IsPedInAnyVehicle(PlayerPedId()) then
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        TaskLeaveVehicle(PlayerPedId(), veh)
        Wait(1500)
        QBCore.Functions.DeleteVehicle(veh)
        DeleteEntity(GetVehiclePedIsIn(PlayerPedId(), false))
        local plate = QBCore.Functions.GetPlate(veh)
        TriggerEvent('mh-vehiclekeyitem:client:DeleteKey', plate)
    end
end

local function createGarage()
    blip = AddBlipForCoord(Config.Rent.spawn.garage.x, Config.Rent.spawn.garage.y, Config.Rent.spawn.garage.z)
    SetBlipSprite(blip, 50)
    SetBlipScale(blip, Config.Rent.blip.scale)
    SetBlipDisplay(blip, 4)
    SetBlipColour(blip, Config.Rent.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.Rent.blip.garagelabel)
    EndTextCommandSetBlipName(blip)
end

local function deleteBlip()
    if blip ~= nil then
        RemoveBlip(blip)
    end
end

local function createBlip()
    deleteBlip()
    blip = AddBlipForCoord(Config.Rent.shop.location.x, Config.Rent.shop.location.y, Config.Rent.shop.location.z)
    SetBlipSprite(blip, Config.Rent.blip.sprite)
    SetBlipScale(blip, Config.Rent.blip.scale)
    SetBlipDisplay(blip, 4)
    SetBlipColour(blip, Config.Rent.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.Rent.blip.shoplabel)
    EndTextCommandSetBlipName(blip)
    createGarage()
end

local function spawnTruck(truckModel, position, heading)
    QBCore.Functions.SpawnVehicle(truckModel, function(veh)
        currentTruck = veh
        currentTruckPlate = 'T_RT_' .. string.format('%06d', math.random(100, 999))
        SetVehicleNumberPlateText(currentTruck, currentTruckPlate)
        SetEntityHeading(currentTruck, heading)
        SetFuel(currentTruck, 100.0)
        SetVehicleOnGroundProperly(currentTruck)
        TaskWarpPedIntoVehicle(PlayerPedId(), currentTruck, -1)
        SetVehicleCustomPrimaryColour(loading, 0, 0, 0)
        SetVehicleDirtLevel(currentTruck, 0)
        WashDecalsFromVehicle(currentTruck, 1.0)
        SetVehRadioStation(currentTruck, 'OFF')
        SetVehicleEngineHealth(currentTruck, 1000.0)
        SetVehicleBodyHealth(currentTruck, 1000.0)
        TriggerServerEvent("qb-vehiclekeys:server:AcquireVehicleKeys", QBCore.Functions.GetPlate(currentTruck))
        TriggerEvent('mh-vehiclekeyitem:client:CreateTempKey', currentTruck)
    end, position, true)
end

local function spawnTrailer(trailerModel, position, heading)
    QBCore.Functions.SpawnVehicle(trailerModel, function(trailer)
        currentTrailerPlate = 'TR_RT_' .. string.format('%06d', math.random(100, 999))
        SetVehicleNumberPlateText(trailer, currentTrailerPlate)
        SetEntityHeading(trailer, heading)
        SetVehicleCustomPrimaryColour(trailer, 0, 0, 0)
        SetVehicleDirtLevel(trailer)
        WashDecalsFromVehicle(trailer, 1.0)
        SetVehicleEngineHealth(trailer, 1000.0)
        SetVehicleBodyHealth(trailer, 1000.0)
    end, position, true)
end

local function SpawnTruckAndTrailer(truckModel, trailerModel)
    local coords = Config.Rent.spawn.truck
    local heading = Config.Rent.spawn.heading
    local tmpSpawnPosition = vector3(coords.x, coords.y, coords.z)
    local vehicle = nil
    if not QBCore.Functions.SpawnClear(tmpSpawnPosition, 5.0) then
        QBCore.Functions.Notify(Lang:t('error.area_is_obstructed'), 'error', 5000)
        return
    else
        if truckModel ~= nil then
            if trailerModel == "boattrailer" then truckModel = "sadler" end
            ClearAreaOfVehicles(tmpSpawnPosition, 10000, false, false, false, false, false)
            spawnTruck(truckModel, tmpSpawnPosition, heading)
        end
        if trailerModel ~= nil then
            local pos = vector3(Config.Rent.spawn.trailer.x, Config.Rent.spawn.trailer.y, Config.Rent.spawn.trailer.z)
            ClearAreaOfVehicles(pos, 10000, false, false, false, false, false)
            spawnTrailer(trailerModel, pos, heading)
        end
    end
end

local function deletePed()
    if rentPed ~= nil then
        DeletePed(rentPed)
        rentPed = nil
    end
end

local function createPed()
    if not rentPed then rentPed = {} end
    local current = GetHashKey(Config.Rent.shop.ped)
    loadModel(current)
    rentPed = CreatePed(0, current, Config.Rent.shop.location.x, Config.Rent.shop.location.y, Config.Rent.shop.location.z - 1, Config.Rent.shop.location.w, false, false)
    TaskStartScenarioInPlace(rentPed, Config.Rent.shop.location.scenario, true)
    FreezeEntityPosition(rentPed, true)
    SetEntityInvincible(rentPed, true)
    SetBlockingOfNonTemporaryEvents(rentPed, true)
    if Config.Target == "qb-target" then
        exports['qb-target']:AddTargetEntity(rentPed, {
            options = {{
                label = Lang:t('target.rent_a_vehicle'),
                icon = 'fa-solid fa-coins',
                action = function()
                    TriggerEvent('mh-trailers:client:TruckAndTrailerMenu')
                end
            }},
            distance = 2.0
        })
    elseif Config.Target == "ox_target" then
        exports.ox_target:removeModel(current, 'rent_a_vehicle')
        exports.ox_target:addModel(current, {
            {
                name = 'rent_a_vehicle',
                icon = 'fa-solid fa-coins',
                label = Lang:t('target.rent_a_vehicle'),
                onSelect = function()
                    TriggerEvent('mh-trailers:client:TruckAndTrailerMenu')
                end,
                distance = 2.0
            },
        })
    end
end

local function isVehicleLoaded(vehicle)
    if currentTrailer ~= nil then
        local tPlate = QBCore.Functions.GetPlate(currentTrailer)
        if trailers[tPlate] then
            for i = 1, #trailers[tPlate] do
                if trailers[tPlate][i].vehicle then
                    if trailers[tPlate][i].vehicle == vehicle then
                        return true
                    end
                end
            end
        end
        return false
    end
end

local function IsTrailer(entity)
    local isTrailer = false
    if Config.TrailerSettings[GetEntityModel(entity)] then isTrailer = true end
    return isTrailer
end

local function AddVehicleToTrailer(trailer, vehicle)
    if trailer ~= nil then
        if isVehicleLoaded(vehicle) then return end
        local tPlate = QBCore.Functions.GetPlate(trailer)
        local vPlate = QBCore.Functions.GetPlate(vehicle)
        if trailers[tPlate] == nil then trailers[tPlate] = {} end
        trailers[tPlate][#trailers[tPlate] + 1] = {vehicle = vehicle, plate = vPlate}
        if Config.DebugTrailers then
            print(json.encode(trailers, {indent = true}))
        end
    end
end

local function RemoveVehicleFromTrailer(vehicle)
    if currentTrailer ~= nil then
        local tPlate = QBCore.Functions.GetPlate(currentTrailer)
        if not isVehicleLoaded(vehicle) then return end
        if trailers[tPlate] then
            for i = 1, #trailers[tPlate] do
                local data = trailers[tPlate][i]
                if trailers[tPlate][i] then
                    if trailers[tPlate][i].vehicle == vehicle then
                        TriggerServerEvent('mh-trailers:server:removevehicle', VehToNet(currentTrailer), VehToNet(vehicle))
                        trailers[tPlate][i].vehicle = nil
                    end
                end
            end
            trailers[tPlate] = {}
        end
        if Config.DebugTrailers then
            print(json.encode(trailers, {indent = true}))
        end
    end
end

local entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then enum.destructor(enum.handle) end
        enum.destructor = nil
        enum.handle = nil
    end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter)
            return
        end
        local enum = {handle = iter, destructor = disposeFunc}
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

local function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

local function GetTrailerData(trailer)
    local model = GetEntityModel(trailer)
    local trailerData = {}
    trailerData.offsetX = Config.TrailerSettings[model].offsetX
    trailerData.offsetY = Config.TrailerSettings[model].offsetY
    trailerData.offsetZ = Config.TrailerSettings[model].offsetZ
    trailerData.width = Config.TrailerSettings[model].width
    trailerData.length = Config.TrailerSettings[model].length
    trailerData.loffset = Config.TrailerSettings[model].loffset
    trailerData.hasRamp = Config.TrailerSettings[model].hasRamp
    trailerData.rampOffsetX = Config.TrailerSettings[model].ramp.offsetX
    trailerData.rampOffsetY = Config.TrailerSettings[model].ramp.offsetY
    trailerData.rampOffsetZ = Config.TrailerSettings[model].ramp.offsetZ
    trailerData.rampRotation = Config.TrailerSettings[model].ramp.rotation
    trailerData.hasdoors = Config.TrailerSettings[model].hasdoors
    return trailerData
end

local function SpawnRamp(trailer)
    local model = Config.Models.ramp
    loadModel(model)
    local rampOffsetX = Config.TrailerSettings[GetEntityModel(trailer)].ramp.offsetX
    local rampOffsetY = Config.TrailerSettings[GetEntityModel(trailer)].ramp.offsetY
    local rampOffsetZ = Config.TrailerSettings[GetEntityModel(trailer)].ramp.offsetZ
    local rampRotation = Config.TrailerSettings[GetEntityModel(trailer)].ramp.rotation
    local coords = GetEntityCoords(trailer)
    local heading = GetEntityHeading(trailer)
    local vehRotation = GetEntityRotation(trailer, 5)
    local trailerpos = GetOffsetFromEntityInWorldCoords(trailer, rampOffsetX, rampOffsetY, rampOffsetZ)
    local ramp = CreateObject(model, coords.x, coords.y, coords.z, true)
    SetEntityCoords(ramp, vector3(trailerpos.x, trailerpos.y, trailerpos.z), false, false, false, true)
    SetEntityRotation(ramp, vehRotation.x, vehRotation.y, vehRotation.z + rampRotation, 5, true)
end

local function UnLockVehiclesOnTrailer(trailer)
    if trailer then
        if trailers then
            local tPlate = QBCore.Functions.GetPlate(trailer)
            if tPlate then
                if trailers[tPlate] then
                    for i = 1, #trailers[tPlate] do
                        if trailers[tPlate][i] then
                            if trailers[tPlate][i].vehicle then
                                DetachEntity(trailers[tPlate][i].vehicle, true, true)
                                RemoveVehicleFromTrailer(trailers[tPlate][i].vehicle)
                                Wait(100)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function AttachToTrailer(trailer, vehicle)
    if trailer then
        if GetEntitySpeed(vehicle) < 0.01 then
            if not IsEntityAttached(vehicle) then
                local vehicleCoords = GetEntityCoords(PlayerPedId())
                local vehOff = GetOffsetFromEntityGivenWorldCoords(trailer, vehicleCoords)
                local vehrot = GetEntityRotation(vehicle, 5)
                local trot = GetEntityRotation(trailer, 5)
                local trailerHeading = GetEntityHeading(trailer)
                local vehicleHeading = GetEntityHeading(vehicle)
                local chassisBone = GetEntityBoneIndexByName(trailer, "chassis")
                AttachEntityToEntity(vehicle, trailer, chassisBone, vector3(vehOff.x, vehOff.y, vehOff.z), vector3(vehrot.y, (vehrot.x + trot.y) / 2, vehicleHeading - trailerHeading), 1, 0, 1, 0, 0, 1)
                SetEntityCanBeDamaged(vehicle, false)
            else
                QBCore.Functions.Notify(Lang:t('notify.already_on_trailer'))
            end
        else
            QBCore.Functions.Notify(Lang:t('notify.vehicle_must_be_stationary'))
        end
    end
end

local function LockVehiclesOnTrailer(trailer)
    if trailer ~= nil then
        for car in EnumerateVehicles() do
            if car ~= nil then
                if not Config.IgnoreVehicle[GetEntityModel(car)] then
                    if IsEntityTouchingEntity(trailer, car) then
                        if not IsVehicleAttachedToTrailer(car) then
                            SetVehicleEngineOn(car, false, false, true)
                            local vehRotation = GetEntityRotation(car)
                            local localcoords = GetOffsetFromEntityGivenWorldCoords(trailer, GetEntityCoords(car))
                            local trailerData = GetTrailerData(trailer)
                            AttachVehicleOnToTrailer(car, trailer, 0.0, 0.0, 0.0, localcoords.x + trailerData.offsetX, localcoords.y + trailerData.offsetY, localcoords.z + trailerData.offsetZ, vehRotation.x, vehRotation.y, 0.0, false)
                            SetEntityCanBeDamaged(car, false)
                            AddVehicleToTrailer(trailer, car)
                            Wait(100)
                        end
                    end
                end
            end
        end
    end
end

local function AddVehicleOnTrailer(trailer)
    local car = GetVehiclePedIsIn(PlayerPedId(), false)
    if IsEntityTouchingEntity(trailer, car) then
        if not IsVehicleAttachedToTrailer(car) then
            SetVehicleEngineOn(car, false, false, true)
            -- (boattrailer) or (trailersmall)
            if GetEntityModel(trailer) == 524108981 or GetEntityModel(trailer) == 712162987 then
                AttachEntityToEntity(car, trailer, 20, 0.0, -1.0, 0.25, 0.0, 0.0, 0.0, false, false, true, false, 20, true)
                -- tr2 trailer
            elseif GetEntityModel(trailer) == 2078290630 then
                local vehRotation = GetEntityRotation(car)
                local localcoords = GetOffsetFromEntityGivenWorldCoords(trailer, GetEntityCoords(car))
                local trailerData = GetTrailerData(trailer)
                AttachVehicleOnToTrailer(car, trailer, 0.0, 0.0, 0.0, localcoords.x + trailerData.offsetX, localcoords.y + trailerData.offsetY, localcoords.z + trailerData.offsetZ, vehRotation.x, vehRotation.y, 0.0, false)
                -- trflat (only a ramp)
            elseif GetEntityModel(trailer) == -1352468814 then
                AttachToTrailer(trailer, car)
            else
                AttachToTrailer(trailer, car)
            end
            SetEntityCanBeDamaged(car, false)
            TriggerServerEvent('mh-trailers:server:addvehicle', VehToNet(trailer), VehToNet(car))
        else
            QBCore.Functions.Notify(Lang:t('notify.already_on_trailer'))
        end
    end
end

local function CanInterAct(model)
    if Config.TrailerSettings[model] then
        if Config.TrailerSettings[model].doors ~= nil then
            if Config.TrailerSettings[model].doors.platform ~= nil then
                platformDoorNumber = Config.TrailerSettings[model].doors.platform -- 4 -- platform
            end
            if Config.TrailerSettings[model].doors.ramp ~= nil then
                rampDoornumber = Config.TrailerSettings[model].doors.ramp -- 5     -- ramp
            end
        end
    end
end

local function GetIn(entity)
    TaskWarpPedIntoVehicle(PlayerPedId(), entity, -1)
    FreezeEntityPosition(entity, false)
    SetVehicleHandbrake(entity, false)
    DetachEntity(entity, true, true)
    SetVehicleEngineOn(entity, true, true)
end

local function ToggleDoor()
    if currentTrailer ~= nil then
        if not rampIsOpen then
            UnLockVehiclesOnTrailer(currentTrailer)
            Wait(500)
            if GetEntityModel(currentTrailer) ~= 524108981 or GetEntityModel(currentTrailer) ~= 712162987 then -- boattrailer/small trailer
                TriggerServerEvent('mh-trailers:server:updateDoor', VehToNet(currentTrailer), rampDoornumber)
            end
        else
            LockVehiclesOnTrailer(currentTrailer)
            if GetEntityModel(currentTrailer) ~= 524108981 or GetEntityModel(currentTrailer) ~= 712162987 then -- boattrailer/small trailer
                TriggerServerEvent('mh-trailers:server:updateDoor', VehToNet(currentTrailer), rampDoornumber)
            end
        end
    end
end

local function TogglePlatform()
    if currentTrailer ~= nil then
        UnLockVehiclesOnTrailer(currentTrailer)
        if not platformIsDown then
            if GetEntityModel(currentTrailer) ~= 524108981 or GetEntityModel(currentTrailer) ~= 712162987 then -- boattrailer/small trailer
                TriggerServerEvent('mh-trailers:server:updatePlatform', VehToNet(currentTrailer), platformDoorNumber)
            end
        else
            if GetEntityModel(currentTrailer) ~= 524108981 or GetEntityModel(currentTrailer) ~= 712162987 then -- boattrailer/small trailer
                TriggerServerEvent('mh-trailers:server:updatePlatform', VehToNet(currentTrailer), platformDoorNumber)
            end
        end
    end
end

local function UpdateDoor(trailer, door)
    if trailer ~= nil then
        CanInterAct(GetEntityModel(trailer))
        if not rampIsOpen then
            rampIsOpen = true
            UnLockVehiclesOnTrailer(trailer)
            Wait(500)
            if GetEntityModel(trailer) ~= 524108981 or GetEntityModel(trailer) ~= 712162987 then -- boattrailer/small trailer
                SetVehicleDoorOpen(trailer, door, false) -- will open all doors from 5
            end
        else
            rampIsOpen = false
            LockVehiclesOnTrailer(trailer)
            if GetEntityModel(trailer) ~= 524108981 or GetEntityModel(trailer) ~= 712162987 then -- boattrailer/small trailer
                SetVehicleDoorShut(trailer, door, false) -- will close all doors from 5
            end
        end
    end
end

local function UpdatePlatform(trailer, door)
    if trailer ~= nil then
        CanInterAct(GetEntityModel(trailer))
        UnLockVehiclesOnTrailer(trailer)
        if not platformIsDown then
            platformIsDown = true
            if GetEntityModel(trailer) ~= 524108981 or GetEntityModel(trailer) ~= 712162987 then -- boattrailer/small trailer
                SetVehicleDoorOpen(trailer, door, false) -- will open all doors from 4
            end
        else
            platformIsDown = false
            if GetEntityModel(trailer) ~= 524108981 or GetEntityModel(trailer) ~= 712162987 then -- boattrailer/small trailer
                SetVehicleDoorShut(trailer, door, false) -- will close all doors from 4
            end
        end
    end
end

local function LoadTarget()
    -- target for all vehicles
    for k, vehicle in pairs(QBCore.Shared.Vehicles) do
        if Config.Target == "qb-target" then
            exports['qb-target']:AddTargetModel(k, {
                options = {{
                    type = "client",
                    event = "mh-trailers:client:getin",
                    icon = "fas fa-car",
                    label = Lang:t('target.get_in'),
                    action = function(entity)
                        GetIn(entity)
                    end,
                    canInteract = function(entity, distance, data)
                        if currentTrailer == nil then return false end
                        if IsTrailer(entity) then return false end
                        return true
                    end
                }},
                distance = 15.0
            })
        elseif Config.Target == "ox_target" then
            exports.ox_target:removeModel(k, 'getin')
            exports.ox_target:addModel(k, {
                {
                    name = 'getin',
                    icon = "fas fa-car",
                    label = Lang:t('target.get_in'),
                    onSelect = function(data)
                        GetIn(data.entity)
                    end,
                    canInteract = function(entity, distance, data)
                        return true
                    end,
                    distance = 15.0
                },
            })
        end
    end
    if Config.Target == "qb-target" then
        -- target ramp model
        exports['qb-target']:AddTargetModel(Config.Models.ramp, {
            options = { -- ramp
            {
                type = "client",
                event = "mh-trailers:client:deleteRamp",
                icon = "fas fa-car",
                label = Lang:t('target.remove_ramp'),
                action = function(entity)
                    rampPlaced = false
                    DeleteEntity(entity)
                end,
                canInteract = function(entity, distance, data)
                    if not rampPlaced then return false end
                    if not Config.TrailerSettings[GetEntityModel(currentTrailer)].hasRamp then return false end
                    return true
                end
            }},
            distance = 5.0
        })
        -- trailer trailers 
        exports['qb-target']:AddTargetModel(Config.Models.trailers, {
            options = { -- ramp
            {
                type = "client",
                event = "mh-trailers:client:toggleDoor",
                icon = "fas fa-car",
                label = Lang:t('target.ramp_up'),
                action = function(entity)
                    TriggerEvent('mh-trailers:client:toggleDoor')
                end,
                canInteract = function(entity, distance, data)
                    if platformIsDown then return false end
                    if not rampIsOpen then return false end
                    if not IsTrailer(entity) then return false end
                    currentTrailer = entity
                    return true
                end
            }, {
                type = "client",
                event = "mh-trailers:client:toggleDoor",
                icon = "fas fa-car",
                label = Lang:t('target.ramp_down'),
                canInteract = function(entity, distance, data)
                    if platformIsDown then return false end
                    if rampIsOpen then return false end
                    if not IsTrailer(entity) then return false end
                    currentTrailer = entity
                    CanInterAct(GetEntityModel(currentTrailer))
                    return true
                end
            }, -- platform
            {
                type = "client",
                event = "mh-trailers:client:togglePlatform",
                icon = "fas fa-car",
                label = Lang:t('target.platform_up'),
                canInteract = function(entity, distance, data)
                    if not rampIsOpen then return false end
                    if not platformIsDown then return false end
                    if platformDoorNumber == nil then return end
                    if not IsTrailer(entity) then return false end
                    currentTrailer = entity
                    return true
                end
            }, {
                type = "client",
                event = "mh-trailers:client:togglePlatform",
                icon = "fas fa-car",
                label = Lang:t('target.platform_down'),
                canInteract = function(entity, distance, data)
                    if not rampIsOpen then return false end
                    if platformIsDown then return false end
                    if platformDoorNumber == nil then return end
                    if not IsTrailer(entity) then return false end
                    currentTrailer = entity
                    return true
                end
            }, {
                type = "client",
                icon = "fas fa-car",
                label = Lang:t('target.place_ramp'),
                onSelect = function(entity)
                    rampPlaced = true
                    SpawnRamp(entity)
                end,
                canInteract = function(entity, distance, data)
                    if rampPlaced then return false end
                    if not IsTrailer(entity) then return false end
                    if not Config.TrailerSettings[GetEntityModel(entity)].hasRamp then return false end
                    currentTrailer = entity
                    return true
                end
            }, {
                type = "client",
                icon = "fas fa-car",
                label = Lang:t('target.lock_trailer'),
                onSelect = function(entity)
                    rampPlaced = true
                    LockVehiclesOnTrailer(entity)
                end,
                canInteract = function(entity, distance, data)
                    if not IsTrailer(entity) then return false end
                    return true
                end
            }, {
                type = "client",
                icon = "fas fa-car",
                label = Lang:t('target.unlock_trailer'),
                onSelect = function(entity)
                    rampPlaced = true
                    UnLockVehiclesOnTrailer(entity)
                end,
                canInteract = function(entity, distance, data)
                    if not IsTrailer(entity) then return false end
                    return true
                end
            }},
            distance = 5.0
        })
    elseif Config.Target == "ox_target" then
        -- target ramp model
        exports.ox_target:removeModel(Config.Models.ramp, 'ramp')
        exports.ox_target:addModel(Config.Models.ramp, {
            {
                name = 'ramp',
                icon = "fas fa-car",
                label = Lang:t('target.remove_ramp'),
                onSelect = function(data)
                    rampPlaced = false
                    DeleteEntity(data.entity)
                end,
                canInteract = function(entity, distance, data)
                    if not rampPlaced then return false end
                    if not Config.TrailerSettings[GetEntityModel(currentTrailer)].hasRamp then return false end
                    return true
                end,
                distance = 2.5
            },
        })

        -- trailer trailers
        exports.ox_target:removeModel(Config.Models.trailers, 'trailer')
        exports.ox_target:addModel(Config.Models.trailers, {
            {
                name = 'ramp_up',
                event = "mh-trailers:client:toggleDoor",
                icon = "fas fa-car",
                label = Lang:t('target.ramp_up'),
                onSelect = function(data)
                    --ToggleDoor()
                    currentTrailer = data.entity
                    TriggerEvent('mh-trailers:client:toggleDoor')
                end,
                canInteract = function(entity, distance, data)
                    if platformIsDown then return false end
                    if not rampIsOpen then return false end
                    if not IsTrailer(entity) then return false end
                    currentTrailer = entity
                    return true
                end,
                distance = 5.0
            }, {
                name = 'ramp_down',
                icon = "fas fa-car",
                label = Lang:t('target.ramp_down'),
                onSelect = function(data)
                    currentTrailer = data.entity
                    TriggerEvent('mh-trailers:client:toggleDoor')
                    CanInterAct(GetEntityModel(currentTrailer))
                end,
                canInteract = function(entity, distance, data)
                    if platformIsDown then return false end
                    if rampIsOpen then return false end
                    if not IsTrailer(entity) then return false end
                    currentTrailer = entity
                    CanInterAct(GetEntityModel(currentTrailer))
                    return true
                end,
                distance = 5.0
            },
            -- platform
            {
                name = 'platform_up',
                icon = "fas fa-car",
                label = Lang:t('target.platform_up'),
                onSelect = function(data)
                    currentTrailer = data.entity
                    TogglePlatform()
                end,
                canInteract = function(entity, distance, data)
                    if not rampIsOpen then return false end
                    if not platformIsDown then return false end
                    if platformDoorNumber == nil then return end
                    if not IsTrailer(entity) then return false end
                    currentTrailer = entity
                    return true
                end,
                distance = 5.0
            }, {
                name = 'platform_down',
                icon = "fas fa-car",
                label = Lang:t('target.platform_down'),
                onSelect = function(data)
                    currentTrailer = data.entity
                    TogglePlatform()
                end,
                canInteract = function(entity, distance, data)
                    if not rampIsOpen then return false end
                    if platformIsDown then return false end
                    if platformDoorNumber == nil then return end
                    if not IsTrailer(entity) then return false end
                    currentTrailer = entity
                    return true
                end,
                distance = 5.0
            }, {
                name = 'place_ramp',
                icon = "fas fa-car",
                label = Lang:t('target.place_ramp'),
                onSelect = function(data)
                    rampPlaced = true
                    SpawnRamp(data.entity)
                end,
                canInteract = function(entity, distance, data)
                    if rampPlaced then return false end
                    if not IsTrailer(entity) then return false end
                    if not Config.TrailerSettings[GetEntityModel(entity)].hasRamp then return false end
                    currentTrailer = entity
                    return true
                end,
                distance = 5.0
            }, {
                name = 'lock_trailer',
                icon = "fas fa-car",
                label = Lang:t('target.lock_trailer'),
                onSelect = function(data)
                    rampPlaced = true
                    LockVehiclesOnTrailer(data.entity)
                end,
                canInteract = function(entity, distance, data)
                    if not IsTrailer(entity) then return false end
                    return true
                end,
                distance = 5.0
            }, {
                name = 'unlock_trailer',
                icon = "fas fa-car",
                label = Lang:t('target.unlock_trailer'),
                onSelect = function(data)
                    rampPlaced = true
                    UnLockVehiclesOnTrailer(data.entity)
                end,
                canInteract = function(entity, distance, data)
                    if not IsTrailer(entity) then return false end
                    return true
                end,
                distance = 5.0
            },
        })
    end
end

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    -- TriggerServerEvent("mh-trailers:server:onjoin")
    trailers = {}
    LoadTarget()
    createPed()
    createBlip()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        trailers = {}
        LoadTarget()
        createPed()
        createBlip()
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        trailers = {}
        LoadTarget()
        deletePed()
        deleteBlip()
    end
end)

RegisterNetEvent('qb-trailers:client:park', function()
    local ped = PlayerPedId()
    if currentTruck ~= nil then
        if IsPedInAnyVehicle(ped) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            local plate = QBCore.Functions.GetPlate(vehicle)
            if currentTruck == vehicle then
                currentTruck = nil
                currentTruckPlate = nil
                TaskLeaveVehicle(ped, vehicle)
                Wait(1500)
                QBCore.Functions.DeleteVehicle(vehicle)
                DeleteEntity(vehicle)
            else
                QBCore.Functions.Notify(Lang:t('notify.return_wrong_vehicle'), "error")
            end
        end
    end
end)

RegisterNetEvent('mh-trailers:client:TruckAndTrailerMenu', function()
    local truckModels = {}
    for key, v in pairs(Config.Models.trucks) do
        truckModels[#truckModels + 1] = {
            value = v,
            text = Lang:t('menu.truck') .. " " .. v
        }
    end

    local trailerModels = {}
    for key, v in pairs(Config.Models.trailers) do
        trailerModels[#trailerModels + 1] = {
            value = v,
            text = Lang:t('menu.trailer') .. " " .. v
        }
    end

    local menu = exports["qb-input"]:ShowInput({
        header = Lang:t('menu.select_header'),
        submitText = "",
        inputs = {{
            text = Lang:t('menu.select_truck'),
            name = "truck",
            type = "select",
            options = truckModels,
            isRequired = true
        }, {
            text = Lang:t('menu.select_trailer'),
            name = "trailer",
            type = "select",
            options = trailerModels,
            isRequired = true
        }}
    })
    if menu then
        if not menu.truck and not menu.trailer then
            return
        else
            QBCore.Functions.TriggerCallback("mh-trailers:server:pay", function(hasPaid)
                if hasPaid then
                    SpawnTruckAndTrailer(tostring(menu.truck), tostring(menu.trailer))
                else
                    QBCore.Functions.Notify(Lang:t('notify.not_enough_money_to_rent'), "error")
                end
            end)
        end
    end
end)

RegisterNetEvent('mh-trailers:client:detach', function(data)
    DetachEntity(data.entity, true, true)
    RemoveVehicleFromTrailer(data.entity)
end)

RegisterNetEvent('mh-trailers:client:togglePlatform', function()
    TogglePlatform()
end)

RegisterNetEvent('mh-trailers:client:toggleDoor', function()
    ToggleDoor()
end)

RegisterNetEvent('mh-trailers:client:updateTrailers', function(trailerNetID, vehicleList)
    if trailerNetID ~= nil then
        local tPlate = QBCore.Functions.GetPlate(NetToVeh(trailerNetID))
        if trailers[tPlate] == nil then trailers[tPlate] = {} end
        for _, vehicles in pairs(vehicleList) do
            if vehicles ~= nil then
                for _, vehicle in pairs(vehicles) do
                    local tmpVeh = NetToVeh(vehicle)
                    local vPlate = QBCore.Functions.GetPlate(tmpVeh)
                    if not isVehicleLoaded(tmpVeh) then
                        trailers[tPlate][#trailers[tPlate] + 1] = {vehicle = tmpVeh, plate = vPlate}
                        AddVehicleToTrailer(NetToVeh(trailerNetID), NetToVeh(vehicle))
                    end
                end
            end
        end
        if Config.DebugTrailers then
            print(json.encode(trailers, {indent = true}))
        end
    end
end)

RegisterNetEvent('mh-trailers:client:onjoin', function(trailerList)
    for t, v in pairs(trailerList) do
        local trailer = NetToVeh(t)
        for _, c in pairs(v) do
            local vehicle = NetToVeh(c)
            AddVehicleToTrailer(NetToVeh(trailer), NetToVeh(vehicle))
        end
    end
end)

RegisterNetEvent('mh-trailers:client:updateDoor', function(data)
    if data.trailer ~= nil then
        UpdateDoor(NetToVeh(data.trailer), data.door)
    end
end)

RegisterNetEvent('mh-trailers:client:updatePlatform', function(data)
    if data.trailer ~= nil then
        UpdatePlatform(NetToVeh(data.trailer), data.door)
    end
end)

RegisterNetEvent('mh-trailers:client:getin', function(data)
    FreezeEntityPosition(data.entity, false)
    SetVehicleHandbrake(data.entity, false)
    DetachEntity(data.entity, true, true)
    TaskWarpPedIntoVehicle(PlayerPedId(), data.entity, -1)
    SetVehicleEngineOn(data.entity, true, true)
end)

CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
            -- print(model)
            if not Config.IgnoreVehicle[GetEntityModel(vehicle)] then
                if currentTrailer ~= nil then
                    if currentTrailer ~= vehicle then
                        if IsEntityTouchingEntity(currentTrailer, vehicle) then
                            if IsThisModelABoat(GetEntityModel(vehicle)) then -- is a boattrailer
                                if GetEntityModel(currentTrailer) == 524108981 then
                                    DisplayHelpText(Lang:t('info.press_boat_message', {key = Config.AttacheKeyTxt}))
                                end
                            else
                                DisplayHelpText(Lang:t('info.press_other_message', {key = Config.AttacheKeyTxt}))
                            end
                        end
                        if IsControlJustPressed(0, Config.AttachedKey) then
                            if not IsVehicleAttachedToTrailer(vehicle) then
                                if IsThisModelABoat(GetEntityModel(vehicle)) then -- is not a boattrailer
                                    if GetEntityModel(currentTrailer) ~= 524108981 then
                                        AddVehicleOnTrailer(currentTrailer)
                                    end
                                else
                                    AddVehicleOnTrailer(currentTrailer)
                                end
                            end
                        end
                    end
                end
            end
            local playerCoords = GetEntityCoords(ped)
            local garageCoords = Config.Rent.spawn.garage
            local distance = #(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - vector3(garageCoords.x, garageCoords.y, garageCoords.z))
            if distance <= 3.0 then
                DisplayHelpText(Lang:t('info.press_to_park', {key = Config.AttacheKeyTxt}))
                if IsControlJustPressed(0, Config.AttachedKey) then TriggerEvent('qb-trailers:client:park') end
            end
        end
    end
end)

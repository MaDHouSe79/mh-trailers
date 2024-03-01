--[[ ===================================================== ]] --
--[[             MH Trailers Script by MaDHouSe            ]] --
--[[ ===================================================== ]] --
local rampDoornumber = nil -- 5 ramp
local platformDoorNumber = nil -- 4 platform
local currentTruck = nil
local currentTrailer = nil
local currentTruckPlate = nil
local currentTruckCoords = nil
local currentTrailerPlate = nil
local currentTrailerCoords = nil
local rampIsOpen = false
local platformIsDown = false
local rampPlaced = false
local trailers = {}
local blip = nil
local tmpTruck = nil
local tmpTrailer = nil
local rentPed = nil

local function Park()
    if IsPedInAnyVehicle(PlayerPedId()) then
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        TaskLeaveVehicle(PlayerPedId(), veh)
        Wait(1500)
        DeleteVehicle(veh)
        DeleteEntity(GetVehiclePedIsIn(PlayerPedId(), false))
        currentTruck = nil
        currentTrailer = nil
        local plate = GetPlate(veh)
        if GetResourceState("mh-vehiclekeyitem") == 'missing' then
            TriggerEvent('vehiclekeys:client:RemoveKeys', GetVehicleNumberPlateText(veh))
        end

        if GetResourceState("mh-vehiclekeyitem") ~= 'missing' then
            TriggerEvent('mh-vehiclekeyitem:client:DeleteKey', plate)
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

local function spawnTruck(model, position, heading)
    currentTruck, currentTruckPlate = SpawnTruck(model, position, heading)
end

local function spawnTrailer(model, position, heading)
    currentTrailer, currentTrailerPlate = SpawnTrailer(model, position, heading)
end

local function SpawnTruckAndTrailer(truckModel, trailerModel)
    local heading = nil
    if truckModel ~= nil then
        if trailerModel == "boattrailer" or trailerModel == 'trailersmall' then truckModel = "sadler" end
        spawnTruck(truckModel, Config.Rent.spawn.truck, Config.Rent.spawn.heading)
        heading = GetEntityHeading(currentTruck)
    end
    if trailerModel ~= nil then
        if trailerModel == "boattrailer" or trailerModel == 'trailersmall' then heading = heading - 45 end

        local offset = Config.Offsets[trailerModel][truckModel]
        local coords = GetOffsetFromEntityInWorldCoords(currentTruck, 0.0, -offset, 0.0)
        local pos = vector3(coords.x, coords.y, coords.z)
        spawnTrailer(trailerModel, pos, heading)
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
    LoadModel(current)
    rentPed = CreatePed(0, current, Config.Rent.shop.location.x, Config.Rent.shop.location.y, Config.Rent.shop.location.z - 1, Config.Rent.shop.location.w, false, false)
    TaskStartScenarioInPlace(rentPed, Config.Rent.shop.location.scenario, true)
    FreezeEntityPosition(rentPed, true)
    SetEntityInvincible(rentPed, true)
    SetBlockingOfNonTemporaryEvents(rentPed, true)
    if Config.Target == "qb-target" then
        exports['qb-target']:AddTargetEntity(rentPed, {
            options = {{
                label = String('rent_a_vehicle'),
                icon = 'fa-solid fa-coins',
                action = function()
                    TriggerEvent('mh-trailers:client:TruckAndTrailerMenu')
                end,
                canInteract = function(entity, distance, data)
                    if currentTruck ~= nil then return false end
                    if currentTrailer ~= nil then return false end
                    return true
                end,
            }},
            distance = 2.0
        })
    elseif Config.Target == "ox_target" then
        exports.ox_target:removeModel(current, 'rent_a_vehicle')
        exports.ox_target:addModel(current, {{
            name = 'rent_a_vehicle',
            icon = 'fa-solid fa-coins',
            label = String('rent_a_vehicle'),
            onSelect = function()
                TriggerEvent('mh-trailers:client:TruckAndTrailerMenu')
            end,
            canInteract = function(entity, distance, data)
                if currentTruck ~= nil then return false end
                if currentTrailer ~= nil then return false end
                return true
            end,
            distance = 2.0
        }})
    end
end

local function isVehicleLoaded(vehicle)
    if currentTrailer ~= nil then
        local tPlate = GetPlate(currentTrailer)
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
    if Config.TrailerSettings[GetEntityModel(entity)] then
        isTrailer = true
    end
    return isTrailer
end

local function RemoveVehicleModelFromTarget(model, id)
    if Config.Target == "ox_target" then
        exports.ox_target:removeModel(model, id)
    elseif Config.Target == "qb-target" then
        exports['qb-target']:RemoveTargetModel(model, id)
    end
end

local function AddVehicleModelToTarGet(model, id)
    if Config.Target == "qb-target" then
        exports['qb-target']:AddTargetModel(model, {
            options = {{
                name = id,
                type = "client",
                event = "mh-trailers:client:getin",
                icon = "fas fa-car",
                label = String('get_in'),
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
        exports.ox_target:addModel(model, {{
            name = id,
            icon = "fas fa-car",
            label = String('get_in'),
            onSelect = function(data)
                GetIn(data.entity)
            end,
            canInteract = function(entity, distance, data)
                if currentTrailer == nil then return false end
                if IsTrailer(entity) then return false end
                return true
            end,
            distance = 15.0
        }})
    end
end

local function AddVehicleToTrailer(trailer, vehicle)
    if trailer ~= nil then
        if isVehicleLoaded(vehicle) then return end
        local tPlate = GetPlate(trailer)
        local vPlate = GetPlate(vehicle)
        if trailers[tPlate] == nil then trailers[tPlate] = {} end
        trailers[tPlate][#trailers[tPlate] + 1] = {vehicle = vehicle, plate = vPlate}
        if Config.DebugTrailers then print(json.encode(trailers, {indent = true})) end
    end
end

local function RemoveVehicleFromTrailer(vehicle)
    if currentTrailer ~= nil then
        local tPlate = GetPlate(currentTrailer)
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
        if Config.DebugTrailers then print(json.encode(trailers, {indent = true})) end
    end
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
    if DoesEntityExist(trailer) then
        local model = Config.Models.ramp
        LoadModel(model)
        local rampOffsetX = Config.TrailerSettings[GetEntityModel(trailer)].ramp.offsetX
        local rampOffsetY = Config.TrailerSettings[GetEntityModel(trailer)].ramp.offsetY
        local rampOffsetZ = Config.TrailerSettings[GetEntityModel(trailer)].ramp.offsetZ
        local rampRotation = Config.TrailerSettings[GetEntityModel(trailer)].ramp.rotation
        local coords = GetEntityCoords(trailer)
        local heading = GetEntityHeading(trailer)
        local vehRotation = GetEntityRotation(trailer, 5)
        local trailerpos = GetOffsetFromEntityInWorldCoords(trailer, rampOffsetX, rampOffsetY, rampOffsetZ)
        local ramp = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
        SetEntityCoords(ramp, vector3(trailerpos.x, trailerpos.y, trailerpos.z), false, false, false, true)
        SetEntityRotation(ramp, vehRotation.x, vehRotation.y, vehRotation.z + rampRotation, 5, true)
        TriggerServerEvent('mh-trailers:server:RegisterRamp', VehToNet(trailer), ObjToNet(ramp))
    end
end

local function UnLockVehiclesOnTrailer(trailer)
    if trailer then
        if trailers then
            local tPlate = GetPlate(trailer)
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
                Notify(String('already_on_trailer'))
            end
        else
            Notify(String('vehicle_must_be_stationary'))
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
            Notify(Lang:t('notify.already_on_trailer'))
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
    for k, v in pairs(Config.Vehicles) do
        RemoveVehicleModelFromTarget(v.model, 'getin')
        AddVehicleModelToTarGet(v.model, 'getin')
    end
    if Config.Target == "qb-target" then
        -- target ramp model
        exports['qb-target']:AddTargetModel(Config.Models.ramp, {
            options = { -- ramp
            {
                type = "client",
                event = "mh-trailers:client:deleteRamp",
                icon = "fas fa-car",
                label = String('remove_ramp'),
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
                label = String('ramp_up'),
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
                label = String('ramp_down'),
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
                label = String('platform_up'),
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
                label = String('platform_down'),
                canInteract = function(entity, distance, data)
                    if not rampIsOpen then return false end
                    if platformIsDown then return false end
                    if platformDoorNumber == nil then return end
                    if not IsTrailer(entity) then return false end
                    currentTrailer = entity
                    return true
                end
            }, {
                icon = "fas fa-car",
                label = String('place_ramp'),
                action = function(entity)
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
                label = String('lock_trailer'),
                action = function(entity)
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
                label = String('unlock_trailer'),
                action = function(entity)
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
                label = String('remove_ramp'),
                onSelect = function(data)
                    rampPlaced = false
                    DeleteEntity(data.entity)
                end,
                canInteract = function(entity, distance, data)
                    if not rampPlaced then return false end
                    return true
                end,
                distance = 2.5
            }
        })
        -- trailer trailers
        exports.ox_target:removeModel(Config.Models.trailers, 'trailer')
        exports.ox_target:addModel(Config.Models.trailers, {
            {
                name = 'ramp_up',
                event = "mh-trailers:client:toggleDoor",
                icon = "fas fa-car",
                label = String('ramp_up'),
                onSelect = function(data)
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
                label = String('ramp_down'),
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
            }, -- platform
            {
                name = 'platform_up',
                icon = "fas fa-car",
                label = String('platform_up'),
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
                label = String('platform_down'),
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
                label = String('place_ramp'),
                onSelect = function(data)
                    rampPlaced = true
                    TriggerServerEvent('mh-trailers:server:SpawnRamp', VehToNet(data.entity))
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
                label = String('lock_trailer'),
                onSelect = function(data)
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
                label = String('unlock_trailer'),
                onSelect = function(data)
                    UnLockVehiclesOnTrailer(data.entity)
                end,
                canInteract = function(entity, distance, data)
                    if not IsTrailer(entity) then return false end
                    return true
                end,
                distance = 5.0
            }
        })
    end
end

-- Open first menu
if Config.Menu == "ox_lib" then

    local function ShopMenu()
        lib.registerMenu({
            id = 'shop_menu_id',
            title = 'Rent Vehicle',
            position = 'center',
            options = {
                {label = 'Rent a '..tmpTruck.." with a "..tmpTrailer, args = {vehicle = tmpTruck, trailer = tmpTrailer}},
            }
        }, function(selected, scrollIndex, args)
            TriggerCallback("mh-trailers:server:pay", function(hasPaid)
                if hasPaid then
                    SpawnTruckAndTrailer(tostring(args.vehicle), tostring(args.trailer))
                else
                    Notify(String('not_enough_money_to_rent'), "error")
                end
            end)
        end)
        lib.showMenu('shop_menu_id')
    end

    local function SelectTrailerMenu(model)
        local trail, trails = nil, {}
        trails[#trails + 1] = "Select a trailer"
        for _, v in pairs(Config.Models.trailers) do
            if Config.AllowToMerge[tmpTruck][v] then 
                trails[#trails + 1] = v 
            end
        end

        lib.registerMenu({
            id = 'trailer_menu_id',
            title = 'Select a Trailer',
            position = 'center',
            onSideScroll = function(selected, scrollIndex, args)
                trail = trails[scrollIndex]
            end,
            onSelected = function(selected, secondary, args)
                trail = trails[selected]
            end,
            options = {
                {label = tmpTruck..' Trailers', icon = 'arrows-up-down-left-right', values = trails},
            }
        }, function(selected, scrollIndex, args)
            tmpTrailer = tostring(trail)
            ShopMenu()
        end)
        lib.showMenu('trailer_menu_id')
    end

    function SelectTruckMenu()
        local truck, trucks = nil, {}

        trucks[#trucks + 1] = "Select a Truck"
        for _, v in pairs(Config.Models.trucks) do
            trucks[#trucks + 1] = v
        end

        lib.registerMenu({
            id = 'truck_menu_id',
            title = 'Select a Truck',
            position = 'center',
            onSideScroll = function(selected, scrollIndex, args)
                truck = trucks[scrollIndex]
            end,
            onSelected = function(selected, secondary, args)
                truck = trucks[selected]
            end,
            options = {
                {label = 'Trucks', icon = 'arrows-up-down-left-right', values = trucks},
            }
        }, function(selected, scrollIndex, args)
            tmpTruck = tostring(truck)
            SelectTrailerMenu(tostring(truck))
        end)
        lib.showMenu('truck_menu_id')
    end

elseif Config.Menu == "qb-input" then

    function SelectTruckMenu()
        local truckModels = {}
        for key, v in pairs(Config.Models.trucks) do
            truckModels[#truckModels + 1] = {
                value = v,
                text = String('truck') .. " " .. v
            }
        end
        local trailerModels = {}
        for key, v in pairs(Config.Models.trailers) do
            trailerModels[#trailerModels + 1] = {
                value = v,
                text = String('trailer') .. " " .. v
            }
        end

        local menu = exports["qb-input"]:ShowInput({
            header = String('select_header'),
            submitText = "",
            inputs = {{
                text = String('select_truck'),
                name = "truck",
                type = "select",
                options = truckModels,
                isRequired = true
            }, {
                text = String('select_trailer'),
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
                TriggerCallback("mh-trailers:server:pay", function(hasPaid)
                    if hasPaid then
                        tmpTruck = tostring(menu.truck)
                        tmpTrailer = tostring(menu.trailer)
                        SpawnTruckAndTrailer(tostring(menu.truck), tostring(menu.trailer))
                    else
                        Notify(String('not_enough_money_to_rent'), "error")
                    end
                end)
            end
        end
    end

end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        IsLoggedIn = true
        trailers = {}
        LoadTarget()
        createPed()
        createBlip()
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        IsLoggedIn = false
        trailers = {}
        deletePed()
        deleteBlip()
    end
end)

AddEventHandler(OnPlayerLoaded, function()
    trailers = {}
    TriggerServerEvent("mh-trailers:server:onjoin")
    IsLoggedIn = true
    LoadTarget()
    createPed()
    createBlip()
end)

AddEventHandler(OnPlayerUnload, function()
    IsLoggedIn = false
    trailers = {}
    deletePed()
    deleteBlip()
end)

RegisterNetEvent('qb-trailers:client:park', function()
    local ped = PlayerPedId()
    if currentTruck ~= nil then
        if IsPedInAnyVehicle(ped) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            local plate = GetPlate(vehicle)
            if currentTruck == vehicle then
                currentTruck = nil
                currentTruckPlate = nil
                TaskLeaveVehicle(ped, vehicle)
                Wait(1500)
                DeleteVehicle(vehicle)
                DeleteEntity(vehicle)
            else
                Notify(String('return_wrong_vehicle'), "error")
            end
        end
    end
end)

RegisterNetEvent('mh-trailers:client:TruckAndTrailerMenu', function()
    SelectTruckMenu()
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

RegisterNetEvent('mh-trailers:client:SpawnRamp', function(trailerNetId)
    local trailer = NetToVeh(trailerNetId)
    SpawnRamp(trailer)
end)

RegisterNetEvent('mh-trailers:client:updateTrailers', function(trailerNetID, vehicleList)
    if trailerNetID ~= nil then
        local tPlate = GetPlate(NetToVeh(trailerNetID))
        if trailers[tPlate] == nil then trailers[tPlate] = {} end
        for _, vehicles in pairs(vehicleList) do
            if vehicles ~= nil then
                for _, vehicle in pairs(vehicles) do
                    local tmpVeh = NetToVeh(vehicle)
                    local vPlate = GetPlate(tmpVeh)
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
        local sleep = 1000
        if IsLoggedIn then
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped) then
                sleep = 0
                local vehicle = GetVehiclePedIsIn(ped, false)
                local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
                if not Config.IgnoreVehicle[GetEntityModel(vehicle)] then
                    if currentTrailer ~= nil then
                        if currentTrailer ~= vehicle then
                            if IsEntityTouchingEntity(currentTrailer, vehicle) then
                                if IsThisModelABoat(GetEntityModel(vehicle)) then -- is a boattrailer
                                    if GetEntityModel(currentTrailer) == 524108981 then
                                        DisplayHelpText(String('press_boat_message', Config.AttacheKeyTxt))
                                    end
                                else
                                    DisplayHelpText(String('press_other_message', Config.AttacheKeyTxt))
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
                    DisplayHelpText(String('press_to_park', Config.AttacheKeyTxt))
                    if IsControlJustPressed(0, Config.AttachedKey) then TriggerEvent('qb-trailers:client:park') end
                end
            end
        end
        Wait(sleep)
    end
end)

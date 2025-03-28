--[[ ===================================================== ]] --
--[[             MH Trailers Script by MaDHouSe            ]] --
--[[ ===================================================== ]] --
Locales = {}
Config = {}

-- Framework (Do not change this)
Config.Framework = nil
if GetResourceState("es_extended") ~= 'missing' then
    Config.Framework = 'esx'
    Config.MoneyType = 'money'
elseif GetResourceState("qb-core") ~= 'missing' then
    Config.Framework = 'qb'
    Config.MoneyType = 'cash'
end

-- Fuel script
Config.FuelScript = 'LegacyFuel'

-- Lib or input detection
if GetResourceState("ox_lib") ~= 'missing' then
    Config.Menu = "ox_lib"
elseif GetResourceState("ox_lib") == 'missing' then
    Config.Menu = "qb-input"
end

-- Target detection
if GetResourceState("ox_target") ~= 'missing' then
    Config.Target = "ox_target"
elseif GetResourceState("qb-target") == 'missing' then
    Config.Target = "qb-target"
end

-- Notify System
Config.NotifyTitle = "MH Trailers"

-- Language
Config.Locale = "en" -- use 'en' or 'nl' 

-- Vehiclekeys trigger
Config.UseServerTrigger = true
Config.ServerVehicleKeyTrigger = "qb-vehiclekeys:server:AcquireVehicleKeys"

Config.UseClientTrigger = false
Config.ClientVehicleKeyTrigger = "vehiclekeys:client:SetOwner"

-- Cash Settings
Config.MoneySign = "€" -- (€/$)

-- find more https://fontawesome.com/
Config.Fontawesome = {
    boss = "fa-solid fa-people-roof",
    pump = "fa-solid fa-gas-pump",
    trucks = "fa-solid fa-truck",
    trailers = "fa-solid fa-trailer",
    garage = "fa-solid fa-warehouse",
    goback = "fa-solid fa-backward-step",
    shop = "fa-solid fa-basket-shopping",
    buy = "fa-solid fa-cash-register",
    stop = "fa-solid fa-stop",
    store = "fa-solid fa-store",
}

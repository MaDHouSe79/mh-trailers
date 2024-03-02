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

if GetResourceState("LegacyFuel") ~= 'missing' then
    Config.FuelScript = 'LegacyFuel'
elseif GetResourceState("mh-fuel") ~= 'missing' then
    Config.FuelScript = 'mh-fuel'
end
-- Config.FuelScript = 'your-fuel-script' -- use this if you have your own fuel script thats not in the list

if GetResourceState("ox_lib") ~= 'missing' then
    Config.Target = "ox_target" -- qb-target or ox_target
    Config.Menu = "ox_lib"      -- qb-input or ox_lib
elseif GetResourceState("ox_lib") == 'missing' then
    Config.Target = "qb-target" -- qb-target or ox_target
    Config.Menu = "qb-input"    -- qb-input or ox_lib
end

-- Notify System
Config.NotifyTitle = "MH Trailers"

-- Language
Config.Locale = "en" -- use 'en' or 'nl' 

-- Vehiclekeys trigger
Config.UseServerTrigger = false
Config.ServerVehicleKeyTrigger = "qb-vehiclekeys:server:AcquireVehicleKeys"

Config.UseClientTrigger = true
Config.ClientVehicleKeyTrigger = "vehiclekeys:client:SetOwner"

-- Cash Settings
Config.MoneySign = "€" -- (€/$)

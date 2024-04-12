--[[ ===================================================== ]] --
--[[             MH Trailers Script by MaDHouSe            ]] --
--[[ ===================================================== ]] --
Locales = {}
Config = {}

-- Framework (Do not change this)
Config.Framework = nil
if GetResourceState("es_extended") ~= 'missing' then
    Config.Framework = 'esx'
elseif GetResourceState("qb-core") ~= 'missing' then
    Config.Framework = 'qb'
end

if GetResourceState("LegacyFuel") ~= 'missing' then
    Config.FuelScript= 'LegacyFuel'
elseif GetResourceState("mh-fuel") ~= 'missing' then
    Config.FuelScript = 'mh-fuel'
end

if GetResourceState("ox_lib") ~= 'missing' then
    Config.Target = "qb-target" -- qb-target or ox_target
    Config.Menu = "qb-input"      -- qb-input or ox_lib
elseif GetResourceState("ox_lib") == 'missing' then
    Config.Target = "qb-target" -- qb-target or ox_target
    Config.Menu = "qb-input"    -- qb-input or ox_lib
end

-- Notify System
Config.NotifyTitle = "MH Trailers"

-- Language
Config.Locale = "en" -- use 'en' or 'nl' 

-- Cash Settings
Config.MoneySign = "€" -- (€/$)
Config.MoneyType = {["qb"] = "cash", ['esx'] = "money"}
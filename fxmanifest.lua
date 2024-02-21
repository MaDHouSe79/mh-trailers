--[[ ===================================================== ]] --
--[[             MH Trailers Script by MaDHouSe            ]] --
--[[ ===================================================== ]] --
fx_version 'cerulean'
game 'gta5'

author 'MaDHouSe'
description 'MH-Trailers - to use trailers like in real life'
version '1.0.0'

shared_scripts {
    --'@es_extended/imports.lua',   -- only if you use esx framework
    --'@ox_lib/init.lua',           -- only if you use ex_lib
    '@qb-core/shared/vehicles.lua', -- only if you use qb framework
    'core/mconfig.lua',
    'core/locale.lua',
    'locales/*.lua',
    'config.lua',
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'core/cl_core.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'core/sv_core.lua',
    'server/main.lua',
}

lua54 'yes'

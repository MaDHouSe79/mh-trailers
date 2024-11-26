--[[ ===================================================== ]] --
--[[             MH Trailers Script by MaDHouSe            ]] --
--[[ ===================================================== ]] --
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'MaDHouSe'
description 'MH-Trailers - to use trailers like in real life'
version '1.0.0'

shared_scripts {
    --'@es_extended/imports.lua', -- only if you use esx framework
    '@ox_lib/init.lua', -- only if you use ox_lib
    'core/mconfig.lua',
    'core/locale.lua',
    'core/vehicles.lua',
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
    'server/update.lua',
}

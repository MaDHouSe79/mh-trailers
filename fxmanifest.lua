fx_version 'cerulean'
game 'gta5'

author 'MaDHouSe'
description 'MH-Trailers - to use trailers like in real life'
version '1.0.0'


shared_scripts {
    '@qb-core/shared/locale.lua',
    '@qb-core/shared/vehicles.lua',
    'locales/nl.lua', -- change to your language (en/nl) for now
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}


lua54 'yes'

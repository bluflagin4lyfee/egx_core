fx_version 'cerulean'
game 'gta5'

name 'egx_core'
author 'Don'
description 'EGX (Extreme Gaming X) Core Framework'
version '0.1.0'
lua54 'yes'

shared_scripts {
    'shared/init.lua',
    'shared/config.lua',
}

client_scripts {
    'client/callbacks_client.lua',
    'client/core_client.lua',
    'client/interaction_client.lua',
}

server_scripts {
    -- '@oxmysql/lib/MySQL.lua', -- uncomment when you add DB
    'server/callbacks_server.lua',
    'server/player_server.lua',
    'server/events_server.lua',
    'server/core_server.lua',
}

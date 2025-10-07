fx_version 'cerulean'
game 'gta5'

author 'Aura Development'
description 'Aura Blips Creator UI'
version '1.1'
discord 'https://discord.gg/auradev'
preview 'https://auradev.dev/blipscreator'
documentation 'https://docs.auradev.dev/blipscreator'

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/assets/*.css',
    'web/dist/assets/*.js',
}

shared_script 'config.lua'
client_script 'client.lua'
server_script 'server.lua'

fx_version 'adamant'
game 'gta5'
lua54 'yes'

author 'Wqual#7949'
descritpion 'House Robbery by Wqual'

shared_script "@es_extended/imports.lua"
shared_script '@ox_lib/init.lua'


client_scripts {
    'config.lua',
    'client/**.lua'
}

server_scripts {
    'config.lua',
    'server/**.lua'
}

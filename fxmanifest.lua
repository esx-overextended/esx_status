fx_version "cerulean"
use_experimental_fxv2_oal "yes"
lua54 "yes"
game "gta5"

name "esx_status"
version "0.0.0"
description "ESX-Overextended Status"

dependencies {
    "es_extended"
}

shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua",
    "shared/*.lua"
}

server_scripts {
    "server/*.lua"
}

client_scripts {
    "client/*.lua",
}

-- addons
shared_script "addons/**/shared/*.lua"
server_script "addons/**/server/*.lua"
client_script "addons/**/client/*.lua"

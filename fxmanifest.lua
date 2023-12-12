game 'rdr3'
fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'celedev97'

client_scripts {
  'client/*.lua'
}

server_scripts {
  'server/*.lua'
}

shared_scripts {
  'locale.lua',
  'config.lua',
  'languages/*.lua',
}

ui_page "ui/dist/index.html"

files {
  "ui/dist/*.*",
}

--dont touch
version '0.0.1'
--vorp_checker 'yes'
--vorp_name '^4Resource version Check^3'
--vorp_github 'https://github.com/celedev97/land_of_steam_mailbox'

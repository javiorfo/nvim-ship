" ######################################################
" # Maintainer: Mr. Charkuils                          #
" # URL:        https://github.com/charkuils/nvim-ship #
" ######################################################

if exists('b:current_syntax')
    finish
endif

let b:current_syntax = 'ship'

lua require('ship.syntax').load()

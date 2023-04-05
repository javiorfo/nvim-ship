" #####################################################
" # Maintainer: Javier Orfo                           #
" # URL:        https://github.com/javiorfo/nvim-ship #
" #####################################################

if exists('b:current_syntax')
    finish
endif

let b:current_syntax = 'ship'

lua require('ship.syntax').load()

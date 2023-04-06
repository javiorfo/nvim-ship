" ######################################################
" # Maintainer: Javier Orfo                            #
" # URL:        https://github.com/whiskoder/nvim-ship #
" ######################################################

if exists('b:current_syntax')
    finish
endif

let b:current_syntax = 'shipo'
    
lua require('ship.syntax').load()

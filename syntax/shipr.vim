" #######################################################
" # Maintainer: System Malt                             #
" # URL:        https://github.com/systemmalt/nvim-ship #
" #######################################################

lua << EOF
local syntax_values = require'ship'.DEFAULTS.syntax

if syntax_values then
    vim.cmd[[
        if exists('b:current_syntax')
          finish
        endif

        let b:current_syntax = "shipr"
    ]]
    local syntax = require'ship.syntax'
    syntax.sync()
    syntax.hi(syntax_values)
end
EOF

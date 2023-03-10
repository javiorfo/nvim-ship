" #####################################################
" # Maintainer: Javier Orfo                           #
" # URL:        https://github.com/javiorfo/nvim-ship #
" #####################################################

lua << EOF
local syntax_values = require'ship'.DEFAULTS.syntax

if syntax_values then
    vim.cmd[[
        if exists('b:current_syntax')
          finish
        endif

        let b:current_syntax = "ship"
    ]]
    local syntax = require'ship.syntax'
    syntax.sync()
    syntax.hi(syntax_values)
end
EOF

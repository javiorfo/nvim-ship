-- ####################################################
-- # Maintainer:  Javier Orfo                         #
-- # URL:         https://github.com/javio7/nvim-cafe #
-- ####################################################

if vim.g.cafe then
    return
end

vim.g.cafe = 1

local function cafe_command(method)
    return string.format([[lua if vim.bo.filetype == 'cafe' then 
                                   require('cafe.commands').%s
                               else
                                   require('cafe.utils').logger:warn('This is not a CAFE filetype')
                               end]], method)
end

vim.api.nvim_create_user_command('CAFESend', cafe_command("send()"), {})
vim.api.nvim_create_user_command('CAFECloseResponse', "lua require('cafe.commands').close_cafer()", {})

vim.api.nvim_create_user_command('CAFECreate', function(opts)
    require 'cafe.commands'.create(opts.fargs)
end, { nargs = "?" })

vim.api.nvim_create_user_command('CAFECreateEnv', function(opts)
    require 'cafe.commands'.create_env(opts.fargs)
end, { nargs = "?" })

-- #######################################################
-- # Maintainer:  Mr. Charkuils                          #
-- # URL:         https://github.com/charkuils/nvim-ship #
-- #######################################################

if vim.g.ship then
    return
end

vim.g.ship = 1

vim.api.nvim_create_user_command('SHIP',"lua require'ship.commands'.send()", {})
vim.api.nvim_create_user_command('SHIPCloseResponse', "lua require('ship.commands').close_shipr()", {})

vim.api.nvim_create_user_command('SHIPCreate', function(opts)
    require 'ship.commands'.create(opts.fargs)
end, { nargs = "?" })

vim.api.nvim_create_user_command('SHIPCreateEnv', function(opts)
    require 'ship.commands'.create_env(opts.fargs)
end, { nargs = "?" })

vim.api.nvim_create_user_command('SHIPShowLogs', "lua require('ship.commands').show_logs()", {})

-- #######################################################
-- # Maintainer:  Mr. Charkuils                          #
-- # URL:         https://github.com/charkuils/nvim-ship #
-- #######################################################

if vim.g.ship then
    return
end

vim.g.ship = 1

local function ship_command(method)
    return string.format([[lua if vim.bo.filetype == 'ship' then 
                                   require('ship.commands').%s
                               else
                                   require('ship.util').logger:warn('This is not a SHIP filetype')
                               end]], method)
end

vim.api.nvim_create_user_command('SHIPSend', ship_command("send()"), {})
vim.api.nvim_create_user_command('SHIPCloseResponse', "lua require('ship.commands').close_shipr()", {})

vim.api.nvim_create_user_command('SHIPCreate', function(opts)
    require 'ship.commands'.create(opts.fargs)
end, { nargs = "?" })

vim.api.nvim_create_user_command('SHIPCreateEnv', function(opts)
    require 'shishipmmands'.create_env(opts.fargs)
end, { nargs = "?" })

-- #####################################################
-- # Maintainer: Javier Orfo                           #
-- # URL:        https://github.com/javiorfo/nvim-ship #
-- #####################################################

if vim.g.ship then
    return
end

vim.g.ship = 1

local special = require'ship'.DEFAULTS.special

vim.api.nvim_create_user_command('SHIP',"lua require'ship.commands'.send()", {})
vim.api.nvim_create_user_command('SHIPCloseResponse', "lua require('ship.commands').close_shipr()", {})

vim.api.nvim_create_user_command('SHIPCreate', function(opts)
    require 'ship.commands'.create(opts.fargs)
end, { nargs = "?" })

vim.api.nvim_create_user_command('SHIPCreateEnv', function(opts)
    require 'ship.commands'.create_env(opts.fargs)
end, { nargs = "?" })

vim.api.nvim_create_user_command('SHIPSpecial', function(opts)
    require 'ship.commands'.special(opts.fargs)
end, {
    nargs = 1,
    complete = function(_, _)
        local names = {}
        if special then
           for _, v in pairs(special) do
                table.insert(names, v.name)
           end
        end
        return names
    end
})

vim.api.nvim_create_user_command('SHIPShowLogs', "lua require('ship.commands').show_logs()", {})
vim.api.nvim_create_user_command('SHIPDeleteLogs', "lua require('ship.commands').delete_logs()", {})
vim.api.nvim_create_user_command('SHIPFindResponse', "lua require('ship.commands').find_responses()", {})

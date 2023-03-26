-- #######################################################
-- # Maintainer: System Malt                             #
-- # URL:        https://github.com/systemmalt/nvim-ship #
-- #######################################################

if vim.g.ship then
    return
end

vim.g.ship = 1

local special = require'ship'.DEFAULTS.special

vim.api.nvim_create_user_command('Ship',"lua require'ship.commands'.send()", {})
vim.api.nvim_create_user_command('ShipCloseResponse', "lua require('ship.commands').close_shipr()", {})

vim.api.nvim_create_user_command('ShipCreate', function(opts)
    require 'ship.commands'.create(opts.fargs)
end, { nargs = "?" })

vim.api.nvim_create_user_command('ShipCreateEnv', function(opts)
    require 'ship.commands'.create_env(opts.fargs)
end, { nargs = "?" })

vim.api.nvim_create_user_command('ShipSpecial', function(opts)
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

vim.api.nvim_create_user_command('ShipShowLogs', "lua require('ship.commands').show_logs()", {})
vim.api.nvim_create_user_command('ShipDeleteLogs', "lua require('ship.commands').delete_logs()", {})
vim.api.nvim_create_user_command('ShipFindResponse', "lua require('ship.commands').find_responses()", {})

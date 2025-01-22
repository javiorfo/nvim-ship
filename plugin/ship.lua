if vim.g.ship then
    return
end

vim.g.ship = 1

local commands = require'ship.commands'

vim.api.nvim_create_user_command('Ship',"lua require'ship.commands'.send()", {})
vim.api.nvim_create_user_command('ShipCloseResponse', "lua require'ship.commands'.close_shipo()", {})

vim.api.nvim_create_user_command('ShipCreate', function(opts)
    commands.create(opts.fargs)
end, { nargs = "?" })

vim.api.nvim_create_user_command('ShipCreateEnv', function(opts)
    commands.create_env(opts.fargs)
end, { nargs = "?" })

vim.api.nvim_create_user_command('ShipSpecial', function(opts)
    commands.special(opts.fargs)
end, {
    nargs = 1,
    complete = function(_, _)
        local specials = require'ship'.DEFAULTS.special
        local names = {}
        if specials then
           for _, v in pairs(specials) do
                table.insert(names, v.name)
           end
        end
        return names
    end
})

vim.api.nvim_create_user_command('ShipShowLogs', "lua require'ship.commands'.show_logs()", {})
vim.api.nvim_create_user_command('ShipDeleteLogs', "lua require'ship.commands'.delete_logs()", {})
vim.api.nvim_create_user_command('ShipFindResponse', "lua require'ship.commands'.find_responses()", {})
vim.api.nvim_create_user_command('ShipDecodeJWT', "lua require'ship.commands'.decode_jwt()", {})
vim.api.nvim_create_user_command('ShipBuild', "lua require'ship.commands'.build()", {})

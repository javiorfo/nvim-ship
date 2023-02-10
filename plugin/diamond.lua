-- #######################################################
-- # Maintainer:  Javier Orfo                            #
-- # URL:         https://github.com/javio7/nvim-diamond #
-- #######################################################

if vim.g.diamond then
    return
end

vim.g.diamond = 1

local function diamond_command(method)
    return string.format([[lua if vim.bo.filetype == 'dmnd' then 
                                   require('diamond.commands').%s
                               else
                                   require('diamond.utils').logger:warn('This is not a diamond filetype')
                               end]], method)
end

vim.api.nvim_create_user_command('DiamondSend', diamond_command("send()"), {})
vim.api.nvim_create_user_command('DiamondCloseResponse', "lua require('diamond.commands').close_dmndr()", {})

vim.api.nvim_create_user_command('DiamondCreate', function(opts)
    require 'diamond.commands'.create(opts.fargs)
end, { nargs = "?" })

vim.api.nvim_create_user_command('DiamondCreateEnv', function(opts)
    require 'diamond.commands'.create_env(opts.fargs)
end, { nargs = "?" })

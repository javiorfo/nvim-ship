-- ####################################################
-- # Maintainer:  Javier Orfo                         #
-- # URL:         https://github.com/javi-7/nvim-vurl #
-- ####################################################

if vim.g.vurl then
    return
end

vim.g.vurl = 1

local function vurl_command(method)
    return string.format([[lua if vim.bo.filetype == 'vurl' then 
                                   require('vurl.commands').%s
                               else
                                   require('vurl.utils').logger:warn('This is not a VURL filetype')
                               end]], method)
end

vim.api.nvim_create_user_command('VURLSend', vurl_command("send()"), {})
vim.api.nvim_create_user_command('VURLCloseResponse', "lua require('vurl.commands').close_vurlr()", {})

vim.api.nvim_create_user_command('VURLCreate', function(opts)
    require 'vurl.commands'.create(opts.fargs)
end, { nargs = "?" })

vim.api.nvim_create_user_command('VURLCreateEnv', function(opts)
    require 'vurl.commands'.create_env(opts.fargs)
end, { nargs = "?" })

-- ####################################################
-- # Maintainer:  Javier Orfo                         #
-- # URL:         https://github.com/javio7/nvim-cafe #
-- ####################################################

local core = require'cafe.core'
local Logger = require'cafe.util'.logger
local M = {}

function M.send()
    core.send()
end

function M.create(args)
    local filename = (args[1] or "unamed") .. ".cafe"
    vim.cmd("e " .. filename)
    vim.fn.setline(1, "# Created by CAFE")
    vim.fn.setline(2, "")
    vim.fn.setline(3, "~[BASE]~")
    vim.fn.setline(4, "url https://host.com/path")
    vim.fn.setline(5, "method GET")
    vim.fn.setline(6, "# env /path/to/env.lua")
    vim.fn.setline(7, "")
    vim.fn.setline(8, "~[HEADERS]~")
    vim.fn.setline(9, "accept application/json")
    vim.fn.setline(10, "")
    vim.fn.setline(11, "~[BODY]~")
    vim.fn.setline(12, "# file /path/to/body.json")
    vim.fn.setline(13, "{}")
    vim.cmd("redraw")
    Logger:info(filename .. " created!")
end

function M.close_cafer()
    pcall(function()
        for _, nr in ipairs(vim.api.nvim_list_bufs()) do
            local buf_name = vim.api.nvim_buf_get_name(nr)
            if buf_name:find(".cafer$") then
               vim.cmd("bd! " .. buf_name)
            end
        end
    end)
end

function M.create_env(args)
    local folder_name = args[1] or "env"
    vim.fn.system("mkdir -p " .. folder_name)
    vim.fn.system("touch " .. folder_name .. "/dev.lua")
    vim.fn.system("touch " .. folder_name .. "/test.lua")
    vim.fn.system("touch " .. folder_name .. "/prod.lua")
    Logger:info(folder_name .. " created!")
end

return M

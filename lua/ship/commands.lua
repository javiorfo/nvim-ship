local core = require 'ship.core'
local util = require 'ship.util'
local validator = require 'ship.validator'
local Logger = util.logger
local spinetta = require 'spinetta'

local M = {}

function M.send()
    if validator.dependencies_installed() then
        Logger:debug("Executing SHIP command...")
        core.send()
        --         vim.cmd("wincmd p")
    end
end

function M.create(args)
    local filename = (args[1] or "std_ship_file") .. ".ship"
    if filename:find("/") then
        local path, _ = filename:match("(.-)([^\\/]-%.?)$")
        os.execute("mkdir -p " .. path)
    end
    os.execute("touch " .. filename)
    vim.cmd("e " .. filename)

    vim.fn.setline(1, "# Created by nvim-ship")
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
    vim.fn.setline(12, "# ship_body_file /path/to/body.json")
    vim.fn.setline(13, "# { \"some_property\": \"some value\" }")
    vim.cmd("w | redraw")
    Logger:info(filename .. " created.")
end

function M.close_shipo()
    for _, nr in ipairs(vim.api.nvim_list_bufs()) do
        local buf_name = vim.api.nvim_buf_get_name(nr)
        if vim.api.nvim_buf_is_loaded(nr) and buf_name:find(".shipo$") then
            vim.cmd("bd! " .. buf_name)
        end
    end
end

function M.create_env(args)
    local folder_name = args[1] or "environment"
    vim.fn.system("mkdir -p " .. folder_name)
    vim.fn.system(string.format("echo -e 'return {\n \t host = \"host\"\n}' > %s/dev.lua;", folder_name))
    vim.fn.system(string.format("echo -e 'return {\n \t host = \"host\"\n}' > %s/test.lua;", folder_name))
    vim.fn.system(string.format("echo -e 'return {\n \t host = \"host\"\n}' > %s/prod.lua;", folder_name))
    Logger:info(folder_name .. " created.")
end

function M.show_logs()
    vim.cmd(string.format("vsp %s | normal G", Logger.ship_log_file))
end

function M.delete_logs()
    os.remove(Logger.ship_log_file)
    Logger:info("Log file deleted.")
end

function M.find_responses()
    local ok, telescope = pcall(require, 'telescope.builtin')
    if ok then
        telescope.live_grep { glob_pattern = "*.shipo" }
    else
        Logger:warn("This action require telescope.nvim plugin to be installed.")
    end
end

function M.special(args)
    Logger:debug("Executing ShipSpecial command...")
    core.special(args[1])
end

function M.decode_jwt()
    Logger:debug("Executing ShipDecodeJWT command...")
    core.decode_jwt()
end

function M.build()
    if vim.fn.executable("cargo") == 0 then
        Logger:warn("Rust is required. Install it to use this plugin and then execute manually :ShipBuild")
        return false
    end

    local root_path = util.ship_root_path
    local script = string.format(
        "%sscript/build.sh %s 2> >( while read line; do echo \"[ERROR][$(date '+%%m/%%d/%%Y %%T')]: ${line}\"; done >> %s)",
        root_path,
        root_path, require 'ship.logger'.ship_log_file)
    local spinner = spinetta:new {
        main_msg = "󰀱  SHIP   Building plugin... ",
        speed_ms = 100,
        on_success = function()
            Logger:info("  nvim-ship is ready to be used!")
        end
    }

    spinner:start(spinetta.job_to_run(script))
end

return M

-- #######################################################
-- # Maintainer:  Mr. Charkuils                          #
-- # URL:         https://github.com/charkuils/nvim-ship #
-- #######################################################

local logger = require'ship.util'.logger
local M = {}

function M:new(fn_to_stop_spinner)
    local table = {}
    self.__index = self
    table.fn_to_stop_spinner = fn_to_stop_spinner
    setmetatable(table, self)
    return table
end

function M:start()
    local sleep_ms = 200
    local starting_msg = "Waiting for response "
    local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }

    local index = 1
    local is_interrupted = false
    while true do
        local _, error = pcall(function()
            logger:info(starting_msg .. spinner[index])
            if index < #spinner then
                index = index + 1
            else
                index = 1
            end

            vim.cmd(string.format("sleep %dms", sleep_ms))
            vim.cmd("redraw")
        end)

        if self.fn_to_stop_spinner() or error then
            if error then is_interrupted = true end
            break
        end
    end
    return is_interrupted
end

function M.break_when_pid_is_complete(pid)
    return function()
        return tonumber(vim.fn.system("[ -f '/proc/" .. pid .. "/status' ] && echo 1 || echo 0")) == 0
    end
end

function M.job_to_run(job_string)
    local pid = vim.fn.jobpid(vim.fn.jobstart(job_string))
    return M.break_when_pid_is_complete(pid)
end

return M

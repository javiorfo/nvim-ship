-- #####################################################
-- # Maintainer: Javier Orfo                           #
-- # URL:        https://github.com/javiorfo/nvim-ship #
-- #####################################################

local M = {}

M.ship_log_file = vim.fn.stdpath('log') .. "/ship.log"
local debug_header = string.format("[DEBUG][%s]:", os.date("%m/%d/%Y %H:%M:%S"))

local function logger(plugin_name, msg)
    return function(level)
        if plugin_name then
            msg = string.format("[%s] => %s", plugin_name, msg)
        end
        vim.notify(msg, level)
    end
end

function M:new(plugin_name)
    local table = {}
    self.__index = self
    table.plugin_name = plugin_name
    setmetatable(table, self)
    return table
end

function M:warn(msg)
    logger(self.plugin_name, msg)(vim.log.levels.WARN)
end

function M:error(msg)
    logger(self.plugin_name, msg)(vim.log.levels.ERROR)
end

function M:info(msg)
    logger(self.plugin_name, msg)(vim.log.levels.INFO)
end

function M:debug(msg)
    if require'ship'.DEFAULTS.internal.log_debug then
        local file = io.open(M.ship_log_file, "a")
        if file then
            file:write(string.format("%s %s\n", debug_header, msg))
            file:close()
        end
    end
end

return M

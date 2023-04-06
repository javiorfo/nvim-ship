-- ######################################################
-- # Maintainer: Javier Orfo                            #
-- # URL:        https://github.com/whiskoder/nvim-ship #
-- ######################################################

local M = {}

M.sections = {
    BASE = "%~%[BASE%]%~",
    HEADERS = "%~%[HEADERS%]%~",
    BODY = "%~%[BODY%]%~"
}

M.status_time_tmp_file = "/tmp/ship_code_time_tmp"
M.ship_response_extension = "shipo"
M.script_path = debug.getinfo(1).source:match("@?(.*/)"):gsub("/lua/ship", "") .. "bin/ship.sh"

local logger = require 'ship.logger':new("SHIP")
M.logger = logger

function M.sections_to_skip(section_to_process)
    if section_to_process == M.sections.BASE then
        return { M.sections.HEADERS, M.sections.BODY }
    end
    if section_to_process == M.sections.HEADERS then
        return { M.sections.BASE, M.sections.BODY }
    end
    if section_to_process == M.sections.BODY then
        return { M.sections.HEADERS, M.sections.BASE }
    end
end

function M.trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function M.table_value_from_readline(line)
    return line:match("^(%S+)(.+)")
end

function M.get_table_by_key_and_value(table, key, value)
    for _, v in pairs(table) do
        if v[key] == value then
            return v
        end
    end
end

return M

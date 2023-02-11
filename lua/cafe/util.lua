-- #######################################################
-- # Maintainer:  Mr. Charkuils                          #
-- # URL:         https://github.com/charkuils/nvim-cafe #
-- #######################################################

local M = {}

M.sections = {
    BASE = "%~%[BASE%]%~",
    HEADERS = "%~%[HEADERS%]%~",
    BODY = "%~%[BODY%]%~"
}

M.status_time_tmp_file = "/tmp/cafe_code_time_tmp"
M.cafe_response_extension = "cafer"
M.script_path = debug.getinfo(1).source:match("@?(.*/)"):gsub("/lua/cafe", "") .. "bin/cafe.sh"
M.cafe_log_file = vim.fn.stdpath('log') .. "/cafe.log"

local logger = require 'cafe.logger':new("CAFE")
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

return M

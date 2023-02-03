-- ####################################################
-- # Maintainer:  Javier Orfo                         #
-- # URL:         https://github.com/javio7/nvim-vurl #
-- ####################################################

local M = {}

M.sections = {
    BASE = "%~%[BASE%]%~",
    HEADERS = "%~%[HEADERS%]%~",
    BODY = "%~%[BODY%]%~"
}

M.status_time_tmp_file = "/tmp/vurl_tmp"
M.vurl_response_extension = "vurlr"
M.script_path = debug.getinfo(1).source:match("@?(.*/)"):gsub("/lua/vurl", "") .. "bin/vurl.sh"

local logger = require'vurl.logger':new("VURL")
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
    return string.match(line, "(.+)%s(.+)")
end

return M

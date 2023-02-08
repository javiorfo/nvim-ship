-- ####################################################
-- # Maintainer:  Javier Orfo                         #
-- # URL:         https://github.com/javio7/nvim-vurl #
-- ####################################################

local setup = require'vurl'.DEFAULTS
local util = require'vurl.util'
local Logger = util.logger
local get_status_description = require'vurl.status'.get_http_status
local validator = require'vurl.validator'
local spinner = require'vurl.spinner'
local M = {}

local function read_section(file, section_to_process)
    local sections_to_skip = util.sections_to_skip(section_to_process)
    local result = {}
    local section
    for line in io.lines(file) do
        if (string.find(line, "#")) ~= 1 then
            if not section then
                section = (string.find(line, section_to_process))
            else
                if not (string.find(line, sections_to_skip[1])) and not (string.find(line, sections_to_skip[2])) then
                    local k, v = util.table_value_from_readline(line)
                    if k then
                        result[k] = util.trim(v)
                    end
                else
                    break
                end
            end
        end
    end
    return result
end

local function read_body(file)
    local body_section = util.sections.BODY
    local sections_to_skip = util.sections_to_skip(body_section)
    local result = {}
    local section
    local is_body = false
    for line in io.lines(file) do
        if (string.find(line, "#")) ~= 1 then
            if not section then
                section = (string.find(line, body_section))
            else
                if not (string.find(line, sections_to_skip[1])) and not (string.find(line, sections_to_skip[2])) then
                    if not is_body then
                        if line:find("^{") or line:find("^<") then
                            is_body = true
                            result.vurl_body = (result.vurl_body or "") .. util.trim(line)
                        end
                    else
                        result.vurl_body = (result.vurl_body or "") .. util.trim(line)
                    end
                    if not is_body then
                        local k, v = util.table_value_from_readline(line)
                        if k then
                            result[k] = util.trim(v)
                            if k == "vurl_body_file" then break end
                        end
                    end
                else
                    break
                end
            end
        end
    end
    return result
end

local function process_headers(headers)
    local result = ""
    for k, v in pairs(headers) do
        result = result .. string.format("' -H \"%s: %s\"'", k, v)
    end
    return result
end

local function process_body(body)
    local result = ""
    for k, v in pairs(body) do
        if k == "vurl_body_file" then
            return string.format("'-d \"@%s\"'", v)
        end
        if k == "vurl_body" then
            return string.format("'-d \"%s\"'", v)
        end
        local string_format = "&%s=%s"
        if #result == 0 then string_format = "%s=%s" end
        result = result .. string.format(string_format, k, v)
    end

    if #result == 0 then
        return result
    else
        return string.format("'-d \"%s\"'", result)
    end
end

local function status_and_time()
    vim.cmd("redraw")
    local line = io.lines(util.status_time_tmp_file)()
    local status, time = line:match("([^,]+),([^,]+)")
    status = string.format("%s <%s>", status, get_status_description(status))
    Logger:info(string.format("Complete! | Status -> %s | Time -> %s", status, time))
end

local function clean(response_file)
    os.remove(util.status_time_tmp_file)
    if not setup.output.save then
        os.remove(response_file)
    end
end

local function open_buffer(response_file)
    local orientation = setup.view.horizontal and "sp" or "vsp"
    vim.cmd(string.format("%d%s %s", setup.view.size, orientation, response_file))
end

local function build_output_folder_and_file()
    local output_folder = setup.output.folder

    if not setup.output.save then
        return output_folder, string.format("/tmp/%s.%s", vim.fn.expand("%:t:r"), util.vurl_response_extension)
    end

    local prefix = ""
    if not setup.output.override then
        prefix = tostring(os.date('%Y%m%d-%H%M%S-'))
    end
    if output_folder == "." or output_folder == "" then
        local filename = prefix .. vim.fn.expand("%:p:r")
        return output_folder, string.format("%s.%s", filename, util.vurl_response_extension)
    else if output_folder:find("^/") or output_folder:find("^~/") then
            local filename = prefix .. vim.fn.expand("%:t:r")
            return output_folder, string.format("%s/%s.%s", output_folder, filename, util.vurl_response_extension)
        else
            local filename = prefix .. vim.fn.expand("%:t:r")
            output_folder = string.format("%s/%s", vim.fn.expand("%:h"), output_folder)
            return output_folder, string.format("%s/%s.%s", output_folder, filename, util.vurl_response_extension)
        end
    end
end

function M.send()
    local file = vim.fn.expand("%:p")
    local base = read_section(file, util.sections.BASE)
    local headers = read_section(file, util.sections.HEADERS)
    local body = read_body(file)

    if not validator.is_base_valid(base) then
        return
    end

    -- TODO leer propiedades
--     print(dofile(base.env).host)

--     print(vim.inspect(base))
--     print(vim.inspect(headers))
--     print(vim.inspect(body))
    local headers_list = process_headers(headers)
    local body_param = process_body(body)
    local output_folder, response_file = build_output_folder_and_file()

    local curl = string.format("%s -t %s -m %s -u %s -h %s -c %s -f %s -s %s -d %s -b %s", util.script_path,
        setup.request.timeout, base.method, base.url, setup.response.show_headers, headers_list,
        response_file, setup.output.save, output_folder, body_param)

    local vurl_spinner = spinner:new(spinner.job_to_run(curl))
    local is_interrupted = vurl_spinner:start()

    if not is_interrupted then
        open_buffer(response_file)
        status_and_time()
        clean(response_file)
    else
        vim.cmd("redraw")
        Logger:info("Call interrupted")
    end
end

return M

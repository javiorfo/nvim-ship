-- #####################################################
-- # Maintainer: Javier Orfo                           #
-- # URL:        https://github.com/javiorfo/nvim-ship #
-- #####################################################

local setup = require'ship'.DEFAULTS
local util = require'ship.util'
local Logger = util.logger
local validator = require'ship.validator'
local spinner = require'ship.spinner'
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
                            result.ship_body = (result.ship_body or "") .. util.trim(line)
                        end
                    else
                        result.ship_body = (result.ship_body or "") .. util.trim(line)
                    end
                    if not is_body then
                        local k, v = util.table_value_from_readline(line)
                        if k then
                            result[k] = util.trim(v)
                            if k == "ship_body_file" then break end
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
        if k == "ship_body_file" then
            return string.format("\"@%s\"", v)
        end
        if k == "ship_body" then
            return string.format("'%s'", v)
        end
        local string_format = "&%s=%s"
        if #result == 0 then string_format = "%s=%s" end
        result = result .. string.format(string_format, k, v)
    end

    if #result == 0 then
        return result
    else
        return string.format("'%s'", result)
    end
end

local function status_and_time()
    vim.cmd("redraw")
    local status, time
    local ok, _ = pcall(function()
        local line = io.lines(util.status_time_tmp_file)()
        status, time = line:match("([^,]+),([^,]+)")
        return status, time
    end)
    if ok then
        status = string.format("%s <%s>", status, require'ship.status'.get_http_status(status))
        Logger:info(string.format("Shipped! | Status -> %s | Time -> %s", status, time))
    else
        Logger:error("Internal error. Please check the logs executing :SHIPShowLogs for further details.")
    end
end

local function clean(response_file)
    os.remove(util.status_time_tmp_file)
    if not setup.output.save then
        os.remove(response_file)
    end
end

local function open_buffer(response_file)
    if setup.response.redraw then
        pcall(function() vim.cmd("bd! " .. response_file) end)
    end

    if vim.fn.filereadable(response_file) == 1 then
        local orientation = setup.response.horizontal and "sp" or "vsp"
        vim.cmd(string.format("%d%s %s", setup.response.size, orientation, response_file))
    end
end

local function build_output_folder_and_file()
    local output_folder = setup.output.folder

    if not setup.output.save then
        return output_folder, string.format("/tmp/%s.%s", vim.fn.expand("%:t:r"), util.ship_response_extension)
    end

    local prefix = ""
    if not setup.output.override then
        prefix = tostring(os.date('%Y%m%d-%H%M%S-'))
    end

    if output_folder == "." or output_folder == "" then
        local filename = prefix .. vim.fn.expand("%:p:r")
        return output_folder, string.format("%s.%s", filename, util.ship_response_extension)
    else if output_folder:find("^/") or output_folder:find("^~/") then
            local filename = prefix .. vim.fn.expand("%:t:r")
            return output_folder, string.format("%s/%s.%s", output_folder, filename, util.ship_response_extension)
        else
            local filename = prefix .. vim.fn.expand("%:t:r")
            output_folder = string.format("%s/%s", vim.fn.expand("%:h"), output_folder)
            return output_folder, string.format("%s/%s.%s", output_folder, filename, util.ship_response_extension)
        end
    end
end

local function process_environment(env, base, headers, body)
    local function process(section, k_env, v_env)
        for k_sec, v_sec in pairs(section) do
            section[k_sec] = (string.gsub(v_sec, "{{" .. k_env .. "}}", v_env))
        end
    end

    for k_env, v_env in pairs(env) do
        process(base, k_env, v_env)
        process(headers, k_env, v_env)
        process(body, k_env, v_env)
    end
end

function M.send()
    if setup.request.autosave then
        vim.cmd("silent w")
    end

    local file = vim.fn.expand("%:p")
    Logger:debug("File: " .. file)

    local base = read_section(file, util.sections.BASE)
    Logger:debug("Base section: " .. vim.inspect(base))

    local headers = read_section(file, util.sections.HEADERS)
    Logger:debug("Headers section: " .. vim.inspect(base))

    local body = read_body(file)
    Logger:debug("Body section: " .. vim.inspect(base))

    if not validator.is_base_valid(base) then
        return
    end

    if base.env then
        local ok, result = pcall(dofile, base.env)
        if ok then
            process_environment(result, base, headers, body)
        else
           Logger:error(result)
           return
        end
    end

    local headers_list = process_headers(headers)
    Logger:debug("List of headers: " .. headers_list)

    local body_param = process_body(body)
    if body_param ~= "" then body_param = " -b " .. body_param end
    Logger:debug("Body param: " .. body_param)

    local output_folder, response_file = build_output_folder_and_file()
    Logger:debug("Output folder: " .. output_folder)
    Logger:debug("Response file: " .. response_file)

    local call_to_ship_sh = string.format("%s -t %s -m %s -u '%s' -h %s -c %s -f %s -s %s -d %s %s -l %s 2> >( while read line; do echo \"[ERROR][$(date '+%%D %%T')]: ${line}\"; done >> %s)",
        util.script_path, setup.request.timeout, base.method, base.url, setup.response.show_headers, headers_list,
        response_file, setup.output.save, output_folder, body_param, Logger.ship_log_file, Logger.ship_log_file)

    Logger:debug("Call to ship.sh: " .. call_to_ship_sh)

    local ship_spinner = spinner:new(spinner.job_to_run(call_to_ship_sh))
    local is_interrupted = ship_spinner:start()

    if not is_interrupted then
        open_buffer(response_file)
        status_and_time()
        clean(response_file)
    else
        vim.cmd("redraw")
        Logger:info("Call interrupted!")
    end
end

return M

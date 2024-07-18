local Logger = require'ship.util'.logger
local validator = require'ship.validator'
local M = {}

M.DEFAULTS = {
    view = {
        autocomplete = true
    },
    request = {
        timeout = 30,
        autosave = true,
        insecure = false
    },
    response = {
        show_headers = 'all',
        window_type = 'h',
        size = 20,
        redraw = true
    },
    output = {
        save = false,
        override = true,
        folder = "output",
    },
    internal = {
        log_debug = false
    }
}

function M.setup(opts)
    if opts.view then
        local v = opts.view
        if v.autocomplete ~= nil then
            if type(v.autocomplete) == "boolean" then
                M.DEFAULTS.view.autocomplete = v.autocomplete
            else
                Logger:error("Setup Error: view.autocomplete must be a boolean value.")
            end
        end
    end
    if opts.request then
        local r = opts.request
        if r.timeout then
            if type(r.timeout) == "number" then
                M.DEFAULTS.request.timeout = r.timeout
            else
                Logger:error("Setup Error: request.timeout must be a number value.")
            end
        end
        if r.autosave ~= nil then
            if type(r.autosave) == "boolean" then
                M.DEFAULTS.request.autosave = r.autosave
            else
                Logger:error("Setup Error: request.autosave must be a boolean value.")
            end
        end
        if r.insecure ~= nil then
            if type(r.insecure) == "boolean" then
                M.DEFAULTS.request.insecure = r.insecure
            else
                Logger:error("Setup Error: request.insecure must be a boolean value.")
            end
        end
    end

    if opts.response then
        local r = opts.response
        if r.show_headers then
            if r.show_headers == "all" or r.show_headers == "res" or r.show_headers == "none" then
                M.DEFAULTS.response.show_headers = r.show_headers
            else
                Logger:error("Setup Error: the value for response.show_headers must be 'all', 'res' or 'none'.")
            end
        end
        if r.window_type then
            if type(r.window_type) == "string" and r.window_type == "p" or r.window_type == "v" or r.window_type == "h" then
                M.DEFAULTS.response.window_type = r.window_type
            else
                Logger:error("Setup Error: response.window_type must be 'p', 'v' or 'h'.")
            end
        end
        if r.size then
            if type(r.size) == "number" then
                M.DEFAULTS.response.size = r.size
            else
                Logger:error("Setup Error: response.size must be a number value.")
            end
        end
        if r.redraw ~= nil then
            if type(r.redraw) == "boolean" then
                M.DEFAULTS.response.redraw = r.redraw
            else
                Logger:error("Setup Error: response.redraw must be a boolean value.")
            end
        end
    end

    if opts.output then
        local r = opts.output
        if r.save ~= nil then
            if type(r.save) == "boolean" then
                M.DEFAULTS.output.save = r.save
            else
                Logger:error("Setup Error: output.save must be a boolean value.")
            end
        end
        if r.override ~= nil then
            if type(r.override) == "boolean" then
                M.DEFAULTS.output.override = r.override
            else
                Logger:error("Setup Error: output.override must be a boolean value.")
            end
        end
        if r.folder then
            if type(r.folder) == "string" then
                M.DEFAULTS.output.folder = r.folder
            else
                Logger:error("Setup Error: output.folder must be a string value.")
            end
        end
    end

    if opts.internal then
        local r = opts.internal
        if r.log_debug ~= nil then
            if type(r.log_debug) == "boolean" then
                M.DEFAULTS.internal.log_debug = r.log_debug
            else
                Logger:error("Setup Error: internal.log_debug must be a boolean value.")
            end
        end
    end

    if opts.special then
       if validator.validate_special(opts.special) then
           M.DEFAULTS.special = opts.special
       end
    end

    Logger:debug("Initial configuration: " .. vim.inspect(M.DEFAULTS))
end

return M

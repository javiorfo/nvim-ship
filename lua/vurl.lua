-- ####################################################
-- # Maintainer:  Javier Orfo                         #
-- # URL:         https://github.com/javio7/nvim-vurl #
-- ####################################################

local Logger = require'vurl.util'.logger
local M = {}

M.DEFAULTS = {
    request = {
        timeout = 60
    },
    response = {
        show_headers = 'all'
    },
    view = {
        horizontal = true,
        size = 20
    },
    output = {
        save = false,
        override = true,
        folder = "output",
    },
    special = {}
}


function M.setup(opts)
    if opts.request then
        local r = opts.request
        if r.timeout then
            if type(r.timeout) == "number" then
                M.DEFAULTS.request.timeout = r.timeout
            else
                Logger:error("Setup Error: request.timeout must be a number value.")
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
    end

    if opts.view then
        local r = opts.view
        if r.horizontal then
            if type(r.horizontal) == "boolean" then
                M.DEFAULTS.view.horizontal = r.horizontal
            else
                Logger:error("Setup Error: view.horizontal must be a boolean value.")
            end
        end
        if r.size then
            if type(r.size) == "number" then
                M.DEFAULTS.view.size = r.size
            else
                Logger:error("Setup Error: view.size must be a number value.")
            end
        end
    end

    if opts.output then
        local r = opts.save
        if r.save then
            if type(r.save) == "boolean" then
                M.DEFAULTS.output.save = r.save
            else
                Logger:error("Setup Error: output.save must be a boolean value.")
            end
        end
        if r.override then
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
end

return M

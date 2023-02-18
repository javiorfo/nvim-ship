-- #######################################################
-- # Maintainer:  Mr. Charkuils                          #
-- # URL:         https://github.com/charkuils/nvim-ship #
-- #######################################################

local Logger = require'ship.util'.logger
local M = {}

local function is_http_method_valid(method)
    local http_methods = { "GET", "POST", "PUT", "DELETE", "PATCH",
        "CONNECT", "OPTIONS", "TRACE", "HEAD" }
    for _, v in ipairs(http_methods) do
        if v == method then
            return true
        end
    end
    return false
end

function M.is_base_valid(base)
    if not base then
        Logger:error("~[BASE]~ section is missing.")
        return false
    end
    if not base.url or base.url == "" then
        Logger:error("url is missing in ~[BASE]~ section.")
        return false
    end
    if not base.method or base.method == "" then
        Logger:error("method is missing in ~[BASE]~ section.")
        return false
    elseif not is_http_method_valid(base.method) then
        Logger:error("method value is not valid in ~[BASE]~ section.")
        return false
    end
    return true
end

function M.dependencies_installed()
    if vim.bo.filetype ~= "ship" then
        Logger:warn('This is not a SHIP filetype.')
        return false
    end
    if vim.fn.executable("curl") == 0 then
        Logger:warn("curl is required to be installed in order to execute SHIP.")
        return false
    end
    if vim.fn.executable("jq") == 0 then
        Logger:warn("jq is required to be installed in order to execute SHIP.")
        return false
    end
    if vim.fn.executable("tidy") == 0 then
        Logger:warn("tidy is required to be installed in order to execute SHIP.")
        return false
    end
    return true
end

return M

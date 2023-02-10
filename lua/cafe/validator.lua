-- ####################################################
-- # Maintainer:  Javier Orfo                         #
-- # URL:         https://github.com/javio7/nvim-cafe #
-- ####################################################

local Logger = require'cafe.util'.logger
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

return M

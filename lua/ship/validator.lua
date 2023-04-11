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

function M.validate_special(special)
    for _, item in pairs(special) do
       if item.name and type(item.name) == "string" and item.name ~= "" then
            if item.take and type(item.take) == "table" then
                if not item.take.ship_file or type(item.take.ship_file) ~= "string" or item.take.ship_file == "" then
                    Logger:error("Setup Error: take.ship_file in special is required, not empty and must be a string value pointing to a ship filetype.")
                    return false
                end
                if not item.take.ship_field or type(item.take.ship_field) ~= "string" or item.take.ship_field == "" then
                    Logger:error("Setup Error: take.ship_field in special is required, not empty and must be a string value.")
                    return false
                end
            else
                Logger:error("Setup Error: take in special is required and must be a table value.")
                    return false
            end
            if item.update and type(item.update) == "table" then
                if not item.update.lua_file or type(item.update.lua_file) ~= "string"  or item.update.lua_file == "" then
                    Logger:error("Setup Error: update.lua_file in special is required, not empty and must be a string value pointing to a lua filetype..")
                    return false
                end
                if not item.update.lua_field or type(item.update.lua_field) ~= "string"  or item.update.lua_field == "" then
                    Logger:error("Setup Error: update.lua_field in special is required, not empty and must be a string value.")
                    return false
                end
            else
                Logger:error("Setup Error: update in special is required and must be a table value.")
                    return false
            end
        else
            Logger:error("Setup Error: name in special is required, not empty and must be a string value.")
                    return false
       end
    end
    return true
end

return M

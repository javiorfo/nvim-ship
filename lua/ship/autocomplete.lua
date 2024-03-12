local source = {}

source.new = function()
    return setmetatable({}, { __index = source })
end

source.complete = function(_, _, callback)
    callback { items = {
        { label = '~[BASE]~' },
        { label = '~[HEADERS]~' },
        { label = '~[BODY]~' },
        { label = 'url' },
        { label = 'method' },
        { label = 'env' },
        { label = 'GET' },
        { label = 'POST' },
        { label = 'PUT' },
        { label = 'DELETE' },
        { label = 'HEAD' },
        { label = 'PATCH' },
--         TODO add common headers
    } }
end

local ok, cmp = pcall(require, 'cmp')

if ok then
    cmp.register_source('ship_complete', source.new())

    cmp.setup.filetype({ "ship" }, {
        sources = {
            { name = 'ship_complete' }
        },
        formatting = {
            format = function(_, vim_item)
--                 TODO kinds
                if vim_item.word == "url" then
                    vim_item.kind = "󰀱 "
                end
                return vim_item
            end
        }
    })
end

return source

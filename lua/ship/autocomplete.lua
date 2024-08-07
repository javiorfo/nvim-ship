local source = {}

local items = {}

local sections = {
    '~[BASE]~',
    '~[HEADERS]~',
    '~[BODY]~',
}

local labels = {
    'url',
    'method',
    'env',
    'ship_body_file'
}

local methods = {
    'GET',
    'POST',
    'PUT',
    'DELETE',
    'HEAD',
    'PATCH',
}

local header_labels = {
    'content-type',
    'accept',
    'accept-language',
    'accept-charset',
    'accept-encoding',
    'accept-control-request-method',
    'accept-control-request-headers',
    'cache-control',
    'content-length',
    'cookie',
    'date',
    'authorization',
    'authorization Basic',
    'authorization Bearer',
}

local header_values = {
    'application/json',
    'application/xml',
    'application/text',
    'application/pdf',
    'application/zip',
    'application/sql',
    'application/x-www-form-urlencoded',
    'text/html',
    'text/plain',
    'text/css',
    'text/csv',
    'text/xml',
    'text/javascript',
    'multipart/form-data',
}

local function add_to_items(values, insert_text)
    for _, v in pairs(values) do
        table.insert(items, { label = v, insertText = v .. insert_text })
    end
end

local function is_in_table(value, table_to_search)
    for _, v in pairs(table_to_search) do
        if value == v then
            return true
        end
    end
    return false
end

source.new = function()
    return setmetatable({}, { __index = source })
end

add_to_items(sections, "\n")
add_to_items(labels, " ")
add_to_items(methods, "")
add_to_items(header_labels, " ")
add_to_items(header_values, "\n")

source.complete = function(_, _, callback)
    callback { items = items }
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
                if is_in_table(vim_item.word, sections) then
                    vim_item.kind = "󰀱 Section"
                elseif is_in_table(vim_item.word, labels) then
                    vim_item.kind = "󰀱 Label"
                elseif is_in_table(vim_item.word, methods) then
                    vim_item.kind = "󰀱 Method"
                elseif is_in_table(vim_item.word, header_labels) then
                    vim_item.kind = "󰀱 Header Label"
                else
                    vim_item.kind = "󰀱 Header Value"
                end
                return vim_item
            end
        }
    })
end

return source

local setup = require'ship'.DEFAULTS

if setup.view.autocomplete then
    require'ship.autocomplete'.new()
end

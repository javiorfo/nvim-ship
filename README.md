# nvim-ship
### S.H.I.P. (Send Handwritten Inquisitive Petitions)
*nvim-ship is a Neovim plugin for calling APIs (REST and GraphQL) written in Lua.*

## Caveats
- **nvim-ship** needs [curl](https://github.com/curl/curl), [jq](https://github.com/stedolan/jq) and [tidy](https://github.com/htacg/tidy-html5) to be installed. Otherwise it will throw a warning message.
- This plugin has been developed on and for Linux following open source philosophy.

| Feature | nvim-ship | NOTE |
| ------- | ------------- | ---- |
| REST | :heavy_check_mark: | Supports all http methods (GET, POST, etc) |
| GraphQL | :heavy_check_mark: | GraphQL queries on body |
| gRPC | :x: |  |
| WebSocket | :x: |  |
| FTP | :x: |  |
| Timeout | :heavy_check_mark: | Set by `setup` |
| Request JSON body | :heavy_check_mark: |  |
| Request HTML body | :heavy_check_mark: |  |
| Request XML body | :heavy_check_mark: |  |
| Request GraphQL query body | :heavy_check_mark: |  |
| Request Multipart Form body | :heavy_check_mark: |  |
| Request Form Url Encoded body | :heavy_check_mark: |  |
| Request EDN body | :x: |  |
| Request YAML body | :x: |  |
| Response JSON | :heavy_check_mark: |  |
| Response HTML | :heavy_check_mark: |  |
| Response XML | :heavy_check_mark: |  |
| Response Plain Text | :heavy_check_mark: |  |
| Response EDN | :x: |  |
| Response YAML | :x: |  |
| Show Headers | :heavy_check_mark: | Set by `setup`. None, only response or all |
| Authorization | :heavy_check_mark: | API Key Auth, Basic Auth, Bearer Token, OAuth 2.0, etc |
| Request body form a file | :heavy_check_mark: | with tag `ship_body_file` |
| URL queries | :heavy_check_mark: |  |
| Path parameters | :heavy_check_mark: |  |
| Environment variables | :heavy_check_mark: | by Lua files |
| Special ENV variables update | :heavy_check_mark: | executing `:SHIPSpecial` (JSON only) |
| Output files | :heavy_check_mark: | Dismiss or save them. Output folder set by `setup` |
| Output files Integrated with Telescope | :heavy_check_mark: | executing `:SHIPFindResponse` |
| Syntax highlighting | :heavy_check_mark: | Included |
| Command to create ship file | :heavy_check_mark: | executing `:SHIPCreate` |
| Command to create env archetype | :heavy_check_mark: | executing `:SHIPCreateEnv` |
| Command to check LOGS | :heavy_check_mark: | executing `:SHIPShowLogs` |
| Wiki | :heavy_check_mark: | [nvim-ship wiki](https://github.com/charkuils/nvim-ship/wiki) |

## Table of Contents
- [Installation](#installation)
- [Shipping Services](#shipping-services)
- [Custom Setup & Configuration](#custom-configuration)
- [Environment Variables](#environment-variables)
- [Commands](#commands)
- [Logs](#logs)
- [Integrations](#integrations)
- [Issues](#issues)

 ## Installation
`Vim Plug`
```vim
Plug 'charkuils/nvim-ship'
Plug 'charkuils/nvim-spinetta'
```
`Packer`
```lua
use {
    'charkuils/nvim-ship',
    requires = 'charkuils/nvim-spinetta'
}
```

**NOTE:** In order to use the command `ShipFindResponse`, [telescope-nvim](https://github.com/nvim-telescope/telescope.nvim) is required to be installed

---

## Shipping Services

The `ship files` are those with **.ship** extension (Ex: _some_file.ship_). These files must contain the following syntax:

<img src="https://github.com/charkuils/img/blob/master/nvim-ship/ship_file.png" alt="ship file" style="width:600px;"/>

**NOTE:** The colorscheme **malt** from [nvim-whisky](https://github.com/charkuils/nvim-whisky) is used in this image

### Sections
- `~[BASE]~` is required and contains the following tags:
    - **url** (required)
    - **method** (required). Examples: GET, POST, PUT, DELETE, etc.
    - **env** (optional). This contains de absolute path of a Lua file in order to use environment variables
- `~[HEADERS]~` is required and contains the headers a user could set. Examples: 
    - **accept** application/json
    - **Authorization** Bearer xxx...
    - **custom-header** something
- `~[BODY]~` is optional. It can contain JSON or XML formats:
    - Simply paste a JSON object or XML below this section and nvim-ship will take it as body parameter
    - Another useful option is to set the tag **ship_body_file** /absolute/path/to/filename.json (It works with XML files too)

### Caveats
- Comments on a ship file are made by `# my comment`
- If you are wondering about the **syntax highlighting** go to this [section](https://github.com/charkuils/nvim-ship/wiki/Setup#syntax)
- Don't use double quotes as values. 
    - :heavy_check_mark: **url** http://localhost:8080/path
    - :x: **url** "http://localhost:8080/path"

### Usage

- Most common first usage is to create a **ship file** and send a simple REST or GraphQL request.
- Recommendations are to use the built-in command `:ShipCreate` which is going to generate a basic ship file. Edit url, method, headers, etc; to request a service.
- Executing the command `:Ship` will show a buffer with the response (including headers, status code and time).

<img src="https://github.com/charkuils/img/blob/master/nvim-ship/ship_simple.gif" alt="ship simple" style="width:600px;"/>

**NOTE:** These test examples are placed in this [folder](https://github.com/charkuils/nvim-ship/tree/master/tests/ships)

---

## Custom Configuration

This is the initial implicit setup of **nvim-ship**

If you don't want to change any of this values, there is no need to paste this snippet on _init.lua_ or _init.vim_, these are the values by default

```lua
require'ship'.setup {
    request = {
        timeout = 30, 
        autosave = true  
    },
    response = {
        show_headers = 'all',
        horizontal = true,
        size = 20,
        redraw = true
    },
    output = {
        save = false,
        override = true,
        folder = "output",
    },
    internal = {
        log_debug = false,
    }
}
```

### Detailed explanation
- `request`
    - **timeout** (number) set the corresponding timeout when you send a request to a service. If a response takes longer than the value set, the process will end. **DEFAULT: 30**
    - **autosave** (boolean) is a way to save the ship file before you execute `:Ship` command, not having to press the write command `:w` every time you edit a ship file before run it. **DEFAULT: true**
- `response`
    - **show_headers** (string) set how to show headers on response (_shipo_). Three values are allowed: 'all' (shows request and response headers), 'res' (shows only response headers) and 'none' (does not show any response). **DEFAULT: 'all'**
    - **horizontal** (boolean) set the orientation of the response buffer (_shipo_). If true, It will open a buffer with horizontal orientation, if false, with vertical orientation. **DEFAULT: true**
    - **size** (number) corresponds to the response buffer size (_shipo_). You can increment or decrement the buffer size according to your convenience. **DEFAULT: 20**
    - **redraw** (boolean) set if you want to redraw the response buffer or you want to accumulate response buffers to compare their results on the window. Note that disable this requires you to close all buffer responses manually. **DEFAULT: true**
- `output`
    - **save** (boolean) set if you want to save the responses (_shipo files_). Maybe to check results every day or something. **DEFAULT: false**
    - **override** (boolean) comes in hand with the above **save** option. If **save** is true and **override** is true, then it will only keep one copy of the _shipo_ file in your machine. Contrary if **override** is set to false then you will have copies for every response with the following format: _%Y%m%d-%H%M%S-filename.shipo_. **DEFAULT: true**
    - **folder** (string) comes in hand with **save** option. This set the path where the _shipo_ files will be stored. Absolute and relative paths are allowed. **DEFAULT: 'output'**
- `internal`
    - **log_debug** (boolean) enables if a debug phase will be considered to be write in **ship.log**

---

This section will cover different ways to setup useful environment variables.

## Environment Variables

The way of configure environment variables for a **ship file** is by Lua files. This feature gives the flexibility of using Lua files for variables, imports and even functions harnessing all the Lua power for this purpose.

Recommendation is to use the command `:ShipCreateEnv`. This command will create three files: dev.lua, test.lua and prod.lua with the following format:
```lua
return {
    host = "https://somedomain.com",
    other_var = "some_value"
}
```
**IMPORTANT:** Variables in Lua file must be **ONLY STRING VALUES**

### Usage
- The **ship file** must contain the tag **env** in `~[BASE]~` section pointing to the absolute path of the environment variables Lua file.
- Use the variables only in values (using as tags is not allowed) like this: **{{my_variable}}**

#### Simple Example

<img src="https://github.com/charkuils/img/blob/master/nvim-ship/ship_environment.gif" alt="ship file" style="width:600px;"/>

**NOTE:** The colorscheme **malt** from [nvim-whisky](https://github.com/charkuils/nvim-whisky) is used in this image

## Special

The **SPECIAL FEATURE** is something useful for updating environment variables. A good example will be an API KEY or token which expires in seconds. It's really a hassle to call a service to obtain a token, paste the token in an enviroment variables file and call again the corresponding service. For this, nvim-ship has a special feature that allows to update a specific enviroment variable in a file by calling another service.

### Example of a special configuration
```lua
require'ship'.setup {
    special = {
        {
            -- Give a name to the special feature
            name = "token_service",
            take = {
                -- Call request to get a token response
                ship_file = "/absolute/path/to/request_token.ship",
                -- Get the value from JSON response
                ship_field = "access_token"
            },
            update = {
                -- Set the Lua enviroment variables file to update
                lua_file = "/absolute/path/to/environment.lua",
                -- Set the variable from 'lua_file' to update
                lua_field = "token"
            }
        }
    }
}
```
Once this is set it up, to call it execute the command `:ShipSpecial token_service` and enviroment.lua will be updated and ready to use

### Caveats
- It works ONLY WITH JSON
- In setup, **special** is a table which contains tables. You can set whatever the number of "specials" you want. The command `:ShipSpecial` will do a fuzzy search by name.

#### Special Example
- In this example there is a **special.lua** file configured and the way to set it on **init.lua* is like this:
```lua
require'ship'.setup {
    special = dofile("/absolute/path/to/special.lua")
}
```

<img src="https://github.com/charkuils/img/blob/master/nvim-ship/ship_special.gif" alt="ship special" style="width:600px;"/>

**NOTE:** The colorscheme **matl** from [nvim-whisky](https://github.com/charkuils/nvim-whisky) is used in this image

## [Tricks](#tricks)

As mentioned, Lua files as enviroment gives you a lot of flexibility so here are some tricks you can implement to make your configurations less repetitive and helpful

### Example
There are cases when some variables are the same in every environment (dev, test, etc). Using Lua you can leverage configurations by imports, functions or any functionality Lua provides

#### localhost.lua
```lua
return {
    host = "localhost:8080",
    auth_server = "https://authserver.com/auth",
    trace = "MY_TRACE_FROM " .. host
}
```

#### dev.lua
```lua
local localhost = require'localhost' -- here using require to get the table from localhost.lua

return {
    host = "dev.domain",
    auth_server = localhost.auth_server, -- A change auth_server in localhost.lua will update both Lua files
    trace = (string.gsub(localhost.trace, localhost.host, host)) -- This replace localhost:8080 by dev.domain (a dummy example but you get the point)
}
```

### Caveats
The examples above are very useful if you do not change environment variables very often. A downside of this could be that **require** keyword load a Lua module one time. So updating localhost.lua will require a Neovim restart to update dev.lua.
A more optimized way to get modules updated is using `dofile` keyword instead of `require`

#### dev.lua
```lua
local localhost = dofile("/absolute/path/to/localhost.lua")
...
```

---

## Commands

### [Ship](#ship)
- This will send the request of a ship file
- It's convenient to mapping this
```lua
-- Mapping bound to user init.lua
vim.api.nvim_set_keymap('n', '<leader>sh', '<cmd>Ship<CR>', { noremap = true, silent = true })
```

### [ShipCloseResponse](#shipclosereponse)
- This will close all the open responses
- It's convenient to mapping this
```lua
-- Mapping bound to user init.lua
vim.api.nvim_set_keymap('n', '<leader>sc', '<cmd>ShipCloseResponse<CR>', { noremap = true, silent = true })
```

### [ShipCreate](#shipcreate)
- This will create a basic ship file
- Executing `:ShipCreate` will create a file called **std_ship_file.ship**
- Executing `:ShipCreate filenamehere` will create a file called **filenamehere.ship**

### [ShipCreateEnv](#shipcreateenv)
- This will create a basic structure for env variables
- Executing `:ShipCreateEnv` will create a folder called **environment** with three Lua files inside: dev.lua, test.lua and prod.lua
- Executing `:ShipCreateEnv foldernamehere` will create a folder called **foldernamehere** with the same Lua files

### [ShipDeleteLogs](#shipdeletelogs)
- This will delete the log file
- Usually placed in **~/.local/state/nvim/ship.log**

### [ShipFindResponse](#shipfindresponse)
- This will open telescope (if installed) to do a **live_grep** on `shipo files`

### [ShipShowLogs](#shipshowlogs)
- This will show the ship.log file on a split buffer
- Usually placed in **~/.local/state/nvim/ship.log**

### [ShipSpecial](#shipspecial)
- This will execute the 'special' section configured by the setup function
- Go to this [section](#environment-variables#special) for further information

---

## [Logs](#logs)
Logs are saved generally in this path: **/home/user/.local/state/nvim/ship.log**

- To check the logs execute the command `:ShipShowLogs`
- To delete all logs execute the command `:ShipDeleteLogs`

**NOTE**: Only error logs are saved. If you want to enable debug phase, enable this on setup configuration:
```lua
require'ship'.setup {
    internal = {
       log_debug = true 
   }
}
```

## [Integrations](#integrations)
**nvim-ship** could be integrated with [telescope.vim](https://github.com/nvim-telescope/telescope.nvim) to see `shipo` files (responses
saved) 

- First, you have to enable save on setup configuration:
```lua
require'ship'.setup {
    ouput = { 
        save = true 
    }
}
```

- Then you can open telescope by executing the command `:ShipFindResponse`

## [Issues](#issues)
- If you have any issue or you find a bug, please let me know about it reporting an issue [here](https://github.com/charkuils/nvim-ship/issues)

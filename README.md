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
- [Custom Setup & Configuration](#custom-setup/configuration)
- [Environment Variables](#environment-variables)
- [Commands](#commands)
- [Others](#others)

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

</br>

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

</br>

## Custom Setup/Configuration

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
    - **size** (number) corresponds to the response buffer size (_shipo_). You can increment or decrement the buffer size according to your convenience. **DEFAULT: *20*
    - **redraw** (boolean) set if you want to redraw the response buffer or you want to accumulate response buffers to compare their results on the window. Note that disable this requires you to close all buffer responses manually. **DEFAULT: true**
- `output`
    - **save** (boolean) set if you want to save the responses (_shipo files_). Maybe to check results every day or something. **DEFAULT: false**
    - **override** (boolean) comes in hand with the above **save** option. If **save** is true and **override** is true, then it will only keep one copy of the _shipo_ file in your machine. Contrary if **override** is set to false then you will have copies for every response with the following format: _%Y%m%d-%H%M%S-filename.shipo_. **DEFAULT: true**
    - **folder** (string) comes in hand with **save** option. This set the path where the _shipo_ files will be stored. Absolute and relative paths are allowed. **DEFAULT: 'output'**
- `internal`
    - **log_debug** (boolean) enables if a debug phase will be considered to be write in **ship.log**

</br>


## Ship Files
The `ship files` are those with **.ship** extension (Ex: _some_file.ship_). These files must contain the following syntax:

<img src="https://github.com/charkuils/img/blob/master/nvim-ship/ship_file.png" alt="ship file" style="width:500px;"/>

Check [Wiki](https://github.com/charkuils/nvim-ship/wiki/Shipping#ship) for further information

## Usage
- Most common first usage is to create a **ship file** and send a simple REST or GraphQL request.
- Recommendations are to use the built-in command `:ShipCreate` which is going to generate a basic ship file. Edit url, method, headers, etc; to request a service.
- Executing the command `:Ship` will show a buffer with the response (including headers, status code and time).
- Check [Wiki](https://github.com/charkuils/nvim-ship/wiki/Shipping) for further information

<img src="https://github.com/charkuils/img/blob/master/nvim-ship/ship_simple.gif" alt="ship simple" style="width:1000px;"/>

**NOTE:** These test examples are placed in this [folder](https://github.com/charkuils/nvim-ship/tree/master/tests/ships)

## Environment Variables
The way of configure environment variables for a **ship file** is by Lua files. This feature gives the flexibility of using Lua files for variables, imports and even functions harnessing all the Lua power for this purpose. Check [Wiki](https://github.com/charkuils/nvim-ship/wiki/Environment#setup) for further information

#### Simple Example

<img src="https://github.com/charkuils/img/blob/master/nvim-ship/ship_environment.gif" alt="ship file" style="width:1000px;"/>

## Special Feature
The **SPECIAL FEATURE** is something useful for updating environment variables. A good example will be an API KEY or token which expires in seconds. It's really a hassle to call a service to obtain a token, paste the token in an enviroment variables file and call again the corresponding service. For this, nvim-ship has a special feature that allows to update a specific enviroment variable in a file by calling another service. Check [Wiki](https://github.com/charkuils/nvim-ship/wiki/Environment#special) for further information

<img src="https://github.com/charkuils/img/blob/master/nvim-ship/ship_special.gif" alt="ship special" style="width:1000px;"/>

**NOTE:** The colorscheme **malt** from [nvim-whisky](https://github.com/charkuils/nvim-whisky) is used in all images and gifs

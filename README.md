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
| Syntax highlighting | :heavy_check_mark: | Set by `setup` or using [nvim-nyctovim](https://github.com/javiorfo/nvim-nyctovim) |
| Command to create ship file | :heavy_check_mark: | executing `:SHIPCreate` |
| Command to create env archetype | :heavy_check_mark: | executing `:SHIPCreateEnv` |
| Command to check LOGS | :heavy_check_mark: | executing `:SHIPShowLogs` |
| Wiki | :heavy_check_mark: | [nvim-ship wiki](https://github.com/javiorfo/nvim-ship/wiki) |

 ## Installation
`Vim Plug`
```vim
Plug 'javiorfo/nvim-ship'
Plug 'javiorfo/nvim-spinetta'
```
`Packer`
```lua
use {
    'javiorfo/nvim-ship',
    requires = 'javiorfo/nvim-spinetta'
}
```

## Ship Files
The `ship files` are those with **.ship** extension (Ex: _some_file.ship_). These files must contain the following syntax:

<img src="https://github.com/javiorfo/img/blob/master/nvim-ship/ship_file.png" alt="ship file" style="width:500px;"/>

Check [Wiki](https://github.com/javiorfo/nvim-ship/wiki/Shipping#ship) for further information

## Usage
- Most common first usage is to create a **ship file** and send a simple REST or GraphQL request.
- Recommendations are to use the built-in command `:ShipCreate` which is going to generate a basic ship file. Edit url, method, headers, etc; to request a service.
- Executing the command `:Ship` will show a buffer with the response (including headers, status code and time).
- Check [Wiki](https://github.com/javiorfo/nvim-ship/wiki/Shipping) for further information

<img src="https://github.com/javiorfo/img/blob/master/nvim-ship/ship_simple.gif" alt="ship simple" style="width:1000px;"/>

**NOTE:** These test examples are placed in this [folder](https://github.com/javiorfo/nvim-ship/tree/master/tests/ships)

## Environment Variables
The way of configure environment variables for a **ship file** is by Lua files. This feature gives the flexibility of using Lua files for variables, imports and even functions harnessing all the Lua power for this purpose. Check [Wiki](https://github.com/javiorfo/nvim-ship/wiki/Environment#setup) for further information

#### Simple Example

<img src="https://github.com/javiorfo/img/blob/master/nvim-ship/ship_environment.gif" alt="ship file" style="width:1000px;"/>

## Special Feature
The **SPECIAL FEATURE** is something useful for updating environment variables. A good example will be an API KEY or token which expires in seconds. It's really a hassle to call a service to obtain a token, paste the token in an enviroment variables file and call again the corresponding service. For this, nvim-ship has a special feature that allows to update a specific enviroment variable in a file by calling another service. Check [Wiki](https://github.com/javiorfo/nvim-ship/wiki/Environment#special) for further information

<img src="https://github.com/javiorfo/img/blob/master/nvim-ship/ship_special.gif" alt="ship special" style="width:1000px;"/>

**NOTE:** The colorscheme **silentium** from [nvim-nyctovim](https://github.com/javiorfo/nvim-nyctovim) is used in all images and gifs

# nvim-cafe (WIP)
### :coffee: C.A.F.E. (Call A Flavorful Endpoint)
*nvim-cafe is a Neovim plugin for calling APIs (REST, GraphQL, etc) written in Lua.*

## Caveats
- nvim-cafe needs `curl`, `jq` and `tidy` to be installed. Otherwise it will throw a warning message. 
- This plugin has been developed on and for Linux following open source philosophy.

| Feature | nvim-spinetta | NOTE |
| ------- | ------------- | ---- |
| REST | :heavy_check_mark: | Supports all http methods (GET, POST, etc) |
| GraphQL | :heavy_check_mark: | GraphQL queries on body |
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
| Show Headers | :heavy_check_mark: | Set by `setup`. (none, only response or all) |
| Authorization | :heavy_check_mark: | API Key Auth, Basic Auth, Bearer Token, OAuth 2.0 |
| URL queries | :heavy_check_mark: |  |
| Path parameters | :heavy_check_mark: |  |
| Environment variables | :heavy_check_mark: | With a special way to update variables |
| Output files | :heavy_check_mark: | Dismiss or save them. Output folder set by `setup` |
| Integration with Telescope | :x: |  |
| Command to create cafe file | :heavy_check_mark: | executing `CAFECreate` |
| Command to create env archetype | :heavy_check_mark: | executing `CAFECreateEnv` |

 ## Installation
`Vim Plug`
```vim
Plug 'charkuils/nvim-cafe'
```
`Packer`
```lua
use 'charkuils/nvim-cafe'
```

## Usage
- Set mappings in *init.vim* or *init.lua*
```lua
print('something')
```

## Configuration
```lua
print('configuration')
```

## Screenshots
### Something

<img src="" alt="something" style="width:600px;"/>

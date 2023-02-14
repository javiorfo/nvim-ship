-- #######################################################
-- # Maintainer:  Mr. Charkuils                          #
-- # URL:         https://github.com/charkuils/nvim-ship #
-- #######################################################

return {
    sync = function()
        vim.cmd("syn keyword shipSection BASE")
        vim.cmd("syn keyword shipSection HEADERS")
        vim.cmd("syn keyword shipSection BODY")
        vim.cmd("syn keyword shipBoolean true false null")
        vim.cmd("syn keyword shipMethod GET POST PUT DELETE PATCH")
        vim.cmd("syn keyword shipMethod CONNECT OPTIONS TRACE HEAD")
        vim.cmd("syn keyword shipInfo STATUS TIME")
        vim.cmd("syn keyword shipError ERROR")

        vim.cmd[[syn match shipComment  '#.*$']]
        vim.cmd[[syn match shipBrackets '[{}]']]

        vim.cmd[[syn region shipEnvVar start="{{" end="}}"]]
        vim.cmd[[syn region shipSection oneline start=/^\s*\~\[/ end=/\]\~/ contains=shipBase,shipHeaders,shipBody]]
        vim.cmd[[syn region shipString start=+"+ end=+"+ contains=shipEnvVar]]
        vim.cmd[[syn region shipVariable start="^\w" end="\s"]]
        vim.cmd[[syn region shipHtmlTag	  start=+<[^/]+ end=+>+]]
        vim.cmd[[syn region shipHtmlEndTag start=+</+	end=+>+]]

        vim.cmd[[syn match shipJson	     /"\([^"]\|\\\"\)\+"[[:blank:]\r\n]*\:/]]
    end,
    hi = function(links)
        vim.cmd('hi link shipVariable ' .. links.ship_variable)
        vim.cmd('hi link shipEnvVar ' .. links.ship_env_var)
        vim.cmd('hi link shipBoolean ' .. links.ship_boolean_null)
        vim.cmd('hi link shipSection ' .. links.ship_section)
        vim.cmd('hi link shipMethod ' .. links.ship_method)
        vim.cmd('hi link shipString ' .. links.ship_string)
        vim.cmd('hi link shipComment ' .. links.ship_comment)
        vim.cmd('hi link shipJson ' .. links.ship_json)
        vim.cmd('hi link shipInfo ' .. links.ship_info)
        vim.cmd('hi link shipHtmlTag ' .. links.ship_xml_tag)
        vim.cmd('hi link shipHtmlEndTag ' .. links.ship_xml_tag)
        vim.cmd('hi link shipBrackets shipSection')
        vim.cmd('hi link shipError Error')
    end
}

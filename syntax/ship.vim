if exists('b:current_syntax')
    finish
endif

let b:current_syntax = 'ship'

syn keyword shipSection BASE
syn keyword shipSection HEADERS
syn keyword shipSection BODY
syn keyword shipBoolean true false null
syn keyword shipMethod  GET POST PUT DELETE PATCH
syn keyword shipMethod  CONNECT OPTIONS TRACE HEAD
syn keyword shipError   ERROR

syn match shipComment  '#.*$'
syn match shipBrackets '[{}]'

syn region shipEnvVar     start="{{" end="}}"
syn region shipSection    oneline start=/^\s*\~\[/ end=/\]\~/ contains=shipBase,shipHeaders,shipBody
syn region shipString     start=+"+ end=+"+ contains=shipEnvVar
syn region shipVariable   start="^\w" end="\s"
syn region shipHtmlTag	  start=+<[^/]+ end=+>+
syn region shipHtmlEndTag start=+</+	end=+>+

syn match shipJson	     /"\([^"]\|\\\"\)\+"[[:blank:]\r\n]*\:/

hi link shipComment    Comment
hi link shipBoolean    Boolean
hi link shipBrackets   shipBoolean
hi link shipSection    shipBoolean
hi link shipBase       shipSection
hi link shipHeaders    shipSection
hi link shipBody       shipSection
hi link shipString     String
hi link shipMethod     Type
hi link shipJson       shipMethod
hi link shipVariable   Define
hi link shipEnvVar     Tag
hi link shipHtmlTag    shipMethod
hi link shipHtmlEndTag shipMethod
hi link shipError      Error

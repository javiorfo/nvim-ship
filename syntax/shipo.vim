" #####################################################
" # Maintainer: Javier Orfo                           #
" # URL:        https://github.com/javiorfo/nvim-ship #
" #####################################################

if exists('b:current_syntax')
    finish
endif

let b:current_syntax = 'shipo'
    
syn keyword shipBoolean true false null
syn keyword shipMethod  GET POST PUT DELETE PATCH
syn keyword shipMethod  CONNECT OPTIONS TRACE HEAD
syn keyword shipError   ERROR

syn match shipBrackets '[{}]'

syn region shipString     start=+"+ end=+"+ contains=shipEnvVar
syn region shipVariable   start="^\w" end="\s"
syn region shipHtmlTag	  start=+<[^/]+ end=+>+
syn region shipHtmlEndTag start=+</+	end=+>+

syn match shipJson	     /"\([^"]\|\\\"\)\+"[[:blank:]\r\n]*\:/

hi link shipBoolean    Boolean
hi link shipBrackets   shipBoolean
hi link shipBody       shipSection
hi link shipString     String
hi link shipMethod     Type
hi link shipJson       shipMethod
hi link shipVariable   Define
hi link shipHtmlTag    shipMethod
hi link shipHtmlEndTag shipMethod
hi link shipError      Error

" {{{ Regexes to clarify current case
" \C - case sensitive
" \v  -  magic mode (no need for \)
let s:dash = '\v^[a-z0-9]+(-+[a-z0-9]+)+$' " '^[a-z0-9]+(-+[a-z0-9]+)+$'  dash-case
let s:camel = '\v\C^[a-z][a-z0-9]*([A-Z][a-z0-9]*)*$'     " camelCase
let s:snake = '\v\C^[a-z0-9]+(_+[a-z0-9]+)*$'           "snake_case
let s:upper = '\v\C^[A-Z][A-Z0-9]*(_[A-Z0-9]+)*$'       "UPPER_CASE
let s:pascal = '\v\C^[A-Z][a-z0-9]*([A-Z0-9][a-z0-9]*)*$'   "PascalCase
let s:title = '\v\C^[A-Z][a-z0-9]*( [A-Z][a-z0-9]+)*$'     "Title Case
let s:any = '\v\C^[a-zA-Z][a-zA-Z0-9]*(( |_|-)[a-zA-Z][a-zA-Z0-9]+)*$'     "aNy_casE  Any-case etc.
" }}}

" {{{ Helpers
function! s:DashToCamel(str) abort
    return substitute(a:str, '\v-+([a-z])', '\U\1', 'g')          "camelCase
endfunction

function! s:CamelToPascal(str) abort
    return substitute(a:str, '^.*$', '\u\0', 'g')                 "PascalCase
endfunction

function! s:PascalToUpper(str) abort
    return toupper(substitute(a:str, '\C^\@<![A-Z]', '_\0', 'g'))          "UPPER_CASE
endfunction

function! s:UpperToTitle(str) abort
    let l:tit_under = substitute(a:str, '\v([A-Z])([A-Z]*)','\1\L\2','g')
    return substitute(l:tit_under,'_',' ','g')                        " Title Case
endfunction

function! s:TitleToSnake(str) abort
    return tolower(substitute(a:str, ' ', '_', 'g'))               " snake_case
endfunction

function! s:SnakeToDash(str) abort
    return substitute(a:str, '_\+', '-', 'g')                      "dash-case
endfunction
" }}}

function! s:StartSession() abort
    echom 's:StartSession()'
    if (!s:sessionStarted)
        augroup au_casechange
            autocmd!
            autocmd CursorMoved * call s:EndSession()
        augroup END
    endif
    let s:sessionStarted += 1
endfunction

function! s:EndSession() abort
    echom 's:EndSession()'
    let s:sessionStarted -= 1
    if (!s:sessionStarted)
        normal 
        augroup au_casechange
            autocmd!
        augroup END
    endif
endfunction

function! casechange#next(str)
    if (a:str =~ s:dash)
        return s:DashToCamel(a:str)
    elseif (a:str =~ s:camel)
        return s:CamelToPascal(a:str)
    elseif (a:str =~ s:pascal)
        return s:PascalToUpper(a:str)
    elseif (a:str =~ s:upper)
        return s:UpperToTitle(a:str)
    elseif (a:str =~ s:title)
        return s:TitleToSnake(a:str)
    elseif (a:str =~ s:snake)   "snake
        return s:SnakeToDash(a:str)
    endif
endfunction

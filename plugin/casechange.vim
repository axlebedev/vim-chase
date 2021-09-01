" casechange.vim - Lets role the cases
" Maintainer:   Ignacio Catalina
" Version:      1.0
"
" Installation:
" Place in either ~/.vim/plugin/casechange.vim (to load at start up) or
" ~/.vim/autoload/casechange.vim (to load automatically as needed).
"
" License:
" Copyright (c) Ignacio Catalina.  Distributed under the same terms as Vim itself.
" See :help license
"

if exists("g:loaded_casechange") || &cp || v:version < 700
    finish
endif
let g:loaded_casechange = 1

" \C - case sensitive
" \v  -  magic mode (no need for \)
let s:dash = '\v^[a-z0-9]+(-+[a-z0-9]+)+$' " '^[a-z0-9]+(-+[a-z0-9]+)+$'  dash-case
let s:camel = '\v\C^[a-z][a-z0-9]*([A-Z][a-z0-9]*)*$'     " camelCase
let s:snake = '\v\C^[a-z0-9]+(_+[a-z0-9]+)*$'           "snake_case
let s:upper = '\v\C^[A-Z][A-Z0-9]*(_[A-Z0-9]+)*$'       "UPPER_CASE
let s:pascal = '\v\C^[A-Z][a-z0-9]*([A-Z0-9][a-z0-9]*)*$'   "PascalCase
let s:title = '\v\C^[A-Z][a-z0-9]*( [A-Z][a-z0-9]+)*$'     "Title Case
let s:any = '\v\C^[a-zA-Z][a-zA-Z0-9]*(( |_|-)[a-zA-Z][a-zA-Z0-9]+)*$'     "aNy_casE  Any-case etc.

function! casechange#next(str)
    if (a:str =~ s:dash)
        return substitute(a:str, '\v-+([a-z])', '\U\1', 'g')          "camelCase
    elseif (a:str =~ s:camel)
        return substitute(a:str, '^.*$', '\u\0', 'g')                 "PascalCase
    elseif (a:str =~ s:upper)
        let l:tit_under = substitute(a:str, '\v([A-Z])([A-Z]*)','\1\L\2','g')
        return substitute(l:tit_under,'_',' ','g')                        " Title Case
    elseif (a:str =~ s:pascal)
        return toupper(substitute(a:str, '\C^\@<![A-Z]', '_\0', 'g'))          "UPPER_CASE
    elseif (a:str =~ s:title)
        return tolower(substitute(a:str, ' ', '_', 'g'))               " snake_case
    elseif (a:str =~ s:snake)   "snake
        return substitute(a:str, '_\+', '-', 'g')                      "dash-case
    else  " (a:str =~ s:any)   - wurst case scenario
        return tolower(substitute(a:str, '\v( |_|-)([a-z])', '_\U\2', 'g'))          "snake_case
    endif
endfunction

if !exists("g:casechange_nomap")
    vnoremap ~ "zc<C-R>=casechange#next(@z)<CR><Esc>v`[
endif

" vim:set ft=vim et sw=4 sts=4:

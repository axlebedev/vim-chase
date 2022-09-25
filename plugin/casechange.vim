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


let g:sentenceCasesOrder = get(g:, 'caseChangeSentenceCasesOrder', [
  \ 'dash',
  \ 'snake',
  \ 'camel',
  \ 'pascal',
  \ 'upper',
  \ 'title',
  \ ])

let g:wordCasesOrder = get(g:, 'caseChangeWordCasesOrder', [
  \ 'wordUpper',
  \ 'wordLower',
  \ 'wordTitle',
  \ ])

let g:letterCasesOrder = get(g:, 'caseChangeLetterCasesOrder', [
  \ 'letterUpper',
  \ 'letterLower',
  \ ])

if !exists("g:casechange_nomap")
    nnoremap ~ <CMD>call casechange#next()<CR>
    vnoremap ~ <CMD>call casechange#next()<CR>
    vnoremap ! <CMD>call casechange#prev()<CR>
endif

" vim:set ft=vim et sw=4 sts=4:

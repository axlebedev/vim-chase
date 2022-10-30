vim9script

import autoload '../autoload/chase.vim'


if exists("g:loaded_chase") || &cp || v:version < 900
    finish
endif
g:loaded_chase = 1


g:sentenceCasesOrder = get(g:, 'chaseSentenceCasesOrder', [
    'dash',
    'snake',
    'camel',
    'camel_abbr',
    'pascal',
    'upper',
    'upper_space',
    'title',
])

g:wordCasesOrder = get(g:, 'chaseWordCasesOrder', [
    'upper',
    'lower',
    'title',
])

g:letterCasesOrder = get(g:, 'chaseletterCasesOrder', [
    'upper',
    'lower',
])

g:highlightTimeout = get(g:, 'chaseHighlightTimeout', 2000)

if !get(g:, 'chase_nomap', 0)
    nnoremap ~ <CMD>call <SID>chase.Next()<CR>
    vnoremap ~ <CMD>call <SID>chase.Next()<CR>
    vnoremap ! <CMD>call <SID>chase.Prev()<CR>
endif

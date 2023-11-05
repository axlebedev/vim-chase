if !has("vim9script") || v:version < 900
    echoerr "VimChase: need support vim9script!"
    finish
endif

vim9script

if exists("g:loaded_chase")
    finish
endif
g:loaded_chase = 1


import autoload '../autoload/chase.vim'

if !exists("g:chaseRespectAbbreviation")
    g:chaseRespectAbbreviation = 1
endif

g:sentenceCasesOrder = get(g:, 'chaseSentenceCasesOrder', [
    # 'camel',
    'camel_abbr',
    'pascal',
    'lower_space',
    'lower_dash',
    'lower_underscore',
    'upper_underscore',
    'upper_dash',
    'upper_space',
    'title',
    'password',
])

g:wordCasesOrder = get(g:, 'chaseWordCasesOrder', [
    'upper',
    'lower',
    'password',
    'title',
])

g:letterCasesOrder = get(g:, 'chaseLetterCasesOrder', [
    'upper',
    'lower',
    'password',
])

g:highlightTimeout = get(g:, 'chaseHighlightTimeout', 2000)

if !get(g:, 'chaseNomap', 0)
    nnoremap ~ <CMD>call <SID>chase.Next()<CR>
    vnoremap ~ <CMD>call <SID>chase.Next()<CR>
    nnoremap ! <CMD>call <SID>chase.Prev()<CR>
    vnoremap ! <CMD>call <SID>chase.Prev()<CR>
endif

command -bar ChaseNext call <SID>chase.Next()
command -bar ChasePrev call <SID>chase.Prev()
command -bar ChasePrintAllCases call <SID>chase.PrintAllCases()

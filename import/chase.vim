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

g:chaseRespectAbbreviation = get(g:, 'chaseRespectAbbreviation', 1)
g:highlightTimeout = get(g:, 'chaseHighlightTimeout', 2000)

g:chaseSentenceCasesOrder = get(g:, 'chaseSentenceCasesOrder', [
    'camel',
    'pascal',
    'lower_space',
    'lower_dash',
    'lower_underscore',
    'upper_underscore',
    'upper_dash',
    'upper_space',
    'title',
])

g:chaseWordCasesOrder = get(g:, 'chaseWordCasesOrder', [
    'upper',
    'lower',
    'title',
])

g:chaseLetterCasesOrder = get(g:, 'chaseLetterCasesOrder', [
    'upper',
    'lower',
])

if !get(g:, 'chaseNomap', 0)
    nnoremap ~ <CMD>call <SID>chase.Next()<CR>
    vnoremap ~ <CMD>call <SID>chase.Next()<CR>
    nnoremap ! <CMD>call <SID>chase.Prev()<CR>
    vnoremap ! <CMD>call <SID>chase.Prev()<CR>
endif

export def ChaseNext(options: dict<any> = {})
    chase.Next(options)
enddef

export def ChasePrev(options: dict<any> = {})
    chase.Prev(options)
enddef

command -bar ChaseNext call <SID>chase.Next()
command -bar ChasePrev call <SID>chase.Prev()


export def PrintAllCases(): void
    chase.PrintAllCases()
enddef
command -bar ChasePrintAllCases call <SID>chase.PrintAllCases()

vim9script

if !has("vim9script") || v:version < 900
    echoerr "VimChase: need support vim9script!"
    finish
endif

if exists("g:loaded_chase")
    finish
endif
g:loaded_chase = 1

import autoload '../autoload/chase.vim'

g:chaseRespectAbbreviation = get(g:, 'chaseRespectAbbreviation', true)
g:chaseHighlightTimeout = get(g:, 'chaseHighlightTimeout', 2000)

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


if !get(g:, 'chaseMapDefault', true)
    nnoremap ~ <ScriptCmd>chase.Next()<cr>
    vnoremap ~ <ScriptCmd>chase.Next()<cr>
    nnoremap ! <ScriptCmd>chase.Prev()<cr>
    vnoremap ! <ScriptCmd>chase.Prev()<cr>
endif

export def Next(options: dict<any> = {})
    chase.Next(options)
enddef

export def Prev(options: dict<any> = {})
    chase.Prev(options)
enddef

command -bar ChaseNext call <SID>chase.Next()
command -bar ChasePrev call <SID>chase.Prev()


export def PrintAllCases(): void
    chase.PrintAllCases()
enddef
command -bar ChasePrintAllCases call <SID>chase.PrintAllCases()

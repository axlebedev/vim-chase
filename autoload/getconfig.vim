vim9script

export def GetConfig(name: string): any
    if (exists('b:' .. name))
        return get(b:, name)
    endif

    # Assume that all configs are set at plugin/chase.vim
    return get(g:, name)
enddef

export def ParseOptions(options: dict<any> = {}): void
    g:chaseSavedOptions = {
        chaseRespectAbbreviation: get(g:, 'chaseRespectAbbreviation'),
        chaseSentenceCasesOrder: get(g:, 'chaseSentenceCasesOrder'),
        chaseWordCasesOrder: get(g:, 'chaseWordCasesOrder'),
        chaseLetterCasesOrder: get(g:, 'chaseLetterCasesOrder'),
    }
    g:chaseRespectAbbreviation = has_key(options, 'chaseRespectAbbreviation') ? get(options, 'chaseRespectAbbreviation') : get(g:, 'chaseRespectAbbreviation')
    g:chaseSentenceCasesOrder = has_key(options, 'chaseSentenceCasesOrder') ? get(options, 'chaseSentenceCasesOrder') : get(g:, 'chaseSentenceCasesOrder')
    g:chaseWordCasesOrder = has_key(options, 'chaseWordCasesOrder') ? get(options, 'chaseWordCasesOrder') : get(g:, 'chaseWordCasesOrder')
    g:chaseLetterCasesOrder = has_key(options, 'chaseLetterCasesOrder') ? get(options, 'chaseLetterCasesOrder') : get(g:, 'chaseLetterCasesOrder')
enddef

export def RestoreOptions(): void
    g:chaseRespectAbbreviation = g:chaseSavedOptions.chaseRespectAbbreviation
    g:chaseSentenceCasesOrder = g:chaseSavedOptions.chaseSentenceCasesOrder
    g:chaseWordCasesOrder = g:chaseSavedOptions.chaseWordCasesOrder
    g:chaseLetterCasesOrder = g:chaseSavedOptions.chaseLetterCasesOrder
    unlet g:chaseSavedOptions
enddef


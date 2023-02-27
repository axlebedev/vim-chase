vim9script

# NOTE
# How to add regex:
# 1. (In folder 'autoload/regex/case') Copypaste any file
# 2. (In new file) Main work: change values in that file: 
#     - regex
#     - array of names of this case (Warning: it should not repeat any of existing one)
#     - function 'StringToParts': how incoming string should be divided into parts 
#       example for camelCase: 'oneTWOThree' => ['one','TWO','three']
#       every word should be in lowercase, abbriveation - in upper case
#     - function 'PartsToString': how incoming array of words should be squashed into one
# 3. (In 'autoload/regex/regex') import new file
# 4. (In 'autoload/regex/regex') Add new case to 'casesArray'
# 5. (In vimrc) Add new case to corresponding casesOrder (g:sentenceCasesOrder, g:wordCasesOrder or g:letterCasesOrder)

import '../getconfig.vim' 
import '../sessionstore.vim'
import '../highlightdiff.vim'

import './case/camel.vim'
import './case/camel_abbr.vim'
import './case/lower.vim'
import './case/lower_dash.vim'
import './case/lower_underscore.vim'
import './case/pascal.vim'
import './case/title.vim'
import './case/undefined.vim' as undefinedCase
import './case/upper.vim'
import './case/upper_space.vim'
import './case/upper_underscore.vim'
import './case/password.vim'

var groups = {
    undefined: 'group-undefined',
    letter: 'group-letter',
    word: 'group-word',
    sentence: 'group-sentence',
}

# =============================================================================

# regex has its own store for session
var regexSessionStore = {
    parts: [],
    group: groups.undefined,
    case: undefinedCase.undefinedCase,
    count: 0,
    precomputedWords: [],
}

# This one will be called on end of session, from SessionController
export def OnRegexSessionEnd(): void
    regexSessionStore.parts = []
    regexSessionStore.group = groups.undefined
    regexSessionStore.case = undefinedCase.undefinedCase
    regexSessionStore.count = 0
    regexSessionStore.precomputedWords = []
enddef

# =============================================================================

var casesArray = [
    lower.lower,
    upper.upper,
    title.title,
    camel.camel,
    camel_abbr.camel_abbr,
    lower_dash.lower_dash,
    lower_underscore.lower_underscore,
    pascal.pascal,
    upper_underscore.upper_underscore,
    upper_space.upper_space,
    password.password,
    undefinedCase.undefinedCase,
]

# =============================================================================

def FindCaseByName(name: string): dict<any> # TODO: return type
    var i = 0
    while (i < casesArray->len())
        if (casesArray[i].name->index(name) > -1)
            return casesArray[i]
        endif
        i += 1
    endwhile
    return undefinedCase.undefinedCase
enddef

def GetCasesOrderByGroup(group: string): list<string>
    if (group == groups.letter)
        return getconfig.GetConfig('letterCasesOrder')
    elseif (group == groups.word)
        return getconfig.GetConfig('wordCasesOrder')
    endif
    return getconfig.GetConfig('sentenceCasesOrder')
enddef

# =============================================================================

def GetWordGroup(word: string): string
    if (word !~? '\v[[:lower:][:upper:]]')
        return groups.undefined
    elseif (word->len() < 2)
        return groups.letter
    elseif (
        word =~# '\v\C^[[:upper:][:digit:]]+$' 
        || word =~# '\v\C^[[:lower:][:digit:]]+$'
        || word =~# '\v\C^[[:upper:]][[:lower:][:digit:]]+$'
    )
        # if only upper or digits or only lower and digits - this is single word
        return groups.word
    endif

    return groups.sentence 
enddef

def GetWordCase(word: string, group: string): dict<any>
    var cases = []
    for name in GetCasesOrderByGroup(group)
        cases->add(FindCaseByName(name))
    endfor

    var i = 0
    while (i < cases->len())
        if (word =~# cases[i].regex)
            return cases[i]
        endif
        i += 1
    endwhile

    return undefinedCase.undefinedCase
enddef

def GetPrecomputedWords(oldWord: string, oldGroup: string, oldCase: dict<any>): list<string>
    if (oldGroup == groups.undefined)
        return []
    endif
    var parts = oldCase.StringToParts(oldWord)
    var caseNames = GetCasesOrderByGroup(oldGroup)
    var precomputedWords = caseNames->copy()->map((i, caseName) => {
        var case = FindCaseByName(caseName)
        return case.PartsToString(parts->copy())
    })
    return precomputedWords
enddef

export def GetNextWord(oldWord: string, isPrev: bool): string
    if (regexSessionStore.count == 0)
        regexSessionStore.group = GetWordGroup(oldWord)
        regexSessionStore.case = GetWordCase(oldWord, regexSessionStore.group)
        regexSessionStore.parts = regexSessionStore.case.StringToParts(oldWord)
        regexSessionStore.precomputedWords = GetPrecomputedWords(oldWord, regexSessionStore.group, regexSessionStore.case)
    endif
    if (regexSessionStore.group == groups.undefined)
        return oldWord
    endif
    
    regexSessionStore.count += isPrev ? -1 : 1

    var words = regexSessionStore.precomputedWords
    var newWord = words[
        (words->index(oldWord) + regexSessionStore.count) % words->len()
    ]

    return newWord
enddef

var popupWinId = 0
export def ShowPopup(curWord: string): void
    popup_close(popupWinId)

    var popupHeight = regexSessionStore.precomputedWords->len()
    var curLine = winline()
    var curCol = getcursorcharpos()[2]
    var winHeight = winheight(winnr())
    popupWinId = popup_atcursor(regexSessionStore.precomputedWords, {
        pos: (winHeight - curLine >= popupHeight ? 'topleft' : 'botleft'),
        col: screenpos(win_getid(winnr()), line('.'), sessionstore.lineBegin->len()).col + 1,
        zindex: 1000,
        wrap: false,
        highlight: 'ChaseWord',
        moved: [0, 0, 0],
    })
    var indexInWords = (
            regexSessionStore.precomputedWords->index(sessionstore.initialWord) 
            + regexSessionStore.count
        ) % regexSessionStore.precomputedWords->len()
    if (!hlexists('ChaseChangedletter'))
        highlightdiff.DeclareHighlightGroups()
    endif
    matchadd(
        'ChaseChangedletter',
        '\%' .. (indexInWords + 1) .. 'l',
        1000,
        1991, # random number here
        {window: popupWinId}
    )
enddef

export def HidePopup(): void
    popup_close(popupWinId)
enddef

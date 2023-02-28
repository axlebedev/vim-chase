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
    if (group == sessionstore.groups.letter)
        return getconfig.GetConfig('letterCasesOrder')
    elseif (group == sessionstore.groups.word)
        return getconfig.GetConfig('wordCasesOrder')
    endif
    return getconfig.GetConfig('sentenceCasesOrder')
enddef

# =============================================================================

def GetWordGroup(word: string): string
    if (word !~? '\v[[:lower:][:upper:]]')
        return sessionstore.groups.undefined
    elseif (word->len() < 2)
        return sessionstore.groups.letter
    elseif (
        word =~# '\v\C^[[:upper:][:digit:]]+$' 
        || word =~# '\v\C^[[:lower:][:digit:]]+$'
        || word =~# '\v\C^[[:upper:]][[:lower:][:digit:]]+$'
    )
        # if only upper or digits or only lower and digits - this is single word
        return sessionstore.groups.word
    endif

    return sessionstore.groups.sentence 
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
    if (oldGroup == sessionstore.groups.undefined)
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
    if (sessionstore.count == 0)
        sessionstore.group = GetWordGroup(oldWord)
        sessionstore.case = GetWordCase(oldWord, sessionstore.group)
        sessionstore.parts = sessionstore.case.StringToParts(oldWord)
        sessionstore.precomputedWords = GetPrecomputedWords(oldWord, sessionstore.group, sessionstore.case)
    endif
    if (sessionstore.group == sessionstore.groups.undefined)
        return oldWord
    endif
    
    sessionstore.count = sessionstore.count + (isPrev ? -1 : 1)

    var words = sessionstore.precomputedWords
    var newWord = words[
        (words->index(oldWord) + sessionstore.count) % words->len()
    ]

    return newWord
enddef

var popupWinId = 0
export def ShowPopup(curWord: string): void
    popup_close(popupWinId)

    # For correct highlight, with paddings
    var precomputedWordsToShow = sessionstore.precomputedWords
        ->copy()
        ->map((i, word) => ' ' .. word .. ' ') # add paddings, for beautiful popup 

    var maxPrecomputedLen = precomputedWordsToShow->copy()->map((index, word) => word->len())->max() 
    precomputedWordsToShow = precomputedWordsToShow->map((i, word) => {
                var paddedWord = word
                while (maxPrecomputedLen > paddedWord->len())
                    paddedWord = paddedWord .. ' '
                endwhile
                return paddedWord
            }) # add padding-right of spaces, for hightlight

    var popupHeight = sessionstore.precomputedWords->len()
    popupWinId = popup_atcursor(
        precomputedWordsToShow,
        {
            pos: (winheight(winnr()) - winline() >= popupHeight ? 'topleft' : 'botleft'),
            col: screenpos(win_getid(winnr()), line('.'), sessionstore.lineBegin->len()).col,
            zindex: 1000,
            wrap: false,
            highlight: 'ChaseWord',
            moved: [0, 0, 0],
        }
    )
    var indexInWords = (
            sessionstore.precomputedWords->index(sessionstore.initialWord) 
            + sessionstore.count
        ) % sessionstore.precomputedWords->len()
    if (!hlexists('ChaseChangedletter'))
        highlightdiff.DeclareHighlightGroups()
    endif
    matchaddpos(
        'ChaseChangedletter',
        [indexInWords + 1],
        1000,
        1991, # random number here
        {window: popupWinId}
    )
enddef

export def HidePopup(): void
    popup_close(popupWinId)
enddef

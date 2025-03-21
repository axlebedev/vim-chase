vim9script

# NOTE
# How to add regex:
# 1. (In folder 'autoload/regex/case') Copypaste any file
# 2. (In new file) Main work: change values in that file: 
#     - regex
#     - name of case
#     - function 'StringToParts': how incoming string should be divided into parts 
#       example for camelCase: 'oneTWOThree' => ['one','TWO','three']
#       every word should be in lowercase, abbriveation - in upper case
#     - function 'PartsToString': how incoming array of words should be squashed into one
# 3. (In 'autoload/regex/regex') import new file
# 4. (In 'autoload/regex/regex') Add new case to 'casesArray'
# 5. (In vimrc) Add new case to corresponding casesOrder (g:chaseSentenceCasesOrder, g:chaseWordCasesOrder or g:chaseLetterCasesOrder)

import '../getconfig.vim' 
import '../sessionstore.vim'
import '../highlightdiff.vim'

import './case/camel.vim'
import './case/lower.vim'
import './case/lower_dash.vim'
import './case/lower_space.vim'
import './case/lower_underscore.vim'
import './case/pascal.vim'
import './case/title.vim'
import './case/sentence.vim'
import './case/undefined.vim' as undefinedCase
import './case/upper.vim'
import './case/upper_dash.vim'
import './case/upper_space.vim'
import './case/upper_underscore.vim'
import './case/password.vim'

# =============================================================================

var casesArray = [
    lower.lower,
    upper.upper,
    title.title,
    sentence.sentence,
    camel.camel,
    lower_dash.lower_dash,
    lower_space.lower_space,
    lower_underscore.lower_underscore,
    pascal.pascal,
    upper_dash.upper_dash,
    upper_underscore.upper_underscore,
    upper_space.upper_space,
    password.password,
    undefinedCase.undefinedCase,
]

# =============================================================================

def FindCaseByName(name: string): dict<any> # TODO: return type
    var i = 0
    while (i < casesArray->len())
        if (casesArray[i].name == name)
            return casesArray[i]
        endif
        i += 1
    endwhile
    return undefinedCase.undefinedCase
enddef

def GetCasesOrderByGroup(group: string, forGetWordCase: bool = false): list<string>
    # 'forGetWordCase': when we find initial word's case - we ignore users
    # settings and search all, for correct StringToParts, so use hardcoded arrays
    if (group == sessionstore.groups.letter)
        if (forGetWordCase)
            return [
                lower.lower.name,
                upper.upper.name,
                undefinedCase.undefinedCase.name,
            ]
        endif
        return getconfig.GetConfig('chaseLetterCasesOrder')
    elseif (group == sessionstore.groups.word)
        if (forGetWordCase)
            return [
                lower.lower.name,
                upper.upper.name,
                title.title.name,
                undefinedCase.undefinedCase.name,
            ]
        endif
        return getconfig.GetConfig('chaseWordCasesOrder')
    endif
    if (forGetWordCase)
        return [
            title.title.name,
            sentence.sentence.name,
            camel.camel.name,
            lower_dash.lower_dash.name,
            lower_space.lower_space.name,
            lower_underscore.lower_underscore.name,
            pascal.pascal.name,
            upper_dash.upper_dash.name,
            upper_underscore.upper_underscore.name,
            upper_space.upper_space.name,
            undefinedCase.undefinedCase.name,
        ]
    endif
    return getconfig.GetConfig('chaseSentenceCasesOrder')
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
    for name in GetCasesOrderByGroup(group, true)
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

export def PrintAllCases(): void
    var parts = ['you', 'are', 'the', 'best']
    for case in casesArray
        echom case.name .. ' --- ' .. case.PartsToString(parts->copy())
    endfor
enddef

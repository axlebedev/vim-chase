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
# 4. (In 'autoload/regex/regex') Add new case to 'casesArrays'
# 5. (In vimrc) Add new case to corresponding casesOrder (g:sentenceCasesOrder, g:wordCasesOrder or g:letterCasesOrder)

import '../getconfig.vim' 

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

var savedParts = []
var savedGroup = groups.undefined
var savedCase = undefinedCase.undefinedCase
var sessionCount = 0

# This one will be called on end of session, from SessionController
export def OnSessionEnd(): void
    savedParts = []
    savedGroup = groups.undefined
    savedCase = undefinedCase.undefinedCase
    sessionCount = 0
enddef

# =============================================================================

var casesArrays = {
    letter: [
        lower.lower,
        upper.upper
    ],
    word: [
        lower.lower,
        upper.upper,
        title.title
    ],
    sentence: [
        camel.camel,
        camel_abbr.camel_abbr,
        lower_dash.lower_dash,
        lower_underscore.lower_underscore,
        pascal.pascal,
        title.title,
        upper_underscore.upper_underscore,
        upper_space.upper_space,
        password.password,
    ],
    undefined: [undefinedCase.undefinedCase],
}

# =============================================================================

def FindCaseByName(name: string, group: string): dict<any> # TODO: return type
    if (group == groups.letter)
        var i = 0
        while (i < casesArrays.letter->len())
            if (casesArrays.letter[i].name->index(name) > -1)
                return casesArrays.letter[i]
            endif
            i += 1
        endwhile
    elseif (group == groups.word)
        var i = 0
        while (i < casesArrays.word->len())
            if (casesArrays.word[i].name->index(name) > -1)
                return casesArrays.word[i]
            endif
            i += 1
        endwhile
    elseif (group == groups.sentence)
        var i = 0
        while (i < casesArrays.sentence->len())
            if (casesArrays.sentence[i].name->index(name) > -1)
                return casesArrays.sentence[i]
            endif
            i += 1
        endwhile
    endif
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

def GetNextCase(group: string, oldCase: dict<any>, d: number): dict<any>
    var casesOrderArray = GetCasesOrderByGroup(group)

    var curindex = 0
    while (curindex < casesOrderArray->len())
        var oneOfNames = casesOrderArray[curindex]
        if (oldCase.name->index(oneOfNames) > -1)
            break
        endif
        curindex += 1
    endwhile
    var nextCaseIndex = (curindex + d) % casesOrderArray->len()

    var nextCaseName = casesOrderArray[nextCaseIndex]
    return FindCaseByName(nextCaseName, group)
enddef

# =============================================================================

def GetWordGroup(word: string): string
    if (word->len() < 2)
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
    var cases = [undefinedCase.undefinedCase]
    if (group == groups.letter)
        cases = casesArrays.letter
    elseif (group == groups.word)
        cases = casesArrays.word
    elseif (group == groups.sentence)
        cases = casesArrays.sentence
    endif

    var i = 0
    while (i < cases->len())
        if (word =~# cases[i].regex)
            return cases[i]
        endif
        i += 1
    endwhile

    return undefinedCase.undefinedCase
enddef

export def GetNextWord(oldWord: string, isPrev: bool): string
    if (sessionCount == 0)
        savedGroup = GetWordGroup(oldWord)
        savedCase = GetWordCase(oldWord, savedGroup)
        savedParts = savedCase.StringToParts(oldWord)
    endif
    
    sessionCount += isPrev ? -1 : 1
    var nextCase = GetNextCase(savedGroup, savedCase, sessionCount)
    var newWord = nextCase.PartsToString(savedParts->copy())
    return newWord
enddef

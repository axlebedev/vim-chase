vim9script

import '../func.vim'

var sentenceUpper = '\v\C^[[:upper:][:digit:]]+$'
var name = 'upper'

def StringToParts(word: string): list<string>
    return [word]->map(func.MapToLower)
enddef

def PartsToString(parts: list<string>): string
    return parts->map(func.MapToUpper)->join(' ')
enddef

export var upper = {
    name: name,
    regex: sentenceUpper,
    StringToParts: StringToParts,
    PartsToString: PartsToString,
}

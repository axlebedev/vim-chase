vim9script

import '../func.vim'

var sentenceUpper = '\v\C^[[:upper:]][[:upper:][:digit:]]*(-[[:upper:][:digit:]]+)+$'
var name = ['upper_dash']

def StringToParts(word: string): list<string>
    return [word]->map(func.MapToLower)
enddef

def PartsToString(parts: list<string>): string
    return parts->map(func.MapToUpper)->join('-')
enddef

export var upper_dash = {
    name: name,
    regex: sentenceUpper,
    StringToParts: StringToParts,
    PartsToString: PartsToString,
}

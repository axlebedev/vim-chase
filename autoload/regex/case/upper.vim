vim9script

import '../func.vim'

var sentenceUpper = '\v\C^[[:upper:][:digit:]]+$'
var name = ['upper']

def StringToParts(word: string): list<string>
    return [word]->map(funcref(func.MapToLower))
enddef

def PartsToString(parts: list<string>): string
    return parts->map(funcref(func.MapToUpper))->join('-')
enddef

export var upper = {
    name: name,
    regex: sentenceUpper,
    StringToParts: function('StringToParts'),
    PartsToString: function('PartsToString'),
}

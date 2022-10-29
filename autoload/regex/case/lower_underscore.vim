vim9script

import '../func.vim'

var sentenceSnake = '\v\C^[[:lower:]][[:lower:][:digit:]]*(_[[:lower:][:digit:]]*)+$'
var name = ['snake', 'lower_underscore']

def StringToParts(word: string): list<string>
    var parts = word
        \ ->substitute('\C[^[:digit:][:lower:][:upper:]]', '_', 'g')
        \ ->split('_')

    return parts->map(funcref(func.MapToLowerIfNotUpper))
enddef

def PartsToString(parts: list<string>): string
    return parts->map(funcref(func.MapToLower))->join('_')
enddef

export var lower_underscore = {
    name: name,
    regex: sentenceSnake,
    StringToParts: StringToParts,
    PartsToString: PartsToString,
}

vim9script

import '../func.vim'

var sentenceSnake = '\v\C^[[:lower:]][[:lower:][:digit:]]*(_[[:lower:][:digit:]]*)+$'
var name = ['snake', 'lower_underscore']

def StringToParts(word: string): list<string>
    var parts = word
        ->substitute('\C[^[:digit:][:lower:][:upper:]]', '_', 'g')
        ->split('_')

    return parts->map(func.MapToLowerIfNotUpper)
enddef

def PartsToString(parts: list<string>): string
    var result = parts->map(func.MapToLower)->join('_')
    return result
enddef

export var lower_underscore = {
    name: name,
    regex: sentenceSnake,
    StringToParts: StringToParts,
    PartsToString: PartsToString,
}

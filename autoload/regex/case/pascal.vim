vim9script

import '../func.vim'

var sentencePascal = '\v\C^[[:upper:]]+[[:lower:][:digit:]]*([[:upper:]]+[[:lower:][:digit:]]*)*$'
var name = 'pascal'

def StringToParts(word: string): list<string>
    var parts = word
        ->substitute('\C\v([[:lower:]])([[:upper:]])', '\1-\2', 'g')
        ->substitute('\C\v([[:upper:]])([[:upper:]][[:lower:]])', '\1-\2', 'g')
        ->split('-')

    return parts->map(func.MapToLowerIfNotUpper)
enddef

def PartsToString(parts: list<string>): string
    var MapToCapitalFunc = get(g:, 'chaseRespectAbbreviation') ? func.MapToCapitalIfNotUpper : func.MapToCapital
    return parts->map(MapToCapitalFunc)->join('')
enddef

export var pascal = {
    name: name,
    regex: sentencePascal,
    StringToParts: StringToParts,
    PartsToString: PartsToString,
}

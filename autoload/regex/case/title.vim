vim9script

import '../func.vim'

var sentenceTitle = '\v\C^[[:upper:]][[:lower:][:digit:]]*( [[:upper:]][[:lower:][:digit:]]+)*$'
var name = 'title'

def StringToParts(word: string): list<string>
    var parts = word
        ->substitute('\C[^[:digit:][:lower:][:upper:]]', '-', 'g')
        ->split('-')

    return parts->map(func.MapToLowerIfNotUpper)
enddef

def PartsToString(parts: list<string>): string
    var MapToCapitalFunc = get(g:, 'chaseRespectAbbreviation') ? func.MapToCapitalIfNotUpper : func.MapToCapital
    return parts->map(MapToCapitalFunc)->join(' ')
enddef

export var title = {
    name: name,
    regex: sentenceTitle,
    StringToParts: StringToParts,
    PartsToString: PartsToString,
}

vim9script

import '../func.vim'

var sentenceSentence = '\v\C^[[:upper:]][[:lower:][:digit:]]*( [[:upper:]][[:lower:][:digit:]]+)*$'
var name = 'sentence'

def StringToParts(word: string): list<string>
    var parts = word
        ->substitute('\C[^[:digit:][:lower:][:upper:]]', '-', 'g')
        ->split('-')

    return parts->map(func.MapToLowerIfNotUpper)
enddef

def PartsToString(parts: list<string>): string
    var MapToCapitalFunc = get(g:, 'chaseRespectAbbreviation') ? func.MapToCapitalIfNotUpper : func.MapToCapital
    return parts->map((i, val) => !i ? MapToCapitalFunc(i, val) : func.MapToLower(i, val))->join(' ')
enddef

export var sentence = {
    name: name,
    regex: sentenceSentence,
    StringToParts: StringToParts,
    PartsToString: PartsToString,
}

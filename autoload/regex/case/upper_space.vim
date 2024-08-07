vim9script

import '../func.vim'

var sentenceUpper = '\v\C^[[:upper:]][[:upper:][:digit:]]*( +[[:upper:][:digit:]]+)+$'
var name = 'upper_space'

def StringToParts(word: string): list<string>
    var parts = word
        ->substitute('\C[^[:digit:][:lower:][:upper:]]', ' ', 'g')
        ->split(' ')

    return parts->map(func.MapToLower)
enddef

def PartsToString(parts: list<string>): string
    return parts->map(func.MapToUpper)->join(' ')
enddef

export var upper_space = {
    name: name,
    regex: sentenceUpper,
    StringToParts: StringToParts,
    PartsToString: PartsToString,
}

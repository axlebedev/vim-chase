vim9script

import '../func.vim'

var sentenceDash = '\v\C^[[:lower:][:digit:]]+(-+[[:lower:][:digit:]]+)+$'
var name = ['dash', 'kebab', 'hyphen', 'lower_dash', 'lower_hyphen']

def StringToParts(word: string): list<string>
    var parts = word
        ->substitute('\C[^[:digit:][:lower:][:upper:]]', '-', 'g')
        ->split('-')

    return parts->map(func.MapToLowerIfNotUpper)
enddef

def PartsToString(parts: list<string>): string
    return parts->map(func.MapToLower)->join('-')
enddef

export var lower_dash = {
    name: name,
    regex: sentenceDash,
    StringToParts: StringToParts,
    PartsToString: PartsToString,
}

vim9script

import '../func.vim'

var sentenceCamel = '\v\C^[[:lower:]][[:lower:][:digit:]]*([[:upper:]][[:lower:][:digit:]]+)+$'
var name = ['camel']

def StringToParts(word: string): list<string>
    var parts = word
                \ ->substitute('\C\v([[:lower:]])([[:upper:]])', '\1-\2', 'g')
                \ ->substitute('\C\v([[:upper:]])([[:upper:]][[:lower:]])', '\1-\2', 'g')
                \ ->split('-')

    return parts->map(funcref(func.MapToLowerIfNotUpper))
enddef

def PartsToString(parts: list<string>): string
    return (parts[0 : 0]->map(funcref(func.MapToLower)) + parts[1 :]->map(funcref(func.MapToCapital)))->join('')
enddef

export var camel = {
    name: name,
    regex: sentenceCamel,
    StringToParts: StringToParts,
    PartsToString: PartsToString,
}

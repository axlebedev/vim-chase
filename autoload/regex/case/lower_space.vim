vim9script

import '../func.vim'

var sentenceSpace = '\v\C^[[:lower:]][[:lower:][:digit:]]+( +[[:lower:][:digit:]]+)+$'
var name = ['lower_space']

def StringToParts(word: string): list<string>
    var parts = word
        ->substitute('\C[^[:digit:][:lower:][:upper:]]', ' ', 'g')
        ->split(' ')

    return parts->map(func.MapToLowerIfNotUpper)
enddef

def PartsToString(parts: list<string>): string
    return parts->map(func.MapToLower)->join(' ')
enddef

export var lower_space = {
    name: name,
    regex: sentenceSpace,
    StringToParts: StringToParts,
    PartsToString: PartsToString,
}

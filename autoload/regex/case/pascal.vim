vim9script

import '../func.vim'

var sentencePascal = '\v\C^[[:upper:]]+[[:lower:][:digit:]]*([[:upper:][:digit:]]+[[:lower:][:digit:]]+)+[[:upper:]]*$'
var name = ['pascal']

def StringToParts(word: string): list<string>
    var parts = word
                \ ->substitute('\C\v([[:lower:]])([[:upper:]])', '\1-\2', 'g')
                \ ->substitute('\C\v([[:upper:]])([[:upper:]][[:lower:]])', '\1-\2', 'g')
                \ ->split('-')

    return parts->map(funcref(func.MapToLowerIfNotUpper))
enddef

def PartsToString(parts: list<string>): string
    return parts->map(funcref(func.MapToCapital))->join('')
enddef

export var pascal = {
  \ 'name': name,
  \ 'regex': sentencePascal,
  \ 'StringToParts': function('StringToParts'),
  \ 'PartsToString': function('PartsToString'),
  \ }

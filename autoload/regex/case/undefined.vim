vim9script

import '../func.vim'

var sentenceUndefined = '\v\C^.*$'
var name = ['undefined']

def StringToParts(word: string): list<string>
    var parts = word
                \ ->substitute('\C[^[:digit:][:lower:][:upper:]]', '-', 'g')
                \ ->split('-')

    return parts->map(funcref(func.MapToLowerIfNotUpper))
enddef

def PartsToString(parts: list<string>): string
    return parts->join(' ')
enddef

export var undefinedCase = {
  \ 'name': name,
  \ 'regex': sentenceUndefined,
  \ 'StringToParts': function('StringToParts'),
  \ 'PartsToString': function('PartsToString'),
  \ }

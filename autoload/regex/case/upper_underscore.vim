vim9script

var sentenceUpper = '\v\C^[[:upper:]][[:upper:][:digit:]]*(_[[:upper:][:digit:]]+)+$'
var name = ['upper', 'upper_underscore']

def StringToParts(word: string): list<string>
    var parts = word
        \ ->substitute('\C[^[:digit:][:lower:][:upper:]]', '_', 'g')
        \ ->split('_')

    return parts->map(funcref('func#MapToLower'))
enddef

def PartsToString(parts: list<string>): string
    return parts->map(funcref('func#MapToUpper'))->join('_')
enddef

export var upper_underscore = {
  \ 'name': name,
  \ 'regex': sentenceUpper,
  \ 'StringToParts': function('StringToParts'),
  \ 'PartsToString': function('PartsToString'),
  \ }

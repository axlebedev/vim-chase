vim9script

var sentenceTitle = '\v\C^[[:upper:]][[:lower:][:digit:]]*( [[:upper:]][[:lower:][:digit:]]+)*$'
var name = ['title']

def StringToParts(word: string): list<string>
    var parts = word
                \ ->substitute('\C[^[:digit:][:lower:][:upper:]]', '-', 'g')
                \ ->split('-')

    return parts->map(funcref('func#MapToLowerIfNotUpper'))
enddef

def PartsToString(parts: list<string>): string
    return parts->map(funcref('func#MapToCapital'))->join(' ')
enddef

export var title = {
  \ 'name': name,
  \ 'regex': sentenceTitle,
  \ 'StringToParts': function('StringToParts'),
  \ 'PartsToString': function('PartsToString'),
  \ }

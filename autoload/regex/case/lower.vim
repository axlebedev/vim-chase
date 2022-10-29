vim9script

var sentenceLower = '\v\C^[[:lower:][:digit:]]+$'
var name = ['lower']

def StringToParts(word: string): list<string>
    return [word]->map(funcref('func#MapToLower'))
enddef

def PartsToString(parts: list<string>): string
    return parts->map(funcref('func#MapToLower'))->join('-')
enddef

export var lower = {
  \ 'name': name,
  \ 'regex': sentenceLower,
  \ 'StringToParts': function('StringToParts'),
  \ 'PartsToString': function('PartsToString'),
  \ }

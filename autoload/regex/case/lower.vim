vim9script

import '../func.vim'

var sentenceLower = '\v\C^[[:lower:][:digit:]]+$'
var name = 'lower'

def StringToParts(word: string): list<string>
    return [word]->map(func.MapToLower)
enddef

def PartsToString(parts: list<string>): string
    return parts->map(func.MapToLower)->join(' ')
enddef

export var lower = {
    name: name,
    regex: sentenceLower,
    StringToParts: StringToParts,
    PartsToString: PartsToString,
}

vim9script

import '../func.vim'

var sentencePassword = '\v\C^\*+$'
var name = ['password']

def StringToParts(word: string): list<string>
    return [word]
enddef

def PartsToString(parts: list<string>): string
    var res = parts->join('*')->substitute('\v\c.', '*', 'g')
    echom 'parts=' .. string(parts) .. ' res=' .. res
    return res
enddef

export var password = {
    name: name,
    regex: sentencePassword,
    StringToParts: StringToParts,
    PartsToString: PartsToString,
}

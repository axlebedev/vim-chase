let s:sentenceLower = '\v\C^[[:lower:][:digit:]]+$'
let s:name = ['lower']

function! s:StringToParts(word) abort
    return [a:word]->map(funcref('func#MapToLower'))
endfunction

function! s:PartsToString(parts) abort
    return a:parts->map(funcref('func#MapToLower'))->join('-')
endfunction

let regex#case#lower#case = {
  \ 'name': s:name,
  \ 'regex': s:sentenceLower,
  \ 'StringToParts': function('s:StringToParts'),
  \ 'PartsToString': function('s:PartsToString'),
  \ }

function! regex#case#lower#init() abort
endfunction

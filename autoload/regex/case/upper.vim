let s:sentenceUpper = '\v\C^[[:upper:][:digit:]]+$'
let s:name = ['upper']

function! s:StringToParts(word) abort
    return [a:word]->map(funcref('func#MapToLower'))
endfunction

function! s:PartsToString(parts) abort
    return a:parts->map(funcref('func#MapToUpper'))->join('-')
endfunction

let regex#case#upper#case = {
  \ 'name': s:name,
  \ 'regex': s:sentenceUpper,
  \ 'StringToParts': function('s:StringToParts'),
  \ 'PartsToString': function('s:PartsToString'),
  \ }

function! regex#case#upper#init() abort
endfunction

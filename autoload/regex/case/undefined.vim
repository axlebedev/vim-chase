let s:sentenceUndefined = '\v\C^.*$'
let s:name = ['undefined']

function! s:StringToParts(word) abort
    let parts = a:word
                \ ->substitute('\C[^[:digit:][:lower:][:upper:]]', '-', 'g')
                \ ->split('-')

    return parts->map(funcref('func#MapToLowerIfNotUpper'))
endfunction

function! s:PartsToString(parts) abort
    return a:parts->join(' ')
endfunction

let regex#case#undefined#case = {
  \ 'name': s:name,
  \ 'regex': s:sentenceUndefined,
  \ 'StringToParts': function('s:StringToParts'),
  \ 'PartsToString': function('s:PartsToString'),
  \ }

function! regex#case#undefined#init() abort
endfunction

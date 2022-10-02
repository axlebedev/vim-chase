let s:sentenceSnake = '\v\C^[[:lower:]][[:lower:][:digit:]]*(_[[:lower:][:digit:]]*)+$'
let s:name = ['snake', 'lower_underscore']

function! s:StringToParts(word) abort
    let parts = a:word
        \ ->substitute('\C[^[:digit:][:lower:][:upper:]]', '_', 'g')
        \ ->split('_')

    return parts->map(funcref('func#MapToLowerIfNotUpper'))
endfunction

function! s:PartsToString(parts) abort
    return a:parts->map(funcref('func#MapToLower'))->join('_')
endfunction

let regex#case#lower_underscore#case = {
  \ 'name': s:name,
  \ 'regex': s:sentenceSnake,
  \ 'StringToParts': function('s:StringToParts'),
  \ 'PartsToString': function('s:PartsToString'),
  \ }

function! regex#case#lower_underscore#init() abort
endfunction

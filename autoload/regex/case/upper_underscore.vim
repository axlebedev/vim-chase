let s:sentenceUpper = '\v\C^[[:upper:]][[:upper:][:digit:]]*(_[[:upper:][:digit:]]+)+$'
let s:name = ['upper', 'upper_underscore']

function! s:StringToParts(word) abort
    let parts = a:word
        \ ->substitute('\C[^[:digit:][:lower:][:upper:]]', '_', 'g')
        \ ->split('_')

    return parts->map(funcref('func#MapToLowerIfNotUpper'))
endfunction

function! s:PartsToString(parts) abort
    return a:parts->map(funcref('func#MapToUpper'))->join('_')
endfunction

let regex#case#upper_underscore#case = {
  \ 'name': s:name,
  \ 'regex': s:sentenceUpper,
  \ 'StringToParts': function('s:StringToParts'),
  \ 'PartsToString': function('s:PartsToString'),
  \ }

function! regex#case#upper_underscore#init() abort
endfunction

let s:sentenceUpper = '\v\C^[[:upper:]][[:upper:][:digit:]]*( [[:upper:][:digit:]]+)+$'
let s:name = ['upper_space']

function! s:StringToParts(word) abort
    let parts = a:word
        \ ->substitute('\C[^[:digit:][:lower:][:upper:]]', '_', 'g')
        \ ->split('_')

    return parts->map(funcref('func#MapToLower'))
endfunction

function! s:PartsToString(parts) abort
    return a:parts->map(funcref('func#MapToUpper'))->join(' ')
endfunction

let regex#case#upper_space#case = {
  \ 'name': s:name,
  \ 'regex': s:sentenceUpper,
  \ 'StringToParts': function('s:StringToParts'),
  \ 'PartsToString': function('s:PartsToString'),
  \ }

function! regex#case#upper_space#init() abort
endfunction

let s:sentenceDash = '\v\C^[[:lower:][:digit:]]+(-+[[:lower:][:digit:]]+)+$'
let s:name = ['dash', 'kebab', 'hyphen', 'lower_dash', 'lower_hyphen']

function! s:StringToParts(word) abort
    let parts = a:word
        \ ->substitute('\C[^[:digit:][:lower:][:upper:]]', '-', 'g')
        \ ->split('-')

    return parts->map(funcref('func#MapToLowerIfNotUpper'))
endfunction

function! s:PartsToString(parts) abort
    return a:parts->map(funcref('func#MapToLower'))->join('-')
endfunction

let regex#case#lower_dash#case = {
  \ 'name': s:name,
  \ 'regex': s:sentenceDash,
  \ 'StringToParts': function('s:StringToParts'),
  \ 'PartsToString': function('s:PartsToString'),
  \ }

function! regex#case#lower_dash#init() abort
endfunction

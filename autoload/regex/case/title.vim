let s:sentenceTitle = '\v\C^[[:upper:]][[:lower:][:digit:]]*( [[:upper:]][[:lower:][:digit:]]+)*$'
let s:name = ['title']

function! s:StringToParts(word) abort
    let parts = a:word
                \ ->substitute('\C[^[:digit:][:lower:][:upper:]]', '-', 'g')
                \ ->split('-')

    return parts->map(funcref('func#MapToLowerIfNotUpper'))
endfunction

function! s:PartsToString(parts) abort
    return a:parts->map(funcref('func#MapToCapital'))->join(' ')
endfunction

let regex#case#title#case = {
  \ 'name': s:name,
  \ 'regex': s:sentenceTitle,
  \ 'StringToParts': function('s:StringToParts'),
  \ 'PartsToString': function('s:PartsToString'),
  \ }

function! regex#case#title#init() abort
endfunction

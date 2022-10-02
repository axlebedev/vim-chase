let s:sentencePascal = '\v\C^[[:upper:]]+[[:lower:][:digit:]]*([[:upper:][:digit:]]+[[:lower:][:digit:]]+)+[[:upper:]]*$'
let s:name = ['pascal']

function! s:StringToParts(word) abort
    let parts = a:word
                \ ->substitute('\C\v([[:lower:]])([[:upper:]])', '\1-\2', 'g')
                \ ->substitute('\C\v([[:upper:]])([[:upper:]][[:lower:]])', '\1-\2', 'g')
                \ ->split('-')

    return parts->map(funcref('func#MapToLowerIfNotUpper'))
endfunction

function! s:PartsToString(parts) abort
    return a:parts->map(funcref('func#MapToCapital'))->join('')
endfunction

let regex#case#pascal#case = {
  \ 'name': s:name,
  \ 'regex': s:sentencePascal,
  \ 'StringToParts': function('s:StringToParts'),
  \ 'PartsToString': function('s:PartsToString'),
  \ }

function! regex#case#pascal#init() abort
endfunction

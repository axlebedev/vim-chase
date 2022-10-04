let s:sentenceCamel = '\v\C^[[:lower:]][[:lower:][:digit:]]*([[:upper:]][[:lower:][:digit:]]*)+$'
let s:name = ['camel_abbr']

function! s:StringToParts(word) abort
    let parts = a:word
                \ ->substitute('\C\v([[:lower:]])([[:upper:]])', '\1-\2', 'g')
                \ ->substitute('\C\v([[:upper:]])([[:upper:]][[:lower:]])', '\1-\2', 'g')
                \ ->split('-')

    return parts->map(funcref('func#MapToLowerIfNotUpper'))
endfunction

function! s:PartsToString(parts) abort
    return (a:parts[0:0]->map(funcref('func#MapToLowerIfNotUpper'))+a:parts[1:]->map(funcref('func#MapToCapitalIfNotUpper')))->join('')
endfunction

let regex#case#camel_abbr#case = {
  \ 'name': s:name,
  \ 'regex': s:sentenceCamel,
  \ 'StringToParts': function('s:StringToParts'),
  \ 'PartsToString': function('s:PartsToString'),
  \ }

function! regex#case#camel_abbr#init() abort
endfunction

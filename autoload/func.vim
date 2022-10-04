function! func#init() abort
endfunction

function! func#MapToLower(i, string) abort
    return a:string->tolower()
endfunction

function! func#MapToUpper(i, string) abort
    return a:string->toupper()
endfunction

function! func#MapToCapital(i, string) abort
    let firstCharIndex = 0
    while (charidx(a:string, firstCharIndex + 1) == 0)
        let firstCharIndex += 1
    endwhile

    return a:string[0:firstCharIndex]->toupper() . a:string[firstCharIndex + 1:]->tolower()
endfunction

function! func#MapToLowerIfNotUpper(i, string) abort
    if (a:string !~# '\C\v^[[:upper:][:digit:]]+$')
        return a:string->tolower()
    endif
    return a:string
endfunction

function! func#MapToCapitalIfNotUpper(i, string) abort
    if (a:string !~# '\C\v^[[:upper:][:digit:]]+$')
        return func#MapToCapital(0, a:string)
    endif
    return a:string
endfunction

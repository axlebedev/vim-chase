vim9script

export def MapToLower(i: number, str: string): string
    return str->tolower()
enddef

export def MapToUpper(i: number, str: string): string
    return str->toupper()
enddef

export def MapToCapital(i: number, str: string): string
    var firstCharIndex = 0
    while (charidx(str, firstCharIndex + 1) == 0)
        firstCharIndex += 1
    endwhile

    return str[0 : firstCharIndex]->toupper() .. str[firstCharIndex + 1 :]->tolower()
enddef

export def MapToLowerIfNotUpper(i: number, str: string): string
    if (str !~# '\C\v^[[:upper:][:digit:]]+$')
        return str->tolower()
    endif
    return str
enddef

export def MapToCapitalIfNotUpper(i: number, str: string): string
    if (str !~# '\C\v^[[:upper:][:digit:]]+$')
        return MapToCapital(0, str)
    endif
    return str
enddef

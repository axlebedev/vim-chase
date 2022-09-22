let s:groups = {
    \ 'undefined': 'group-undefined',
    \ 'letter': 'group-letter',
    \ 'word': 'group-word',
    \ 'sentence': 'group-sentence',
\ }

" -- 2 or more words
" dash     any-word
let s:sentenceDash = '\v\C^[a-z0-9]+(-+[a-z0-9]+)+$'
" camel    anyWord
let s:sentenceCamel = '\v\C^[a-z][a-z0-9]*([A-Z][a-z0-9]*)+$'
" snake    any_word
let s:sentenceSnake = '\v\C^[a-z][a-z0-9]*(_[a-z0-9]*)+$'
" upper    ANY_WORD
let s:sentenceUpper = '\v\C^[A-Z][A-Z0-9]*(_[A-Z0-9]+)+$'
" pascal   AnyWord
let s:sentencePascal = '\v\C^[A-Z][a-z0-9]*([A-Z0-9][a-z0-9]+)+$'
" title    Any Word
let s:sentenceTitle = '\v\C^[A-Z][a-z0-9]*( [A-Z][a-z0-9]+)+$'

let s:sentenceCasesOrder = [
  \ s:sentenceDash,
  \ s:sentenceSnake,
  \ s:sentenceCamel,
  \ s:sentencePascal,
  \ s:sentenceUpper,
  \ s:sentenceTitle,
  \ ]

" -- single word, 2 or more letters
" lower    word
let s:wordLower = '\v\C^[a-z0-9]+$'
" upper    WORD
let s:wordUpper = '\v\C^[A-Z0-9]+$'
" title    Word
let s:wordTitle = '\v\C^[A-Z][a-z0-9]+$'

let s:wordCasesOrder = [
  \ s:wordUpper,
  \ s:wordLower,
  \ s:wordTitle,
  \ ]

" -- single letter
" lower    w
let s:letterLower = '\v\C^[a-z]$'
" upper    W
let s:letterUpper = '\v\C^[A-Z]$'

function! s:GetWordRegex(word) abort
    if (a:word =~# s:letterLower)
        return { 'regex': s:letterLower, 'group': s:groups.letter }
    elseif (a:word =~# s:letterUpper)
        return { 'regex': s:letterUpper, 'group': s:groups.letter }
    elseif (a:word =~# s:wordUpper)
        return { 'regex': s:wordUpper, 'group': s:groups.word }
    elseif (a:word =~# s:wordLower)
        return { 'regex': s:wordLower, 'group': s:groups.word }
    elseif (a:word =~# s:wordTitle)
        return { 'regex': s:wordTitle, 'group': s:groups.word }
    elseif (a:word =~# s:sentenceUpper)
        return { 'regex': s:sentenceUpper, 'group': s:groups.sentence }
    elseif (a:word =~# s:sentenceSnake)
        return { 'regex': s:sentenceSnake, 'group': s:groups.sentence }
    elseif (a:word =~# s:sentenceDash)
        return { 'regex': s:sentenceDash, 'group': s:groups.sentence }
    elseif (a:word =~# s:sentenceTitle)
        return { 'regex': s:sentenceTitle, 'group': s:groups.sentence }
    elseif (a:word =~# s:sentencePascal)
        return { 'regex': s:sentencePascal, 'group': s:groups.sentence }
    elseif (a:word =~# s:sentenceCamel)
        return { 'regex': s:sentenceCamel, 'group': s:groups.sentence }
    endif
    return { 'regex': '', 'group': s:groups.undefined }
endfunction

" Normalize string: any case -> to dash case (lower)
function! s:ToDash(word, currentRegex) abort
    " camelCase, pascalCase
    if (a:currentRegex ==# s:sentenceCamel || a:currentRegex ==# s:sentencePascal)
        return a:word->substitute('\C^\@<![A-Z]', '-\0', 'g')->tolower()
    endif

    " all other cases
    return a:word->substitute('\C[^a-zA-Z0-9]', '-', 'g')->tolower()
endfunction

function! s:DashToNext(word, group, oldRegex) abort
    if (a:group ==# s:groups.letter)
        if (a:oldRegex ==# s:letterLower)
            return a:word->toupper()
        else
            return a:word->tolower()
        endif
    endif

    if (a:group ==# s:groups.word)
        " any -> lower ->  title -> upper -> lower
        let nextCaseIndex = (s:wordCasesOrder->index(a:oldRegex) + 1) % s:wordCasesOrder->len()
        let nextCase = s:wordCasesOrder[nextCaseIndex]

        if (nextCase ==# s:wordLower)
            return a:word->tolower()
        elseif (nextCase ==# s:wordUpper)
            return a:word->toupper()
        else
            return a:word->tolower()->substitute('^[a-z]', '\u\0', 'g')
        endif
    endif

    let nextCaseIndex = (s:sentenceCasesOrder->index(a:oldRegex) + 1) % s:sentenceCasesOrder->len()
    let nextCase = s:sentenceCasesOrder[nextCaseIndex]

    if (nextCase ==# s:sentenceDash)
        return a:word
    elseif (nextCase ==# s:sentenceCamel)
        return a:word->substitute('\v\-([a-z])', '\u\1', 'g')
    elseif (nextCase ==# s:sentenceSnake)
        return a:word->substitute('-', '_', 'g')
    elseif (nextCase ==# s:sentenceUpper)
        return a:word->substitute('-', '_', 'g')->toupper()
    elseif (nextCase ==# s:sentencePascal)
        return a:word->substitute('\v\-([a-z])', '\u\1', 'g')->substitute('\v^([a-z])', '\u\1', '')
    elseif (nextCase ==# s:sentenceTitle)
        return a:word->substitute('\v\-([a-z])', ' \u\1', 'g')->substitute('\v^([a-z])', '\u\1', '')
    endif

    return a:word
endfunction

function! regex#GetNextWord(oldWord) abort
    let oldRegex = s:GetWordRegex(a:oldWord)
    let dashWord = s:ToDash(a:oldWord, oldRegex.regex)
    let newWord = s:DashToNext(dashWord, oldRegex.group, oldRegex.regex)
    return newWord
endfunction

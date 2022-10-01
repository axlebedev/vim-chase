
let s:groups = {
    \ 'undefined': 'group-undefined',
    \ 'letter': 'group-letter',
    \ 'word': 'group-word',
    \ 'sentence': 'group-sentence',
\ }

" -- 2 or more words
" dash     any-word
let s:sentenceDash = '\v\C^[[:lower:][:digit:]]+(-+[[:lower:][:digit:]]+)+$'
" camel    anyWord
let s:sentenceCamel = '\v\C^[[:lower:]][[:lower:][:digit:]]*([[:upper:]][[:lower:][:digit:]]*)+$'
" snake    any_word
let s:sentenceSnake = '\v\C^[[:lower:]][[:lower:][:digit:]]*(_[[:lower:][:digit:]]*)+$'
" upper    ANY_WORD
let s:sentenceUpper = '\v\C^[[:upper:]][[:upper:][:digit:]]*(_[[:upper:][:digit:]]+)+$'
" pascal   AnyWord
let s:sentencePascal = '\v\C^[[:upper:]][[:lower:][:digit:]]*([[:upper:][:digit:]][[:lower:][:digit:]]+)+$'
" title    Any Word
let s:sentenceTitle = '\v\C^[[:upper:]][[:lower:][:digit:]]*( [[:upper:]][[:lower:][:digit:]]+)+$'

" -- single word, 2 or more letters
" lower    word
let s:wordLower = '\v\C^[[:lower:][:digit:]]+$'
" upper    WORD
let s:wordUpper = '\v\C^[[:upper:][:digit:]]+$'
" title    Word
let s:wordTitle = '\v\C^[[:upper:]][[:lower:][:digit:]]+$'

" -- single letter
" lower    w
let s:letterLower = '\v\C^[[:lower:]]$'
" upper    W
let s:letterUpper = '\v\C^[[:upper:]]$'

let s:caseDict = {
  \ 'dash': s:sentenceDash,
  \ 'kebab': s:sentenceDash,
  \ 'hyphen': s:sentenceDash,
  \
  \ 'snake': s:sentenceSnake,
  \ 'lower_underscore': s:sentenceSnake,
  \
  \ 'upper': s:sentenceUpper,
  \ 'upper_underscore': s:sentenceUpper,
  \
  \ 'camel': s:sentenceCamel,
  \ 'pascal': s:sentencePascal,
  \ 'title': s:sentenceTitle,
  \
  \ 'wordUpper': s:wordUpper,
  \ 'wordLower': s:wordLower,
  \ 'wordTitle': s:wordTitle,
  \
  \ 'letterUpper': s:letterUpper,
  \ 'letterLower': s:letterLower,
  \ }

function! s:MakeCasesOrderRegexArray(casesOrderNamesArray) abort
    return copy(a:casesOrderNamesArray)
      \ ->map({_, name -> s:caseDict[name]})
endfunction

function! s:MakeCasesOrderRegexArrayByGroup(group) abort
    if (a:group == s:groups.letter)
        return s:MakeCasesOrderRegexArray(g:letterCasesOrder)
    endif
    if (a:group == s:groups.word)
        return s:MakeCasesOrderRegexArray(g:wordCasesOrder)
    endif
        return s:MakeCasesOrderRegexArray(g:sentenceCasesOrder)
endfunction

function! s:GetWordRegex(word) abort
    if (a:word =~# s:letterLower)
        return { 'regex': s:letterLower, 'group': s:groups.letter, 'name': 'letterLower' }
    elseif (a:word =~# s:letterUpper)
        return { 'regex': s:letterUpper, 'group': s:groups.letter, 'name': 'letterUpper' }
    elseif (a:word =~# s:wordUpper)
        return { 'regex': s:wordUpper, 'group': s:groups.word, 'name': 'wordUpper' }
    elseif (a:word =~# s:wordLower)
        return { 'regex': s:wordLower, 'group': s:groups.word, 'name': 'wordLower' }
    elseif (a:word =~# s:wordTitle)
        return { 'regex': s:wordTitle, 'group': s:groups.word, 'name': 'wordTitle' }
    elseif (a:word =~# s:sentenceUpper)
        return { 'regex': s:sentenceUpper, 'group': s:groups.sentence, 'name': 'sentenceUpper' }
    elseif (a:word =~# s:sentenceSnake)
        return { 'regex': s:sentenceSnake, 'group': s:groups.sentence, 'name': 'sentenceSnake' }
    elseif (a:word =~# s:sentenceDash)
        return { 'regex': s:sentenceDash, 'group': s:groups.sentence, 'name': 'sentenceDash' }
    elseif (a:word =~# s:sentenceTitle)
        return { 'regex': s:sentenceTitle, 'group': s:groups.sentence, 'name': 'sentenceTitle' }
    elseif (a:word =~# s:sentencePascal)
        return { 'regex': s:sentencePascal, 'group': s:groups.sentence, 'name': 'sentencePascal' }
    elseif (a:word =~# s:sentenceCamel)
        return { 'regex': s:sentenceCamel, 'group': s:groups.sentence, 'name': 'sentenceCamel' }
    endif
    return { 'regex': '', 'group': s:groups.undefined, 'name': 'undefined' }
endfunction

" Normalize string: any case -> to dash case (lower)
function! s:ToDash(word, currentRegex) abort
    " camelCase, pascalCase
    if (a:currentRegex ==# s:sentenceCamel || a:currentRegex ==# s:sentencePascal)
        return a:word->substitute('\C^\@<![[:upper:]]', '-\0', 'g')->tolower()
    endif

    " all other cases
    return a:word->substitute('\C[^[:digit:][:lower:][:upper:]]', '-', 'g')->tolower()
endfunction

function! s:GetNextCase(group, oldRegex, isPrev) abort
    let regexArray = s:MakeCasesOrderRegexArrayByGroup(a:group)
    let d = a:isPrev ? -1 : 1
    let nextCaseIndex = (regexArray->index(a:oldRegex) + d) % regexArray->len()
    let nextCase = regexArray[nextCaseIndex]
    return nextCase
endfunction

function! s:DashToNext(word, group, oldRegex, isPrev) abort
    let nextCase = s:GetNextCase(a:group, a:oldRegex, a:isPrev)
    if (nextCase ==# s:letterUpper
      \ || nextCase ==# s:wordUpper)
        return a:word->toupper()
    elseif (nextCase ==# s:letterLower 
      \ || nextCase ==# s:wordLower)
        return a:word->tolower()
    elseif (nextCase ==# s:sentenceDash)
        return a:word
    elseif (nextCase ==# s:sentenceCamel)
        return a:word->substitute('\v\-([[:lower:]])', '\u\1', 'g')
    elseif (nextCase ==# s:sentenceSnake)
        return a:word->substitute('-', '_', 'g')
    elseif (nextCase ==# s:sentenceUpper)
        return a:word->substitute('-', '_', 'g')->toupper()
    elseif (nextCase ==# s:sentencePascal)
        return a:word->substitute('\v\-([[:lower:]])', '\u\1', 'g')->substitute('\v^([[:lower:]])', '\u\1', '')
    elseif (nextCase ==# s:wordTitle
      \ || nextCase ==# s:sentenceTitle)
        return a:word->substitute('\v\-([[:lower:]])', ' \u\1', 'g')->substitute('\v^([[:lower:]])', '\u\1', '')
    endif

    return a:word
endfunction

function! regex#GetNextWord(oldWord, isPrev) abort
    let oldRegex = s:GetWordRegex(a:oldWord)
    let dashWord = s:ToDash(a:oldWord, oldRegex.regex)
    let newWord = s:DashToNext(dashWord, oldRegex.group, oldRegex.regex, a:isPrev)
    return newWord
endfunction

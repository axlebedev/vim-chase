let s:sentenceCasesOrder = get(g:, 'caseChangeSentenceCasesOrder', [
  \ 'dash',
  \ 'snake',
  \ 'camel',
  \ 'pascal',
  \ 'upper',
  \ 'title',
  \ ])

let s:wordCasesOrder = get(g:, 'caseChangeWordCasesOrder', [
  \ 'wordUpper',
  \ 'wordLower',
  \ 'wordTitle',
  \ ])

let s:letterCasesOrder = get(g:, 'caseChangeLetterCasesOrder', [
  \ 'letterUpper',
  \ 'letterLower',
  \ ])

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

" -- single word, 2 or more letters
" lower    word
let s:wordLower = '\v\C^[a-z0-9]+$'
" upper    WORD
let s:wordUpper = '\v\C^[A-Z0-9]+$'
" title    Word
let s:wordTitle = '\v\C^[A-Z][a-z0-9]+$'

" -- single letter
" lower    w
let s:letterLower = '\v\C^[a-z]$'
" upper    W
let s:letterUpper = '\v\C^[A-Z]$'

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
  \ 'wordUpper': s:wordUpper,
  \ 'wordLower': s:wordLower,
  \ 'wordTitle': s:wordTitle,
  \ 'letterUpper': s:letterUpper,
  \ 'letterLower': s:letterLower,
  \ }

function! s:MakeCasesOrderRegexArray(casesOrderNamesArray) abort
    return copy(a:casesOrderNamesArray)
      \ ->map({_, name -> s:caseDict[name]})
endfunction

function! s:MakeCasesOrderRegexArrayByGroup(group) abort
    if (a:group == s:groups.letter)
        return s:MakeCasesOrderRegexArray(s:letterCasesOrder)
    endif
    if (a:group == s:groups.word)
        return s:MakeCasesOrderRegexArray(s:wordCasesOrder)
    endif
        return s:MakeCasesOrderRegexArray(s:sentenceCasesOrder)
endfunction

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
        return a:word->substitute('\v\-([a-z])', '\u\1', 'g')
    elseif (nextCase ==# s:sentenceSnake)
        return a:word->substitute('-', '_', 'g')
    elseif (nextCase ==# s:sentenceUpper)
        return a:word->substitute('-', '_', 'g')->toupper()
    elseif (nextCase ==# s:sentencePascal)
        return a:word->substitute('\v\-([a-z])', '\u\1', 'g')->substitute('\v^([a-z])', '\u\1', '')
    elseif (nextCase ==# s:wordTitle
      \ || nextCase ==# s:sentenceTitle)
        return a:word->substitute('\v\-([a-z])', ' \u\1', 'g')->substitute('\v^([a-z])', '\u\1', '')
    endif

    return a:word
endfunction

function! regex#GetNextWord(oldWord, isPrev) abort
    let oldRegex = s:GetWordRegex(a:oldWord)
    let dashWord = s:ToDash(a:oldWord, oldRegex.regex)
    let newWord = s:DashToNext(dashWord, oldRegex.group, oldRegex.regex, a:isPrev)
    return newWord
endfunction

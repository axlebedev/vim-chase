" {{{ Regexes to clarify current case
" \C - case sensitive
" \v  -  magic mode (no need for \)
" }}}

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
  \ s:sentenceCamel,
  \ s:sentenceSnake,
  \ s:sentenceUpper,
  \ s:sentencePascal,
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

let s:sessionStarted = 0

function! s:GetWordRegex(word) abort
    if (a:word =~ s:letterLower)
        return { 'regex': s:letterLower, 'group': s:groups.letter }
    elseif (a:word =~ s:letterUpper)
        return { 'regex': s:letterUpper, 'group': s:groups.letter }
    elseif (a:word =~ s:wordUpper)
        return { 'regex': s:wordUpper, 'group': s:groups.word }
    elseif (a:word =~ s:wordLower)
        return { 'regex': s:wordLower, 'group': s:groups.word }
    elseif (a:word =~ s:wordTitle)
        return { 'regex': s:wordTitle, 'group': s:groups.word }
    elseif (a:word =~ s:sentenceUpper)
        return { 'regex': s:sentenceUpper, 'group': s:groups.sentence }
    elseif (a:word =~ s:sentenceSnake)
        return { 'regex': s:sentenceSnake, 'group': s:groups.sentence }
    elseif (a:word =~ s:sentenceDash)
        return { 'regex': s:sentenceDash, 'group': s:groups.sentence }
    elseif (a:word =~ s:sentenceTitle)
        return { 'regex': s:sentenceTitle, 'group': s:groups.sentence }
    elseif (a:word =~ s:sentencePascal)
        return { 'regex': s:sentencePascal, 'group': s:groups.sentence }
    elseif (a:word =~ s:sentenceCamel)
        return { 'regex': s:sentenceCamel, 'group': s:groups.sentence }
    endif
    return { 'regex': '', 'group': s:groups.undefined }
endfunction

" Normalize string: any case -> to dash case (lower)
function! s:ToDash(word, currentRegex) abort
    " camelCase, pascalCase
    if (a:currentRegex == s:sentenceCamel || a:currentRegex == s:sentencePascal)
        return a:word->substitute('\C^\@<![A-Z]', '-\0', 'g')->tolower()
    endif

    " all other cases
    return a:word->substitute('\C[^a-zA-Z0-9]', '-', 'g')->tolower()
endfunction

function! s:DashToNext(word, group, oldRegex) abort
    if (a:group == s:groups.letter)
        if (a:oldRegex === s:letterLower)
            return a:word->toupper()
        else
            return a:word->tolower()
        endif
    endif

    if (a:group == s:groups.word)
        " any -> lower ->  title -> upper -> lower
        let nextCaseIndex = (s:wordCasesOrder->index(a:oldRegex) + 1) % s:wordCasesOrder->len()
        let nextCase = s:wordCasesOrder[nextCaseIndex]

        if (nextCase == s:wordLower)
            return a:word->tolower()
        elseif (nextCase == s:wordUpper)
            return a:word->toupper()
        else
            return a:word->tolower()->substitute('^[a-z]', '\u\0', 'g')
        endif
    endif

    let nextCaseIndex = (s:sentenceCasesOrder->index(a:oldRegex) + 1) % s:sentenceCasesOrder->len()
    let nextCase = s:sentenceCasesOrder[nextCaseIndex]

    if (nextCase == s:sentenceDash)
        return a:word
    elseif (nextCase == s:sentenceCamel)
        return a:word->substitute('\v\-([a-z])', '\u\1', 'g')
    elseif (nextCase == s:sentenceSnake)
        return a:word->substitute('-', '_', 'g')
    elseif (nextCase == s:sentenceUpper)
        return a:word->substitute('-', '_', 'g')->toupper()
    elseif (nextCase == s:sentencePascal)
        return a:word->substitute('\v\-([a-z])', '\u\1', 'g')->substitute('\v^([a-z])', '\u\1', '')
    elseif (nextCase == s:sentenceTitle)
        return a:word->substitute('\v\-([a-z])', ' \u\1', 'g')->substitute('\v^([a-z])', '\u\1', '')
    endif

    return a:word
endfunction

function! s:GetSelectionColumns() abort
    let pos1 = getpos('v')[2]-1
    let pos2 = getpos('.')[2]-1
    return { 'start': min([pos1, pos2]), 'end': max([pos1, pos2]) }
endfunction

" Get visual selected text
function! s:GetSelectionWord() abort
    let selection = s:GetSelectionColumns()
    return getline('.')[selection.start:selection.end]
endfunction

" Replace visual selection to argument
function! s:GetCurrentLineWithReplacedSelection(argument)
    let selection = s:GetSelectionColumns()
    let line = getline('.')
    if (selection.start == 0)
        return a:argument.line[selection.end+1:]
    endif
    return line[:selection.start-1].a:argument.line[selection.end+1:]
endfunction

function! casechange#next() abort
    " let s:count += 1
    " augroup ww
    "     autocmd!
    "     autocmd CursorMoved * call s:RestoreSettings()
    " augroup END

    let selectionColumns = s:GetSelectionColumns()
    let oldWord = s:GetSelectionWord()
    let oldRegex = s:GetWordRegex(oldWord)
    " echom 'oldWord="'.oldWord.'" '.string(oldRegex)
    let dashWord = s:ToDash(oldWord, oldRegex.regex)
    echom 'dashWord="'.dashWord.'"'
    let newWord = s:DashToNext(dashWord, oldRegex.group, oldRegex.regex)
    " echom 'newWord="'.newWord.'"'
    " if (s:sessionStarted)
    "     undojoin
    " endif
    call setline('.', s:GetCurrentLineWithReplacedSelection(newWord))

    call setpos("'<", [0, line('.'), selectionColumns.start + 1])
    call setpos("'>", [0, line('.'), selectionColumns.start + len(newWord)])
    normal! gv
    " let s:sessionStarted = 1
endfunction

" " {{{ Helpers
" function! s:DashToCamel(str) abort
"     return substitute(a:str, '\v-+([a-z])', '\U\1', 'g')          "camelCase
" endfunction
"
" function! s:CamelToPascal(str) abort
"     return substitute(a:str, '^.*$', '\u\0', 'g')                 "PascalCase
" endfunction
"
" function! s:PascalToUpper(str) abort
"     return toupper(substitute(a:str, '\C^\@<![A-Z]', '_\0', 'g'))          "UPPER_CASE
" endfunction
"
" function! s:UpperToTitle(str) abort
"     let l:tit_under = substitute(a:str, '\v([A-Z])([A-Z]*)','\1\L\2','g')
"     return substitute(l:tit_under,'_',' ','g')                        " Title Case
" endfunction
"
" function! s:TitleToSnake(str) abort
"     return tolower(substitute(a:str, ' ', '_', 'g'))               " snake_case
" endfunction
"
" function! s:SnakeToDash(str) abort
"     return substitute(a:str, '_\+', '-', 'g')                      "dash-case
" endfunction
" " }}}
"
" function! s:GetNewWord(str) abort
"     if (a:str =~ s:dash)
"         return s:DashToCamel(a:str)
"     elseif (a:str =~ s:camel)
"         return s:CamelToPascal(a:str)
"     elseif (a:str =~ s:pascal)
"         return s:PascalToUpper(a:str)
"     elseif (a:str =~ s:upper)
"         return s:UpperToTitle(a:str)
"     elseif (a:str =~ s:title)
"         return s:TitleToSnake(a:str)
"     elseif (a:str =~ s:snake)   "snake
"         return s:SnakeToDash(a:str)
"     endif
" endfunction
"
" let s:count = 0
" function! s:RestoreSettings()
"     " CursorMoved is async event, so need to use a hack:
"     " run this function only 
"     " when this plugin's 'CursorMoved's have been triggered
"     if (s:count > 0)
"         let s:count -= 1
"         return
"     endif
"
"     augroup ww
"         autocmd!
"     augroup END
"
"     let s:sessionStarted = 0
"     " exit visual mode
"     execute "normal! \<Esc>"
" endfunction
"
" function! casechange#next() abort
"     let s:count += 1
"     augroup ww
"         autocmd!
"         autocmd CursorMoved * call s:RestoreSettings()
"     augroup END
"
"     let selectionColumns = s:GetSelectionColumns()
"     let oldWord = s:GetSelectionWord()
"     let newWord = s:GetNewWord(oldWord)
"     if (s:sessionStarted)
"         undojoin
"     endif
"     call setline('.', s:GetCurrentLineWithReplacedSelection(newWord))
"
"     call setpos("'<", [0, line('.'), selectionColumns.start + 1])
"     call setpos("'>", [0, line('.'), selectionColumns.start + len(newWord)])
"     normal! gv
"     let s:sessionStarted = 1
" endfunction

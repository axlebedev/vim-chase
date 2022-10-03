call func#init()
" =============================================================================

let s:savedParts = []

" This one will be called on end of session, from SessionController
function! regex#regex#ResetSavedParts() abort
    let s:savedParts = []
endfunction

" =============================================================================

let s:groups = {
    \ 'undefined': 'group-undefined',
    \ 'letter': 'group-letter',
    \ 'word': 'group-word',
    \ 'sentence': 'group-sentence',
\ }
let regex#regex#groups = s:groups

call regex#case#lower#init()
call regex#case#upper#init()
call regex#case#camel#init()
call regex#case#lower_dash#init()
call regex#case#lower_underscore#init()
call regex#case#pascal#init()
call regex#case#title#init()
call regex#case#undefined#init()
call regex#case#upper_underscore#init()
let s:casesArrays = {
\ 'letter': [
\     regex#case#lower#case,
\     regex#case#upper#case
\ ],
\ 'word': [
\     regex#case#lower#case,
\     regex#case#upper#case,
\     regex#case#title#case
\ ],
\ 'sentence': [
\     regex#case#camel#case,
\     regex#case#lower_dash#case,
\     regex#case#lower_underscore#case,
\     regex#case#pascal#case,
\     regex#case#title#case,
\     regex#case#upper_underscore#case,
\ ],
\ 'undefined': [regex#case#undefined#case],
\ }

" =============================================================================

function! s:FindCaseByName(name, group)
    if (a:group == s:groups.letter)
        let i = 0
        while (i < s:casesArrays.letter->len())
            if (s:casesArrays.letter[i].name->index(a:name) > -1)
                return s:casesArrays.letter[i]
            endif
            let i += 1
        endwhile
    elseif (a:group == s:groups.word)
        let i = 0
        while (i < s:casesArrays.word->len())
            if (s:casesArrays.word[i].name->index(a:name) > -1)
                return s:casesArrays.word[i]
            endif
            let i += 1
        endwhile
    elseif (a:group == s:groups.sentence)
        let i = 0
        while (i < s:casesArrays.sentence->len())
            if (s:casesArrays.sentence[i].name->index(a:name) > -1)
                return s:casesArrays.sentence[i]
            endif
            let i += 1
        endwhile
    endif
    return g:regex#case#undefined#case
endfunction

function! s:GetCasesOrderByGroup(group) abort
    if (a:group == s:groups.letter)
        return g:letterCasesOrder
    elseif (a:group == s:groups.word)
        return g:wordCasesOrder
    endif
    return g:sentenceCasesOrder
endfunction

function! s:GetNextCase(group, oldCase, isPrev) abort
    let casesOrderArray = s:GetCasesOrderByGroup(a:group)
    let d = a:isPrev ? -1 : 1

    let curindex = 0
    while (curindex < casesOrderArray->len())
        let oneOfNames = casesOrderArray[curindex]
        if (a:oldCase.name->index(oneOfNames) > -1)
            break
        endif
        let curindex += 1
    endwhile
    let nextCaseIndex = (curindex + d) % casesOrderArray->len()

    let nextCaseName = casesOrderArray[nextCaseIndex]
    return s:FindCaseByName(nextCaseName, a:group)
endfunction

" =============================================================================
"
function! s:GetWordGroup(word) abort
    if (a:word->len() < 2)
        return s:groups.letter
    elseif (
      \    a:word =~# '\v\C^[[:upper:][:digit:]]+$' 
      \ || a:word =~# '\v\C^[[:lower:][:digit:]]+$'
      \ || a:word =~# '\v\C^[[:upper:]][[:lower:][:digit:]]+$'
      \ )
        " if only upper or digits or only lower and digits - this is single word
        return s:groups.word
    endif

    return s:groups.sentence 
endfunction

function! s:GetWordCase(word, group) abort
    let cases = [g:regex#case#undefined#case]
    if (a:group == s:groups.letter)
        let cases = s:casesArrays.letter
    elseif (a:group == s:groups.word)
        let cases = s:casesArrays.word
    elseif (a:group == s:groups.sentence)
        let cases = s:casesArrays.sentence
    endif

    let i = 0
    while (i < cases->len())
        if (a:word =~# cases[i].regex)
            return cases[i]
        endif
        let i += 1
    endwhile

    return g:regex#case#undefined#case
endfunction

function! regex#regex#GetNextWord(oldWord, isPrev) abort
    let group = s:GetWordGroup(a:oldWord)
    let oldCase = s:GetWordCase(a:oldWord, group)
    if (s:savedParts == [])
        let s:savedParts = oldCase.StringToParts(a:oldWord)
    endif
    let nextCase = s:GetNextCase(group, oldCase, a:isPrev)
    let newWord = nextCase.PartsToString(s:savedParts)
    return newWord
endfunction

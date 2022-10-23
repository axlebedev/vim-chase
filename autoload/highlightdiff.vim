let s:highlightsDeclared = 0
function! s:DeclareHighlightGroups() abort
    " highlights may be declared in vim config
    if (!hlexists('ChaseWord'))
        highlight ChaseWord guibg=#C7A575
    endif
    if (!hlexists('ChaseSeparator'))
        highlight ChaseSeparator guibg=#FF9999
    endif
    if (!hlexists('ChaseChangedLetter'))
        highlight ChaseChangedLetter guibg=#99FF99
    endif
    let s:highlightsDeclared = 1
endfunction

function! s:GetCharAtIndex(str, index) abort
    let charnr = strgetchar(a:str, charidx(a:str, a:index))
    return nr2char(charnr)
endfunction

" Get all not-letter symbol indexes
function! s:GetSeparatorIndexes(word) abort
    let res = []
    let i = 0
    while (i < a:word->len())
        if (s:GetCharAtIndex(a:word, i) !~? '[[:lower:][:digit:][:upper:]]')
            call add(res, i)
        endif
        let i += 1
    endwhile
    return res
endfunction

function! s:GetChangedIndexes(oldWord, newWord) abort
    if (a:oldWord->len() != a:newWord->len())
        return []
    endif

    let res = []
    let i = 0
    while (i < a:oldWord->len())
        let oldChar = s:GetCharAtIndex(a:oldWord, i)
        let newChar = s:GetCharAtIndex(a:newWord, i)
        if (oldChar !=# newChar)
            call add(res, i)
        endif
        let i += 1
    endwhile
    return res
endfunction

" leave only letters and numbers
function! s:GetCleanWord(word) abort
    return a:word->substitute('\C[^[:lower:][:upper:][:digit:]]', '', 'g')
endfunction

" insert separator in old word
function! s:GetDirtyWord(oldWord, newWord) abort
    let dirtyOldWord = copy(a:oldWord)
    if (a:newWord->len() > a:oldWord->len()) 
        let separatorIndexes = s:GetSeparatorIndexes(a:newWord)
        let i = 0
        while (i < separatorIndexes->len())
            let separatorIndex = separatorIndexes[i]
            let dirtyOldWord = dirtyOldWord[0:separatorIndex-1].a:newWord[separatorIndex].dirtyOldWord[separatorIndex:]
            let i += 1
        endwhile
    endif
    return dirtyOldWord
endfunction

function! s:GetIndexesToHighlight(oldWord, newWord) abort
    if (a:oldWord->len() > a:newWord->len())
        let cleanOldWord = s:GetCleanWord(a:oldWord)
        return {
          \ 'separator': [],
          \ 'changedLetters': s:GetChangedIndexes(cleanOldWord, a:newWord) 
      \ }
    endif

    let separatorIndexes = s:GetSeparatorIndexes(a:newWord)
    if (a:oldWord->len() == a:newWord->len())
        return {
          \ 'separator': separatorIndexes,
          \ 'changedLetters': s:GetChangedIndexes(a:oldWord, a:newWord) 
      \ }
    endif

    return {
          \ 'separator': separatorIndexes,
          \ 'changedLetters': s:GetChangedIndexes(s:GetDirtyWord(a:oldWord, a:newWord), a:newWord) 
      \ }
endfunction

let s:matchIds = []
function! highlightdiff#ClearHighlights(...) abort
        for id in s:matchIds
            call matchdelete(id)
        endfor
        let s:matchIds = []
endfunction

function! highlightdiff#HighlightDiff(oldWord, newWord) abort
    if (!s:highlightsDeclared)
        call s:DeclareHighlightGroups()
    endif
    let indexes = s:GetIndexesToHighlight(a:oldWord, a:newWord)

    " We cant override visual selection, so go to normal mode
    execute "normal! \<Esc>"

    let curline = line('.')
    let startOfWord = getpos("'<")[2]
    let endOfWord = getpos("'>")[2]
    call add(s:matchIds, matchadd('ChaseWord', '\%'.curline.'l\%>'.(startOfWord).'c\%<'.(endOfWord).'c'))
    for i in indexes.changedLetters
        call add(s:matchIds, matchadd('ChaseChangedLetter', '\%'.curline.'l\%'.(i + startOfWord).'c'))
    endfor
    for i in indexes.separator
        call add(s:matchIds, matchadd('ChaseSeparator', '\%'.curline.'l\%'.(i + startOfWord).'c'))
    endfor
endfunction

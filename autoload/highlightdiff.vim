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

let s:timer = 0
function! highlightdiff#HighlightDiff(oldWord, newWord) abort
    call timer_stop(s:timer)
    let indexes = s:GetIndexesToHighlight(a:oldWord, a:newWord)

    highlight CaseChangeWord guibg=#C7A575
    highlight Separator guibg=#FF9999
    highlight Changed guibg=#99FF99

    let curline = line('.')
    let startOfWord = getpos("'<")[2]
    let endOfWord = getpos("'>")[2]
    call add(s:matchIds, matchadd('CaseChangeWord', '\%'.curline.'l\%>'.(startOfWord).'c\%<'.(endOfWord).'c'))
    for i in indexes.changedLetters
        call add(s:matchIds, matchadd('Changed', '\%'.curline.'l\%'.(i + startOfWord).'c'))
    endfor
    for i in indexes.separator
        call add(s:matchIds, matchadd('Separator', '\%'.curline.'l\%'.(i + startOfWord).'c'))
    endfor

    let s:timer = timer_start(g:highlightTimeout, 'highlightdiff#ClearHighlights')
endfunction

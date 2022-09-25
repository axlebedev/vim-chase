" Get all not-letter symbol indexes
function! s:GetSeparatorIndexes(word) abort
    let res = []
    let i = 0
    while (i < a:word->len())
        " echom i.': '.a:word[i].' add='.(a:word[i] !~? '\v\C[a-z0-9]')
        if (a:word[i] !~? '\v[a-z0-9]')
            call add(res, i)
            " echom 'res='.string(res)
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
        " echom a:oldWord[i].' !=# '.a:newWord[i].'='.(a:oldWord[i] !=# a:newWord[i])
        if (a:oldWord[i] !=# a:newWord[i])
            call add(res, i)
        endif
        let i += 1
    endwhile
    " echom 'GetChangedIndexes('.a:oldWord.', '.a:newWord.') res='.string(res)
    return res
endfunction

" leave only letters and numbers
function! s:GetCleanWord(word) abort
    return a:word->substitute('\C[^a-zA-Z0-9]', '', 'g')
endfunction

" insert separator in old word
function! s:GetDirtyWord(oldWord, newWord) abort
    let dirtyOldWord = copy(a:oldWord)
    if (a:newWord->len() > a:oldWord->len()) 
        let separatorIndexes = s:GetSeparatorIndexes(a:newWord)
        " echom 'a:newWord='.string(a:newWord)
        " echom 'separatorIndexes='.string(separatorIndexes)
        let i = 0
        while (i < separatorIndexes->len())
            let separ = separatorIndexes[i]
            let dirtyOldWord = dirtyOldWord[0:separ-1].a:newWord[separ].dirtyOldWord[separ:]
            let i += 1
        endwhile
    endif
    return dirtyOldWord
endfunction

function! s:GetIndexesToHighlight(oldWord, newWord) abort
    if (a:oldWord->len() > a:newWord->len())
        " echom 'old > new'
        let cleanOldWord = s:GetCleanWord(a:oldWord)
        return {
          \ 'separator': [],
          \ 'changedLetters': s:GetChangedIndexes(cleanOldWord, a:newWord) 
      \ }
    endif

    let separatorIndexes = s:GetSeparatorIndexes(a:newWord)
    if (a:oldWord->len() == a:newWord->len())
        " echom 'old == new'
        return {
          \ 'separator': separatorIndexes,
          \ 'changedLetters': s:GetChangedIndexes(a:oldWord, a:newWord) 
      \ }
    endif

        " echom 'old < new'
    return {
          \ 'separator': separatorIndexes,
          \ 'changedLetters': s:GetChangedIndexes(s:GetDirtyWord(a:oldWord, a:newWord), a:newWord) 
      \ }
endfunction

let s:matchIds = []
function! highlightdiff#HighlightDiff(oldWord, newWord) abort
    let indexes = s:GetIndexesToHighlight(a:oldWord, a:newWord)

    highlight Separator guibg=#FF9999 ctermbg=NONE
    highlight Changed guibg=#99FF99 ctermbg=NONE

    let curline = line('.')
    let startOfWord = getpos("'<")[2]
    for i in indexes.changedLetters
        call add(s:matchIds, matchadd('Changed', '\%'.curline.'l\%'.(i + startOfWord).'c'))
    endfor
    for i in indexes.separator
        call add(s:matchIds, matchadd('Separator', '\%'.curline.'l\%'.(i + startOfWord).'c'))
    endfor

    func! MyHandler(timer)
        for id in s:matchIds
            call matchdelete(id)
        endfor
        let s:matchIds = []
    endfunc
    let timer = timer_start(1000, 'MyHandler')
endfunction

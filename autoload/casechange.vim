" {{{ Regexes to clarify current case
" \C - case sensitive
" \v  -  magic mode (no need for \)
" }}}
" 1. + Проверить что работает как надо
" 2.   Конфиг последовательности
" 3.   Подсветка при casechange#next
" 4. + Сделать casechange#prev
" 5. + undojoin
" 6.   Аббривеатуры, типа 'NDALabel'
" 7. + Сбросить visual mode на CursorMoved
" 8.   Старт из normal mode, поиск слова на котором стоит курсор (вкл. символ -)

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
function! s:GetCurrentLineWithReplacedSelection(argument) abort
    let selection = s:GetSelectionColumns()
    let line = getline('.')
    if (selection.start == 0)
        return a:argument.line[selection.end+1:]
    endif
    return line[:selection.start-1].a:argument.line[selection.end+1:]
endfunction

function! s:ResetAugroup() abort
    augroup au_vimcasechange
        autocmd!
    augroup END
endfunction

function! s:SetAugroup() abort
    augroup au_vimcasechange
        autocmd!
        autocmd CursorMoved * call s:OnCursorMoved()
    augroup END
endfunction

let s:sessionStarted = 0
function! s:OnCursorMoved() abort
    call s:ResetAugroup()
    let s:sessionStarted = 0

    " exit visual mode
    execute "normal! \<Esc>"
endfunction

function! s:ReplaceWithNext(isPrev) abort
    call timer_stopall()
    call s:ResetAugroup()

    let selectionColumns = s:GetSelectionColumns()
    let oldWord = s:GetSelectionWord()
    let newWord = regex#GetNextWord(oldWord, a:isPrev)
    if (s:sessionStarted)
        undojoin | call setline('.', s:GetCurrentLineWithReplacedSelection(newWord))
    else
        call setline('.', s:GetCurrentLineWithReplacedSelection(newWord))
    endif

    call setpos("'<", [0, line('.'), selectionColumns.start + 1])
    call setpos("'>", [0, line('.'), selectionColumns.start + len(newWord)])
    normal! gv
    let s:sessionStarted = 1
    call timer_start(100, { -> s:SetAugroup() })
endfunction

function! casechange#next() abort
    call s:ReplaceWithNext(0)
endfunction

function! casechange#prev() abort
    call s:ReplaceWithNext(1)
endfunction

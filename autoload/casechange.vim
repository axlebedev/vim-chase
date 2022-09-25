" {{{ Regexes to clarify current case
" \C - case sensitive
" \v  -  magic mode (no need for \)
" }}}
" 1 . + Проверить что работает как надо
" 2 . + Конфиг последовательности
" 3 . - Подсветка при casechange#next (сделано в п.9)
" 4 . + Сделать casechange#prev
" 5 . + undojoin
" 6 .   Аббривеатуры, типа 'NDALabel'
" 7 . + Сбросить visual mode на CursorMoved
" 8 . + Старт из normal mode, поиск слова на котором стоит курсор (вкл. символ -)
" 9 * + Подсветка диффа при casechange#next
" 10.   Сделать аргумент функции, чтобы можно было сделать вызов с кастомной последовательностью
" 11.   Сделать readme
" 12. + Синонимы
" 13.   Интернационализация: чтобы работали не только буквы латиницы

function! s:GetSelectionColumns() abort
    let pos1 = getpos('v')[2]-1
    let pos2 = getpos('.')[2]-1
    return { 'start': min([pos1, pos2]), 'end': max([pos1, pos2]) }
endfunction

" Get visual selected text
function! s:GetSelectionWord() abort
    if (mode() == 'n')
        let s:savedIskeyword = &iskeyword
        set iskeyword+=-
        normal! viw
        let &iskeyword = s:savedIskeyword
    endif
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

let s:savedVisualSelection = { 'start': 0, 'end': 0 }
let s:gvTimer = 0
function! GV(...) abort
    call setpos("'<", [0, line('.'), s:savedVisualSelection.start])
    call setpos("'>", [0, line('.'), s:savedVisualSelection.end])
    normal! gv
    let s:gvTimer = 0
endfunc

function! s:ReplaceWithNext(isPrev) abort
    if (s:gvTimer)
        call timer_stop(s:gvTimer)
        call GV()
    endif

    " NOTE: undojoin also here
    call sessioncontroller#SessionController()

    let oldWord = s:GetSelectionWord()
    let selectionColumns = s:GetSelectionColumns()
    let newWord = regex#GetNextWord(oldWord, a:isPrev)

    let s:savedVisualSelection = { 'start': selectionColumns.start + 1, 'end': selectionColumns.start + len(newWord) }
        call setline('.', s:GetCurrentLineWithReplacedSelection(newWord))

    call setpos("'<", [0, line('.'), s:savedVisualSelection.start])
    call setpos("'>", [0, line('.'), s:savedVisualSelection.end])
    call setpos(".", [0, line('.'), s:savedVisualSelection.end])
    execute "normal! \<Esc>"
    call highlightdiff#HighlightDiff(oldWord, newWord)
    let s:gvTimer = timer_start(g:highlightTimeout, function('GV'))
endfunction

function! casechange#next() abort
    call s:ReplaceWithNext(0)
endfunction

function! casechange#prev() abort
    call s:ReplaceWithNext(1)
endfunction

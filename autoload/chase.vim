" {{{ Regexes to clarify current case
" \C - case sensitive
" \v  -  magic mode (no need for \)
" }}}
" 1 . + Проверить что работает как надо
" 2 . + Конфиг последовательности
" 3 . - Подсветка при chase#next (сделано в п.9)
" 4 . + Сделать chase#prev
" 5 . + undojoin
" 6 . + Аббривеатуры, типа 'NDALabel'
" 7 . + Сбросить visual mode на CursorMoved
" 8 . + Старт из normal mode, поиск слова на котором стоит курсор (вкл. символ -)
" 9 * + Подсветка диффа при chase#next
" 10.   Сделать аргумент функции, чтобы можно было сделать вызов с кастомной последовательностью
" 11.   Сделать readme
" 12. + Синонимы
" 13. + Интернационализация: чтобы работали не только буквы латиницы
" 14.   Добавить больше возможных регекспов
" 15. - Добавить проверку на повторения имён - не нужно после того, как мы
"       научились работать с повторами
" 16.   Добавить конфиг цветов WARN! autocmd ColorScheme * \ highlight ChaseWord guibg=#0000FF

import './getconfig.vim'
import './regex/regex.vim'

function! s:GetSelectionColumns() abort
    let pos1 = getpos('v')[2]
    let pos2 = getpos('.')[2]

    let start = min([pos1, pos2]) - 1

    let end = start + expand('<cword>')->len()
    if (mode() == 'v')
        let end = max([pos1, pos2])
    endif
    let linenr = line('.')
    while (virtcol([linenr, end]) == virtcol([linenr, end + 1]))
        let end += 1
    endwhile

    return { 'start': start, 'end': end - 1 }
endfunction

" Get visual selected text
function! s:GetSelectionWord() abort
    if (mode() == 'n')
        normal! viw
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

function! s:ReplaceWithNext(isPrev) abort
    call sessioncontroller#SessionControllerStartRun()

    let oldWord = s:GetSelectionWord()
    let selectionColumns = s:GetSelectionColumns()
    let newWord = s:regex.GetNextWord(oldWord, a:isPrev)

    call sessioncontroller#SetVisualSelection({ 'start': selectionColumns.start + 1, 'end': selectionColumns.start + len(newWord) })
    call setline('.', s:GetCurrentLineWithReplacedSelection(newWord))

    if (s:getconfig.GetConfig('highlightTimeout'))
        call highlightdiff#HighlightDiff(oldWord, newWord)
    endif
    call sessioncontroller#SessionControllerEndRun()
endfunction

function! chase#next() abort
    call s:ReplaceWithNext(0)
endfunction

function! chase#prev() abort
    call s:ReplaceWithNext(1)
endfunction

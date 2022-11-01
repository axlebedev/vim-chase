vim9script

# {{{ Regexes to clarify current case
# \C - case sensitive
# \v  -  magic mode (no need for \)
# }}}
# 1 . + Проверить что работает как надо
# 2 . + Конфиг последовательности
# 3 . - Подсветка при chase#next (сделано в п.9)
# 4 . + Сделать chase#prev
# 5 . + undojoin
# 6 . + Аббривеатуры, типа 'NDALabel'
# 7 . + Сбросить visual mode на CursorMoved
# 8 . + Старт из normal mode, поиск слова на котором стоит курсор (вкл. символ -)
# 9 * + Подсветка диффа при chase#next
# 10.   Сделать аргумент функции, чтобы можно было сделать вызов с кастомной последовательностью
# 11.   Сделать readme
# 12. + Синонимы
# 13. + Интернационализация: чтобы работали не только буквы латиницы
# 14.   Добавить больше возможных регекспов
# 15. - Добавить проверку на повторения имён - не нужно после того, как мы
#       научились работать с повторами
# 16.   Добавить конфиг цветов WARN! autocmd ColorScheme * \ highlight ChaseWord guibg=#0000FF
# 17.   Если очень быстро нажимать '~' - то неправильно работает хайлайт: он пропадает и не появляется заново
# 18.   Опять сходит с умма на русских символах

import './getconfig.vim'
import './regex/regex.vim'
import './sessioncontroller.vim'
import './highlightdiff.vim'

def GetSelectionColumns(): dict<number>
    var pos1 = getpos('v')[2]
    var pos2 = getpos('.')[2]

    var startCol = min([pos1, pos2]) - 1

    var endCol = startCol + expand('<cword>')->len()
    if (mode() == 'v')
        endCol = max([pos1, pos2])
    endif
    var linenr = line('.')
    while (virtcol([linenr, endCol]) == virtcol([linenr, endCol + 1]))
        endCol += 1
    endwhile

    return { start: startCol, end: endCol - 1 }
enddef

# Get visual selected text
def GetSelectionWord(): string
    if (mode() == 'n')
        normal! viw
    endif
    var selection = GetSelectionColumns()
    return getline('.')[selection.start : selection.end]
enddef

# Replace visual selection to argument
def GetCurrentLineWithReplacedSelection(argument: string): string
    var selection = GetSelectionColumns()
    var line = getline('.')
    if (selection.start == 0)
        return argument .. line[selection.end + 1 :]
    endif
    return line[: selection.start - 1] .. argument .. line[selection.end + 1 :]
enddef

def ReplaceWithNext(isPrev: bool): void
    sessioncontroller.SessionControllerStartRun()

    var oldWord = GetSelectionWord()
    var selectionColumns = GetSelectionColumns()
    var newWord = regex.GetNextWord(oldWord, isPrev)

    sessioncontroller.SetVisualSelection({
        start: selectionColumns.start + 1,
        end: selectionColumns.start + newWord->len()
    })
    setline('.', GetCurrentLineWithReplacedSelection(newWord))

    if (getconfig.GetConfig('highlightTimeout') > 0)
        highlightdiff.HighlightDiff(oldWord, newWord)
    endif
    sessioncontroller.SessionControllerEndRun()
enddef

export def Next(): void
    ReplaceWithNext(false)
enddef

export def Prev(): void
    ReplaceWithNext(true)
enddef

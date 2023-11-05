vim9script

# {{{ Regexes to clarify current case
# \C - case sensitive
# \v  -  magic mode (no need for \)
# }}}
#
# 1 . + Проверить что работает как надо
# 2 . + Конфиг последовательности
# 3 . + Подсветка при chase#next (сделано в п.9)
# 4 . + Сделать chase#prev
# 5 . + undojoin
# 6 . + Аббривеатуры, типа 'NDALabel'
# 7 . + Сбросить visual mode на CursorMoved
# 8 . + Старт из normal mode, поиск слова на котором стоит курсор (вкл. символ -)
# 9 * + Подсветка диффа при chase#next
# 12. + Синонимы
# 13. + Интернационализация: чтобы работали не только буквы латиницы
# 14. + Добавить больше возможных регекспов
# 15. + Добавить проверку на повторения имён - не нужно после того, как мы научились работать с повторами
# 17. ? (Не воспроизводится) Если очень быстро нажимать '~' - то неправильно работает хайлайт: он пропадает и не появляется заново
# 18. + Опять сходит с умма на русских символах
# 20. + TODO: Commands for functions (?), проверить можно ли выставить маппинги извне плагина
# 23. + BUG: Баг, не слетает visual mode после движения курсора, если начали с visual mode
# 24. + BUG: Баг, не работает undojoin, если начали с visual mode
#
# 10.   TODO: Сделать аргумент функции, чтобы можно было сделать вызов с кастомной последовательностью
# 11.   TODO: Сделать readme
# 16.   TODO: Добавить конфиг цветов WARN! autocmd ColorScheme * \ highlight ChaseWord guibg=#0000FF
# 19. + TODO: Запилить проверку что мы выделили текст внутри одной строки
# 22. + TODO: Setting to respect abbriveations
# 25    TODO: Опция, чтобы на первом нажатии ничего не менял а только показывал попап

import './regex/regex.vim'
import './sessioncontroller.vim'
import './highlightdiff.vim'
import './sessionstore.vim'
import './popup.vim'

# return error if selection is multi line
def CheckSelection(): bool
    if (mode() == 'n')
        return true
    endif

    if (getpos('v')[1] != getpos('.')[1])
        execute "normal! \<Esc>"
        echom 'VimChase: only single line selections allowed'
        return false
    endif

    return true
enddef

def ReplaceWithNext(isPrev: bool): void
    sessioncontroller.OnRunStart()
    if (!sessionstore.isSessionStarted)
        sessioncontroller.OnSessionStart()
    endif

    var newWord = regex.GetNextWord(sessionstore.initialWord, isPrev)

    if (newWord != sessionstore.currentWord)
        var newLine = sessionstore.lineBegin .. newWord .. sessionstore.lineEnd
        setline(line('.'), newLine)
        setcursorcharpos(line('.'), sessionstore.lineBegin->len() + 1)
        highlightdiff.HighlightDiff(sessionstore.currentWord, newWord)
        sessionstore.currentWord = newWord
    endif

    popup.ShowPopup(newWord)
    sessioncontroller.OnRunEnd()
enddef

export def Next(): void
    if (!CheckSelection())
        return
    endif

    ReplaceWithNext(false)
enddef

export def Prev(): void
    if (!CheckSelection())
        return
    endif
    ReplaceWithNext(true)
enddef

# re-export from 'regex.vim' to avoid circular dependency errors
export def PrintAllCases(): void
    regex.PrintAllCases()
enddef

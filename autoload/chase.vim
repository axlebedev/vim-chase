vim9script

# {{{ Regexes to clarify current case
# \C - case sensitive
# \v  -  magic mode (no need for \)
# }}}
#
# 1 .   Проверить что работает как надо
# 2 .   Конфиг последовательности
# 3 .   Подсветка при chase#next (сделано в п.9)
# 4 . + Сделать chase#prev
# 5 . + undojoin
# 6 . + Аббривеатуры, типа 'NDALabel'
# 7 . + Сбросить visual mode на CursorMoved
# 8 . + Старт из normal mode, поиск слова на котором стоит курсор (вкл. символ -)
# 9 *   Подсветка диффа при chase#next
# 10.   Сделать аргумент функции, чтобы можно было сделать вызов с кастомной последовательностью
# 11.   Сделать readme
# 12. + Синонимы
# 13. + Интернационализация: чтобы работали не только буквы латиницы
# 14.   Добавить больше возможных регекспов
# 15. + Добавить проверку на повторения имён - не нужно после того, как мы
#       научились работать с повторами
# 16.   Добавить конфиг цветов WARN! autocmd ColorScheme * \ highlight ChaseWord guibg=#0000FF
# 17.   Если очень быстро нажимать '~' - то неправильно работает хайлайт: он пропадает и не появляется заново
# 18. + Опять сходит с умма на русских символах

# 20.   Запилить проверку что мы выделили текст внутри одной строки

import './regex/regex.vim'
import './sessioncontroller.vim'
import './highlightdiff.vim'
import './sessionstore.vim'

def ReplaceWithNext(isPrev: bool): void
    sessioncontroller.OnRunStart()
    if (!sessionstore.isSessionStarted)
        sessioncontroller.OnSessionStart()
    endif

    var newWord = regex.GetNextWord(sessionstore.initialWord, isPrev)
    var newLine = sessionstore.lineBegin .. newWord .. sessionstore.lineEnd
    setline(line('.'), newLine)
    setcursorcharpos(line('.'), sessionstore.lineBegin->len() + 1)
    highlightdiff.HighlightDiff(sessionstore.currentWord, newWord)
    sessionstore.currentWord = newWord

    sessioncontroller.OnRunEnd()
enddef

export def Next(): void
    ReplaceWithNext(false)
enddef

export def Prev(): void
    ReplaceWithNext(true)
enddef

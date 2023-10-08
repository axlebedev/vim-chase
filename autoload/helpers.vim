vim9script

import './sessionstore.vim'

def GetSelectionColumns(): dict<number>
    var pos1 = getcharpos('v')[2]
    var pos2 = getcharpos('.')[2]
    return {
        start: min([pos1, pos2]),
        end: max([pos1, pos2]),
    }
enddef

export def GetSelectedWord(): string
    if (mode() == 'n')
        return expand('<cword>')
    endif

    var sel = GetSelectionColumns()
    # "- 1" because sel indexes start from 1, getline starts from 0
    return getline('.')[sel.start - 1 : sel.end - 1]
enddef

export def GetCharAtPos(str: string, pos: number): string
    return str
        ->strgetchar(pos)
        ->nr2char()
enddef

export def GetStartPosOfCurrentWord(): number
    var cursorcharpos = getcursorcharpos()
    var pos = cursorcharpos[2]
    var line = getline('.')
    # "- 1" because line starts from 0, pos starts from 1
    while (line->GetCharAtPos(pos - 1) =~ '\k' && pos > 1)
        pos -= 1
    endwhile

    return pos
enddef

# Get part of line before changed word
export def GetCurrrentLineBegin(): string
    var line = getline('.')

    if (sessionstore.initialMode == 'n')
        setcursorcharpos(line('.'), GetStartPosOfCurrentWord())
        var curpos = getcursorcharpos()[2]

        if (curpos > 1)
            return line[ : curpos - 1]
        endif

        if (curpos == 1 && line->GetCharAtPos(0) !~ '\k')
            return line[0]
        endif

        return ''
    endif

    var sel = GetSelectionColumns()
    if (sel.start == 1)
        return ''
    endif
    return line[ : sel.start - 2]
enddef

# Get part of line after changed word
export def GetCurrrentLineEnd(): string
    var line = getline('.')

    if (sessionstore.initialMode == 'n')
        setcursorcharpos(line('.'), GetStartPosOfCurrentWord())
        var curpos = getcursorcharpos()[2]
        var secondHalf = line
        if (curpos > 1)
            secondHalf = line[curpos : ]
        endif

        if (curpos == 1 && line->GetCharAtPos(0) !~ '\k')
            secondHalf = line[curpos : ]
        endif

        var escapedWord = '\V' .. escape(sessionstore.initialWord, '\')
        return secondHalf->substitute(escapedWord, '', '')
    endif

    var sel = GetSelectionColumns()
    return line[sel.end : ]
enddef

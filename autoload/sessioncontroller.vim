vim9script 

import './getconfig.vim'
import './regex/regex.vim'
import './highlightdiff.vim'
import './sessionstore.vim'
import './helpers.vim'

def ResetSessionEndTrigger(): void
    augroup au_vimchase
        autocmd!
    augroup END
enddef

def SetSessionEndTrigger(): void
    augroup au_vimchase
        autocmd!
        autocmd CursorMoved * OnSessionEnd()
    augroup END
enddef

export def OnSessionStart(): void
    sessionstore.initialMode = mode()
    sessionstore.savedIskeyword = &iskeyword
    set iskeyword+=-

    sessionstore.initialWord = helpers.GetSelectedWord()
    sessionstore.initialCursorPos = getcursorcharpos()
    sessionstore.lineBegin = helpers.GetCurrrentLineBegin()
    sessionstore.lineEnd = helpers.GetCurrrentLineEnd()


    sessionstore.isSessionStarted = true
enddef

# NOTE: 'onSessionEnd_callCount' is _dirty_ workaround: 
# every run 'setline' causes 'CursorMoved' event once
# So we need to ignore first CursorMoved autocmd event
var onSessionEnd_callCount = 0
export def OnSessionEnd(): void
    if (onSessionEnd_callCount == 0) 
        onSessionEnd_callCount = 1
        return
    endif
    onSessionEnd_callCount = 0

    &iskeyword = sessionstore.savedIskeyword
    # sessionstore.initialWord = ''
    # sessionstore.initialCursorPos = getcursorcharpos()

    sessionstore.isSessionStarted = false

    if (sessionstore.initialMode == 'n')
        execute "normal! \<Esc>"
    endif

    regex.OnSessionEnd()
    ResetSessionEndTrigger()
enddef

export def OnRunStart(): void
    ResetSessionEndTrigger()
    if (sessionstore.isSessionStarted)
        undojoin
    endif
enddef

export def OnRunEnd(): void
    onSessionEnd_callCount = 0

    # initialCursorPos = [bufnr, line, col, ...]
    setcursorcharpos(sessionstore.initialCursorPos[1 : 2])

    SetSessionEndTrigger()
enddef

vim9script 

import './regex/regex.vim'
import './sessionstore.vim'
import './helpers.vim'
import './getconfig.vim'
import './popup.vim'

var crSaved = maparg('<Enter>', 'n')
def ResetSessionEndTrigger(): void
    augroup au_vimchase
        autocmd!
    augroup END
    exe 'nnoremap <Enter> ' .. crSaved
enddef

def SetSessionEndTrigger(): void
    augroup au_vimchase
        autocmd!
        autocmd CursorMoved,CursorMovedI,InsertEnter * OnSessionEnd()
    augroup END
    nnoremap <Enter> <ScriptCmd>OnSessionEnd()<CR>
enddef

export def OnSessionStart(): void
    sessionstore.initialMode = mode()
    sessionstore.savedIskeyword = &iskeyword
    set iskeyword+=-

    sessionstore.initialWord = helpers.GetSelectedWord()
    sessionstore.currentWord = sessionstore.initialWord
    sessionstore.initialCursorPos = getcursorcharpos()
    sessionstore.lineBegin = helpers.GetCurrrentLineBegin()
    sessionstore.lineEnd = helpers.GetCurrrentLineEnd()

    sessionstore.isSessionStarted = true
enddef

# NOTE: 'onSessionEnd_callCount' is _dirty_ workaround: 
# every run 'setline' causes 'CursorMoved' event once
# So we need to ignore first CursorMoved autocmd event
var onSessionEnd_callCount = 0
def OnSessionEnd(): void
    if (onSessionEnd_callCount == 0) 
        onSessionEnd_callCount = 1
        return
    endif
    popup.HidePopup()
    onSessionEnd_callCount = 0

    &iskeyword = sessionstore.savedIskeyword

    sessionstore.isSessionStarted = false

    sessionstore.parts = []
    sessionstore.group = sessionstore.groups.undefined
    sessionstore.case = {}
    sessionstore.count = 0
    sessionstore.precomputedWords = []

    ResetSessionEndTrigger()
enddef

export def OnRunStart(): void
    ResetSessionEndTrigger()
    if (sessionstore.isSessionStarted)
        # need 'silent!' to supress 'cant undojoin after undo' error message
        silent! undojoin
    endif
enddef

export def OnRunEnd(): void
    onSessionEnd_callCount = 0

    # initialCursorPos = [bufnr, line, col, ...]
    setcursorcharpos(sessionstore.initialCursorPos[1 : 2])

    SetSessionEndTrigger()

    if (sessionstore.initialMode == 'v')
        setpos("'<", [bufnr(), line('.'), sessionstore.lineBegin->strlen() + 1, 0])
        setpos("'>", [bufnr(), line('.'), getline('.')->len() - sessionstore.lineEnd->strlen(), 0])
        if (getconfig.GetConfig('chaseHighlightTimeout') == 0)
            normal! gv
        endif
    endif
enddef

vim9script 

import './getconfig.vim'
import './regex/regex.vim'

var savedIskeyword = &iskeyword
var sessionStarted = 0
var startingMode = 'n'
var highlightTimer = 0

var savedVisualSelection = { 'start': 0, 'end': 0 }
var gvTimer = 0
def GV(): void
    timer_stop(gvTimer)
    gvTimer = 0

    setpos("'<", [0, line('.'), savedVisualSelection.start])
    setpos("'>", [0, line('.'), savedVisualSelection.end])
    normal! gv
enddef
export def SetVisualSelection(selection: dict<number>): void
    savedVisualSelection = selection
enddef

def ResetSessionEndTrigger(): void
    augroup au_vimchase
        autocmd!
    augroup END
enddef

def SetSessionEndTrigger(): void
    augroup au_vimchase
        autocmd!
        autocmd CursorMoved * SessionControllerReset()
    augroup END
enddef

export def SessionControllerStartRun(): bool
    if (sessionStarted)
        undojoin
        highlightdiff#ClearHighlights()
        ResetSessionEndTrigger()
    else # if (!sessionStarted)
        startingMode = mode()
        savedIskeyword = &iskeyword
        set iskeyword+=-
    endif
    var oldSessionStarted = sessionStarted
    sessionStarted = 1
    timer_start(10, (timerId: number) => SetSessionEndTrigger() )
    if (gvTimer > 0)
        GV()
    endif
    return oldSessionStarted
enddef

export def SessionControllerEndRun(): void
    setpos("'<", [0, line('.'), savedVisualSelection.start])
    setpos("'>", [0, line('.'), savedVisualSelection.end])
    setpos(".", [0, line('.'), savedVisualSelection.end])
    var highlightTimeout = getconfig.GetConfig('highlightTimeout')
    highlightTimer = timer_start(highlightTimeout, 'highlightdiff#ClearHighlights')
    if (highlightTimeout > 0)
        gvTimer = timer_start(highlightTimeout, function('GV'))
    else
        GV()
    endif
enddef

def SessionControllerReset(): void
    sessionStarted = 0
    timer_stop(gvTimer)
    gvTimer = 0
    if (startingMode == 'n')
        execute "normal! \<Esc>"
    endif
    highlightdiff#ClearHighlights()
    &iskeyword = savedIskeyword
    regex.OnSessionEnd()
    ResetSessionEndTrigger()
enddef

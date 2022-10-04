let s:savedIskeyword = &iskeyword
let s:sessionStarted = 0
let s:startingMode = 'n'
let s:highlightTimer = 0
let s:savedCursorPosition = 0

let s:savedVisualSelection = { 'start': 0, 'end': 0 }
let s:gvTimer = 0
function! GV(...) abort
    call timer_stop(s:gvTimer)
    let s:gvTimer = 0

    call setpos("'<", [0, line('.'), s:savedVisualSelection.start])
    call setpos("'>", [0, line('.'), s:savedVisualSelection.end])
    normal! gv
endfunc
function! sessioncontroller#SetVisualSelection(selection) abort
    let s:savedVisualSelection = a:selection
endfunction

function! s:ResetSessionEndTrigger() abort
    augroup au_vimcasechange
        autocmd!
    augroup END
endfunction

function! s:SetSessionEndTrigger() abort
    augroup au_vimcasechange
        autocmd!
        autocmd CursorMoved * call sessioncontroller#SessionControllerReset()
    augroup END
endfunction

function! sessioncontroller#SessionControllerStartRun() abort
    if (s:sessionStarted)
        undojoin
        call highlightdiff#ClearHighlights()
        call s:ResetSessionEndTrigger()
    else " if (!s:sessionStarted)
        let s:startingMode = mode()
        let s:savedIskeyword = &iskeyword
        set iskeyword+=-
        let s:savedCursorPosition = getpos('.')
    endif
    let s:sessionStarted = 1
    call timer_start(10, { -> s:SetSessionEndTrigger() })
    if (s:gvTimer)
        call GV()
    endif
endfunction

function! sessioncontroller#SessionControllerEndRun() abort
    call setpos("'<", [0, line('.'), s:savedVisualSelection.start])
    call setpos("'>", [0, line('.'), s:savedVisualSelection.end])
    call setpos(".", [0, line('.'), s:savedVisualSelection.end])
    let s:highlightTimer = timer_start(g:highlightTimeout, 'highlightdiff#ClearHighlights')
    let s:gvTimer = timer_start(g:highlightTimeout, function('GV'))
endfunction

function! sessioncontroller#SessionControllerReset() abort
    let s:sessionStarted = 0
    call timer_stop(s:gvTimer)
    let s:gvTimer = 0
    if (s:startingMode == 'n')
        execute "normal! \<Esc>"
        call setpos('.', s:savedCursorPosition)
    endif
    call highlightdiff#ClearHighlights()
    let &iskeyword = s:savedIskeyword
    call regex#regex#OnSessionEnd()
    call s:ResetSessionEndTrigger()
endfunction

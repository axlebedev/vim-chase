let s:savedIskeyword = &iskeyword
let s:sessionStarted = 0
let s:startingMode = 'n'
let s:highlightTimer = 0

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
    else
        let s:startingMode = mode()
        let s:savedIskeyword = &iskeyword
        set iskeyword+=-
    endif
    let s:sessionStarted = 1
    call timer_start(10, { -> s:SetSessionEndTrigger() })
endfunction

function! sessioncontroller#SessionControllerEndRun() abort
    let s:highlightTimer = timer_start(g:highlightTimeout, 'highlightdiff#ClearHighlights')
endfunction

function! sessioncontroller#SessionControllerReset() abort
    let s:sessionStarted = 0
    if (s:startingMode == 'n')
        execute "normal! \<Esc>"
    endif
    call highlightdiff#ClearHighlights()
    let &iskeyword = s:savedIskeyword
    call regex#regex#OnSessionEnd()
    call s:ResetSessionEndTrigger()
endfunction

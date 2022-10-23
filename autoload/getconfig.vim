function! getconfig#GetConfig(name) abort
    if (exists('b:'.a:name))
        return get(b:, a:name)
    endif

    " Assume that all configs are set at plugin/chase.vim
    return get(g:, a:name)
endfunction


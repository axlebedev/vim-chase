vim9script

export def GetConfig(name: string): any
    if (exists('b:' .. name))
        return get(b:, name)
    endif

    # Assume that all configs are set at plugin/chase.vim
    return get(g:, name)
enddef


vim9script

import './helpers.vim'
import './sessionstore.vim'
import './getconfig.vim'

var GetCharAtPos = helpers.GetCharAtPos

def ResetHighlightEndTrigger(): void
    augroup au_vimchase_highlight
        autocmd!
    augroup END
enddef

def SetHighlightEndTrigger(): void
    augroup au_vimchase_highlight
        autocmd!
        autocmd CursorMoved * ClearHighlights(true)
    augroup END
enddef

var isHighlightsDeclared = false
export def DeclareHighlightGroups(): void
    # highlights may be declared in vim config
    if (!hlexists('ChaseWord'))
        highlight link ChaseWord Pmenu
    endif
    if (!hlexists('ChaseChangedLetter'))
        highlight link ChaseChangedLetter Search
    endif
    if (!hlexists('ChaseSeparator'))
        highlight link ChaseSeparator ChaseChangedLetter
    endif
    isHighlightsDeclared = true
enddef

# Get all not-letter symbol indexes
def GetSeparatorIndexes(word: string): list<number>
    var res = []
    var i = 0
    while (i < word->len())
        if (word->GetCharAtPos(i) !~? '[[:lower:][:digit:][:upper:]]')
            add(res, i)
        endif
        i += 1
    endwhile
    return res
enddef

def GetChangedIndexes(oldWord: string, newWord: string): list<number>
    if (oldWord->len() != newWord->len())
        return []
    endif

    var res = []
    var i = 0
    while (i < oldWord->len())
        var oldChar = oldWord->GetCharAtPos(i)
        var newChar = newWord->GetCharAtPos(i)
        if (oldChar !=# newChar)
            add(res, i)
        endif
        i += 1
    endwhile
    return res
enddef

# leave only letters and numbers
def GetCleanWord(word: string): string
    return word->substitute('\C[^[:lower:][:upper:][:digit:]]', '', 'g')
enddef

# insert separator in old word
def GetDirtyWord(oldWord: string, newWord: string): string
    var dirtyOldWord = copy(oldWord)
    if (newWord->len() > oldWord->len()) 
        var separatorIndexes = GetSeparatorIndexes(newWord)
        var i = 0
        while (i < separatorIndexes->len())
            var separatorIndex = separatorIndexes[i]
            dirtyOldWord = dirtyOldWord[0 : separatorIndex - 1] .. newWord[separatorIndex] .. dirtyOldWord[separatorIndex :]
            i += 1
        endwhile
    endif
    return dirtyOldWord
enddef

def GetIndexesToHighlight(oldWord: string, newWord: string): dict<list<number>>
    if (oldWord->len() > newWord->len())
        var cleanOldWord = GetCleanWord(oldWord)
        return {
            separator: [],
            changedletters: GetChangedIndexes(cleanOldWord, newWord) 
        }
    endif

    var separatorIndexes = GetSeparatorIndexes(newWord)
    if (oldWord->len() == newWord->len())
        return {
            separator: separatorIndexes,
            changedletters: GetChangedIndexes(oldWord, newWord) 
        }
    endif

    return {
        separator: separatorIndexes,
        changedletters: GetChangedIndexes(GetDirtyWord(oldWord, newWord), newWord) 
    }
enddef

var matchIds = []
var clearHighlightsTimerId = 0
var cursorMove_callCount = 0 # same hack as in sessioncontroller, search 'callCount'
export def ClearHighlights(isOnCursorMove = false): void
    if (cursorMove_callCount == 0 && isOnCursorMove)
        cursorMove_callCount += 1
        return
    endif
    cursorMove_callCount = 0

    timer_stop(clearHighlightsTimerId)
    clearHighlightsTimerId = 0
    matchIds->map((index, id) => matchdelete(id))
    matchIds = []
    
    ResetHighlightEndTrigger()
enddef

export def HighlightDiff(oldWord: string, newWord: string): void
    ResetHighlightEndTrigger()
    if (!isHighlightsDeclared)
        DeclareHighlightGroups()
    endif
    ClearHighlights()
    var indexes = GetIndexesToHighlight(oldWord, newWord)

    # Highlight cant override selection color, so leave visual mode if it is
    execute "normal! \<Esc>"

    var curline = line('.')
    var startOfWord = sessionstore.lineBegin->len() + 1
    var endOfWord = startOfWord + newWord->len() - 1
    matchIds->add(matchadd('ChaseWord', '\%' .. curline .. 'l\%>' .. (startOfWord - 1) .. 'c\%<' .. (endOfWord + 1) .. 'c'))
    for i in indexes.changedletters
        var byte = byteidx(newWord, i) + startOfWord
        matchIds->add(matchadd('ChaseChangedLetter', '\%' .. curline .. 'l\%' .. byte .. 'c'))
    endfor
    for i in indexes.separator
        var byte = byteidx(newWord, i) + startOfWord
        matchIds->add(matchadd('ChaseSeparator', '\%' .. curline .. 'l\%' .. byte .. 'c'))
    endfor

    clearHighlightsTimerId = timer_start(
        getconfig.GetConfig('chaseHighlightTimeout'),
        (timerId) => ClearHighlights()
    )
    SetHighlightEndTrigger()
enddef

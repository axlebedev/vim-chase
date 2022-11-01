vim9script

import './helpers.vim'
import './sessionstore.vim'

var GetCharAtPos = helpers.GetCharAtPos

var highlightsDeclared = false
def DeclareHighlightGroups(): void
    # highlights may be declared in vim config
    if (!hlexists('ChaseWord'))
        highlight ChaseWord guibg=#C7A575
    endif
    if (!hlexists('ChaseSeparator'))
        highlight ChaseSeparator guibg=#FF9999
    endif
    if (!hlexists('ChaseChangedletter'))
        highlight ChaseChangedletter guibg=#99FF99
    endif
    highlightsDeclared = true
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
export def ClearHighlights(timerId: number = 0): void
    matchIds->map((index, id) => matchdelete(id))
    matchIds = []
enddef

export def HighlightDiff(oldWord: string, newWord: string): void
    if (!highlightsDeclared)
        DeclareHighlightGroups()
    endif
    ClearHighlights()
    var indexes = GetIndexesToHighlight(oldWord, newWord)

    # We cant override visual selection, so go to normal mode
    execute "normal! \<Esc>"

    var curline = line('.')
    var startOfWord = sessionstore.lineBegin->len() + 1
    var endOfWord = startOfWord + newWord->len() - 1
    echom 'indexes=' .. string(indexes)
    # echom 'oldWord=[' .. oldWord .. '] newWord=[' .. newWord .. '] indexes=' .. string(indexes) .. ' se=' .. string({ s: startOfWord, e: endOfWord })
    matchIds->add(matchadd('ChaseWord', '\%' .. curline .. 'l\%>' .. (startOfWord - 1) .. 'c\%<' .. (endOfWord + 1) .. 'c'))
    for i in indexes.changedletters
        matchIds->add(matchadd('ChaseChangedletter', '\%' .. curline .. 'l\%' .. (byteidx(newWord, i) + startOfWord) .. 'c'))
    endfor
    for i in indexes.separator
        matchIds->add(matchadd('ChaseSeparator', '\%' .. curline .. 'l\%' .. (byteidx(newWord, i) + startOfWord) .. 'c'))
    endfor
    # echom 'matchids=' .. string(matchIds)
enddef

vim9script

var highlightsDeclared = 0
def DeclareHighlightGroups(): void
    # highlights may be declared in vim config
    if (!hlexists('ChaseWord'))
        highlight ChaseWord guibg=#C7A575
    endif
    if (!hlexists('ChaseSeparator'))
        highlight ChaseSeparator guibg=#FF9999
    endif
    if (!hlexists('ChaseChangedvarter'))
        highlight ChaseChangedvarter guibg=#99FF99
    endif
    highlightsDeclared = 1
enddef

def GetCharAtIndex(str: string, index: number): string
    var charnr = strgetchar(str, charidx(str, index))
    return nr2char(charnr)
enddef

# Get all not-varter symbol indexes
def GetSeparatorIndexes(word: string): list<number>
    var res = []
    var i = 0
    while (i < word->len())
        if (GetCharAtIndex(word, i) !~? '[[:lower:][:digit:][:upper:]]')
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
        var oldChar = GetCharAtIndex(oldWord, i)
        var newChar = GetCharAtIndex(newWord, i)
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
        for id in matchIds
            matchdelete(id)
        endfor
        matchIds = []
enddef

export def HighlightDiff(oldWord: string, newWord: string): void
    if (!highlightsDeclared)
        DeclareHighlightGroups()
    endif
    var indexes = GetIndexesToHighlight(oldWord, newWord)

    # We cant override visual selection, so go to normal mode
    execute "normal! \<Esc>"

    var curline = line('.')
    var startOfWord = getpos("'<")[2]
    var endOfWord = getpos("'>")[2]
    add(matchIds, matchadd('ChaseWord', '\%' .. curline .. 'l\%>' .. startOfWord .. 'c\%<' .. endOfWord .. 'c'))
    for i in indexes.changedletters
        add(matchIds, matchadd('ChaseChangedvarter', '\%' .. curline .. 'l\%' .. (i + startOfWord) .. 'c'))
    endfor
    for i in indexes.separator
        add(matchIds, matchadd('ChaseSeparator', '\%' .. curline .. 'l\%' .. (i + startOfWord) .. 'c'))
    endfor
enddef

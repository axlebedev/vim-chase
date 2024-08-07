vim9script

import './sessionstore.vim'
import './highlightdiff.vim'

def PositiveModulus(a: number, b: number): number
    var modulus = a % b
    if (modulus > 0)
        return modulus
    endif
    return (modulus + b) % b
enddef

var popupWinId = 0
export def ShowPopup(curWord: string): void
    popup_close(popupWinId)
    if (sessionstore.precomputedWords->len() == 0)
        return
    endif

    # For correct highlight, with paddings
    var precomputedWordsToShow = sessionstore.precomputedWords
        ->copy()
        ->map((i, word) => ' ' .. word .. ' ') # add paddings, for beautiful popup 

    var maxPrecomputedLen = precomputedWordsToShow->copy()->map((index, word) => word->len())->max() 
    precomputedWordsToShow = precomputedWordsToShow->map((i, word) => {
                var paddedWord = word
                while (maxPrecomputedLen > paddedWord->len())
                    paddedWord = paddedWord .. ' '
                endwhile
                return paddedWord
            }) # add padding-right of spaces, for hightlight

    var popupHeight = sessionstore.precomputedWords->len()
    popupWinId = popup_atcursor(
        precomputedWordsToShow,
        {
            pos: (winheight(winnr()) - winline() >= popupHeight ? 'topleft' : 'botleft'),
            col: screenpos(win_getid(winnr()), line('.'), sessionstore.lineBegin->len()).col,
            zindex: 1000,
            wrap: false,
            highlight: 'ChaseWord',
            moved: [0, 0, 0],
        }
    )

    var dirtyIndex = sessionstore.precomputedWords->index(sessionstore.initialWord)
    var indexInWords = PositiveModulus(
        dirtyIndex + sessionstore.count,
        sessionstore.precomputedWords->len(),
    )
    if (!hlexists('ChaseChangedLetter'))
        highlightdiff.DeclareHighlightGroups()
    endif
    matchaddpos(
        'ChaseChangedLetter',
        [indexInWords + 1],
        1000,
        1991, # random number here
        {window: popupWinId}
    )
enddef

export def HidePopup(): void
    popup_close(popupWinId)
enddef

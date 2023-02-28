vim9script

import './sessionstore.vim'
import './highlightdiff.vim'

var popupWinId = 0
export def ShowPopup(curWord: string): void
    popup_close(popupWinId)

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
    var indexInWords = (
            sessionstore.precomputedWords->index(sessionstore.initialWord) 
            + sessionstore.count
        ) % sessionstore.precomputedWords->len()
    if (!hlexists('ChaseChangedletter'))
        highlightdiff.DeclareHighlightGroups()
    endif
    matchaddpos(
        'ChaseChangedletter',
        [indexInWords + 1],
        1000,
        1991, # random number here
        {window: popupWinId}
    )
enddef

export def HidePopup(): void
    popup_close(popupWinId)
enddef

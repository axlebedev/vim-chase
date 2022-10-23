if exists("g:loaded_casechange") || &cp || v:version < 700
    finish
endif
let g:loaded_casechange = 1


let g:sentenceCasesOrder = get(g:, 'caseChangeSentenceCasesOrder', [
  \ 'dash',
  \ 'snake',
  \ 'camel',
  \ 'camel_abbr',
  \ 'pascal',
  \ 'upper',
  \ 'upper_space',
  \ 'title',
  \ ])

let g:wordCasesOrder = get(g:, 'caseChangeWordCasesOrder', [
  \ 'upper',
  \ 'lower',
  \ 'title',
  \ ])

let g:letterCasesOrder = get(g:, 'caseChangeLetterCasesOrder', [
  \ 'upper',
  \ 'lower',
  \ ])

let g:highlightTimeout = get(g:, 'caseChangeHighlightTimeout', 2000)

if !exists("g:casechange_nomap")
    nnoremap ~ <CMD>call casechange#next()<CR>
    vnoremap ~ <CMD>call casechange#next()<CR>
    vnoremap ! <CMD>call casechange#prev()<CR>
endif

" vim:set ft=vim et sw=4 sts=4:

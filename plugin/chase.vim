if exists("g:loaded_chase") || &cp || v:version < 700
    finish
endif
let g:loaded_chase = 1


let g:sentenceCasesOrder = get(g:, 'chaseSentenceCasesOrder', [
  \ 'dash',
  \ 'snake',
  \ 'camel',
  \ 'camel_abbr',
  \ 'pascal',
  \ 'upper',
  \ 'upper_space',
  \ 'title',
  \ ])

let g:wordCasesOrder = get(g:, 'chaseWordCasesOrder', [
  \ 'upper',
  \ 'lower',
  \ 'title',
  \ ])

let g:letterCasesOrder = get(g:, 'chaseLetterCasesOrder', [
  \ 'upper',
  \ 'lower',
  \ ])

let g:highlightTimeout = get(g:, 'chaseHighlightTimeout', 2000)

if !get(g:, 'chase_nomap', 0)
    nnoremap ~ <CMD>call chase#next()<CR>
    vnoremap ~ <CMD>call chase#next()<CR>
    vnoremap ! <CMD>call chase#prev()<CR>
endif

" vim:set ft=vim et sw=4 sts=4:

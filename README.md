# VIM Plugin: *ch*ange c*ase*
Change case of selected word.
Pure vim9script
TODO: video

### USAGE
Place cursor at target.  
Press `~` (1 or several times).  
To stop plugin work, move cursor or enter insert mode.

### INSTALLATION
Example of installation and setting configs
```
  Plug 'axlebedev/vim-chase'
```

---

### CONFIGURATION
g:chaseSentenceCasesOrder
g:chaseWordCasesOrder
g:chaseLetterCasesOrder
g:chaseHighlightTimeout
g:chaseNomap
g:chaseRespectAbbreviation

<!-- ##### `g:footprintsColor` -->
<!-- Default: `'#3A3A3A'` or `'#C1C1C1'` depending on `&background` setting   -->
<!-- Hex number. Color of the latest change highlight. Used in gui or if `&termguicolors`   -->
<!-- Older highlights will be dimmed to 'Normal' background according to `g:footprintsEasingFunction`.   -->
<!-- `let g:footprintsColor = '#275970'` -->

highlight ChaseWord
highlight ChaseSeparator
highlight ChaseChangedletter
---

### COMMANDS

`:ChaseNext`  
`:ChasePrev`  
`:ChasePrintAllCases`  

---

<!-- ### API -->

---

### NOTES
If you find a bug, or have an improvement suggestion -
please place an issue in this repository.

---

Check out my Vim plugins:   
https://github.com/axlebedev  

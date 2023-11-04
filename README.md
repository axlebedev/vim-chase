TODO: Command to show all available cases
TODO: Commands for functions (?), проверить можно ли выставить маппинги извне плагина
TODO: Command to set to any case
TODO: Setting to respect abbriveations
TODO: Баг, не слетает visual mode после движения курсора, если начали с visual mode
TODO: Баг, не работает undojoin, если начали с visual mode

# VIM Plugin: *ch*ange c*ase*
Change case of selected word.
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
g:sentenceCasesOrder
g:wordCasesOrder
g:letterCasesOrder
g:highlightTimeout
g:chaseNomap

##### `g:footprintsColor`
Default: `'#3A3A3A'` or `'#C1C1C1'` depending on `&background` setting  
Hex number. Color of the latest change highlight. Used in gui or if `&termguicolors`  
Older highlights will be dimmed to 'Normal' background according to `g:footprintsEasingFunction`.  
`let g:footprintsColor = '#275970'`

---

### COMMANDS

`:FootprintsDisable`  
`:FootprintsEnable`  
`:FootprintsToggle`  

  Enable/disable Footprints globally  

---

`:FootprintsBufferDisable`  
`:FootprintsBufferEnable`  
`:FootprintsBufferToggle`  

  Enable/disable Footprints only in current buffer

---

`:FootprintsCurrentLineDisable`  
`:FootprintsCurrentLineEnable`  
`:FootprintsCurrentLineToggle`  

  Enable/disable Footprint highlight for current line

---

### API

##### `footprints#SetColor(hexColor: string)`
Set `g:footprintsColor` and update highlights to new color.  
Note: this change will not be saved to next vim run, use `g:footprintsColor` for persistent change.  
`call footprints#SetColor('#FF0000')`  

##### `footprints#SetTermColor(termColorCode: number)`
Set `g:footprintsTermColor` and update highlights to new color.  
Note: this change will not be saved to next vim run, use `g:footprintsTermColor` for persistent change.  
`call footprints#SetTermColor(200)`  

##### `footprints#SetHistoryDepth(depth: number)`
Set `g:footprintsHistoryDepth` and update highlights to new depth.  
Note: this change will not be saved to next vim run, use `g:footprintsHistoryDepth` for persistent change.  
`call footprints#SetHistoryDepth(200)`  

##### `footprints#Footprints()`
Update footprints in current buffer  
`call footprints#Footprints()`  

##### `footprints#OnBufEnter()`
Update footprints on bufenter or any other case when current window contains some older highlights  
`call footprints#OnBufEnter()`  

##### `footprints#OnCursorMove()`
Update footprints when content was not changed, only update current line highlight  
`call footprints#OnCursorMove()`  

##### `footprints#Disable(forCurrentBuffer: bool)`
##### `footprints#Enable(forCurrentBuffer: bool)`
##### `footprints#Toggle(forCurrentBuffer: bool)`
Disable, enable or toggle footprints.
`forCurrentBuffer == 0` - do it globally  
`forCurrentBuffer == 1` - do only for current buffer  
```
    call footprints#Disable(0)
    call footprints#Enable(1)
    call footprints#Toggle(1)
```

##### `footprints#EnableCurrentLine()`
##### `footprints#DisableCurrentLine()`
##### `footprints#ToggleCurrentLine()`
Disable, enable or toggle footprint on current line.
```
call footprints#DisableCurrentLine()
call footprints#EnableCurrentLine()
call footprints#ToggleCurrentLine()
```

---

### TROUBLESHOOTING
If you use NeoVim, version 0.5+ is required

### NOTES
If you find a bug, or have an improvement suggestion -
please place an issue in this repository.

---

Check out Vim plugins:   
[**vim-gotoline-popup**](https://github.com/axlebedev/vim-gotoline-popup)  
[**vim-find-my-cursor**](https://github.com/axlebedev/vim-find-my-cursor)  

**<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;★</p>**

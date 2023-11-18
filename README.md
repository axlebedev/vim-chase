# VIM Plugin: **ch**ange c**ase**
Change case of selected word.
Pure vim9script

Find current word's case, start from it
Normal mode - for cword, Visual - for selection
undo works fine

TODO: video

### USAGE
Place cursor at target.  
Press `~` (1 or several times).  
(Plugin stops at cursor move or enter insert mode)

Supported cases:
| Case name | Example |
| --------- | ------- |
| `title` | `You Are The Best` |
| `camel` | `youAreTheBest` |
| `lower_dash` | `you-are-the-best` |
| `lower_space` | `you are the best` |
| `lower_underscore` | `you_are_the_best` |
| `pascal` | `YouAreTheBest` |
| `upper_dash` | `YOU-ARE-THE-BEST` |
| `upper_underscore` | `YOU_ARE_THE_BEST` |
| `upper_space` | `YOU ARE THE BEST` |
| `password` | `****************` |

### INSTALLATION
```
  Plug 'axlebedev/vim-chase'
```

### DEFAULT_MAPPINGS
    nnoremap ~ chase.Next()
    vnoremap ~ <CMD>call <SID>chase.Next()<CR>
    nnoremap ! <CMD>call <SID>chase.Prev()<CR>
    vnoremap ! <CMD>call <SID>chase.Prev()<CR>

---

### CONFIGURATION
##### `g:chaseRespectAbbreviation`
Default: `true`
*Bool*.
Only for `title`, `camel` and `pascal` cases.
Define how to deal with abbreviations:  
true: 'sendSMSMessage' => 'SendSMSMessage' => 'Send SMS Message' 
false: 'sendSMSMessage' => 'sendSmsMessage' => 'Send Sms Message' 
`let g:chaseRespectAbbreviation = false`

##### `g:chaseHighlightTimeout`
Default: `2000`
*Number* milliseconds
Time delay. After this highlight will be hidden.
`let g:chaseHighlightTimeout = 700`

##### `g:chaseSentenceCasesOrder`
Default:
```
[
    'camel',
    'pascal',
    'lower_space',
    'lower_dash',
    'lower_underscore',
    'upper_underscore',
    'upper_dash',
    'upper_space',
    'title',
]
```
*list<string>, array of case names*
Order, in which multi-word cases will be passed through, starting from current word's case
If current case is undefined - start from beginning of list
`let g:chaseSentenceCasesOrder = ['upper_underscore', 'camel']`

##### `g:chaseWordCasesOrder`
Default:
```
[
    'upper',
    'lower',
    'title',
]
```
*list<string>, array of case names*
Order, in which single-word cases will be passed through, starting from current word's case
If current case is undefined - start from beginning of list
`let g:chaseWordCasesOrder = ['upper']`

##### `g:chaseLetterCasesOrder`
Default:
```
[
    'upper',
    'lower',
]
```
*list<string>, array of case names*
Order, in which single-letter cases will be passed through, starting from current letter's case
If current case is undefined - start from beginning of list
`let g:chaseLetterCasesOrder = ['upper']`

##### `g:chaseMapDefault`
Default: `true`
*Bool*
Set default mappings - `~` for forward and `!` for backward, visual and normal modes
`let g:chaseNomap = false`

### HIGHLIGHTS
Customize highlight for *chased* word:
`highlight ChaseWord guibg=#532120 guifg=NONE`  
or  
`highlight link ChaseChangedLetter Search`

**ChaseWord**
All *chased* word
Default: same as 'Pmenu' highlight group

**ChaseChangedLetter**
Colors for those letters that were changed
Default: same as 'Search' highlight group

**ChaseSeparator**
Colors for those 'separator' characters of current case
Default: same as 'ChaseChangedLetter' highlight group

### COMMANDS
`:ChaseNext`  
`:ChasePrev`  
Run "chase": change current word's case to next or prev.

---

`:ChasePrintAllCases`  
Print all case names to 'echom'

### FUNCTIONS
First, import source file with these functions:
`import 'chase.vim' as chase`

`chase.Next(options = {})`  
`chase.Prev(options = {})`  
Run "chase": change current word's case to next or prev.

`options` is map, where you can pass any of configuration options only for one run.  
It may include following configuration options:
```
    chaseRespectAbbreviation
    chaseSentenceCasesOrder
    chaseWordCasesOrder
    chaseLetterCasesOrder
    chaseHighlightTimeout
```

Example:
`chase.Next()` - simple run, without any customizations. Use global options
`chase.Next({chaseRespectAbbreviation: false})` - simple run, but all abbreviations will be *chased* as usual word
`chase.Next({chaseWordCasesOrder: ['upper'], chaseSentenceCasesOrder: ['upper_underscore']})` - replace any variable with CONSTANT_CASE

---

`chase.PrintAllCases()`
Print all availble case names.

---

### NOTES
If you find a bug, or have an improvement suggestion -
please place an issue in this repository.

---

Check out my Vim plugins:   
https://github.com/axlebedev  

# VIM Plugin: change word case
```
  Plug 'axlebedev/vim-chase'
```
vim9script  
Change word case, or *chase*: ***ch***ange c***ase***  

Plugin will define current word's case, and chane it starting from current case.

TODO: video

## USAGE
1. Place cursor at word, or visual select text (no multiline selections)
2. Press `~` (one or several times).  

Supported cases:
| Case name | Example |
| --------- | ------- |
| `title` | `Hello Vim World` |
| `camel` | `helloVimWorld` |
| `pascal` | `HelloVimWorld` |
| `lower_dash` | `hello-vim-world` |
| `lower_space` | `hello vim world` |
| `lower_underscore` | `hello_vim_world` |
| `upper_dash` | `HELLO-VIM-WORLD` |
| `upper_underscore` | `HELLO_VIM_WORLD` |
| `upper_space` | `HELLO VIM WORLD` |
| `password` | `*************` |

## DEFAULT_MAPPINGS
Disable default mappings: `g:chaseMapDefault = false`
```
nnoremap ~ <ScriptCmd>chase.Next()<cr>
vnoremap ~ <ScriptCmd>chase.Next()<cr>
nnoremap ! <ScriptCmd>chase.Prev()<cr>
vnoremap ! <ScriptCmd>chase.Prev()<cr>
```

## CONFIGURATION
#### `g:chaseMapDefault`
Is [default mappings](https://github.com/axlebedev/vim-chase/tree/master#default_mappings) been set by default or not.  

*Bool*  
Default: `true`  
`let g:chaseMapDefault = false`

#### `g:chaseHighlightTimeout`
Time to highlight _chase_.  
Set 0 to disable highlight.  

*Number* milliseconds.  
Default: `2000`  
`let g:chaseHighlightTimeout = 700`

#### `g:chaseRespectAbbreviation`
Only for `title`, `camel` and `pascal` cases.  
Define how to deal with abbreviations or uppercased sections:  
<details>
<summary>Example</summary>
Example:  
`g:chaseRespectAbbreviation = true`:  
`'sendSMSMessage' => 'SendSMSMessage' => 'Send SMS Message'`  
`g:chaseRespectAbbreviation = false`:  
`'sendSMSMessage' => 'sendSmsMessage' => 'Send Sms Message'`  
</details>

*Bool*  
Default: `true`  
`let g:chaseRespectAbbreviation = false`

#### `g:chaseLetterCasesOrder`
Order, in which single-letter cases will be passed through, starting from current letter's case
If current case is undefined - start from beginning of list

*list\<string\>*, array of case names  
Default: `['upper', 'lower']`  
`let g:chaseLetterCasesOrder = ['upper']`

#### `g:chaseWordCasesOrder`
Order, in which single-word cases will be passed through, starting from current word's case
If current case is undefined - start from beginning of list

*list\<string\>*, array of case names  
Default: `['upper', 'lower', 'title']`  
`let g:chaseWordCasesOrder = ['upper']`

#### `g:chaseSentenceCasesOrder`
Order, in which multi-word cases will be passed through, starting from current word's case
If current case is undefined - start from beginning of list

*list\<string\>*, array of case names  
<details>
<summary>Default:</summary>
<pre>
<code>
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
</code>
</pre>
</details>

`let g:chaseSentenceCasesOrder = ['upper_underscore', 'camel']`

## COLORS
![vim-chase-highlights](https://github.com/axlebedev/vim-chase/assets/3949614/777ee4a0-20bb-4b4e-b038-4a7919b6f482)
Customize colors for *chased* word:  
`highlight ChaseWord guibg=#532120 guifg=NONE`  
or  
`highlight link ChaseChangedLetter Search`

**ChaseWord**  
Color for whole *chased* word.  
Default: same as 'Pmenu' highlight group

**ChaseChangedLetter**  
Colors for those letters that were changed  
Default: same as 'Search' highlight group

**ChaseSeparator**  
Colors for those 'separator' characters of current case  
Default: same as 'ChaseChangedLetter' highlight group

## COMMANDS
`:ChaseNext`  
`:ChasePrev`  
Run "chase": change current word's case to next or prev.

`:ChasePrintAllCases`  
Print all case names to 'echom'

## FUNCTIONS
```
import 'chase.vim' as chase

chase.Next(options = {})  
chase.Prev(options = {})  
```

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

<details>
<summary>Example</summary>

<code>chase.Next()</code> - simple run, without any customizations. Use global options<br/>  

<code>chase.Next({chaseRespectAbbreviation: false})</code> - simple run, but all abbreviations will be <i>chased</i> as usual word<br/>  

<code>chase.Next({chaseWordCasesOrder: ['upper'], chaseSentenceCasesOrder: ['upper_underscore']})</code> - replace any variable with CONSTANT_CASE<br/>
</details>

---

`chase.PrintAllCases()`
Print all availble case names.

## NOTES
Plugin was originally forked from 'vim-case-change'.  
If you find a bug, want to add new case, or have an improvement suggestion -
please place an issue in this repository.

Check out my Vim plugins:   
https://github.com/axlebedev  

vim9script

export var isSessionStarted = false
export var lineBegin = ''
export var lineEnd = ''
export var initialMode = 'n'
export var initialCursorPos = []
export var savedIskeyword = ''
export var initialWord = ''
export var currentWord = ''

# former regex session store
export var groups = {
    undefined: 'group-undefined',
    letter: 'group-letter',
    word: 'group-word',
    sentence: 'group-sentence',
}

export var parts = []
export var group = groups.undefined
export var case: dict<any> = {}
export var count = 0
export var precomputedWords = []

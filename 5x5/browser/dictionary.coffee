class Dictionary
  constructor: (@originalWordList, grid) ->
    console.log "setting grid with size: #{grid.size}"
    @setGrid grid if grid?

  setGrid: (@grid) ->
    @wordList = @originalWordList.slice 0
    @wordList = (word for word in @wordList when word.length <= @grid.size)
    @minWordLength = Math.min.apply Math, (word.length for word in @wordList)
    @usedWords = []
    for x in [0...@grid.size]
      for y in [0...@grid.size]
        @markUsed word for word in @wordsThroughTile @grid, x, y

  markUsed: (word) ->
    if word in @usedWords
      false
    else
      @usedWords.push word
      true

  isWord: (str) ->
    str in @wordList

  isNewWord: (str) ->
    isWord str and str not in @usedWords

  wordsThroughTile: (x, y) ->
    grid = @grid
    console.log "Finding words through tile in grid with size #{grid.size}"
    console.log "Minimum word length: #{@minWordLength}"
    strings = []
    for length in [@minWordLength..grid.size]
      range = length - 1
      addTiles = (func) ->
        strings.push (func(i) for i in [0..range]).join ''
      for offset in [0...length]
        # vertical
        if grid.inRange(x - offset, y) and grid.inRange(x - offset + range, y)
          addTiles (i) -> grid.tiles[x - offset + i][y]

        # horizontal
        if grid.inRange(x, y - offset) and grid.inRange(x, y - offset + range)
          addTiles (i) -> grid.tiles[x][y - offset + i]

        # diagonal, upper left to down right
        if grid.inRange(x - offset, y - offset) and grid.inRange(x - offset + range,y - offset + range)
          addTiles (i) -> grid.tiles[x - offset + i][y - offset + i]

        # diagonal, lower left to upper right
        if grid.inRange(x - offset, y + offset) and grid.inRange(x - offset + range, y + offset - range)
          addTiles (i) -> grid.tiles[x - offset + i][y + offset - i]
    str for str in strings when @isWord str

root = exports ? window
root.Dictionary = Dictionary

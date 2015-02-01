{Dictionary} = require './dictionary'
{Grid} = require './grid'
{Player} = require './player'
{OWL2} = require './OWL2'

grid = dictionary = currPlayer = player1 = player2 = null

stdin = process.openStdin();
stdin.setEncoding 'utf8'
inputCallback = null
stdin.on 'data', (input) -> inputCallback input

newGame = ->
  grid = new Grid
  dictionary = new Dictionary OWL2, grid
  currPlayer = player1 = new Player 'A', dictionary
  player2 = new Player 'B', dictionary

  console.log 'Welcome to 5x5 Game'
  unless dictionary.usedWords.length is 0
    console.log """
      Initially used words:
      #{dictionary.usedWords.join(',')}
    """
  promptForTile1()

printGrid = ->
  rows = grid.rows()
  rowStrings = (' ' + row.join(' | ') for row in rows)
  rowSeparator = ('-' for i in [1...grid.size * 4]).join('')
  console.log "\n" + rowStrings.join("\n#{rowSeparator}\n") + "\n"

promptForTile1 = ->
  printGrid()
  console.log "#{currPlayer}, Please enter the coordinate for tile 1"
  inputCallback = (input) ->
    try
      {x, y} = strToCoordinates input
    catch e
      console.log e
      return
    promptForTile2 x, y

promptForTile2 = (x1, y1) ->
  console.log "#{currPlayer}, Please enter the coordinate for tile 2"
  inputCallback = (input) ->
    try
      {x: x2, y: y2} = strToCoordinates input
    catch e
      console.log e
      return
    if x1 is x2 and y1 is y2
      console.log 'The second tile must be different from the first'
    else
      console.log "Swapping (#{x1}, #{y1}) with (#{x2}, #{y2})..."
      x1--; x2--; y1--; y2--;
      {moveScore, newWords} = currPlayer.makeMove {x1, y1, x2, y2}
      unless moveScore is 0
        console.log """
          #{currPlayer} formed the following #{newWords.length} word(s)
          #{newWords.join(', ')}
          earning #{moveScore / newWords.length}x#{newWords.length} = #{moveScore} points
        """
      console.log """
        #{currPlayer}'s score after #{currPlayer.moveCount} moves: #{currPlayer.score}
      """
      currPlayer = if currPlayer is player1 then player2 else player1
      promptForTile1()

isInteger = (x) -> x is Math.round x

strToCoordinates = (str) ->
  halves = str.split ','
  if halves.length is 2
    x = parseFloat halves[0]
    y = parseFloat halves[1]
    if !isInteger(x) or !isInteger(y)
      console.log 'Coordinates must be integers'
    else if not grid.inRange(x - 1, y - 1)
      console.log "Coordinates must be between 1 and #{GRID_SIZE}"
    else
      {x, y}
  else
    console.log 'Coordinates must be in the format of x,y'

newGame()
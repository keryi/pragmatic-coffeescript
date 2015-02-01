grid = dictionary = currPlayer = player1 = player2 = selectedCoordinates = null

newGame = ->
  grid = new Grid
  dictionary = new Dictionary OWL2, grid
  currPlayer = player1 = new Player 'Player 1', dictionary
  player2 = new Player 'Player 2', dictionary

  drawTiles()

  player1.num = 1
  player2.num = 2

  for player in [player1, player2]
    $("#p#{player.num}name").html player.name
    $("#p#{player.num}score").html 0
  showMessage 'firstTile'

drawTiles = ->
  gridHtml = ''
  for x in [0...grid.tiles.length]
    gridHtml += '<ul>'
    for y in [0...grid.tiles.length]
      gridHtml += "<li id='tile_#{x}_#{y}'>" + grid.tiles[x][y] + "</li>"
    gridHtml += '</ul>'
  $('#grid').html gridHtml
  $('#grid li').on 'click', tileClick

tileClick = ->
  $tile = $(this)
  if $tile.hasClass 'selected'
    selectedCoordinates = null
    $tile.removeClass 'selected'
    showMessage 'firstTile'
  else
    $tile.addClass 'selected'
    [x, y] = @id.match(/(\d+)_(\d+)/)[1..]
    selectTile x, y

selectTile = (x, y) ->
  if selectedCoordinates is null
    selectedCoordinates = {x1: x, y1: y}
    showMessage 'secondTile'
  else
    selectedCoordinates.x2 = x
    selectedCoordinates.y2 = y
    $('#grid li').removeClass 'selected'
    doMove()

doMove = ->
  {moveScore, newWords} = currPlayer.makeMove selectedCoordinates
  if moveScore is 0
    $notice = $("""
      <p class="notice">#{currPlayer} formed no word in this round."</p>
    """)
  else
    $notice = $("""
    <p class="notice">
      #{currPlayer} has formed the following #{newWords.length} words:</br>
      <b>#{newWords.join(', ')}</b>
      earning <b>#{moveScore / newWords.length} x #{newWords.length} =
      #{moveScore}</b> points
    </p>
    """)
  showThenFade $notice
  endTurn()

showThenFade = ($elem) ->
  $elem.insertAfter '#grid'
  animationTarget = opacity: 0, height: 0, padding: 0
  $elem.delay(5000).animate animationTarget, 500, -> $elem.remove()

endTurn = ->
  drawTiles()
  selectedCoordinates = null
  $("#p#{currPlayer.num}score").html currPlayer.score
  currPlayer = if currPlayer is player1 then player2 else player1
  showMessage 'firstTile'

showMessage = (messageType) ->
  switch messageType
    when 'firstTile'
      messageHtml = "#{currPlayer}, Please select your first tile."
    when 'secondTile'
      messageHtml = "#{currPlayer}, Please select a second tile."
  $('#message').html messageHtml

$(document).ready ->
  newGame()

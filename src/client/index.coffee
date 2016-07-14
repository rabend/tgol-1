property = (name)->(d)->d[name]
zoom = require "./zoom"

parse = (s)->
  cells = []
  right = bottom = 0
  rows = s
    .replace /\|/g, ''
    .split '\n'
  for row,y in rows
    for char,x in row
      cells.push id:[x,y].toString(), x:x, y:y if char == '*'
  livingCells:cells
  left:0
  top:0
  bottom:rows.length
  right: rows[0].length

render = (board)->
  cells = board.livingCells
  svg = d3.select "svg"
  canvas = svg.select "g.canvas"
  {width, height} = svg.node().getBoundingClientRect()
  {scale, translate} = zoom board, 
    left:15
    top:15
    right:width-15
    bottom:height-15
  canvas.attr "transform", "translate(" + translate + ")scale(" + scale + ")"
  canvas.style "stroke-width", 1/scale + "px"
  #canvas.append "circle"
  #  .attr "cx",2
  #  .attr "cy",2
  #  .attr "r",0.1
  #  .style "stroke", "green"
  #canvas.append "circle"
  #  .attr "cx",0
  #  .attr "cy",0
  #  .attr "r",0.1
  cells = canvas
    .selectAll "g.cell"
    .data cells, property "id"

  cells.enter()
    .append "g"
    .classed "cell", true
    .attr "transform", (d)->"translate(#{[d.x,d.y]})"
    .append "rect"
    .attr "x",0.025
    .attr "y",0.025
    .attr "width", 0.95
    .attr "height", 0.95
    .attr "rx", 0.05
    .attr "ry", 0.05
  cells.exit()
    .remove()

registerListeners = ->
  svg = d3.select "svg"
  #svg.on "touchend", ->
  svg.on "click", ->
    p = @createSVGPoint()
    {x:p.x,y:p.y}=d3.event
    click.call this, p
    render board
  svg.on "touchstart",->
    svg.on "click", null
    d3.event.preventDefault()
    for touch in d3.event.changedTouches
      p = @createSVGPoint()
      p.x=touch.clientX
      p.y=touch.clientY
      click.call this, p
    render board

click = (p) ->
  p=p.matrixTransform d3.select(this).select("g.canvas").node().getScreenCTM().inverse()
  cellId = [p.x,p.y].map(Math.floor).toString()
  cellPos =undefined
  for cell,i in board.livingCells when cellId==cell.id
    cellPos = i
    break
  if cellPos?
    board.livingCells.splice cellPos,1
  else
    board.livingCells.push
      id:cellId
      x:Math.floor p.x
      y:Math.floor p.y

kill = (cell,i)->
  board.livingCells.splice i,1
  render board
  
board = parse """
 *|_|_|_|_|
 _|_|*|_|_|
 _|_|_|*|_|
 _|*|*|*|_|
 _|_|_|_|*|
"""

window.onresize = -> render board
render board
registerListeners()

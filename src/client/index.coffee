property = (name)->(d)->d[name]
zoom = require "./zoom"
Board = require "../board"

board = Board """
 *|_|_|_|_|
 _|_|*|_|_|
 _|_|_|*|_|
 _|*|*|*|_|
 _|_|_|_|*|
"""

render = (board)->
  cells = board.livingCells()
  svg = d3.select "svg"
  canvas = svg.select "g.canvas"
  {width, height} = svg.node().getBoundingClientRect()
  bbox = board.bbox()
  extent =
    left:bbox.left-1
    top:bbox.top-1
    right:bbox.right+1
    bottom:bbox.bottom+1
  viewport =
    left:15
    top:15
    right:width-15
    bottom:height-15
  {scale, translate} = zoom extent, viewport

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
    .data cells, (d)->d.toString()

  cells.enter()
    .append "g"
    .classed "cell", true
    .attr "transform", (d)->"translate(#{d})"
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
  panel = d3.select ".panel.bottom"
  panel.on "click", ->
    board = board.next()
    render board
  #svg.on "touchend", ->
  svg.on "click", ->
    p = @createSVGPoint()
    {x:p.x,y:p.y}=d3.event
    click.call this, p
    render board
  svg.on "touchstart",->
    svg.on "click", null
    #d3.event.preventDefault()
    for touch in d3.event.changedTouches
      p = @createSVGPoint()
      p.x=touch.clientX
      p.y=touch.clientY
      click.call this, p
    render board
  

click = (p) ->
  p=p.matrixTransform d3.select(this).select("g.canvas").node().getScreenCTM().inverse()
  [x,y] = [p.x,p.y].map(Math.floor)
  board.toggle x,y

  


window.onresize = -> render board
render board
registerListeners()

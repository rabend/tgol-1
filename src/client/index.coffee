property = (name)->(d)->d[name]
fit = require "./fit-viewport"
Board = require "../board"
Pattern = require "../pattern"

qr = require "qr-image"
d3 = require "d3-selection"
d3Zoom = require "d3-zoom"
zoom = d3Zoom.zoom()
board = Board """
 *|_|_|_|_|
 _|_|*|_|_|
 _|_|_|*|_|
 _|*|*|*|_|
 _|_|_|_|*|
"""
translate = scale = undefined
render = (board)->
  cells = board.livingCells()
  svg = d3.select "svg"
  canvas = svg.select "g.canvas"

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
  d3.select "#save-button"
    .on "click", ->
      name=window.prompt "Wie soll's denn heißen?", "fump?"
      p=new Pattern(board.livingCells()).minimize()
      board = Board p.cells
      d3.select "#pattern-input"
        .append "option"
        .attr "label", name
        .attr "value",p.codes()
      render board
  d3.select "#pattern-input"
    .on "change", ->
      codes = @value.split(",").map (c)->parseInt c
      p=new Pattern codes
      board = Board p.cells
      render board
  svg = d3.select "svg"
  panel = d3.select ".panel.bottom"
  panel.on "click", ->
    board = board.next()
    render board
    zoomToBBox()

  #svg.on "touchend", ->
  svg.on "click.toggle", ->
    p = @createSVGPoint()
    p.x = d3.event.clientX
    p.y = d3.event.clientY
    toggle.call this, p
    render board
  handleTouchEnd = ->
    console.log "end"
    svg.on "touchend.toggle", null
    for touch in d3.event.changedTouches
      p = @createSVGPoint()
      p.x=touch.clientX
      p.y=touch.clientY
      click.call this, p
    render board
  svg.call zoom
  svg.on "touchstart.toggle", ->
    svg.on "click.toggle", null
    svg.on "touchend.toggle", handleTouchEnd
    console.log "add"
  svg.on "touchmove.toggle", ->
    console.log "remove"
    svg.on "touchend.toggle", null

  zoom.on "zoom", ->
    t= d3.event.transform
    canvas = svg.select "g.canvas"
    canvas.attr "transform", t
    canvas.style "stroke-width", 1/t.k + "px"
  
zoomToBBox = ()->
  svg = d3.select "svg"
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
  {scale:k, translate:[x,y]} = fit extent, viewport
  t = d3Zoom.zoomIdentity.translate(x, y).scale(k)
  svg.transition().duration(750).call(zoom.transform,t)

toggle = (p) ->
  p=p.matrixTransform d3.select(this).select("g.canvas").node().getScreenCTM().inverse()
  [x,y] = [p.x,p.y].map(Math.floor)
  board.toggle x,y

  


window.onresize = -> render board
render board
registerListeners()
zoomToBBox()
d3.select "#qr-code"
  .html (qr.imageSync window.location.toString(), type:"svg")

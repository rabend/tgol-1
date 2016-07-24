isArray = require("util").isArray
merge = require "deepmerge"
BBox = require "./bbox"
parseString = (s)->
  cells = []
  rows = s
    .replace /\|/g, ''
    .split '\n'
  for row,y in rows
    for char,x in row
      cells.push [x,y] if char == '*'
  cells

cantorCode = ([x,y]) -> (x+y)*(x+y+1)/2 + y
cantorDecode = (z) ->
  j = Math.floor(Math.sqrt(0.25 + 2*z) - 0.5)
  y = z- j*(j+1)/2
  x = j-y
  [x,y]

class Pattern
  constructor: (input, bbox)->
    throw new Error "you forgot to use 'new', doh!" if not (this instanceof Pattern)
    switch
      when typeof input == "string" then @cells= parseString input
      when isArray input
        if isArray input[0]
          @cells = input
        else if typeof input[0] == "number"
          @cells = input.map cantorDecode
        else throw new Error "input must be either a string, an array of coordinate pairs or an array of Cantor Numbers"
      else throw new Error "bad input"
    if bbox?
      @_bbox= if bbox instanceof BBox then bbox else new BBox bbox



  indexOf: (x,y)->
    return i for cell,i in @cells when cell[0]==x and cell[1]==y
  alive: (x,y)->
    return @indexOf(x,y)?

  asciiArt:(extent={})->
    {left,top,right,bottom} = merge @bbox(), extent

    ( for y in [top...bottom]
        ( for x in [left...right]
            if @alive x,y then '*|' else '_|'
        ).join ''
    ).join '\n'

  bbox: ->@_bbox?=new BBox @cells
  translate: (dx,dy)->
    cells = ([x+dx,y+dy] for [x,y] in @cells)
    bbox = @_bbox?.translate(dx,dy)
    new Pattern cells, bbox
  normalize: ->
    {left,top}=@bbox()
    @translate 0-left, 0-top
  transpose: ()->
    cells = ([y,x] for [x,y] in @cells)
    bbox = @_bbox?.transpose()
    new Pattern cells, bbox
  vflip: ()->
    cells = ([x,-y] for [x,y] in @cells)
    new Pattern cells, @_bbox?.vflip()
  hflip: ()->
    cells = ([-x,y] for [x,y] in @cells)
    new Pattern cells, @_bbox?.hflip()
  codes: ()->
    @_cantorCodes ?= @cells.map(cantorCode).sort (a,b)->a-b
  compareTo: (o)->
    myCodes = @codes().slice().reverse()
    otherCodes = o.codes().slice().reverse()
    for i in [0...Math.max(myCodes.length, otherCodes.length)]
      a=myCodes[i] ? -1
      b=otherCodes[i] ? -1
      return a-b if a!=b
    return 0
  similarPatterns: ->
    [
      a=@normalize()
      a=a.vflip().normalize()
      a=a.transpose().normalize()
      a=a.vflip().normalize()
      a=a.transpose().normalize()
      a=a.vflip().normalize()
      a=a.transpose().normalize()
      a=a.vflip().normalize()
    ]

  minimize: ->
    min = null
    min = a for a in @similarPatterns() when not min? or (a.compareTo(min) < 0)

    min
  clip: (spec)->
    box = new BBox spec
    new Pattern @cells.filter (p)-> box.includes p

  cut: (spec)->
    box = new BBox spec
    new Pattern @cells.filter (p)-> not box.includes p


module.exports= Pattern

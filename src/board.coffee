merge = require "deepmerge"
parseString = (s)->
  cells = []
  rows = s
    .replace /\|/g, ''
    .split '\n'
  for row,y in rows
    for char,x in row
      cells.push [x,y] if char == '*'
  cells

Board = (cells)->
  _livingCells = cells.slice()
  _bbox=null

  initBbox = ()->
    _bbox={}
    addToBbox cell for cell in _livingCells

  addToBbox = (cell)->
    _bbox.left = cell[0] if not _bbox.left? or _bbox.left > cell[0]
    _bbox.right = cell[0] + 1 if not _bbox.right? or _bbox.right < cell[0] + 1
    _bbox.top = cell[1] if not _bbox.top? or _bbox.top > cell[1]
    _bbox.bottom = cell[1] + 1 if not _bbox.bottom? or _bbox.bottom < cell[1] + 1

  bbox = ()->
    initBbox() if not _bbox
    top:_bbox.top
    left:_bbox.left
    bottom:_bbox.bottom
    right:_bbox.right
  livingCells = ()->
    _livingCells.slice()


  indexOf = (x,y)->
    return i for cell,i in _livingCells when cell[0]==x and cell[1]==y
  alive = (x,y)->
    return indexOf(x,y)?

  kill = (i)->
    [x,y] = _livingCells.splice i,1
    if _bbox? and ((not  _bbox.left < x < _bbox.right - 1) or not( _bbox.top < y < _bbox.bottom - 1))
      _bbox = null
  spawn =(x,y)->
    c= [x,y]
    _livingCells.push c
    addToBbox c if _bbox?

  toggle = (x,y)->
    i = indexOf x,y
    if i?
      kill i
    else
      spawn x,y

  asciiArt = (extent={})->
    {left,top,right,bottom} = merge bbox(), extent

    ( for y in [top...bottom]
        ( for x in [left...right]
            if alive x,y then '*|' else '_|'
        ).join ''
    ).join '\n'

  neighbours = ([x,y])-> 
    [
      [x-1,y-1], [x,y-1], [x+1,y-1]
      [x-1,y],            [x+1,y]
      [x-1,y+1], [x,y+1], [x+1,y+1]
    ]
  next = ()->
    counters={}
    live={}
    for cell in _livingCells
      live[cell]=true
      for neighbour in neighbours cell
        if counters[neighbour]?
          counters[neighbour][1]++
        else
          counters[neighbour]=[neighbour,1]
    
    nextCells = (cell for _,[cell,counter] of counters when counter == 3 or live[cell] and 2 <= counter <=3)
    Board nextCells

  livingCells:livingCells
  bbox:bbox
  alive:alive
  toggle:toggle
  asciiArt:asciiArt
  next:next

module.exports= (input)->
  switch
    when typeof input == "string" then Board parseString input
    when typeof input == "object" then Board input
    else throw new Error "bad input"

merge = require "deepmerge"
BBox = require "./bbox"
Pattern = require "./pattern"

Board = (spec)->
  _livingCells = new Pattern(spec).cells
  _bbox=null


  bbox = ()->
    _bbox = new BBox _livingCells if not _bbox
    _bbox.data()
  livingCells = ()->
    _livingCells.slice()


  indexOf = (x,y)-> new Pattern(_livingCells).indexOf(x,y)
  alive = (x,y)->new Pattern(_livingCells).alive(x,y)

  kill = (i)->
    [[x,y]] = _livingCells.splice i,1
    if _bbox?.touches [x,y]
      _bbox = null
  spawn =(x,y)->
    c= [x,y]
    _livingCells.push c
    _bbox?.add c

  toggle = (x,y)->
    i = indexOf x,y
    if i?
      kill i
    else
      spawn x,y

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
  asciiArt: -> 
    p=new Pattern(_livingCells)
    p.asciiArt.apply this,arguments
  next:next

module.exports= Board

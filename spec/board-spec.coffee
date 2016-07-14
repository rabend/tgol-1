describe "The Board", ->
  Board = require "../src/board"
  cell = (x,y)->[x,y]

  it "has a list of living cells and a bounding box", ->
    board = Board """ 
     _|_|_|_|_|
     _|_|*|_|_|
     _|_|_|*|_|
     _|*|*|*|_|
     _|_|_|_|_|
    """
    expect(board.livingCells()).to.eql [
      cell 2,1
      cell 3,2
      cell 1,3
      cell 2,3
      cell 3,3
    ]
    expect(board.bbox()).to.eql
      left:1
      top:1
      right:4
      bottom:4

  it "can check the state of any given cell", ->
    board = Board """ 
     _|_|_|_|_|
     _|_|*|_|_|
     _|_|_|*|_|
     _|*|*|*|_|
     _|_|_|_|_|
    """
    expect(board.alive 2,1 ).to.be.true
    expect(board.alive 3,2 ).to.be.true
    expect(board.alive 4,3 ).to.be.false

  it "can toggle the state of a cell and update its bounding box", ->
    board = Board """ 
     _|_|_|_|_|
     _|_|*|_|_|
     _|_|_|*|_|
     _|*|*|*|_|
     _|_|_|_|_|
    """
    expect(board.bbox()).to.eql
      left:1
      top:1
      right:4
      bottom:4
    board.toggle 2,3
    board.toggle 3,2
    board.toggle 2,2
    expect(board.alive 2,3 ).to.be.false
    expect(board.alive 3,2 ).to.be.false
    expect(board.alive 2,2 ).to.be.true
    expect(board.bbox()).to.eql
      left:1
      top:1
      right:4
      bottom:4
    board.toggle 0,0
    expect(board.alive 0,0).to.be.true
    expect(board.bbox()).to.eql
      left:0
      top:0
      right:4
      bottom:4

    board.toggle 3,3
    expect(board.alive 3,3).to.be.false
    expect(board.bbox()).to.eql
      left:0
      top:0
      right:3
      bottom:4

  it "can represent its state using ascii art",->
    board = Board """ 
     _|_|_|_|_|
     _|_|*|_|_|
     _|_|_|*|_|
     _|*|*|*|_|
     _|_|_|_|_|
    """
    expect( board.asciiArt
      top:0
      left:0
    ).to.eql """
     _|_|_|_|
     _|_|*|_|
     _|_|_|*|
     _|*|*|*|
    """
    expect( board.asciiArt
      right:5
      bottom:5
    ).to.eql """
    _|*|_|_|
    _|_|*|_|
    *|*|*|_|
    _|_|_|_|
    """

  it "can calculate the next generation of cells", ->
    board = Board """ 
     _|_|_|_|
     _|_|*|_|
     _|_|_|*|
     _|*|*|*|
    """
    expect(board.next().asciiArt left:0,top:0).to.eql """
     _|_|_|_|
     _|_|_|_|
     _|*|_|*|
     _|_|*|*|
     _|_|*|_|
    """

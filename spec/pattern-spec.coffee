describe "A Pattern", ->
  
  Pattern = require "../src/pattern"
  cell = (x,y)->[x,y]

  it "complains if constructor is called without the 'new'-keyword", ->
    expect( ->Pattern [] ).to.throw /new/

  it "can be created from and represented as ASCII-art", ->
    p = new Pattern """ 
     _|_|_|_|_|
     _|_|*|_|_|
     _|_|_|*|_|
     _|*|*|*|_|
     _|_|_|_|_|
    """
  
    expect(p.cells).to.eql [
      cell 2,1
      cell 3,2
      cell 1,3
      cell 2,3
      cell 3,3
    ]
    expect(p.bbox().data()).to.eql
      left:1
      top:1
      right:4
      bottom:4
    expect( p.asciiArt()).to.eql """
     _|*|_|
     _|_|*|
     *|*|*|
    """

  it "can be created from an array of Cantor Numbers", ->
    p = new Pattern [1,5,7,8,12]
    expect(p.asciiArt()).to.eql """
     _|*|_|
     _|_|*|
     *|*|*|
    """
  it "is fun" ,->
    p= new Pattern [10...20]
    q= new Pattern [[0,0],[9,0],[0,9],[9,9]]
    console.log p.asciiArt()
    console.log q.codes()
    console.log q.asciiArt()
    pairs = []
    for x in [0..9]
      for y in [0..9]
        pairs.push [x,y]
    codes = (new Pattern pairs).codes()
    console.log codes

      
  it "can be encoded as an array of Cantor Numbers", ->
    p = new Pattern """
     _|*|_|
     _|_|*|
     *|*|*|
    """
    expect(p.codes()).to.eql [1,5,7,8,12]

  it "can produce a transposed copy of itself", ->
    p = new Pattern """
     _|*|_|
     _|_|*|
     *|*|*|
    """
    p.bbox() #force initialization of bbox
    expect(p.transpose().asciiArt()).to.eql """
    _|_|*|
    *|_|*|
    _|*|*|
    """

  it "can produce a vertically flipped copy of itself", ->
    p = new Pattern """ 
     _|_|_|_|_|
     _|_|*|_|_|
     _|_|_|*|_|
     _|*|*|*|_|
     _|_|_|_|_|
    """
    p.bbox() #force initialization of bbox
    expect(p.vflip().asciiArt()).to.eql """
     *|*|*|
     _|_|*|
     _|*|_|
    """
  
  it "can produce a horizontally flipped copy of itself", ->
    p = new Pattern """ 
     _|_|_|_|_|
     _|_|*|_|_|
     _|_|_|*|_|
     _|*|*|*|_|
     _|_|_|_|_|
    """
    p.bbox() #force initialization of bbox
    expect(p.hflip().asciiArt()).to.eql """
     _|*|_|
     *|_|_|
     *|*|*|
    """

  it "can produce a translated copy of itself",->
    p = new Pattern [
      cell -1, 4
      cell 2, -5 
    ]
    p.bbox()
    p=p.translate(1,5)

    expect(p.cells).to.eql [
      cell 0, 9
      cell 3, 0
    ]
    expect(p.bbox().data()).to.eql
      left:0
      top:0
      right:4
      bottom:10
  
  it "can produce a normalized copy of itself",->
    p = new Pattern [
      cell -1, 4
      cell 2, -5 
    ]

    p=p.normalize()

    expect(p.cells).to.eql [
      cell 0, 9
      cell 3, 0
    ]
    expect(p.bbox().data()).to.eql
      left:0
      top:0
      right:4
      bottom:10

  xit "can be compared with other patterns", ->
    a = new Pattern """
    _|*|
    _|_|
    *|_|
    """
    b = new Pattern """
    _|_|*|
    *|_|_|
    """
    
    c = new Pattern """
    *|_|_|
    _|_|*|
    """

    patterns = [a,b,c].sort (a,b)->a.compareTo b
    expect(patterns).to.eql [] 

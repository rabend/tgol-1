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

  it "can be compared with other patterns", ->
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
    expect(patterns).to.eql [b,a,c]

  it "can produce an array of all similar patterns", ->

    a = new Pattern """
    *|*|
    _|_|
    *|_|
    """
    similarPatterns = a.similarPatterns()

    expect(similarPatterns.map (p)->p.asciiArt()).to.eql [
      """
      *|*|
      _|_|
      *|_|
      """
      """
      *|_|
      _|_|
      *|*|
      """

      """
      *|_|*|
      _|_|*|
      """
      """
      _|_|*|
      *|_|*|
      """

      """
      _|*|
      _|_|
      *|*|
      """
      """
      *|*|
      _|_|
      _|*|
      """

      """
      *|_|_|
      *|_|*|
      """
      """
      *|_|*|
      *|_|_|
      """
    ]

  it "can find the minimal similar pattern (as determined by .compareTo)", ->

    a = new Pattern """
    *|*|
    _|_|
    *|_|
    """

    expect(a.minimize().asciiArt()).to.eql """
    *|_|*|
    *|_|_|
    """
  it "can extract a rectangular subpattern of itself", ->
    a = new Pattern """
    _|_|_|_|
    _|*|*|*|
    _|*|_|_|
    _|_|*|_|
    """
    expect(a.clip(left:1,top:1,right:3, bottom:3).asciiArt(left:0,top:0,right:4,bottom:4)).to.eql """
    _|_|_|_|
    _|*|*|_|
    _|*|_|_|
    _|_|_|_|
    """
  
  it "can create a copy of itself with all living cells within a rectangular area removed", ->
    a = new Pattern """
    *|*|*|
    *|*|*|
    *|*|*|
    """
    expect(a.cut(left:0,top:0,right:2, bottom:2).asciiArt(right:3,bottom:3)).to.eql """
    _|_|*|
    _|_|*|
    *|*|*|
    """

  it "can be 'added' to another pattern", ->
    a = new Pattern """
    _|_|_|
    _|*|*|
    _|*|*|
    """
    b = new Pattern """
    *|*|_|
    *|*|_|
    _|_|_|
    """
    expect(a.union(b).asciiArt()).to.eql """
    *|*|_|
    *|*|*|
    _|*|*|
    """


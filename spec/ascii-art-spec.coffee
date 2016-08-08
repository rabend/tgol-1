describe "The ascii-art module", ->
  AsciiArt = require "../src/ascii-art"
  it "can render list of living cells as nice ascii art", ->
    cells = [
      [2,1]
      [3,2]
      [1,3]
      [2,3]
      [3,3]
    ]
    expect( AsciiArt.render(cells, 
      extent:
        left: 0
        top: 0
        bottom: 5
        right: 5
    )).to.eql """
     _|_|_|_|_|
     _|_|*|_|_|
     _|_|_|*|_|
     _|*|*|*|_|
     _|_|_|_|_|
    """

  it "can parse ascii art to a list of living cells", ->
    cells = AsciiArt.parse """
     _|_|_|_|_|
     _|_|*|_|_|
     _|_|_|*|_|
     _|*|*|*|_|
     _|_|_|_|_|
    """
    expect(cells).to.eql [
      [2,1]
      [3,2]
      [1,3]
      [2,3]
      [3,3]
    ]
  it "can render cell colors", ->
    cells = [
      [2,1,0]
      [3,2,1]
      [1,3,0]
      [2,3,1]
      [3,3,0]
    ]
    expect( AsciiArt.render(cells, 
      extent:
        left: 0
        top: 0
        bottom: 5
        right: 5
    )).to.eql """
     _|_|_|_|_|
     _|_|*|_|_|
     _|_|_|o|_|
     _|*|o|*|_|
     _|_|_|_|_|
    """

  it "can parse cell colors", ->
    cells = AsciiArt.parse """
     _|_|_|_|_|
     _|_|*|_|_|
     _|_|_|o|_|
     _|*|o|*|_|
     _|_|_|_|_|
    """,
    parseColors:true

    expect(cells).to.eql [
      [2,1,0]
      [3,2,1]
      [1,3,0]
      [2,3,1]
      [3,3,0]
    ]

describe "A Bounding Box", ->
  BBox = require "../src/bbox"
  p = (x,y)->[x,y]
  
  it "throws an error if constructor is called without the 'new' keyword", ->
    expect( -> BBox [] ).to.throw /new/

  it "can be calculated from an array of points", ->

    bbox = new BBox [
      p 2,1
      p 3,2
      p 1,3
      p 2,3
      p 3,3
    ]
    expect(bbox.data()).to.eql
      left:1
      top:1
      right:4
      bottom:4
      
  it "can grow (but not shrink!) incrementally", ->

    bbox = new BBox [
      p 2,1
      p 3,2
      p 2,3
      p 3,3
    ]
    bbox.add p 1,3
    expect(bbox.data()).to.eql
      left:1
      top:1
      right:4
      bottom:4

  it "can test wether a point is included", ->
    bbox = new BBox [
      p 2,1
      p 3,2
      p 1,3
      p 2,3
      p 3,3
    ]
    expect(bbox.touches [1,2]).to.be.true
    expect(bbox.touches [4,3]).to.be.false
    expect(bbox.touches [2,2]).to.be.false

  it "can test wether a point is on the boundary", ->

    bbox = new BBox [
      p 2,1
      p 3,2
      p 1,3
      p 2,3
      p 3,3
    ]
    expect(bbox.includes [1,2]).to.be.true
    expect(bbox.includes [4,3]).to.be.false
    expect(bbox.includes [2,2]).to.be.true

  it "can produce a copy of its data", ->
    bbox = new BBox [
      p 1,1
      p 2,3
    ]
    expect(bbox.data()).to.eql
      left:1
      top:1
      right:3
      bottom:4

  it "can produce a translated copy of itself",->
    bbox = new BBox [
      p 1,1
      p 2,3
    ]
    expect(bbox.translate(2,3).data()).to.eql
      left:3
      top:4
      right:5
      bottom:7
  it "can produce a transposed copy of itself", ->
    bbox = new BBox [
      p 1,1
      p 2,3
    ]
    expect(bbox.transpose().data()).to.eql
      left:1
      top:1
      right:4
      bottom:3
  it "can produce a vertically flipped copy of itself", ->
    bbox = new BBox [
      p 1,1
      p 2,3
    ]
    expect(bbox.vflip().data()).to.eql
      left:1
      top:-3
      right:3
      bottom:0
  it "can produce a horizontally flipped copy of itself", ->
    bbox = new BBox [
      p 1,1
      p 2,3
    ]
    expect(bbox.hflip().data()).to.eql
      left:-2
      top:1
      right:0
      bottom:4


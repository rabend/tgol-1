AsciiArt = require "./ascii-art"
isArray = require("util").isArray
Promise = require "bluebird"
zlib = require "zlib"
deflate = Promise.promisify zlib.deflate
inflate = Promise.promisify zlib.inflate
module.exports=
  cantorCode: ([x,y]) -> (x+y)*(x+y+1)/2 + y
  cantorDecode: (z) ->
    j = Math.floor(Math.sqrt(0.25 + 2*z) - 0.5)
    y = z- j*(j+1)/2
    x = j-y
    [x,y]
  cells: (input, opts)->
    switch
      when typeof input == "string" and input[1] == '|' then AsciiArt.parse input,opts
      when isArray input
        if input.length==0 or isArray input[0]
          input
        else if typeof input[0] == "number"
          input.map @cantorDecode
        else throw new Error "An array is ok, but it must contain coordinate pairs or Cantor Numbers"
      else throw new Error "Bad input"
  encodeCoordinates: (cells)->
    coords = Array::concat.apply [], cells
    buf = Buffer.from Uint8Array.from coords
    deflate buf
      .then (zbuf)->zbuf.toString "base64"
  decodeCoordinates: (s)->
    buf = new Buffer s, "base64"
    inflate buf
      .then (buf)->
        flatCoords = Uint8Array.from buf
        [flatCoords[2*i],flatCoords[2*i+1]] for i in [0...flatCoords.length/2]

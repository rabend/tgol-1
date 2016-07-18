isArray = require("util").isArray
module.exports = class BBox
  constructor: (spec)->
    throw new Error "you forgot to use 'new', doh!" if not (this instanceof BBox)

    if isArray spec
      @add point for point in spec
    else
      this.left=spec.left
      this.right=spec.right
      this.top=spec.top
      this.bottom=spec.bottom

  left:null
  top:null
  bottom:null
  right:null
  add: ([x,y])->
    @left = x if not @left? or @left > x
    @right = x + 1 if not @right? or @right < x + 1
    @top = y if not @top? or @top > y
    @bottom = y + 1 if not @bottom? or @bottom < y + 1
  touches: ([x,y])->
    y>=@top and y < @bottom and (x==@left or x==@right-1 ) or x>=@left and x < @right and (y==@top or y ==@bottom-1)

  includes: ([x,y])->
    x>=@left and x<@right and y>=@top and y <@bottom
  data: ->
    left:@left
    right:@right
    top:@top
    bottom:@bottom
  translate: (dx,dy)->
    new BBox
      left:@left+dx
      right:@right+dx
      top:@top+dy
      bottom:@bottom+dy
  transpose: ->
    new BBox
      left:@top
      right:@bottom
      top:@left
      bottom:@right
  vflip: ->
    new BBox
      left:@left
      right:@right
      top: 1 - @bottom
      bottom: 1 - @top
  hflip: ->
    new BBox
      left:1 - @right
      right:1 - @left
      top: @top
      bottom: @bottom

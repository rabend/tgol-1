module.exports = ( layer, cells, transforms, selection)->

  # apply zoom transformation to layer
  #target = if d3.event? then layer else layer.interrupt().transition().duration 500

  k = transforms.reduce ((a,b)->a*b.k),1
  transform = transforms.join(" ")
  layer
    .attr "transform", transform
    .style "stroke-width", 1/k + "px"

  # bind living cells
  gCell = layer
    .selectAll "g.cell"
    .data cells, (d)->d.toString()

  # remove dead gCell
  gCell.exit().remove()

  # add new born gCell
  gCellEnter = gCell.enter()
    .append "g"
    .classed "cell", true
    .attr "transform", (d)->
      "translate(#{d})"
  gCellEnter
    .append "rect"
    .attr "x",0.025
    .attr "y",0.025
    .attr "width", 0.95
    .attr "height", 0.95
    .attr "rx", 0.05
    .attr "ry", 0.05
  # update selection state of gCell
  gCellEnter
    .merge gCell
    .classed "selected", (d)->
      if selection?
        [[left,top],[right,bottom]]=selection
        [x,y] = d
        left <= x < right and top <= y < bottom


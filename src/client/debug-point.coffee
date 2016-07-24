
module.exports = (canvas,points=[],cssClass="generic")->
  marker = canvas.selectAll "g.debug.#{cssClass}"
    .data points
  marker.exit().remove()
  newMarker = marker
    .enter()
    .append "g"
    .classed "debug", true
    .classed cssClass, true
  newMarker
    .append "circle"
    .attr "cx",0
    .attr "cy",0
    .attr "r", 1
  newMarker.append "line"
    .attr "x1",0-1
    .attr "y1",0
    .attr "x2",0+1
    .attr "y2",0
  newMarker.append "line"
    .attr "x1",0
    .attr "y1",0-1
    .attr "x2",0
    .attr "y2",0+1
  newMarker
    .merge marker
    .attr "transform", (d)->"translate(#{d})"

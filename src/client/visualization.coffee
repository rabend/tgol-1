Bacon = require "baconjs"
React = require "react"
d3 = require "d3-selection"
d3Zoom = require "d3-zoom"
d3Brush = require "d3-brush"

{div} = require "../react-utils"
fit = require "./fit-viewport"
debugPoint = require "./debug-point"
class Visualiztation extends React.Component
  constructor: (props)->

    @state =
      selection:null

    super props
    zoom = d3Zoom.zoom()
    brush = d3Brush.brush()
    touchSupported = ->
      msTouchEnabled = window.navigator.msMaxTouchPoints
      generalTouchEnabled = 'ontouchstart' of document.createElement('div')
      msTouchEnabled or generalTouchEnabled

    muted = {}
    @mute = (name)->muted[name]=true
    @unmute = (name)->delete muted[name]
    eventStream = (sel, name)->
      Bacon.fromBinder (sink)->
        sel.on name, (d,i,group) ->
          sink d3.event if not muted[name]
        -> sel.on "name",null




    @viewport = ->
      [width,height] = @state.size
      {left,top,bottom,right} = @props.margin
      left: left
      top: top
      right: width-right
      bottom: height-bottom

    @transform = ->
      {scale:k, translate:[x,y]} = fit @props.window, @viewport()
      d3Zoom.zoomIdentity.translate(x,y).scale(k)
    @create = ->

      root = @getDOMNode()
      bus = @props.bus
      svg = d3.select root
        .append "svg"

      mouseCatcher = svg.append "rect"
        .classed "mouse-catcher", true
        .attr "x",0
        .attr "y",0
        .attr "width",1000
        .attr "height",1000
        .style "fill", "yellow"
        .style "opacity", 0
        .style "stroke", "magenta"
        .style "stroke-width", 15
      canvas = svg.append "g"
        .classed "canvas", true

      zoomEvents = eventStream zoom, "zoom.tgol"
        .map (ev)=>
          t=ev.transform
          {top,left,bottom,right} = @viewport()
          worldWindow = {}
          [worldWindow.left,worldWindow.top] = t.invert [left,top]
          [worldWindow.right,worldWindow.bottom] = t.invert [right,bottom]
          worldWindow



      tapEvents = (start, move, end)->
        #a property that is true when start is followed by move
        dragging = move.awaiting start
        #a tap is happens when an end event accurs while not dragging
        end.filter dragging.not()


      unprojectSelectionEvent = (ev)=>
        t = @transform()
        ev.selection?.map (p,i)->t.invert( p).map (c)->Math.round(c)

      brushEvents = eventStream brush, "brush.tgol"
        .map unprojectSelectionEvent

      brushDoneEvents = tapEvents(
        eventStream brush, "start.tgol"
        brushEvents
        eventStream brush, "end.tgol"
      ).map unprojectSelectionEvent

      resizeEvents = eventStream d3.select(window), "resize"
        .map ()->
          {width, height} = svg.node().getBoundingClientRect()
          [width,height]
      toggleEvents = undefined
      if touchSupported()
        touchStart = eventStream svg, "touchstart.tgol"
        touchMove = eventStream svg, "touchmove.tgol"
        touchEnd = eventStream svg, "touchend.tgol"

        toggleEvents = tapEvents touchStart, touchMove,touchEnd
          .flatMap (ev)->
            {top,left}=svg.node().getBoundingClientRect()
            Bacon.fromArray ([touch.clientX-left,touch.clientY-top] for touch in event.changedTouches)
      else
        toggleEvents = eventStream svg, "click.tgol"
          .map (ev)->
            {top,left}=svg.node().getBoundingClientRect()
            [ev.clientX-left,ev.clientY-top]
      toggleEvents = toggleEvents.map (p)=>
        @transform().invert(p).map Math.floor

      bus("toggle").plug toggleEvents
      bus("zoom").plug zoomEvents
      bus("selectionDone").plug brushDoneEvents

      set = (property)->(obj0,value)->

        obj = {}
        obj[k]=v for k,v of obj0
        obj[property]=value
        obj

      identity = (obj)->obj

      Bacon.update(
        @state,
        #[zoomEvents], set "zoomTransform"
        [brushEvents], set "selection"
        [resizeEvents], set "size"
      ).onValue (v)=> @setState v


      {width,height} = svg.node().getBoundingClientRect()
      @setState size: [width,height]
      svg.call zoom

    @update = ->
      root = @getDOMNode()
      svg = d3.select(root).select("svg")
      canvas = svg.select("g.canvas")

      {selection} = @state
      {mode, livingCells} = @props
      zoomTransform = @transform()
      @mute "zoom.tgol"
      svg
        #.transition()
        #.duration 500 
        .call zoom.transform, zoomTransform 
        #.on "end", => @unmute "zoom.tgol"
      @unmute "zoom.tgol"

      # apply zoom transformation to canvas
      #target = if d3.event? then canvas else canvas.interrupt().transition().duration 500
      target=canvas
      target
        .attr "transform", zoomTransform
        .style "stroke-width", 1/zoomTransform.k + "px"

      # bind living cells
      cells = canvas
        .selectAll "g.cell"
        .data livingCells, (d)->d.toString()

      # remove dead cells
      cells.exit().remove()

      # add new born cells
      newCells = cells.enter()
        .append "g"
        .classed "cell", true
        .attr "transform", (d)->
          "translate(#{d})"
      newCells  
        .append "rect"
        .attr "x",0.025
        .attr "y",0.025
        .attr "width", 0.95
        .attr "height", 0.95
        .attr "rx", 0.05
        .attr "ry", 0.05
      # update selection state of cells
      newCells
        .merge cells
        .classed "selected", (d)->
          if selection?
            [[left,top],[right,bottom]]=selection
            [x,y] = d
            left <= x < right and top <= y < bottom

      # manage the selection brush:
      #
      # select all brushes (of course there will be at most one!)
      # and bind to an array containing a single element if there is
      # a selection or none if there is no selection.
      selectionUi = svg
        .selectAll "g.brush"
        .data [1].filter ->mode=="select"

      # create a new selection widget if needed
      selectionUi.enter()
        .append "g"
        .attr "class", "brush"
        .call brush
        .call brush.move, => selection?.map (p,i)=>zoomTransform.apply(p.map (c)->c)
      # remove the widget if it is not used any more
      selectionUi.exit()
        .remove()

      {top:wt,left:wl,bottom:wb,right:wr}= @props.window
      debugPoint canvas, [[wl,wt],[wr,wb]], "window"
      debugPoint canvas, selection, "selection"
  @defaultProps:
    mode:"edit"
    # these are world coordinates, but not necessarily integers.
    # Example:
    # Assuming a matrix of 10x10 cells, if we set bottom to 9.5,
    # only the half of the bottom row will be visible.
    window:
      top:0.0
      left:0.0
      bottom:10.0
      right:10.0
    margin:
      top:15
      left:15
      bottom:15
      right:15
    livingCells:[]

  getDOMNode:->
    require("react-dom").findDOMNode this

  render: ->
    div className:"wrapper"
  componentDidMount: ->
    @create()
  componentDidUpdate: ->
    @update()
  componentWillUnmount: ->
    @destroy()

module.exports = React.createFactory Visualiztation

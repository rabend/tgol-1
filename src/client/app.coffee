{div,factory} = require "../react-utils"
React = require "react"
Visualization = require "./visualization"
Panel = require "./panel"
Dispatcher = require "../dispatcher"
Board = require "../board"
Pattern = require "../pattern"
class App extends React.Component
  constructor: (props)->
    super props
    board = Board """
                  _|_|_|_|_|
                  _|*|*|*|_|
                  _|*|_|_|_|
                  _|_|*|_|_|
                  _|_|_|_|_|
                  """
    @state=
      livingCells: board.livingCells()
      mode:"edit"
      window:
        top:0
        left:0
        bottom:10
        right:10
      selection:null
      pattern:null
      translate: [0,0]
    @bus = Dispatcher()




    commands= (()=>
      play =
        name: "play"
        icon: "play.svg"
        action: =>
          @setState {mode:"play"}, @tick
      back =
        name: "back"
        icon: "back.svg"
        action: => @setState 
          mode:"edit"
          selection:null
          pattern:null
      fit =
        name: "fit"
        icon: "fit.svg"
        action: =>
          @setState window: @board().bbox()

      select=
        name: "select",
        icon: "view-zoom-fit-symbolic.svg"
        action: (ev)=>
          @setState {mode:"select"}
      copy=
        name: "copy"
        icon: "copy.svg"
        action: => 
          [[l,t],[r,b]] = @state.selection
          pattern = new Pattern @livingCells()
            .clip left:l,top:t,right:r,bottom:b
          console.log "selection:",@state.selection.toString()
          console.log "pattern:\n#{pattern.asciiArt(left:0,top:0)}"
          @setState 
            mode: "pattern"
            pattern: pattern.cells
            translate: [0,0]
            selection: null

      edit:[play,select, fit ]
      select:[copy, back]
      pattern:[back]
      play:[back, fit]
    )()

    @tick= =>
      if @state.mode == "play"
        b=@board().next()
        @setState({livingCells:b.livingCells(), window:b.bbox()},=>window.requestAnimationFrame(@tick))

    @board= -> Board @livingCells()
    @topCommands= -> []
    @bottomCommands= ->commands[@state.mode] ? []
    @bus("selectionDone").onValue =>
      @setState mode:"edit"
    @bus("toggle").onValue ([x,y]) =>
      @setState
        livingCells:
          @board()
            .toggle x,y
            .livingCells()
    @bus("zoom").onValue (window)=>
      @setState window:window
    @bus("selection").onValue (selection)=>
      @setState selection:selection
    @bus("drag").onValue (t)=>
      console.log "drag", t
      @setState translate:t
    @bus("drop").onValue (t)=>
      console.log "drop", t
      @setState 
        translate:[0,0]
        pattern: @patternCells t
  livingCells: ->
    @state.livingCells
  patternCells: (tl)->
    if @state.pattern?
      [dx,dy] = tl ? @state.translate
      new Pattern @state.pattern
        .translate dx,dy
        .cells
  render: ->
    (div className:"layout",
      (div id:"top-panel", className:"panel top",
        (Panel bus:@bus, commands: @topCommands())
      )
      (div id:"main-area", className:"main",
        Visualization
          bus:@bus
          livingCells:@livingCells()
          mode:@state.mode
          window:@state.window
          selection:@state.selection
          pattern:@state.pattern
          translate:@state.translate
      )
      (div id:"bottom-panel", className:"panel bottom",
        (Panel bus:@bus, commands: @bottomCommands())
      )
    )

module.exports = React.createFactory App

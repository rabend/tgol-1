{div,factory} = require "../react-utils"
React = require "react"
Visualization = require "./visualization"
Panel = require "./panel"
Dispatcher = require "../dispatcher"
Board = require "../board"
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
        action: => @setState mode:"edit"
      fit =
        name: "fit"
        icon: "fit.svg"
        action: =>
          @setState window: @board().bbox()

      select=
        name: "select",
        icon: "view-zoom-fit-symbolic.svg"
        action: (ev)=>
          @setState mode:"select"
      copy=
        name: "copy"
        icon: "copy.svg"
        action: => @setState mode: "pattern"
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
      console.log "toggle",x,y
      @setState
        livingCells:
          @board()
            .toggle x,y
            .livingCells()
    @bus("zoom").onValue (window)=>
      @setState window:window
  livingCells: ->
    @state.livingCells
  render: ->
    (div className:"layout",
      (div id:"top-panel", className:"panel top",
        (Panel bus:@bus, commands: @topCommands())
      )
      (div id:"main-area", className:"main",
        (Visualization bus:@bus, livingCells:@livingCells(), mode:@state.mode, window:@state.window)
      )
      (div id:"bottom-panel", className:"panel bottom",
        (Panel bus:@bus, commands: @bottomCommands())
      )
    )

module.exports = React.createFactory App

{Component, createFactory, Children} = require "react"
{div, h2} = require "../react-utils"
class App extends Component
  constructor: (props)->
    super props
  render: ->
    div( className:"wrapper",
      @props.children
    )
module.exports =   App

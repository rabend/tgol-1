
{factory,img} = require "../react-utils"
React = require "react"
module.exports = class Command extends React.Component
  render: ->
    {name,icon,action} = @props.command
    bus = @props.bus
    img 
      className: "command" 
      key:name 
      src:"images/#{icon}"
      onClick: (ev)->
        action.call(this,ev) 
        bus(name).push ev

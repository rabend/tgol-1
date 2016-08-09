
{factory,img} = require "../react-utils"
React = require "react"
{Link} =  require "react-router"
Link = factory Link

module.exports = class Command extends React.Component
  render: ->
    {name,icon,action, link} = @props.command
    bus = @props.bus

    image = img
      className: "command"
      key:name
      src:"images/#{icon}"
      onClick: (ev)->
        if action? and bus?
          action.call(this,ev)
          bus(name).push ev
    if link?
      Link(
        to: link()
        image
      )
    else
      image


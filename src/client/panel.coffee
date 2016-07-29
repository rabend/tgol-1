
{div,factory,img} = require "../react-utils"
Command = factory require "./command"
React = require "react"

module.exports = class Panel extends React.Component
  render: ->
    (div className:"commands",
      (Command key:command.name, command:command, bus:@props.bus) for command in @props.commands
    )

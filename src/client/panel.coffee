
{div,factory,img} = require "../react-utils"
Command = require "./command"

module.exports = factory ->
  render: ->
    (div className:"commands",
      (Command key:command.name, command:command, bus:@props.bus) for command in @props.commands
    )


{factory,img} = require "../react-utils"

module.exports = factory ->
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

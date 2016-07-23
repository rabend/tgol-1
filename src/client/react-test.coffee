{factory, render, h1, div, p, ul, li} = require "../react-utils"
Welcome = factory
  render: ()->
    p
      className: @props.className
      "Welcome to this #{@props.attr} party!"
      ul
        li "this..."
        li "is.."
        li "AWESOME!"

App = factory
  render: ()->
    (div
      id:"foo"
      h1
        className:"header"
        "Greetings #{@props.name}!"
      Welcome className:"body", attr:"awesome"
    )
render((App name:"Onkel"), document.getElementById('bottom-panel'))


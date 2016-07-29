
React = require "react"
ReactDOM = require "react-dom"
isArray = require("util").isArray
build = (name)->
  (opts0, children0...)->
    children =children0.slice()

    if isArray( opts0) or( opts0 instanceof React.Component) or React.isValidElement(opts0) or ((typeof opts0) isnt "object")
      children.unshift opts0
      opts=null
    else
      opts=opts0
    
    children=children.map (child)->
      if child instanceof React.Component
        React.createElement child, null
      else
        child
    children.unshift name, opts
    React.createElement.apply React, children


module.exports.factory=React.createFactory 
module.exports.render = ReactDOM.render
module.exports[key] = build key for key of React.DOM


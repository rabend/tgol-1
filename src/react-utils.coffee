
React = require "react"
ReactDOM = require "react-dom"

build = (name)->
  (opts0, children...)->
    if opts0._isReactElement or (typeof opts0) isnt "object"
      opts = null
      children = [opts0].concat children
    else
      opts = opts0
    React.createElement.apply React, [name,opts].concat children


module.exports.factory = (spec)-> 
  spec = spec() if typeof spec is "function"
  if spec instanceof React.Component
    React.createFactory spec
  else
    React.createFactory React.createClass spec

module.exports.render = ReactDOM.render
module.exports[key] = build key for key of React.DOM


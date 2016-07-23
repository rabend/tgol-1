module.exports = ->
  Bacon = require "baconjs"
  busses = {}

  (name)->
    busses[name] ?= new Bacon.Bus

{render} = require "../react-utils"
App = require "./app"
ready = require "document-ready"
ready ->
  render App(), document.getElementById "app-root"

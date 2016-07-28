{render,factory} = require "../react-utils"
App = require "./app"
ready = require "document-ready"
{Router, Route, browserHistory} = require "react-router"
{createFactory} = require "react"
Router =createFactory Router
Route = createFactory Route
ready ->
  render(
    Router(
      history:browserHistory
      Route path:"/", component: App
    )
    document.getElementById "app-root"
  )

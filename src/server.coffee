module.exports = (CGOL_HOME, settings)->
  Promise = require "bluebird"
  http = require "http"
  net = require "net"

  Service = require "../src/service"

  server = undefined

  startServer = ()->
    new Promise (resolve,reject)->
      try
        server = http.createServer Service CGOL_HOME, settings
        server.listen settings.port, settings.host, resolve
      catch e
        reject e

  stopServer = ()->
    new Promise (resolve, reject)->
      try
        server.close resolve
      catch e
        reject e
  start: startServer
  stop: stopServer


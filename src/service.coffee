module.exports = (CGOL_HOME, settings)->
  Express = require "express"
  Repository = require "./repository"
  browserify = require "browserify-middleware"
  coffeeify = require "coffeeify"
  path = require "path"
  repo = Repository CGOL_HOME, settings


  service = Express()

  # client code
  browserify.settings 'extensions', ['.coffee']
  browserify.settings 'transform', [coffeeify]
  browserify.settings 'grep', /\.coffee$|\.js$/
  service.get '/js/client.js', browserify (path.join __dirname, "client","index.coffee")


  # service root
  # TODO: move api routes to a separate module?
  service.get '/api', (req,res)->
    repo.allTournaments()
      .then (tnames)->

          res.json
            version: require("../package.json").version
            tournaments: tnames
  # static assets
  service.use Express.static('static')
  
  service

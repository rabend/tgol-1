module.exports = (CGOL_HOME, settings)->
  Express = require "express"
  Repository = require "./repository"
  browserify = require "browserify-middleware"
  coffeeify = require "coffeeify"
  path = require "path"
  repo = Repository CGOL_HOME, settings
  bodyParser = require "body-parser"
  jsonParser = bodyParser.json()

  packageJson = require "../package.json"
  service = Express()

  # client code
  browserify.settings 'extensions', ['.coffee']
  browserify.settings 'transform', [coffeeify]
  browserify.settings 'grep', /\.coffee$|\.js$/
  # debugging on android does not work if filesize is to big.
  #browserify.settings.development 'debug', false
  #browserify.settings.development 'minify', false
  entry = require.resolve "./client/index"
  shared = [
    'deepmerge'
    'baconjs'
    'd3-brush'
    'd3-selection'
    'd3-zoom'
    'document-ready'
    'qr-image'
    'react'
    'react-dom'
    'react-router'
    'kbpgp'
    'bluebird'
  ]
  service.get '/js/vendor.js', browserify shared,
    debug:false
    minify:true
  service.get '/js/client.js', browserify entry, external:shared


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

  service.get '/api/leaderboard', (req, res)->
    res.json
      data: [
        {name: 'Roman'
        games: 3
        score: 234
        mail: 'romanabendroth@t-online.de'}
        {name: 'Tester1'
        games: 4
        score: 456
        mail: 'service-spec@tarent.de'}
      ]

  service.post '/api/:tournament/patterns',jsonParser, (req, res)->
    pdoc = req.body.pdoc
    try
      repo.savePattern(pdoc,req.params.tournament).then ->
        res.statusCode = 200
        res.sendFile path.resolve __dirname, '..', 'static', 'index.html'
    catch e
      res.statusCode = 901
      res.sendFile path.resolve __dirname, '..', 'static', 'error.html'

      
  service.get '/kiosk/leaderboard', (req, res) ->
    res.sendFile path.resolve __dirname, '..', 'static', 'leaderboard.html'

  # for everything else, just return index.html
  # so client-side routing works smoothly
  service.get '*',  (request, response)->
    response.sendFile path.resolve __dirname, '..', 'static', 'index.html'

  service

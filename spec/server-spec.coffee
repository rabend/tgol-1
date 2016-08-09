
describe "The Service", ->
  Promise = require "bluebird"
  Builder = require "../src/builder"
  Repository = require "../src/repository"

  path = require "path"
  fs = require "fs"
  request = Promise.promisify require "request"
  mkdir = Promise.promisify require "mkdirp"
  rmdir = Promise.promisify require "rimraf"
  writeFile = Promise.promisify fs.writeFile
  readFile = Promise.promisify fs.readFile

  loadYaml = require "../src/load-yaml"
  Server = require "../src/server"
  CGOL_HOME = undefined
  builder = undefined
  repo = undefined
  pdoc = undefined
  property = (name)->(obj)->obj[name]

  example = (gwt)->
    gwt.given = gwt.given ? ->[]
    ()->
      Promise
        .resolve(gwt.given(builder))
        .then ()->
          builder.buildTournaments()
        .then (tournaments)->
          Promise.all (repo.saveTournament tournament for tournament in tournaments)
        .then(gwt.when)
        .then(gwt.then)

  server = undefined
  settings = loadYaml path.resolve __dirname, "../settings.yaml"
  settings.port = 9988

  base = "http://localhost:#{settings.port}"
  beforeEach ->
    builder = Builder()
    CGOL_HOME = tmpFileName @test
    mkdir CGOL_HOME
      .then ->
        repo = Repository CGOL_HOME
        server = Server CGOL_HOME, settings
        server.start()
  afterEach ->
    server
      .stop()
      .then -> rmdir CGOL_HOME

##################################################################################################

  it "reports its own version and a links to all tournaments", example
    given: (a)->
      a.tournament name: 'onkels'
      a.tournament name: 'tanten'
    when: -> request "#{base}/api"
    then: (resp)->
      expect(resp.statusCode).to.eql 200
      expect(JSON.parse resp.body).to.eql
        version: require("../package.json").version
        tournaments: [
          '/onkels'
          '/tanten'
        ]

  it "can persist an uploaded pattern", example
    given: (a)->
      a.tournament name:"TestTournament"
    when: ->
      pdoc=
        name:'MyPattern'
        author:'John Doe'
        mail:'john@tarent.de'
        elo:1000
        base64String:'lkjfazakjds=='
        pin:'12345'
      auth =
        url:base+'/api/TestTournament/patterns'
        method: 'POST'
        json:
          pdoc:
            name:'MyPattern'
            author:'John Doe'
            mail:'john@tarent.de'
            elo:1000
            base64String:'lkjfazakjds=='
            pin:'12345'
      request auth
    then: (resp)->
      expect(resp.statusCode).to.eql 200
      expect(repo.getPatternByBase64ForTournament('lkjfazakjds==', 'TestTournament')).to.be.fulfilled.then (resPdoc)->
        expect(resPdoc).to.be.eql pdoc


  it "can answer if a pattern has already been uploaded to a tournament", example
    given: (a)->
      a.tournament 
        name:"TestTournamentForBaseRecog"
        patterns:[
          pdoc:
            name:'MyPattern'
            author:'John Doe'
            mail:'john@tarent.de'
            elo:1000
            base64String:'lkjfazakjds=='
            pin:'12345'
        ]
      # auth =
      #   url:base+'/api/TestTournament/patterns'
      #   method: 'POST'
      #   json:
      #     pdoc:
      #       name:'MyPattern'
      #       author:'John Doe'
      #       mail:'john@tarent.de'
      #       elo:1000
      #       base64String:'lkjfazakjds=='
      #       pin:'12345'
      # request auth
    when: ->
      request(base+'/api/TestTournament/patterns/lkjfazakjds==')
        .then (resp)->
          expect(resp.statusCode).to.eql 200
          expect(JSON.parse resp.body).to.eql pdoc


  it "can return scores for the matches to be displayed on a leaderboard", ->
    given: (a)->
      a.tournament name:"TestTournament"
    when: ->
      request "#{base}/api/leaderboard"
        .then (resp)->
          expect(resp.statusCode).to.eql 200
          expect(JSON.parse resp.body).to.be.an('object')
          expect(JSON.parse resp.body).to.have.property('data')
          expect(JSON.parse resp.body).has.a.property('data').which.is.an('array')
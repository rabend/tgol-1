module.exports = (CGOL_HOME, settings)->
  Express = require "express"
  Repository = require "./repository"
  repo = Repository CGOL_HOME, settings


  service = Express()
  service.get '/', (req,res)->
    repo.allTournaments()
      .then (tnames)->

          res.json
            version: require("../package.json").version
            tournaments: tnames
  service

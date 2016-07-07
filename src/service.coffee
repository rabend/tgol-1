module.exports = (CGOL_HOME, settings)->
  Express = require "express"

  service = Express()
  service.get '/', (req,res)->
    res.json
      version: require("../package.json").version
  service

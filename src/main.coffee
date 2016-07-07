fs = require "fs"
path = require "path"
merge = require "deepmerge"
loadYaml = require "./load-yaml"
settings = loadYaml (path.resolve __dirname, "../settings.yaml")
TGOL_HOME = process.argv[2] ? process.env.TGOL_HOME ? process.cwd()

configFile = if TGOL_HOME? then path.resolve TGOL_HOME, 'settings.yaml'
if TGOL_HOME? and (fs.existsSync configFile) and (fs.statSync configFile).isFile()
  settings = merge settings, loadYaml configFile


Server = require "./server"
Server(TGOL_HOME, settings).start().done ->
  console.error "server listening on port #{settings.port}"

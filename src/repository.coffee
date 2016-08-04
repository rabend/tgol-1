module.exports = (CGOL_HOME, settings)->
  Promise = require "bluebird"
  path = require "path"
  fs = require "fs"
  mkdir = Promise.promisify require "mkdirp"
  rmdir = Promise.promisify require "rimraf"
  readdir = Promise.promisify require "readdirp"
  writeFile = Promise.promisify fs.writeFile
  readFile = Promise.promisify fs.readFile
  dump = require("js-yaml").dump
  loadYaml = require "load-yaml"

  savePattern = (pdoc)->
    tdir = path.join CGOL_HOME,pdoc.tournament
    pdir = path.join tdir, 'patterns'
    pfile = path.join pdir, pdoc.name+".yaml"
    writeFile pfile, dump pdoc
    
  saveMatch = (mdoc)->
    tdir = path.join CGOL_HOME,mdoc.tournament
    mdir = path.join tdir, 'matches'
    mfile = path.join mdir, mdoc.name+".yaml"
    writeFile mfile, dump mdoc
 

  saveTournament = (tdoc)->
    tdir = path.join CGOL_HOME,tdoc.name
    metafile = path.join tdir, 'meta.yaml'
    matchdir = path.join tdir, 'matches'
    patterndir = path.join tdir, 'patterns'

    mkdir tdir
      .then -> mkdir matchdir
      .then -> mkdir patterndir
      .then -> writeFile metafile, dump
        name:tdoc.name
        pin: tdoc.pin
      .then ->
        Promise.all (savePattern pattern for pattern in tdoc.patterns)
      .then ->
        Promise.all (saveMatch match for match in tdoc.matches)


  allTournaments = ->
    readdir root: CGOL_HOME, depth: 0,entryType: 'directories'
      .then (entries)->
        entries.directories
          .map (entry)->"/"+entry.name
          .sort()

  getTwoPatternsForELO = (elo, tournamentName)->
    tdir = path.join CGOL_HOME, tournamentName
    pdir = path.join tdir, 'patterns'
    allPatterns = readdir root:pdir, depth:0, entryType:'files'
      .then(entries)->
        entries.files
          .map(file)->loadYaml(file)
    #TODO: pass array of patterns to matchmaker and receive patterns[2] back, then return to caller


  allTournaments: allTournaments
  saveTournament: saveTournament

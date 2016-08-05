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

  savePattern = (pdoc, tournamentName)->
    tdir = path.join CGOL_HOME, tournamentName
    pdir = path.join tdir, 'patterns'
    pfile = path.join pdir, pdoc.mail+".yaml"
    isMailAlreadyInUse(pdoc.mail).then (val)->
      if val
        throw new Error('Mail already in use!')
      else
        writeFile pfile, dump 
          name:pdoc.name
          author:pdoc.author
          mail:pdoc.mail
          elo:pdoc.elo
          base64String:pdoc.base64String
          pin:pdoc.pin
    
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
        Promise.all (savePattern pattern,tdoc.name for pattern in tdoc.patterns)
      .then ->
        Promise.all (saveMatch match for match in tdoc.matches)


  allTournaments = ->
    readdir root: CGOL_HOME, depth: 0,entryType: 'directories'
      .then (entries)->
        entries.directories
          .map (entry)->"/"+entry.name
          .sort()
  
  
  isMailAlreadyInUse = (mail)->
    readdir root:CGOL_HOME, entryType: 'files'
    .then (entryStream)->
      files = entryStream.files
        .map (entry)->entry.name
      mail+'.yaml' in files


  allTournaments: allTournaments
  saveTournament: saveTournament
  savePattern: savePattern
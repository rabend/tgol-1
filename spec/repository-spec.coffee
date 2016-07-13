describe "The Repository",->
  loadYaml = require "../src/load-yaml"
  Builder = require "../src/builder"
  Repository = require "../src/repository"
  Promise = require "bluebird"
  path = require "path"
  fs = require "fs"
  mkdir = Promise.promisify require "mkdirp"
  rmdir = Promise.promisify require "rimraf"
  writeFile = Promise.promisify fs.writeFile
  readFile = Promise.promisify fs.readFile
  stringify = require("js-yaml").dump
  builder = undefined
  repository = undefined
  CGOL_HOME = undefined
  b=undefined

  beforeEach ->
    b = Builder()
    CGOL_HOME = tmpFileName @test
    mkdir CGOL_HOME
      .then ->
        repository = Repository CGOL_HOME
  afterEach ->
    rmdir CGOL_HOME

  it "can persist tournament data in a filesystem directory", ->
    tdoc = b.tournament
      name:"onkels"
      patterns: [
        "p1"
        "p2"
        "p3"
      ]
      matches: [
        "m1"
        "m2"
        "m3"
        "m4"
      ]
    expect(repository.saveTournament(tdoc)).to.be.fulfilled.then ->
      tdir = path.join CGOL_HOME,tdoc.name
      metafile = path.join tdir, 'meta.yaml'
      matchdir = path.join tdir, 'matches'
      patterndir = path.join tdir, 'patterns'
      expect(loadYaml metafile).to.eql
        name:tdoc.name
        pin:tdoc.pin

      expect(loadYaml path.join patterndir, pdoc.name+".yaml").to.eql pdoc for pdoc in tdoc.patterns
      expect(loadYaml path.join matchdir, mdoc.name+".yaml").to.eql mdoc for mdoc in tdoc.matches

  it "can list the names of all tournaments", ->
    expect(Promise.all [
      mkdir path.join CGOL_HOME,"t1"
      mkdir path.join CGOL_HOME,"t2"
      mkdir path.join CGOL_HOME,"t3"
    ]).to.be.fulfilled.then ->
      expect(repository.allTournaments()).to.eventually.eql ['/t1','/t2','/t3']

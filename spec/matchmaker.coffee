describe "The Matchmaker", ->
mkdir = Promise.promisify require "mkdirp"
Promise = require "bluebird"
Matchmaker = require "../src/matchmaker"
matcher = undefined
Repository = require "../src/repository"
repo = undefined

  beforeEach ->
    matcher = Matchmaker()
    CGOL_HOME = tmpFileName @test
    mkdir CGOL_HOME
      .then ->
        repo = Repository CGOL_HOME
  it "can select two equally strong patterns from an array", ->
    
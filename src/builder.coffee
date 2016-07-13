module.exports = ->
  tournaments = []
  patterns = []
  matches = []
  toArray = (args)->
    Array::slice.call args
  flatten = (args)->
    Array::concat.apply [],args

  spec2obj = (spec, pk='name')->
    return spec if typeof spec == "object"
    "#{pk}":spec


  merge = ()->
    args = flatten arguments
    defaults = spec2obj args[0]
    doc = {}
    for spec in args
      overrides = spec2obj spec
      doc[key] = overrides[key] for key of defaults when overrides[key]?
    doc

  match = ()->
    defaults=
      id:"match_"+matches.length
      tournament:"tournament_"+tournaments.length-1
      pin:'t0ps3cr3t'
    doc = merge defaults, toArray arguments
    patterns.push doc
    doc
  pattern = ()->
    defaults=
      name:"pattern_"+patterns.length
      tournament:"tournament_"+tournaments.length-1
      pin:'t0ps3cr3t'
    doc = merge defaults, toArray arguments
    patterns.push doc
    doc
  tournament = ()->
    defaults=
      name:"tournament_"+tournaments.length
      pin:'t0ps3cr3t'
      patterns:[]
      matches:[]
    doc = merge defaults, toArray arguments
    tournaments.push doc
    doc.patterns = (pattern spec, tournament:doc.name for spec in doc.patterns)
    doc.matches = (match spec, tournament:doc.name for spec in doc.patterns)
    doc

  pattern:pattern
  tournament:tournament
  match:match
  buildTournaments: ->tournaments

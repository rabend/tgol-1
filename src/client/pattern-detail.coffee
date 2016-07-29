React = require "react"
Pattern = require "../pattern"
{h1,div,factory,input, button} = require "../react-utils"
kbpgp = require "kbpgp"
Promise = require "bluebird"

generate_rsa = Promise.promisify (options, callback)->
  kbpgp.KeyManager.generate_rsa options, callback
export_pgp_private = Promise.promisify (keyman, options, callback)->
  keyman.export_pgp_private options, callback
export_pgp_public = Promise.promisify (keyman, options, callback)->
  keyman.export_pgp_public options, callback
sign = Promise.promisify (keyman, options, callback)->
  keyman.sign options, (err)->callback err, keyman
options =
  userid: "John Doe <john.doe@tarent.de>"
  #primary:
  #  nbits: 4096
  #  flags: F.certify_keys | F.sign_data | F.auth | F.encrypt_comm | F.encrypt_storage
  #  expire_in : 0
johnP = generate_rsa options
  .then (john)-> sign john, {}

Visualization = factory require "./visualization"
module.exports = class PatternDetail extends React.Component
  constructor: (props)->
    super props

    @state = {}
  updatePattern: ->

    Promise
      .all([
        johnP.then (john)-> export_pgp_public john, {}
        johnP.then (john)-> export_pgp_private john, {}
        Pattern.decode @props.params.spec
      ])
      .then ([pub,priv,pattern])=>
        console.log "pub", pub
        console.log "priv", priv
        @setState
          pattern:pattern
          pubkey:pub

  componentWillReceiveProps: (newProps)-> 
    @updatePattern() if newProps.params.spec != @props.params.spec
  componentDidMount: -> @updatePattern()
  render: ->
    div(
      h1 "well..."
      Visualization
        livingCells:@state.pattern?.cells
        window:@state.pattern?.bbox()
      div 
        className: "field-group"
        input type:"text", placeholder:"Name"
        input type:"text", placeholder:"Author"
        button 
          value:"claim!"
          "Upload your claim!"
      div
        className: "pubkey"
        @state.pubkey
    )

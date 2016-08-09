React = require "react"
qr = require "qr-image"
Pattern = require "../pattern"
{h1,div,factory,input, button, span, img} = require "../react-utils"
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
#johnP = generate_rsa options
#  .then (john)-> sign john, {}

Visualization = factory require "./visualization"
module.exports = class PatternDetail extends React.Component
  constructor: (props)->
    super props

    @state = {}
  #updatePattern: ->

  #  Promise
  #    .all([
  #      johnP.then (john)-> export_pgp_public john, {}
  #      johnP.then (john)-> export_pgp_private john, {}
  #      Pattern.decode @props.params.spec
  #    ])
  #    .then ([pub,priv,pattern])=>
  #      console.log "pub", pub
  #      console.log "priv", priv
  #      @setState
  #        pattern:pattern
  #        pubkey:pub

  #componentWillReceiveProps: (newProps)-> 
  #  @updatePattern() if newProps.params.spec != @props.params.spec
  #componentDidMount: -> @updatePattern()
  render: ->
    pattern = new Pattern @props.params.spec
  
    labelValue = (label, value)->
      div
        className: "label-value"
        span
          className: "label"
          label
        span
          className: "value"
          value
    div(
      h1 "Pattern Details"
      Visualization
        livingCells:pattern.cells
        window:pattern.bbox()
      img
        className: "qr-code"
        src:"data:image/png;base64," + qr.imageSync( window.location.toString(), type:"png").toString("base64")
      div 
        className: "field-group"
        input type:"text", placeholder:"Name"
        input type:"text", placeholder:"Author"
        labelValue "Status:", "unknown"
        labelValue "Cells:", pattern.cells.length
        labelValue "Dimensions:", pattern.bbox().width()+" x "+pattern.bbox().height()
        button 
          value:"claim!"
          "Upload your claim!"
    )

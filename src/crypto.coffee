Promise = require "bluebird"
kbpgp = require "kbpgp"
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
import_from_armored_pgp = Promise.promisify (opts,callback)->
  kbpgp.KeyManager.import_from_armored_pgp opts,callback


keypair = (keyman)->
       userId: ->  keyman.userids[0].userid.toString()

module.exports.load = (storage=localStorage)->
  privkey = storage.getItem 'id.priv'
  import_from_armored_pgp armored:privkey
    .then keypair


module.exports.create = (userId, storage)->
  asp = new kbpgp.ASP
    progress_hook: (o)-> #console.log "progress",o
  opts=
    #asp: asp
    userid:userId
    nbits: 1024
  generate_rsa opts
    .then (keyman)-> sign keyman, {}
    .then (keyman)->
      export_pgp_private keyman, {}
        .then (privkey)->
          storage.setItem 'id.priv', privkey
          keyman
    .then keypair

module.exports.exists = (storage)->
  storage.getItem('id.priv')?
  

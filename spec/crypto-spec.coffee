fs = require "fs"
Storage = require "dom-storage"
crypto = require "../src/crypto"
Promise = require "bluebird"
describe "The crypto-Module", ->
  pubkey = fs.readFileSync require.resolve "./pubkey.txt" 
  privkey = fs.readFileSync require.resolve "./privkey.txt" 
  userid = "John Doe <john.doe@tarent.de>"
  localStorage = null
  beforeEach ->
    localStorage =  new Storage(null, { strict: true })
  it "can load a keypair from domstorage", ->
    localStorage.setItem 'id.priv', privkey
    expect(crypto.load(localStorage)).to.be.fulfilled.then (keypair)->
      expect(keypair.userId()).to.eql userid

  #disabled because it takes very long
  xit "can create a keypair and save it in dom storage", ->
    @timeout(60000)
    console.log "creating keypair. This takes bloody ages, sorry. :-("
    expect(crypto.create userid, localStorage).to.be.fulfilled.then (keypair)->
      expect(keypair.userId()).to.eql userid
      expect(localStorage.getItem('id.priv').split('\n')[0]).to.eql '-----BEGIN PGP PRIVATE KEY BLOCK-----'
      expect(localStorage.getItem('id.priv')).to.not.eql privkey #... because we expect a *new* key

    
  it "can tell you whether a keypair is stored in dom storage", ->
    expect(crypto.exists(localStorage)).to.be.false
    localStorage.setItem 'id.priv', privkey
    expect(crypto.exists(localStorage)).to.be.true

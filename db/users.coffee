db = require './'
tools = require '../tools'

client = db.client

class User

  constructor: ({
    @id
    @email
    @firstname
    @lastname
    @room
    @password
    @status
    @hash
  }) ->

  persist: (cb) ->
    #TODO use async and logger in this class
    client.hdel "users:#{@id}", 'hash'
    client.del "hashes:#{@hash}:uid"
    return client.hmset "users:#{@id}",
      status: 'registred'
    , cb

  getBids: (cb) ->

  getAsks: (cb) ->

  isRegistred: ->
    return @status is 'registred'

  isUnconfirmed: ->
    return @status is 'unconfirmed'

  hasPassword: (password) ->
    return @password is tools.sole password

  @create: ({
    email
    firstname
    lastname
    room
    password
  }, cb) ->
    return client.incr 'users:next', (err, uid) ->
      return cb err, null if err
      hash = tools.hash email
      solePassword = tools.sole password
      userConfig =
        id: uid + ''
        email: email
        firstname: firstname
        lastname: lastname
        room: room
        password: solePassword
        status: 'unconfirmed'
        hash: hash
      client.set "hashes:#{hash}:uid", uid
      client.set "emails:#{email}:uid", uid
      client.hmset "users:#{uid}", userConfig
      user = new User userConfig
      return cb null, user

  @findByEmail: (email, cb) ->
    return client.get "emails:#{email}:uid", (err, uid) ->
      return cb err, null if err or not uid
      return db.users.findById uid, cb

  @findByHash: (hash, cb) ->
    return client.get "hashes:#{hash}:uid", (err, uid) ->
      return cb err, null if err or not uid
      return db.users.findById uid, cb

  @findById: (uid, cb) ->
    return client.hgetall "users:#{uid}", (err, userConfig) ->
      return cb err, null if err or not userConfig
      user = new User userConfig
      return cb null, user

module.exports = User

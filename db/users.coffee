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
    return client.hset "users:#{@id}", 'status', 'registred', cb

  forgotPassword: (cb) ->
    hash = tools.hash @email, Date.now()
    #TODO make hashes temporary and clean on expire
    client.set "restores:#{hash}:uid", @id, (err) ->
      return cb err, hash

  restorePassword: ({hash, password}, cb) ->
    @password = tools.hash password
    client.del "restores:#{hash}:uid"
    return client.hset "users:#{@id}", 'password', @password, cb

  getBids: (cb) ->

  getAsks: (cb) ->

  isRegistred: ->
    return @status is 'registred'

  isUnconfirmed: ->
    return @status is 'unconfirmed'

  hasPassword: (password) ->
    return @password is tools.hash password

  @create: ({
    email
    firstname
    lastname
    room
    password
  }, cb) ->
    return client.incr 'users:next', (err, uid) ->
      return cb err, null if err
      hash = tools.hash email, Date.now()
      solePassword = tools.hash password
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

  @findByRestore: (hash, cb) ->
    return client.get "restores:#{hash}:uid", (err, uid) ->
      return cb err, null if err
      return db.users.findById uid, cb

module.exports = User

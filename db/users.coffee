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
    #TODO use generators + bluebird and logger in this class
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
  
  placeBid: (bid, cb) ->
    db.bids.create @id, bid, cb
    
  placeAsk: (bid, cb) ->

  getBids: (cb) ->
    client.smembers "users:#{@id}:bids", (err, bidIds) ->
      console.log bidIds

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
    return client.incr 'users:next', (err, userId) ->
      return cb err, null if err
      hash = tools.hash email, Date.now()
      solePassword = tools.hash password
      userConfig =
        id: userId + ''
        email: email
        firstname: firstname
        lastname: lastname
        room: room
        password: solePassword
        status: 'unconfirmed'
        hash: hash
      client.set "hashes:#{hash}:uid", userId
      client.set "emails:#{email}:uid", userId
      client.hmset "users:#{userId}", userConfig
      user = new User userConfig
      return cb null, user

  @findByEmail: (email, cb) ->
    return client.get "emails:#{email}:uid", (err, userId) ->
      return cb err, null if err or not userId
      return db.users.findById userId, cb

  @findByHash: (hash, cb) ->
    return client.get "hashes:#{hash}:uid", (err, userId) ->
      return cb err, null if err or not userId
      return db.users.findById userId, cb

  @findById: (userId, cb) ->
    return client.hgetall "users:#{userId}", (err, userConfig) ->
      return cb err, null if err or not userConfig
      user = new User userConfig
      return cb null, user

  @findByRestore: (hash, cb) ->
    return client.get "restores:#{hash}:uid", (err, userId) ->
      return cb err, null if err
      return db.users.findById userId, cb

module.exports = User

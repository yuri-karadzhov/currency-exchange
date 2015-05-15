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

  persist: tools.wrap ->
    console.log @id
    client.hdel "users:#{@id}", 'hash'
    client.del "hashes:#{@hash}:uid"
    return yield client.hset "users:#{@id}", 'status', 'registred'

  forgotPassword: ->
    #FIXME this is realy ugly
    user = @
    tools.wrap ->
      console.log 'weeeeeeeeee', @email, user.email
      hash = tools.hash @email, Date.now()
      #TODO make hashes temporary and clean on expire
      yield client.set "restores:#{hash}:uid", @id
      return hash

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

  @create: tools.wrap ({
    email
    firstname
    lastname
    room
    password
  }) ->
    userId = yield client.incr 'users:next'
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
    return new User userConfig

  @findByEmail: tools.wrap (email) ->
    userId = yield client.get "emails:#{email}:uid"
    return null unless userId
    return db.users.findById userId

  @findByHash: tools.wrap (hash) ->
    userId = yield client.get "hashes:#{hash}:uid"
    return null unless userId
    return db.users.findById userId

  @findById: tools.wrap (userId) ->
    userConfig = yield client.hgetall "users:#{userId}"
    user = new User userConfig
    return user

  @findByRestore: (hash, cb) ->
    return client.get "restores:#{hash}:uid", (err, userId) ->
      return cb err, null if err
      return db.users.findById userId, cb

module.exports = User

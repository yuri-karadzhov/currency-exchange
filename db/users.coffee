Promise = require 'bluebird'

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

  persist: Promise.coroutine ->
    client.hdel "users:#{@id}", 'hash'
    client.del "hashes:#{@hash}:uid"
    return yield client.hset "users:#{@id}", 'status', 'registred'

  forgotPassword: Promise.coroutine ->
    hash = tools.hash @email, Date.now()
    #TODO make hashes temporary and clean on expire
    yield client.set "restores:#{hash}:uid", @id
    return hash

  restorePassword: Promise.coroutine ({hash, password}) ->
    @password = tools.hash password
    client.del "restores:#{hash}:uid"
    return yield client.hset "users:#{@id}", 'password', @password

  placeBid: (bid) ->
    db.bids.create @id, bid

  placeAsk: (bid) ->

  getBids: Promise.coroutine ->
    bidIds = yield client.smembers "users:#{@id}:bids"
    return yield Promise.all bidIds.map db.bids.findById

  getAsks: ->

  isRegistred: ->
    return @status is 'registred'

  isUnconfirmed: ->
    return @status is 'unconfirmed'

  hasPassword: (password) ->
    return @password is tools.hash password

  @create: Promise.coroutine ({
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

  @findByEmail: Promise.coroutine (email) ->
    userId = yield client.get "emails:#{email}:uid"
    return null unless userId
    return db.users.findById userId

  @findByHash: Promise.coroutine (hash) ->
    userId = yield client.get "hashes:#{hash}:uid"
    return null unless userId
    return db.users.findById userId

  @findById: Promise.coroutine (userId) ->
    userConfig = yield client.hgetall "users:#{userId}"
    user = new User userConfig
    return user

  @findByRestore: Promise.coroutine (hash) ->
    userId = yield client.get "restores:#{hash}:uid"
    return null unless userId
    return db.users.findById userId

module.exports = User
